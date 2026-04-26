local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local npcRegistry = require(ReplicatedStorage.Shared.Modules.Core.NpcRegistry)

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

	for _ = 1, 20 do
		newTroop:MoveTo(Vector3.new(random:NextInteger(-100, 100), 5, random:NextInteger(-100, 100)))
		task.wait(5)
	end
end

function troopService:Update(dt, troopList)
	for i, troop in ipairs(troopList) do
		troop:Update(dt)

		if not troop.isAlive then
			table.remove(troopList, i)
		end
	end
end

return troopService -- SERVER
