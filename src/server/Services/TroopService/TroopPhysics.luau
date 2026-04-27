local Grid = require(script.Parent.Grid)

local troopPhysics = {}

function troopPhysics:circleVsCircle(p1, r1, p2, r2)
	local p1n = Vector3.new(p1.x, 0, p1.z)
	local p2n = Vector3.new(p2.x, 0, p2.z)
	return (p1n - p2n).Magnitude <= (r1 + r2)
end

function troopPhysics:circleVsBox(circlePos, radius, boxPos, boxSize)
	local circlePosN = Vector3.new(circlePos.x, 0, circlePos.z)
	local boxPosN = Vector3.new(boxPos.x, 0, boxPos.z)
	local half = boxSize / 2

	local closestX = math.clamp(circlePosN.X, boxPosN.X - half.X, boxPosN.X + half.X)
	local closestZ = math.clamp(circlePosN.Z, boxPosN.Z - half.Y, boxPosN.Z + half.Y)

	local closestPoint = Vector3.new(closestX, circlePosN.Y, closestZ)

	return (circlePosN - closestPoint).Magnitude <= radius
end

function troopPhysics:resolveUnitCollision(t1, t2)
	local diff = t1.position - t2.position
	diff = Vector3.new(diff.X, 0, diff.Z)

	local dist = diff.Magnitude
	if dist == 0 then
		diff = Vector3.new(math.random(), 0, math.random()).Unit
		dist = 0.001
	end

	local overlap = (t1.hitbox.radius + t2.hitbox.radius) - dist
	if overlap <= 0 then
		return
	end

	local dir = diff.Unit

	local totalMass = t1.mass + t2.mass
	local t1Move = (t2.mass / totalMass)
	local t2Move = (t1.mass / totalMass)

	-- accumulate correction (use your correction system)
	t1.correction = (t1.correction or Vector3.zero) + dir * overlap * t1Move
	t2.correction = (t2.correction or Vector3.zero) - dir * overlap * t2Move

	-- velocity response (also mass-based)
	local force = overlap * 5
	t1.velocity += dir * force * t1Move
	t2.velocity -= dir * force * t2Move
end

function troopPhysics:resolveCircleBox(troop, building)
	local pos = troop.position
	local boxPos = building.position
	local size = building.hitbox.size -- Vector2 (X, Z)

	local half = size / 2

	-- closest point on box
	local closestX = math.clamp(pos.X, boxPos.X - half.X, boxPos.X + half.X)
	local closestZ = math.clamp(pos.Z, boxPos.Z - half.Y, boxPos.Z + half.Y)

	local closest = Vector3.new(closestX, pos.Y, closestZ)

	local diff = pos - closest
	diff = Vector3.new(diff.X, 0, diff.Z)

	local dist = diff.Magnitude

	if dist == 0 then
		diff = Vector3.new(math.random(), 0, math.random()).Unit
		dist = 0.001
	end

	local overlap = troop.hitbox.radius - dist
	if overlap <= 0 then
		return
	end

	local dir = diff.Unit

	troop.velocity += dir * overlap * 5
end

function troopPhysics:Update(troops, buildings, grid: typeof(Grid.new()))
	for _, troop in pairs(troops) do
		local pos = troop.position

		for _, building in pairs(buildings) do
			if troopPhysics:circleVsBox(pos, troop.hitbox.radius, building.root.Position, building.hitbox.size) then
				troopPhysics:resolveUnitCollision(troop, building)
			end
		end
	end

	for _, t1 in pairs(troops) do
		local nearby = grid:GetNearby(t1.position)
		--print(nearby)

		for _, t2 in pairs(nearby) do
			if troopPhysics:circleVsCircle(t1.position, t1.hitbox.radius, t2.position, t2.hitbox.radius) then
				troopPhysics:resolveUnitCollision(t1, t2)
			end
		end
	end
end

return troopPhysics
