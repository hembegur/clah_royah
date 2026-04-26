local InGamePlayer = {}
InGamePlayer.__index = InGamePlayer

function InGamePlayer.new()
	local self = setmetatable({}, InGamePlayer)

	self.kingTower = nil
end

return InGamePlayer
