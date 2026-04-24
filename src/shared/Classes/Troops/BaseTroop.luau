local BaseTroop = {}
BaseTroop.__index = BaseTroop

function BaseTroop.new(clientModel: Model, serverModel: Model)
	local self = setmetatable({}, BaseTroop)

	self.clientModel = clientModel:Clone() :: Model
	self.serverModel = serverModel:Clone() :: Model
	self.serverModel.Parent = workspace
	self.serverModel:PivotTo(CFrame.new(0, 20, 0))

	self.serverHumanoid = self.serverModel:FindFirstChildOfClass("Humanoid") :: Humanoid
	self.serverHrp = self.serverModel:FindFirstChild("HumanoidRootPart") :: BasePart

	self.serverHumanoid.RequiresNeck = false
	self.serverHumanoid.PlatformStand = true

	-- stats
	self.maxHp = 100
	self.hp = self.maxHp
	self.damage = 10
	self.attackCooldown = 1
	self.range = 5
	self.walkSpeed = 10

	self.team = nil
	self.target = nil
	self.isAlive = true
	self.lastAttackTime = 0
	self.moveTarget = nil

	-- Velocity
	self.lv = Instance.new("LinearVelocity")
	self.lv.MaxForce = math.huge
	self.lv.Attachment0 = self.serverHrp:FindFirstChild("RootAttachment")
	self.lv.Parent = self.serverHrp
	self.lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	self.lv.PlaneVelocity = Vector2.new(0, 0)
	self.lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
	self.lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)

	self.ao = Instance.new("AlignOrientation")
	self.ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	self.ao.Attachment0 = self.serverHrp:FindFirstChildOfClass("Attachment")
	self.ao.RigidityEnabled = false
	self.ao.Responsiveness = 5
	self.ao.MaxTorque = 10000
	self.ao.Parent = self.serverHrp

	return self
end

-------------------MOVEMENT LOGIC
function BaseTroop:SetPosition(position: Vector3)
	self.serverModel:PivotTo(CFrame.new(position))
end

function BaseTroop:LookAt(position: Vector3)
	if not self.serverHrp or not self.ao then
		--print("no turning")
		return
	end

	local look = CFrame.lookAt(self.serverHrp.Position, position)
	self.ao.CFrame = look
end

function BaseTroop:MoveTo(position: Vector3)
	self:LookAt(position)
	self.moveTarget = position
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
function BaseTroop:Update(dt)
	if not self.isAlive then
		return
	end

	----------Movement
	if self.moveTarget then
		local dir = (self.moveTarget - self.serverHrp.Position)
		dir = Vector3.new(dir.X, 0, dir.Z)

		if dir.Magnitude > 1 then
			dir = dir.Unit * self.walkSpeed
		else
			self.moveTarget = nil
			self.lv.PlaneVelocity = Vector2.zero
		end

		local current = self.lv.PlaneVelocity

		self.lv.PlaneVelocity = current:Lerp(Vector2.new(dir.X, dir.Z), 0.1)
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
