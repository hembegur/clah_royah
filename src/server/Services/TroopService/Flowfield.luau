local FlowField = {}

FlowField.__index = FlowField
function FlowField.new(cellsize)
	local self = setmetatable({}, FlowField)

	self.cost = {} -- distance from target
	self.dir = {} -- direction vector per cell
	self.blocked = {} -- walls/buildings

	self.minX = -16
	self.maxX = 16
	self.minZ = -10
	self.maxZ = 10
	self.cellsize = cellsize

	return self
end

local function key(x, z)
	return x .. "," .. z
end

function FlowField:SetBlockedFromBuilding(building, grid)
	local keys = grid:_getKeysForObject(building)
	--print(keys)

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

function FlowField:BuildFromTargets(targetKeys)
	self.cost = {}
	local queue = {}

	for _, k in ipairs(targetKeys) do
		self.cost[k] = 0
		table.insert(queue, k)
	end

	while #queue > 0 do
		local k = table.remove(queue, 1)

		local x, z = k:match("([^,]+),([^,]+)")
		x, z = tonumber(x), tonumber(z)

		for _, offset in ipairs({
			{ 1, 0 },
			{ -1, 0 },
			{ 0, 1 },
			{ 0, -1 },
			{ 1, 1 },
			{ -1, -1 },
			{ -1, 1 },
			{ 1, -1 },
		}) do
			local nx = x + offset[1]
			local nz = z + offset[2]

			if nx < self.minX or nx > self.maxX then
				continue
			end
			if nz < self.minZ or nz > self.maxZ then
				continue
			end

			local nk = nx .. "," .. nz

			if self.blocked[nk] then
				continue
			end
			if self.cost[nk] then
				continue
			end

			local isDiagonal = offset[1] ~= 0 and offset[2] ~= 0

			-- prevent corner cutting
			if isDiagonal then
				local k1 = (x + offset[1]) .. "," .. z
				local k2 = x .. "," .. (z + offset[2])

				if self.blocked[k1] or self.blocked[k2] then
					continue
				end
			end

			local stepCost = isDiagonal and 1.414 or 1

			self.cost[nk] = self.cost[k] + stepCost
			table.insert(queue, nk)
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

			-- diagonals
			{ cx + 1, cz + 1, Vector3.new(1, 0, 1) },
			{ cx - 1, cz - 1, Vector3.new(-1, 0, -1) },
			{ cx - 1, cz + 1, Vector3.new(-1, 0, 1) },
			{ cx + 1, cz - 1, Vector3.new(1, 0, -1) },
		}) do
			local nx, nz = n[1], n[2]
			local nk = key(nx, nz)
			local nCost = self.cost[nk]

			if not nCost then
				continue
			end

			local isDiagonal = (nx ~= cx and nz ~= cz)

			-- prevent corner cutting
			if isDiagonal then
				local k1 = key(nx, cz)
				local k2 = key(cx, nz)

				if self.blocked[k1] or self.blocked[k2] then
					continue
				end
			end

			if nCost < bestCost then
				bestCost = nCost
				bestDir = n[3]
			end
		end

		-- normalize so diagonals aren't faster
		if bestDir.Magnitude > 0 then
			bestDir = bestDir.Unit
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
