local RunService = game:GetService("RunService")
local BaseClientTroop = {}
BaseClientTroop.__index = BaseClientTroop

function BaseClientTroop.new(config)
	local self = setmetatable({}, BaseClientTroop)

	self.Npcs = {}
	self.Name = config.Name
	self.Model = config.Model
	self.HealthGui = config.HealthGui
	self.NpcClass = config.NpcClass
	self.packets = config.Packets
	self.ragdollService = config.RagdollService

	self:_initPackets()
	self:_initLoop()

	return self
end

function BaseClientTroop:_spawn(data)
	local model = self.Model:Clone()
	model.Parent = workspace
	model.HumanoidRootPart.Anchored = true

	local gui = self.HealthGui:Clone()
	gui.Parent = model.Head

	self.ragdollService:SetUp(model)
	self.ragdollService:RagdollCharacter(model)

	local npc = self.NpcClass.new(data.id, model, gui)
	self.Npcs[data.id] = npc
end

function BaseClientTroop:_initPackets()
	local packets = self.packets

	packets.spawnNpc.OnClientEvent:Connect(function(data)
		if data.Name ~= self.Name then
			return
		end
		self:_spawn(data)
	end)

	packets.updateNpcPos.OnClientEvent:Connect(function(id, pos)
		local npc = self.Npcs[id]
		if npc then
			npc:SetTargetPos(pos)
		end
	end)

	packets.updateNpcDir.OnClientEvent:Connect(function(id, dir)
		local npc = self.Npcs[id]
		if npc then
			npc:SetTargetDir(dir)
		end
	end)

	packets.teleportNpc.OnClientEvent:Connect(function(id, pos)
		local npc = self.Npcs[id]
		if npc then
			npc:Teleport(pos)
		end
	end)

	packets.killNpc.OnClientEvent:Connect(function(id)
		local npc = self.Npcs[id]
		if npc then
			npc:Destroy()
			self.Npcs[id] = nil
		end
	end)

	packets.updateNpcHp.OnClientEvent:Connect(function(id, hp)
		local npc = self.Npcs[id]
		if npc then
			npc:UpdateHp(hp)
		end
	end)
end

function BaseClientTroop:_initLoop()
	RunService.Heartbeat:Connect(function(dt)
		for _, npc in pairs(self.Npcs) do
			npc:Update(dt)
		end
	end)
end

return BaseClientTroop
