--!strict
local rs = game:GetService("ReplicatedStorage")
local packages = rs:WaitForChild("Packages")
local debris = game:GetService("Debris")

function apply(att: Attachment, velocity: Vector3, maxAxesForce: Vector3, duration: number)
	local slide = Instance.new("LinearVelocity")
	slide.MaxAxesForce = maxAxesForce
	slide.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	slide.VectorVelocity = velocity
	slide.Parent = att
	slide.Attachment0 = att
	debris:AddItem(slide, duration)
end

return apply
