local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InGamePlayer = require(script.Parent.InGamePlayer)
local TroopService = require(ServerScriptService.Server.Services.TroopService.TroopService)
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local Grid = require(ServerScriptService.Server.Services.TroopService.Grid)

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
	self.grid = Grid.new(12)

	self.janitor = Janitor.new()
	self.janitor:Add(self.mapModel, "Destroy")

	return self
end

function Match:AddPlayer(player: Player, team)
	local newPlayer = InGamePlayer.new(player)
	if team == "Blue" then
		table.insert(self.blueTeam, newPlayer)
	else
		table.insert(self.redTeam, newPlayer)
	end
end

function Match:Start()
	self.state = "OnGoing"
	local janitor = self.janitor :: typeof(Janitor.new())
	janitor:Add(
		RunService.Heartbeat:Connect(function(dt: number)
			TroopService:Update(dt, self.redTeamTroop, self.grid)
			TroopService:Update(dt, self.blueTeamTroop, self.grid)
		end),
		"Disconnect"
	)
	janitor:Add(
		packets.spawnNpc.OnServerEvent:Connect(function(player: Player, data)
			for _, p in ipairs(self.redTeam) do
				if p.player == player then
					local newTroop = TroopService:SpawnNpc(data, self.redTeamTroop)
					janitor:Add(newTroop, "Die")
					return newTroop
				end
			end
			for _, p in ipairs(self.blueTeam) do
				if p.player == player then
					local newTroop = TroopService:SpawnNpc(data, self.blueTeamTroop)
					janitor:Add(newTroop, "Die")
					return newTroop
				end
			end
			return
		end),
		"Disconnect"
	)
end

function Match:Stop()
	self.state = "Stopped"
	local janitor = self.janitor :: typeof(Janitor.new())
	janitor:Cleanup()
end

return Match
