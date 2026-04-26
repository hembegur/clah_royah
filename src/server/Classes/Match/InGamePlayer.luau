local InGamePlayer = {}
InGamePlayer.__index = InGamePlayer

function InGamePlayer.new(player: Player)
	local self = setmetatable({}, InGamePlayer)

	self.player = player
	self.kingTower = nil
	self.tix = 0
	self.maxTix = 10
	self.troops = {}
end

return InGamePlayer
