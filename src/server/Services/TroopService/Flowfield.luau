local FlowField = {}

FlowField.__index = FlowField
function FlowField.new()
	local self = setmetatable({}, FlowField)

	self.cost = {} -- distance from target
	self.dir = {} -- direction vector per cell
	self.blocked = {} -- walls/buildings

	return self
end

local function key(x, z)
	return x .. "," .. z
end

function FlowField:SetBlockedFromBuilding(building, grid)
	local keys = grid:_getKeysForObject(building)

	for _, k in ipairs(keys) do
		self.blocked[k] = true
	end
end

function FlowField:Build(targetCell)
	self.cost = {}
	local queue = { targetCell }

	self.cost[targetCell] = 0

	while #queue > 0 do
		local current = table.remove(queue, 1)
		local cx, cz = current.X, current.Z

		for _, n in ipairs({
			Vector2.new(cx + 1, cz),
			Vector2.new(cx - 1, cz),
			Vector2.new(cx, cz + 1),
			Vector2.new(cx, cz - 1),
		}) do
			local k = key(n.X, n.Y)

			if not self.blocked[k] and not self.cost[k] then
				self.cost[k] = self.cost[key(cx, cz)] + 1
				table.insert(queue, n)
			end
		end
	end
end

function FlowField:BuildDirection()
	self.dir = {}

	for k, cost in pairs(self.cost) do
		local cx, cz = k:match("([^,]+),([^,]+)")
		cx, cz = tonumber(cx), tonumber(cz)

		local bestCost = cost
		local bestDir = Vector3.zero

		for _, n in ipairs({
			{ cx + 1, cz, Vector3.new(1, 0, 0) },
			{ cx - 1, cz, Vector3.new(-1, 0, 0) },
			{ cx, cz + 1, Vector3.new(0, 0, 1) },
			{ cx, cz - 1, Vector3.new(0, 0, -1) },
		}) do
			local nk = key(n[1], n[2])
			local nCost = self.cost[nk]

			if nCost and nCost < bestCost then
				bestCost = nCost
				bestDir = n[3]
			end
		end

		self.dir[k] = bestDir
	end
end

function FlowField:UpdateFromBlocked(changedKeys)
	local queue = {}

	-- invalidate affected cells
	for _, k in ipairs(changedKeys) do
		self.cost[k] = nil
		table.insert(queue, k)
	end

	-- propagate updates outward
	while #queue > 0 do
		local k = table.remove(queue, 1)

		local cx, cz = k:match("([^,]+),([^,]+)")
		cx, cz = tonumber(cx), tonumber(cz)

		local best = math.huge

		for _, n in ipairs({
			key(cx + 1, cz),
			key(cx - 1, cz),
			key(cx, cz + 1),
			key(cx, cz - 1),
		}) do
			if self.cost[n] then
				best = math.min(best, self.cost[n] + 1)
			end
		end

		if best < math.huge then
			if self.cost[k] ~= best then
				self.cost[k] = best

				-- propagate further
				table.insert(queue, key(cx + 1, cz))
				table.insert(queue, key(cx - 1, cz))
				table.insert(queue, key(cx, cz + 1))
				table.insert(queue, key(cx, cz - 1))
			end
		end
	end

	self:BuildDirection()
end

return FlowField
