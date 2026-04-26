local Match = {}
Match.__index = Match

function Match.new()
	local self = setmetatable({}, Match)

	self.redTeam = {}
	self.blueTeam = {}
	self.state = "Preparing"
	self.redTeamTroop = {}
	self.blueTeamTroop = {}
end

return Match
