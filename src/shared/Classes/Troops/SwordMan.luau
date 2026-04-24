local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseTroop = require(script.Parent.BaseTroop)
local assets = ReplicatedStorage.Assets

local SwordMan = setmetatable({}, BaseTroop)
SwordMan.__index = SwordMan

function SwordMan.new(team)
	local self = setmetatable(BaseTroop.new(assets.Troops.DefaultRig, assets.Troops.ServerSide.Normal), SwordMan)

	self.team = team
	self.maxHp = 100
	self.hp = 100
	self.damage = 8
	self.attackCooldown = 0.5

	return self
end

return SwordMan
