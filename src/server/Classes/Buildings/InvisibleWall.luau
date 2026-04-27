local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseBuilding = require(script.Parent.BaseBuilding)
local assets = ReplicatedStorage.Assets

local InvisibleWall = setmetatable({}, BaseBuilding)
InvisibleWall.__index = InvisibleWall

function InvisibleWall.new(id, position, size)
	local self = setmetatable(BaseBuilding.new(id), InvisibleWall)
	self.maxHp = 10000000
	self.hp = 10000000
	self.position = position
	self.hitbox = {
		type = "box",
		size = size,
	}
	return self
end

return InvisibleWall
