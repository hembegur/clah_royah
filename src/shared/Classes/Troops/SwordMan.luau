local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage.Assets
local npcRegistry = require(ReplicatedStorage.Shared.Modules.Core.NpcRegistry)
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)

local SwordMan = {}

SwordMan.Npcs = {}

packets.spawnNpc.OnClientEvent:Connect(function(data)
	if data.Name ~= "SwordMan" then
		return
	end

	local npcClone = ReplicatedStorage.Assets.Troops.DefaultRig:Clone()
	npcClone.Parent = workspace
	npcClone.HumanoidRootPart.Anchored = true
	SwordMan.Npcs[data.id] = npcClone
	ragdollService:SetUp(npcClone)
	ragdollService:RagdollCharacter(npcClone)
end)

packets.updateNpcPos.OnClientEvent:Connect(function(id: number, position: Vector3)
	if not SwordMan.Npcs[id] then
		return
	end

	local model = SwordMan.Npcs[id] :: Model
	model:PivotTo(CFrame.new(position))
end)

return SwordMan
