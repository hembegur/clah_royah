local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local keybindModule = require(ReplicatedStorage.Shared.Modules.Game.Keybind)
local janitor = require(ReplicatedStorage.Packages.Janitor).new()
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local player = Players.LocalPlayer
local shit = {}

local function characterAdded(char)
	janitor:Cleanup()
	local ability1 = keybindModule.GetAction("InGame", "Ability1")
	ability1.KeyboardBinding.KeyCode = Enum.KeyCode.E
	janitor:Add(
		ability1.Pressed:Connect(function()
			for _ = 1, 10 do
				packets.spawnTestNPC:Fire(char.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
			end
		end),
		"Disconnect"
	)

	keybindModule.EnableContext("InGame")
end

player.CharacterAdded:Connect(characterAdded)

return shit
