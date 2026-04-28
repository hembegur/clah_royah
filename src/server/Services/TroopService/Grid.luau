local Grid = {}
Grid.__index = Grid

local function getKey(x, z)
	return x .. "," .. z
end

function Grid.new(cellSize)
	return setmetatable({
		cellSize = cellSize,
		cells = {}, -- [key] = {objects}
	}, Grid)
end

-- Convert world → cell
function Grid:WorldToCell(pos)
	return math.floor(pos.X / self.cellSize), math.floor(pos.Z / self.cellSize)
end

-- Get all cells an object occupies
function Grid:_getKeysForObject(obj)
	local pos = obj.position

	local minX, maxX, minZ, maxZ

	if obj.hitbox.type == "circle" then
		local r = obj.hitbox.radius
		minX, maxX = pos.X - r, pos.X + r
		minZ, maxZ = pos.Z - r, pos.Z + r
	elseif obj.hitbox.type == "box" then
		local half = obj.hitbox.size / 2
		minX, maxX = pos.X - half.X, pos.X + half.X
		minZ, maxZ = pos.Z - half.Y, pos.Z + half.Y
	else
		error("Unknown hitbox type")
	end

	local epsilon = 1e-4

	local minCX = math.floor((minX + epsilon) / self.cellSize)
	local maxCX = math.floor((maxX - epsilon) / self.cellSize)
	local minCZ = math.floor((minZ + epsilon) / self.cellSize)
	local maxCZ = math.floor((maxZ - epsilon) / self.cellSize)

	local keys = {}

	for x = minCX, maxCX do
		for z = minCZ, maxCZ do
			table.insert(keys, getKey(x, z))
		end
	end

	return keys
end

-- Add object to grid
function Grid:Add(obj)
	local keys = self:_getKeysForObject(obj)

	obj._cells = keys

	for _, key in ipairs(keys) do
		local cell = self.cells[key]
		if not cell then
			cell = {}
			self.cells[key] = cell
		end
		table.insert(cell, obj)
	end
end

-- Remove object from grid
function Grid:Remove(obj)
	if not obj._cells then
		return
	end

	for _, key in ipairs(obj._cells) do
		local cell = self.cells[key]
		if cell then
			for i = #cell, 1, -1 do
				if cell[i] == obj then
					table.remove(cell, i)
				end
			end
		end
	end

	obj._cells = nil
end

-- Update object position in grid
function Grid:Update(obj)
	local newKeys = self:_getKeysForObject(obj)

	-- quick check if same
	local oldKeys = obj._cells
	local same = true

	if not oldKeys or #oldKeys ~= #newKeys then
		same = false
	else
		for i = 1, #newKeys do
			if oldKeys[i] ~= newKeys[i] then
				same = false
				break
			end
		end
	end

	if same then
		return
	end

	self:Remove(obj)
	self:Add(obj)
end

-- Get nearby objects (with dedupe)
function Grid:GetNearby(pos)
	local cx, cz = self:WorldToCell(pos)

	local results = {}
	local seen = {}

	for x = -1, 1 do
		for z = -1, 1 do
			local key = getKey(cx + x, cz + z)
			local cell = self.cells[key]

			if cell then
				for _, obj in ipairs(cell) do
					if not seen[obj] then
						seen[obj] = true
						table.insert(results, obj)
					end
				end
			end
		end
	end

	return results
end

return Grid
