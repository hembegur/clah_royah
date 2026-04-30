local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local Flowfield = require(ServerScriptService.Server.Services.TroopService.Flowfield)

local BaseTroop = {}
BaseTroop.__index = BaseTroop

function BaseTroop.new(id)
	local self = setmetatable({}, BaseTroop)
	self.type = "Troop"

	-- stats
	self.id = id
	self.maxHp = 100
	self.hp = self.maxHp
	self.walkSpeed = 10

	self.damage = 10
	self.attackCooldown = 1
	self.attackRange = 5
	self.aggroRange = 26

	-- state
	self.position = Vector3.new(0, 0, 0)
	self.direction = Vector3.new(0, 0, 1)
	self.target = nil
	self.locked = false
	self.isAlive = true
	self.lastAttackTime = 0
	self.moveTarget = nil
	self.moveElapsed = 0

	self.mass = 1
	self.velocity = Vector3.zero
	self.hitbox = {
		type = "circle",
		radius = 1.5,
	}
	self.moveDir = Vector3.zero
	self.dt = 0.016

	self.renderHeight = 6.5
	self.dataSendRate = 0.05
	self.lastPos = self.position

	return self
end
-------------------SETTERS
function BaseTroop:SetHitBox(newHitbox)
	self.hitbox = newHitbox
end
-------------------MOVEMENT LOGIC
function BaseTroop:SetPosition(position: Vector3)
	self.position = position
	packets.teleportNpc:Fire(self.id, Vector3.new(self.position.X, self.renderHeight, self.position.Z))
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
	packets.updateNpcDir:Fire(self.id, self.direction)
end

function BaseTroop:MoveTo(position: Vector3)
	self:LookAt(position)
	self.moveTarget = Vector3.new(position.X, self.renderHeight, position.Z)
end

-------------------ATTACK LOGIC
function BaseTroop:TakeDamage(amount: number)
	if not self.isAlive then
		return
	end

	packets.updateNpcHp:Fire(self.id, self.hp / self.maxHp * 1000)
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

function BaseTroop:FindTarget(ingameTroop)
	if self.locked then
		return
	end

	local targetGroup
	if self.team == "Red" then
		targetGroup = ingameTroop["Blue"]
	else
		targetGroup = ingameTroop["Red"]
	end

	local closestDistSq = self.aggroRange * self.aggroRange
	local target = nil

	local px, pz = self.position.X, self.position.Z

	for _, enemy in ipairs(targetGroup) do
		if not enemy.isAlive then
			continue
		end

		local dx = enemy.position.X - px
		local dz = enemy.position.Z - pz

		-- cheap AABB check first
		if math.abs(dx) > self.aggroRange or math.abs(dz) > self.aggroRange then
			continue
		end

		local distSq = dx * dx + dz * dz

		if distSq < closestDistSq then
			closestDistSq = distSq
			target = enemy
		end
	end

	return target
end

-------------------UPDATE
function BaseTroop:Update(dt: number, flowfield: typeof(Flowfield.new()), ingameTroop)
	if not self.isAlive then
		return
	end
	self.dt = dt
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
		self.moveDir = dir
	else
		local cx = math.floor(self.position.X / flowfield.cellsize)
		local cz = math.floor(self.position.Z / flowfield.cellsize)

		local k = cx .. "," .. cz
		local dir = flowfield.dir[k]
		--print(k, dir)

		if dir then
			self.moveDir = dir
			local moveStep = self.walkSpeed * dt
			self.position += dir * moveStep
		end
	end

	self.position += self.velocity * dt
	self.velocity *= 0.9

	--Update position
	self.moveElapsed += dt
	if self.moveElapsed > self.dataSendRate and (self.lastPos - self.position).Magnitude > 0.1 then
		packets.updateNpcPos:Fire(self.id, Vector3.new(self.position.X, self.renderHeight, self.position.Z))
		self.lastPos = self.position
		self.moveElapsed -= 0.05
	end

	-- Combat
	local newTarget = self:FindTarget(ingameTroop)
	if newTarget ~= nil then
		self.target = newTarget
		self.moveTarget = newTarget.position
	end

	if not self.target or not self.target.isAlive then
		self.target = nil
		self.moveTarget = nil
		self.locked = false
		return
	end

	local dist = (self.position - self.target.position).Magnitude

	if dist <= self.attackRange then
		--print(self.team .. " attack")
		---self.velocity *= 0.5 -- slow down / stop
		self.locked = true
		self:Attack(self.target)
		self.moveTarget = self.position
	else
		self.locked = false
	end
end

function BaseTroop:Die()
	self.isAlive = false
	packets.killNpc:Fire(self.id)
end

return BaseTroop
