local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
local applyKnockback = require(ReplicatedStorage.Shared.Modules.Game.Applyknockback)
packets.spawnTestNPC.OnServerEvent:Connect(function(player: Player, pos: Vector3)
	print("spawn")
	local clone = workspace.Rig:Clone() :: Model
	clone.Parent = workspace
	clone:PivotTo(CFrame.new(pos))
	ragdollService:SetUp(clone)
	ragdollService:RagdollCharacter(clone)

	while clone ~= nil do
		task.wait(2)
		applyKnockback(clone.HumanoidRootPart.RootAttachment, Vector3.new(0, 1000, 0), Vector3.new(0, 10000, 0), 0.1)
	end
end)

-- Players.PlayerAdded:Connect(function(player: Player)
-- 	local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
-- 	player.CharacterAdded:Connect(function(char: Model)
-- 		ragdollService:SetUp(char)

-- 		while true do
-- 			task.wait(5)
-- 			ragdollService:RagdollCharacter(char, 1)
-- 			print("while loop")
-- 		end
-- 	end)
-- end)
