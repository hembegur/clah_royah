local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local BaseTroop = {}
BaseTroop.__index = BaseTroop

function BaseTroop.new(id, clientModel: Model)
	local self = setmetatable({}, BaseTroop)

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
	self.moveTarget = nil
	self.moveElapsed = 0

	self.clientModel = clientModel:Clone() :: Model

	return self
end

-------------------MOVEMENT LOGIC
function BaseTroop:SetPosition(position: Vector3)
	self.position = position
end

function BaseTroop:LookAt(targetPosition: Vector3)
	if not self.position then
		return
	end

	local dir = targetPosition - self.position
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude == 0 then
		return
	end
	self.direction = dir.Unit
end

function BaseTroop:MoveTo(position: Vector3)
	self:LookAt(position)
	self.moveTarget = Vector3.new(position.X, 0, position.Z)
end

-------------------ATTACK LOGIC
function BaseTroop:TakeDamage(amount: number)
	if not self.isAlive then
		return
	end

	self.hp -= amount

	if self.hp <= 0 then
		self:Die()
	end
end

function BaseTroop:Attack(target)
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

function BaseTroop:SetTarget(target)
	self.target = target
end

-------------------UPDATE
function BaseTroop:Update(dt: number)
	if not self.isAlive then
		return
	end

	-- Movement
	if self.moveTarget then
		local dir = self.moveTarget - self.position
		dir = Vector3.new(dir.X, 0, dir.Z)

		local dist = dir.Magnitude

		if dist > 0 then
			dir = dir.Unit
			local moveStep = self.walkSpeed * dt

			if moveStep >= dist then
				self.position = self.moveTarget
				self.moveTarget = nil
			else
				self.position += dir * moveStep
			end
		end

		self.moveElapsed += dt

		if self.moveElapsed > 0.05 then
			packets.updateNpcPos:Fire(self.id, Vector3.new(self.position.X, 3, self.position.Z))
			--print(Vector3.new(self.position.X, 0, self.position.Z))
			self.moveElapsed -= 0.05
		end
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

function BaseTroop:Die()
	self.isAlive = false
end

return BaseTroop
