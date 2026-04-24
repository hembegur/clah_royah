local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)

local troopService = {} -- SHARED

return troopService -- SHARED

-- Velocity
-- self.lv = Instance.new("LinearVelocity")
-- self.lv.MaxForce = math.huge
-- self.lv.Attachment0 = self.serverHrp:FindFirstChild("RootAttachment")
-- self.lv.Parent = self.serverHrp
-- self.lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
-- self.lv.PlaneVelocity = Vector2.new(0, 0)
-- self.lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
-- self.lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)

-- self.ao = Instance.new("AlignOrientation")
-- self.ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
-- self.ao.Attachment0 = self.serverHrp:FindFirstChildOfClass("Attachment")
-- self.ao.RigidityEnabled = false
-- self.ao.Responsiveness = 5
-- self.ao.MaxTorque = 10000
-- self.ao.Parent = self.serverHrp
