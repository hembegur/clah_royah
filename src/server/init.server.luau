local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local services = script.Services

require(services.TroopService.TroopService)
require(ReplicatedStorage.Packages.Chrono).Start()

packets.testMatch.OnServerEvent:Connect(function(player: Player)
	local match = require(ServerScriptService.Server.Classes.Match.Match)
	local newMatch = match.new(ReplicatedStorage.Assets.Maps.TestMap, Vector3.new(0, 6, 0))
	newMatch:AddPlayer(player, "Blue")
	newMatch:Start()
	task.wait(120)
	newMatch:Stop()
end)

-- local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
-- local applyKnockback = require(ReplicatedStorage.Shared.Modules.Game.Applyknockback)
-- packets.spawnTestNPC.OnServerEvent:Connect(function(player: Player, pos: Vector3)
-- 	print("spawn")
-- 	local clone = workspace.Rig:Clone() :: Model
-- 	clone.Parent = workspace
-- 	clone:PivotTo(CFrame.new(pos))
-- 	ragdollService:SetUp(clone)
-- 	ragdollService:RagdollCharacter(clone)

-- 	while clone ~= nil do
-- 		task.wait(2)
-- 		applyKnockback(clone["Left Arm"].LeftGripAttachment, Vector3.new(0, 1000, 0), Vector3.new(0, 10000, 0), 0.1)
-- 	end
-- end)
