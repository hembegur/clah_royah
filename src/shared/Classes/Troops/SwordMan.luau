local BaseTroop = require(script.Parent.BaseTroop)

local SwordMan = setmetatable({}, BaseTroop)
SwordMan.__index = SwordMan

function SwordMan.new(model)
	local self = setmetatable(BaseTroop.new(model), SwordMan)

	self.maxHp = 100
	self.hp = 100
	self.damage = 8
	self.attackCooldown = 0.5

	return self
end

return SwordMan
