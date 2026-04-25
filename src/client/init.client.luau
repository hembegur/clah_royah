local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

require(ReplicatedStorage.Packages.Chrono).Start()

require(script.test)

packets.removeFromClient.OnClientEvent:Connect(function(object)
	if typeof(object) ~= "Instance" then
		return
	end
	pcall(function()
		object:Destroy()
	end)
end)

require(ReplicatedStorage.Shared.Classes.Troops.SwordMan)
