local NPC = {}
NPC.__index = NPC

function NPC.new(id, model, healthGui)
	local self = setmetatable({}, NPC)

	self.id = id
	self.model = model
	self.healthGui = healthGui

	self.targetPos = nil
	self.targetDir = nil

	return self
end

function NPC:SetTargetPos(pos)
	self.targetPos = pos
end

function NPC:SetTargetDir(dir)
	self.targetDir = dir
end

function NPC:Teleport(pos)
	self.model:PivotTo(CFrame.new(pos))
	self.targetPos = pos
end

function NPC:Update(dt)
	if not self.model or not self.targetPos then
		return
	end

	local currentCF = self.model:GetPivot()
	local currentPos = currentCF.Position

	-- position lerp
	local newPos = currentPos:Lerp(self.targetPos, 0.05)

	local newCF
	if self.targetDir then
		local currentLook = currentCF.LookVector
		local newLook = currentLook:Lerp(self.targetDir, 0.1)

		if newLook.Magnitude > 0 then
			newCF = CFrame.lookAt(newPos, newPos + newLook)
		else
			newCF = CFrame.new(newPos)
		end
	else
		newCF = CFrame.new(newPos)
	end

	self.model:PivotTo(newCF)
end

function NPC:UpdateHp(hp)
	self.healthGui.Health.Meter:TweenSize(UDim2.fromScale(hp / 1000, 1), "In", "Linear", 0.1)
end

function NPC:Destroy()
	if self.model then
		self.model:Destroy()
	end
end

return NPC
