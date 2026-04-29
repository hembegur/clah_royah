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
	local inQueue = {}

	-- mark blocked + invalidate
	for _, k in ipairs(changedKeys) do
		self.blocked[k] = true
		self.cost[k] = nil

		table.insert(queue, k)
		inQueue[k] = true
	end

	local head = 1

	local offsets = {
		{ 1, 0 },
		{ -1, 0 },
		{ 0, 1 },
		{ 0, -1 },
		{ 1, 1 },
		{ -1, -1 },
		{ -1, 1 },
		{ 1, -1 },
	}

	while head <= #queue do
		local k = queue[head]
		head += 1
		inQueue[k] = nil

		local cx, cz = k:match("([^,]+),([^,]+)")
		cx, cz = tonumber(cx), tonumber(cz)

		-- skip blocked
		if self.blocked[k] then
			continue
		end

		local best = math.huge

		for _, o in ipairs(offsets) do
			local nx = cx + o[1]
			local nz = cz + o[2]

			if nx < self.minX or nx > self.maxX then
				continue
			end
			if nz < self.minZ or nz > self.maxZ then
				continue
			end

			local nk = nx .. "," .. nz
			local nCost = self.cost[nk]

			if not nCost then
				continue
			end

			local isDiagonal = (o[1] ~= 0 and o[2] ~= 0)

			-- prevent corner cutting
			if isDiagonal then
				local k1 = (cx + o[1]) .. "," .. cz
				local k2 = cx .. "," .. (cz + o[2])

				if self.blocked[k1] or self.blocked[k2] then
					continue
				end
			end

			local stepCost = isDiagonal and 1.414 or 1
			best = math.min(best, nCost + stepCost)
		end

		local oldCost = self.cost[k]

		if best < math.huge then
			if oldCost ~= best then
				self.cost[k] = best

				-- propagate
				for _, o in ipairs(offsets) do
					local nx = cx + o[1]
					local nz = cz + o[2]

					if nx < self.minX or nx > self.maxX then
						continue
					end
					if nz < self.minZ or nz > self.maxZ then
						continue
					end

					local nk = nx .. "," .. nz

					if not inQueue[nk] then
						table.insert(queue, nk)
						inQueue[nk] = true
					end
				end
			end
		else
			-- unreachable now
			if oldCost ~= nil then
				self.cost[k] = nil

				for _, o in ipairs(offsets) do
					local nx = cx + o[1]
					local nz = cz + o[2]

					if nx < self.minX or nx > self.maxX then
						continue
					end
					if nz < self.minZ or nz > self.maxZ then
						continue
					end

					local nk = nx .. "," .. nz

					if not inQueue[nk] then
						table.insert(queue, nk)
						inQueue[nk] = true
					end
				end
			end
		end
	end

	self:BuildDirection()
end

return FlowField
