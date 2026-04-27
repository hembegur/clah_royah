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
		return
	end

	local overlap = (t1.hitbox.radius + t2.hitbox.radius) - dist
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
	for i, troop in pairs(troops) do
		local pos = troop.position
		--print(i, pos)

		for _, building in pairs(buildings) do
			if troopPhysics:circleVsBox(pos, troop.hitbox.radius, building.root.Position, building.hitbox.size) then
				print("hit wall")
			end
		end
	end

	for i = 1, #troops do
		for j = i + 1, #troops do
			local t1 = troops[i]
			local t2 = troops[j]

			if troopPhysics:circleVsCircle(t1.position, t1.hitbox.radius, t2.position, t2.hitbox.radius) then
				troopPhysics:resolveUnitCollision(t1, t2)
			end
		end
	end
end

return troopPhysics
