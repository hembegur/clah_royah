local PointsService = game:GetService("PointsService")
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
	self.ingameTroop = {
		Red = {},
		Blue = {},
	}
	self.ingameBuilding = {
		Red = {},
		Blue = {},
	}

	self.mapPosition = position
	self.mapModel = mapModel:Clone()
	self.mapModel:PivotTo(CFrame.new(position))
	self.mapModel.Parent = workspace
	self.grid = Grid.new(8)

	self.janitor = Janitor.new()
	self.janitor:Add(self.mapModel, "Destroy")

	return self
end

-------------------------Internal

local invisWall = require(ServerScriptService.Server.Classes.Buildings.InvisibleWall)
function Match:_buildWall(pos, size)
	local newWall = invisWall.new(6767, pos, size)
	self.janitor:Add(newWall, "Die")
	table.insert(self.ingameBuilding["Blue"], newWall)
end

function Match:_setupWalls()
	local mapPos = self.mapPosition
	--Bridge
	self:_buildWall(mapPos, Vector2.new(8, 32))
	self:_buildWall(mapPos + Vector3.new(0, 0, 32), Vector2.new(8, 8))
	self:_buildWall(mapPos + Vector3.new(0, 0, -32), Vector2.new(8, 8))
	--Outside walls
	self:_buildWall(mapPos + Vector3.new(0, 0, 42), Vector2.new(128, 12))
	self:_buildWall(mapPos + Vector3.new(0, 0, -42), Vector2.new(128, 12))

	self:_buildWall(mapPos + Vector3.new(64 + 6, 0, 0), Vector2.new(12, 72))
	self:_buildWall(mapPos + Vector3.new(60 + 6, 0, -24), Vector2.new(12, 24))
	self:_buildWall(mapPos + Vector3.new(60 + 6, 0, 24), Vector2.new(12, 24))
	self:_buildWall(mapPos + Vector3.new(-64 - 6, 0, 0), Vector2.new(12, 72))
	self:_buildWall(mapPos + Vector3.new(-60 - 6, 0, -24), Vector2.new(12, 24))
	self:_buildWall(mapPos + Vector3.new(-60 - 6, 0, 24), Vector2.new(12, 24))
end

-------------------------Plubic

function Match:AddPlayer(player: Player, team)
	local newPlayer = InGamePlayer.new(player)
	if team == "Blue" then
		table.insert(self.blueTeam, newPlayer)
	else
		table.insert(self.redTeam, newPlayer)
	end
end

function Match:Start()
	---------------BUILD WALLS
	self:_setupWalls()

	---------------START ROUND
	self.state = "OnGoing"
	local janitor = self.janitor :: typeof(Janitor.new())
	janitor:Add(
		RunService.Heartbeat:Connect(function(dt: number)
			TroopService:Update(dt, self.ingameTroop, self.ingameBuilding, self.grid)
		end),
		"Disconnect"
	)
	janitor:Add(
		packets.spawnNpc.OnServerEvent:Connect(function(player: Player, data)
			for _, p in ipairs(self.redTeam) do
				if p.player == player then
					local newTroop = TroopService:SpawnNpc(data, self.ingameTroop["Red"])
					janitor:Add(newTroop, "Die")
					return newTroop
				end
			end
			for _, p in ipairs(self.blueTeam) do
				if p.player == player then
					local newTroop = TroopService:SpawnNpc(data, self.ingameTroop["Blue"])
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
