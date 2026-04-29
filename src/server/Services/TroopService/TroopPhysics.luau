local Grid = require(script.Parent.Grid)

local troopPhysics = {}

function troopPhysics:circleVsCircle(p1, r1, p2, r2)
	local p1n = Vector3.new(p1.x, 0, p1.z)
	local p2n = Vector3.new(p2.x, 0, p2.z)
	return (p1n - p2n).Magnitude <= (r1 + r2)
end

function troopPhysics:circleVsBox(circlePos, radius, boxPos, boxSize)
	local half = boxSize / 2

	local dx = math.clamp(circlePos.X, boxPos.X - half.X, boxPos.X + half.X)
	local dz = math.clamp(circlePos.Z, boxPos.Z - half.Y, boxPos.Z + half.Y)

	local diffX = circlePos.X - dx
	local diffZ = circlePos.Z - dz

	return (diffX * diffX + diffZ * diffZ) <= (radius * radius)
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

	if dist < 1e-4 then -- Inside box
		local dx = pos.X - boxPos.X
		local dz = pos.Z - boxPos.Z

		local overlapX = half.X + troop.hitbox.radius - math.abs(dx)
		local overlapZ = half.Y + troop.hitbox.radius - math.abs(dz)

		if overlapX < overlapZ then
			local dir = Vector3.new(dx > 0 and 1 or -1, 0, 0)
			troop.velocity += dir * overlapX * 5
		else
			local dir = Vector3.new(0, 0, dz > 0 and 1 or -1)
			troop.velocity += dir * overlapZ * 5
		end

		return
	end

	local overlap = troop.hitbox.radius - dist
	if overlap <= 0 then
		return
	end

	local dir = diff.Unit

	local normal = dir -- already unit

	-- your intended movement this frame
	local move = troop.moveDir * troop.walkSpeed * troop.dt
	-- check if moving into wall
	if move:Dot(normal) < -0.001 then
		-- remove inward component → slide
		move = move - normal * move:Dot(normal)
	end
	-- apply corrected movement
	troop.position += move
	-- push out
	troop.position += normal * overlap
end

function troopPhysics:Update(grid)
	local processed = {} -- prevent double unit collisions

	for _, cell in pairs(grid.cells) do
		for _, obj in ipairs(cell) do
			if obj.type ~= "Troop" then
				continue
			end

			local nearby = grid:GetNearby(obj.position)

			for _, other in ipairs(nearby) do
				if obj == other then
					continue
				end

				--TROOP vs TROOP
				if other.type == "Troop" then
					local key = obj.id < other.id and obj.id .. "-" .. other.id or other.id .. "-" .. obj.id
					if processed[key] then
						continue
					end
					processed[key] = true

					if self:circleVsCircle(obj.position, obj.hitbox.radius, other.position, other.hitbox.radius) then
						self:resolveUnitCollision(obj, other)
					end

				--TROOP vs BUILDING
				elseif other.type == "Building" then
					if self:circleVsBox(obj.position, obj.hitbox.radius, other.position, other.hitbox.size) then
						--print("collide")
						self:resolveCircleBox(obj, other)
					end
				end
			end
		end
	end
end

return troopPhysics
