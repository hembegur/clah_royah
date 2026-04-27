local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local BaseBuilding = {}
BaseBuilding.__index = BaseBuilding

function BaseBuilding.new(id)
	local self = setmetatable({}, BaseBuilding)
	self.type = "Building"

	-- stats
	self.id = id
	self.maxHp = 100
	self.hp = self.maxHp
	self.damage = 10
	self.attackCooldown = 1
	self.range = 5
	self.walkSpeed = 10

	-- state
	self.position = Vector3.new(0, 0, 0)
	self.direction = Vector3.new(0, 0, 1)
	self.target = nil
	self.isAlive = true
	self.lastAttackTime = 0

	self.mass = 1
	self.velocity = Vector3.zero
	self.hitbox = {
		type = "box",
		size = Vector2.new(10, 10), -- XZ size
	}

	self.renderHeight = 6.5
	self.dataSendRate = 0.05

	return self
end
-------------------SETTERS
function BaseBuilding:SetHitBox(newHitbox)
	self.hitbox = newHitbox
end
-------------------MOVEMENT LOGIC
function BaseBuilding:SetPosition(position: Vector3)
	self.position = position
	packets.teleportNpc:Fire(self.id, Vector3.new(self.position.X, self.renderHeight, self.position.Z))
end

function BaseBuilding:LookAt(targetPosition: Vector3)
	if not self.position then
		return
	end

	local dir = targetPosition - self.position
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude == 0 then
		return
	end
	self.direction = dir.Unit
	packets.updateNpcDir:Fire(self.id, self.direction)
end

function BaseBuilding:MoveTo(position: Vector3)
	self:LookAt(position)
	self.moveTarget = Vector3.new(position.X, self.renderHeight, position.Z)
end

-------------------ATTACK LOGIC
function BaseBuilding:TakeDamage(amount: number)
	if not self.isAlive then
		return
	end

	self.hp -= amount

	if self.hp <= 0 then
		self:Die()
	end
end

function BaseBuilding:Attack(target)
	if not target or not target.isAlive then
		return
	end

	local now = os.clock()
	if now - self.lastAttackTime < self.attackCooldown then
		return
	end

	self.lastAttackTime = now
	target:TakeDamage(self.damage)
end

function BaseBuilding:SetTarget(target)
	self.target = target
end

-------------------UPDATE
function BaseBuilding:Update(dt: number)
	if not self.isAlive then
		return
	end

	-- Combat
	if not self.target or not self.target.isAlive then
		return
	end

	local dist = (self.position - self.target.position).Magnitude

	if dist <= self.range then
		self:Attack(self.target)
	else
		self:MoveTo(self.target.position)
	end
end

function BaseBuilding:Die()
	self.isAlive = false
	packets.killNpc:Fire(self.id)
end

return BaseBuilding
