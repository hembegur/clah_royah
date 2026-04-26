local InGamePlayer = require(script.Parent.InGamePlayer)

local Match = {}
Match.__index = Match

function Match.new(mapModel: Model, position: Vector3)
	local self = setmetatable({}, Match)

	self.redTeam = {}
	self.blueTeam = {}
	self.state = "Preparing"
	self.redTeamTroop = {}
	self.blueTeamTroop = {}

	self.mapModel = mapModel:Clone()
	self.mapModel:PivotTo(CFrame.new(position))
	self.mapModel.Parent = workspace
end

function Match:AddPlayer(player: Player, team)
	local newPlayer = InGamePlayer.new(player)
end

return Match
