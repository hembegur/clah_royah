local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local npcRegistry = require(ReplicatedStorage.Shared.Modules.Core.NpcRegistry)

local troopService = {} -- SERVER

local troops = {}
local troopsRegistry = {
	SwordMan = require(ServerScriptService.Server.Classes.Troops.SwordMan),
}

local random = Random.new()
packets.spawnNpc.OnServerEvent:Connect(function(player: Player, data)
	print("spawn")
	local newTroop = troopsRegistry[data.Name].new(npcRegistry:GetNextId(), data.Team)
	npcRegistry:Register(newTroop)
	newTroop:SetPosition(data.Position + Vector3.new(0, 10, 0))
	table.insert(troops, newTroop)

	for _ = 1, 20 do
		newTroop:MoveTo(Vector3.new(random:NextInteger(-100, 100), 5, random:NextInteger(-100, 100)))
		task.wait(5)
	end
end)

RunService.Heartbeat:Connect(function(dt: number)
	for i, troop in ipairs(troops) do
		troop:Update(dt)

		if not troop.isAlive then
			table.remove(troops, i)
		end
	end
end)

return troopService -- SERVER
