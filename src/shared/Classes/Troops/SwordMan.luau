local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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

SwordMan.TargetPos = SwordMan.TargetPos or {}

packets.updateNpcPos.OnClientEvent:Connect(function(id: number, position: Vector3)
	if not SwordMan.Npcs[id] then
		return
	end
	SwordMan.TargetPos[id] = position
end)

RunService.Heartbeat:Connect(function(dt)
	for id, model in pairs(SwordMan.Npcs) do
		local target = SwordMan.TargetPos[id]
		if not target then
			continue
		end

		local current = model:GetPivot().Position
		local newPos = current:Lerp(target, 0.05)

		model:PivotTo(CFrame.new(newPos))
	end
end)

return SwordMan
