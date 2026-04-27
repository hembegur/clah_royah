local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local assets = ReplicatedStorage.Assets
local npcRegistry = require(ReplicatedStorage.Shared.Modules.Core.NpcRegistry)
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)
local applyKnockback = require(ReplicatedStorage.Shared.Modules.Game.Applyknockback)
local random = Random.new()

local SwordMan = {}

SwordMan.Npcs = {}

packets.spawnNpc.OnClientEvent:Connect(function(data)
	if data.Name ~= "SwordMan" then
		return
	end

	local npcClone = ReplicatedStorage.Assets.Troops.DefaultRig:Clone()
	npcClone.Parent = workspace
	npcClone.HumanoidRootPart.Anchored = true
	SwordMan.Npcs[data.id] = {
		model = npcClone,
		targetPos = nil,
		targetDir = nil,
	}
	ragdollService:SetUp(npcClone)
	ragdollService:RagdollCharacter(npcClone)

	-- while npcClone ~= nil do
	-- 	task.wait(2)
	-- 	applyKnockback(npcClone["Left Arm"].LeftGripAttachment, Vector3.new(0, 1000, 0), Vector3.new(0, 10000, 0), 1)
	-- end
end)

packets.updateNpcPos.OnClientEvent:Connect(function(id: number, position: Vector3)
	if not SwordMan.Npcs[id] then
		return
	end
	SwordMan.Npcs[id]["targetPos"] = position
	--+ Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
end)

packets.updateNpcDir.OnClientEvent:Connect(function(id: number, dir: Vector3)
	if not SwordMan.Npcs[id] then
		return
	end
	SwordMan.Npcs[id]["targetDir"] = dir
end)

packets.teleportNpc.OnClientEvent:Connect(function(id: number, position: Vector3)
	if not SwordMan.Npcs[id] then
		return
	end
	SwordMan.Npcs[id]["model"]:PivotTo(CFrame.new(position))
	SwordMan.Npcs[id]["targetPos"] = position
end)

packets.killNpc.OnClientEvent:Connect(function(id: number)
	if SwordMan.Npcs[id] then
		SwordMan.Npcs[id]["model"]:Destroy()
		SwordMan.Npcs[id] = nil
	end
end)

RunService.Heartbeat:Connect(function(dt)
	for id, npc in pairs(SwordMan.Npcs) do
		local model = npc.model
		local targetPos = npc.targetPos
		if not model or not targetPos then
			continue
		end

		local currentCF = model:GetPivot()
		local currentPos = currentCF.Position

		-- position lerp
		local newPos = currentPos:Lerp(targetPos, 0.05)

		-- direction lerp (if exists)
		local newCF
		if npc.targetDir then
			local currentLook = currentCF.LookVector
			local newLook = currentLook:Lerp(npc.targetDir, 0.1)

			if newLook.Magnitude > 0 then
				newCF = CFrame.lookAt(newPos, newPos + newLook)
			else
				newCF = CFrame.new(newPos)
			end
		else
			newCF = CFrame.new(newPos)
		end

		model:PivotTo(newCF)
	end
end)

return SwordMan
