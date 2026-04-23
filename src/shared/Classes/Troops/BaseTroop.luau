local BaseTroop = {}
BaseTroop.__index = BaseTroop

function BaseTroop.new(model: Model)
	local self = setmetatable({}, BaseTroop)

	self.model = model
	self.humanoid = model:FindFirstChildOfClass("Humanoid")
	self.root = model:FindFirstChild("HumanoidRootPart")

	-- stats (default)
	self.maxHp = 100
	self.hp = self.maxHp
	self.damage = 10
	self.attackCooldown = 1
	self.range = 5

	self.target = nil
	self.isAlive = true
	self.lastAttackTime = 0

	return self
end

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

function BaseTroop:MoveTo(position: Vector3)
	if self.humanoid then
		self.humanoid:MoveTo(position)
	end
end

function BaseTroop:SetTarget(target)
	self.target = target
end

function BaseTroop:Update(dt)
	if not self.isAlive then
		return
	end
	if not self.target or not self.target.isAlive then
		return
	end

	local dist = (self.root.Position - self.target.root.Position).Magnitude

	if dist <= self.range then
		self:Attack(self.target)
	else
		self:MoveTo(self.target.root.Position)
	end
end

function BaseTroop:Die()
	self.isAlive = false

	if self.model then
		self.model:Destroy()
	end
end

return BaseTroop
