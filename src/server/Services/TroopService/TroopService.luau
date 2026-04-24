local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local troopService = {} -- SERVER

local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
local applyKnockback = require(ReplicatedStorage.Shared.Modules.Game.Applyknockback)
packets.spawnTestNPC.OnServerEvent:Connect(function(player: Player, pos: Vector3)
	print("spawn")
	local swordmanClass = require(ReplicatedStorage.Shared.Classes.Troops.SwordMan)
	local newswordman = swordmanClass.new("Blue")
end)

return troopService -- SERVER
