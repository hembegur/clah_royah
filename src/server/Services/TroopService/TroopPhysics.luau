local troopPhysics = {}

function troopPhysics:circleVsCircle(p1, r1, p2, r2)
	return (p1 - p2).Magnitude <= (r1 + r2)
end

function troopPhysics:circleVsBox(circlePos, radius, boxPos, boxSize)
	local half = boxSize / 2

	local closestX = math.clamp(circlePos.X, boxPos.X - half.X, boxPos.X + half.X)
	local closestZ = math.clamp(circlePos.Z, boxPos.Z - half.Y, boxPos.Z + half.Y)

	local closestPoint = Vector3.new(closestX, circlePos.Y, closestZ)

	return (circlePos - closestPoint).Magnitude <= radius
end

function troopPhysics:resolveUnitCollision(t1, t2)
	local a = t1.hitbox
	local b = t2.hitbox
	local diff = t1.position - t2.position
	diff = Vector3.new(diff.X, 0, diff.Z)

	local dist = diff.Magnitude
	if dist == 0 then
		return
	end

	local overlap = (a.radius + b.radius) - dist
	if overlap <= 0 then
		return
	end

	local dir = diff.Unit

	-- push both
	t1.position += dir * (overlap * 0.5)
	t2.position -= dir * (overlap * 0.5)

	-- optional: velocity response (THIS is the smooth knockback)
	t1.velocity += dir * overlap * 5
	t2.velocity -= dir * overlap * 5
end

function troopPhysics:Update(troops, buildings)
	for _, troop in pairs(troops) do
		local pos = troop.position

		for _, building in pairs(buildings) do
			if troopPhysics:circleVsBox(pos, troop.hitbox.radius, building.root.Position, building.hitbox.size) then
				print("hit wall")
			end
		end
	end

	for _, t1 in pairs(troops) do
		for _, t2 in pairs(troops) do
			if troopPhysics:circleVsCircle(t1.position, t1.hitbox.radius, t2.position, t2.hitbox.radius) then
				troopPhysics:resolveUnitCollision(t1, t2)
			end
		end
	end
end

return troopPhysics
