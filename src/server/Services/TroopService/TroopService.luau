local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local troopService = {} -- SERVER

local troops = {}

local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
local applyKnockback = require(ReplicatedStorage.Shared.Modules.Game.Applyknockback)

local random = Random.new()
packets.spawnTestNPC.OnServerEvent:Connect(function(player: Player, position: Vector3)
	print("spawn")
	local swordmanClass = require(ServerScriptService.Server.Classes.Troops.SwordMan)
	local newswordman = swordmanClass.new("Blue")
	newswordman:SetPosition(position + Vector3.new(0, 10, 0))
	table.insert(troops, newswordman)

	for _ = 1, 20 do
		newswordman:MoveTo(Vector3.new(random:NextInteger(-100, 100), 5, random:NextInteger(-100, 100)))
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
