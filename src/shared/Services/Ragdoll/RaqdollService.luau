local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local ragdollData = require(script.Parent.RaqdollData)

local RagdollService = {}

function RagdollService:BuildJoints(char: Model)
	local hrp = char:FindFirstChild("HumanoidRootPart")

	for _, v in pairs(char:GetDescendants()) do
		if
			not v:IsA("BasePart")
			or v:FindFirstAncestorOfClass("Accessory")
			or v.Name == "Handle"
			or v.Name == "Torso"
			or v.Name == "HumanoidRootPart"
		then
			continue
		end
		if not ragdollData[v.Name] then
			continue
		end

		local a0: Attachment, a1: Attachment = Instance.new("Attachment"), Instance.new("Attachment")
		local joint: Constraint = Instance.new("BallSocketConstraint")

		a0.Name = "RAGDOLL_ATTACHMENT"
		a0.Parent = v
		a0.CFrame = ragdollData[v.Name].CFrame[2]

		a1.Name = "RAGDOLL_ATTACHMENT"
		a1.Parent = hrp
		a1.CFrame = ragdollData[v.Name].CFrame[1]

		joint.Name = "RAGDOLL_CONSTRAINT"
		joint.Parent = v
		joint.Attachment0 = a0
		joint.Attachment1 = a1

		v.Massless = true
	end
end

function RagdollService:DestroyJoints(char: Model)
	if not char:FindFirstChild("HumanoidRootPart") then
		return
	end
	char.HumanoidRootPart.Massless = false

	for _, v in pairs(char:GetDescendants()) do
		if v.Name == "RAGDOLL_ATTACHMENT" or v.Name == "RAGDOLL_CONSTRAINT" then
			v:Destroy()
		end

		if
			not v:IsA("BasePart")
			or v:FindFirstAncestorOfClass("Accessory")
			or v.Name == "Torso"
			or v.Name == "Head"
		then
			continue
		end
	end
end

function RagdollService:BuildCollisionParts(char: Model)
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			local p = Instance.new("Part")
			p.Size = Vector3.one
			p.Transparency = 1
			p.CanCollide = false
			p.Massless = true
			p.Name = "Collide"
			p.CFrame = v.CFrame
			p.Parent = v

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = v
			weld.Part1 = p
			weld.Parent = p
		end
	end
end

function RagdollService:EnableCollisionParts(char: Model, enabled)
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.CanCollide = not enabled
			v.Collide.CanCollide = enabled
		end
	end
end

function RagdollService:EnableMotor6D(char: Model, enabled: boolean)
	for _, v in pairs(char:GetDescendants()) do
		if v.Name == "Handle" or v.Name == "RootJoint" or v.Name == "Neck" then
			continue
		end
		if v:IsA("Motor6D") then
			v.Enabled = enabled
		end
		if v:IsA("BasePart") then
			v.CollisionGroup = if enabled then "Character" else "Ragdoll"
		end
	end
end

function RagdollService:RagdollCharacter(char: Model, duration: number?)
	if not char then
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not hum then
		return
	end

	if char:GetAttribute("isRagdoll") then
		return
	end
	char:SetAttribute("isRagdoll", true)

	local plr = Players:GetPlayerFromCharacter(char)

	self:EnableMotor6D(char, false)
	self:BuildJoints(char)
	self:EnableCollisionParts(char, true)

	hrp:SetNetworkOwner(nil)
	hum.AutoRotate = false
	hum.PlatformStand = true

	if not duration then
		return
	end

	task.delay(duration, function()
		self:UnragdollCharacter(char)
	end)
end

function RagdollService:UnragdollCharacter(char: Model)
	if not char then
		return
	end

	-- attribute check
	if not char:GetAttribute("isRagdoll") then
		return
	end
	char:SetAttribute("isRagdoll", false)

	local plr = Players:GetPlayerFromCharacter(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not hum or not hrp then
		return
	end

	hrp:SetNetworkOwner(nil)

	if hum:GetState() ~= Enum.HumanoidStateType.Dead then
		hum.PlatformStand = false
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	self:DestroyJoints(char)
	self:EnableMotor6D(char, true)
	self:EnableCollisionParts(char, false)

	hum.AutoRotate = true
end

function RagdollService:SetUp(char: Model)
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	hum.BreakJointsOnDeath = false
	hum.RequiresNeck = false
	char:SetAttribute("isRagdoll", false)

	RagdollService:BuildCollisionParts(char)
end

return RagdollService
