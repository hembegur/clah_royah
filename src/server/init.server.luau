local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Players.PlayerAdded:Connect(function(player: Player)
	local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
	player.CharacterAdded:Connect(function(char: Model)
		ragdollService:SetUp(char)

		while true do
			task.wait(2)
			ragdollService:RagdollCharacter(char)
			task.wait(2)
			ragdollService:UnragdollCharacter(char)
			print("while loop")
		end
	end)
end)
