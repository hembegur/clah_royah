local Grid = {}
Grid.__index = Grid

function Grid.new(cellSize)
	return setmetatable({
		cellSize = cellSize,
		cells = {}, -- [key] = {objects}
	}, Grid)
end

local function getKey(x, z)
	return x .. "," .. z
end

function Grid:WorldToCell(pos: Vector3)
	return math.floor(pos.X / self.cellSize), math.floor(pos.Z / self.cellSize)
end

function Grid:Add(obj, pos)
	local cx, cz = self:WorldToCell(pos)
	local key = getKey(cx, cz)

	self.cells[key] = self.cells[key] or {}
	table.insert(self.cells[key], obj)

	obj._cell = key
end

function Grid:Update(obj, pos)
	local cx, cz = self:WorldToCell(pos)
	local newKey = getKey(cx, cz)

	if obj._cell == newKey then
		return
	end

	-- remove from old
	local oldCell = self.cells[obj._cell]
	if oldCell then
		for i, v in ipairs(oldCell) do
			if v == obj then
				table.remove(oldCell, i)
				break
			end
		end
	end

	-- add to new
	self.cells[newKey] = self.cells[newKey] or {}
	table.insert(self.cells[newKey], obj)
	obj._cell = newKey
end

function Grid:GetNearby(pos)
	local cx, cz = self:WorldToCell(pos)
	local results = {}

	for x = -1, 1 do
		for z = -1, 1 do
			local key = getKey(cx + x, cz + z)
			local cell = self.cells[key]
			if cell then
				for _, obj in ipairs(cell) do
					table.insert(results, obj)
				end
			end
		end
	end

	return results
end

return Grid
