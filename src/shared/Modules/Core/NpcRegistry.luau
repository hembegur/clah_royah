local NpcRegistry = {}

NpcRegistry.nextId = 0
NpcRegistry.npcs = {} -- [id] = troop

function NpcRegistry:GetNextId()
	self.nextId += 1
	return self.nextId
end

function NpcRegistry:Register(troop)
	if not troop.id then
		local id = self:GetNextId()
		troop.id = id
	end
	self.npcs[troop.id] = troop
	return troop.id
end

function NpcRegistry:Remove(id)
	self.npcs[id] = nil
end

function NpcRegistry:Get(id)
	return self.npcs[id]
end

return NpcRegistry
