local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local npcRegistry = require(ReplicatedStorage.Shared.Modules.Core.NpcRegistry)
local troopPhysics = require(script.Parent.TroopPhysics)
local Grid = require(script.Parent.Grid)

local troopService = {} -- SERVER

local troopsRegistry = {
	SwordMan = require(ServerScriptService.Server.Classes.Troops.SwordMan),
}

local random = Random.new()
-- packets.spawnNpc.OnServerEvent:Connect(function(player: Player, data)

-- end)

function troopService:SpawnNpc(data, troopList)
	print("spawn")
	local newTroop = troopsRegistry[data.Name].new(npcRegistry:GetNextId(), data.Team)
	npcRegistry:Register(newTroop)
	table.insert(troopList, newTroop)

	local newData = data -- send data back to replicate on client by adding id to the data
	data["id"] = newTroop.id
	packets.spawnNpc:Fire(newData)

	newTroop:SetPosition(data.Position + Vector3.new(0, 10, 0))

	task.spawn(function() --test move
		for _ = 1, 20 do
			newTroop:MoveTo(Vector3.new(random:NextInteger(-30, 30), 10, random:NextInteger(-30, 30)))
			task.wait(5)
		end
	end)

	return newTroop
end

function troopService:Update(dt, troopList, grid: typeof(Grid.new()))
	for _, team in pairs(troopList) do
		for i, troop in pairs(team) do
			troop:Update(dt)
			grid:Update(troop, troop.position)

			if not troop.isAlive then
				table.remove(team, i)
			end
		end
	end
	troopPhysics:Update(grid)
end

return troopService -- SERVER
