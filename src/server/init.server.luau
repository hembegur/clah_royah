local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)

packets.spawnTestNPC.OnServerEvent:Connect(function(player: Player, pos: Vector3)
	local clone = workspace.Rig:Clone() :: Model
	clone.Parent = workspace
	clone:PivotTo(CFrame.new(pos))
	ragdollService:SetUp(clone)
	ragdollService:RagdollCharacter(clone)
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
