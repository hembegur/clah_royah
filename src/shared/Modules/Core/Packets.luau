local rs = game:GetService("ReplicatedStorage")
local packages = rs:WaitForChild("Packages")
local packet = require(packages:WaitForChild("Packet"))

local Packets = {}

-- NPC related shit
Packets.spawnNpc = packet("spawnNpc", packet.Any) --Data
Packets.killNpc = packet("killNpc", packet.NumberU16) -- Id
Packets.updateNpcPos = packet("updateNpcPos", packet.NumberU16, packet.Vector3F24) --id / position
Packets.updateNpcDir = packet("updateNpcDir", packet.NumberU16, packet.Vector3F24) --id / look at position
Packets.teleportNpc = packet("teleportNpc", packet.NumberU16, packet.Vector3F24) --id / position
Packets.updateNpcHp = packet("updateHP", packet.NumberU16, packet.NumberS16) --id / hp

Packets.removeFromClient = packet("removeFromClient", packet.Any) --Delete from client

Packets.testMatch = packet("testMatch")

return Packets

--[[
	S8		Minimum: -128			Maximum: 127
	S16		Minimum: -32768			Maximum: 32767
	S24		Minimum: -8388608		Maximum: 8388607
	S32		Minimum: -2147483648	Maximum: 2147483647

	U8		Minimum: 0				Maximum: 255
	U16		Minimum: 0				Maximum: 65535
	U24		Minimum: 0				Maximum: 16777215
	U32		Minimum: 0				Maximum: 4294967295

	F16		±2048					[65520]
	F24		±262144					[4294959104]
	F32		±16777216				[170141183460469231731687303715884105728]
	F64		±9007199254740992		[huge]
]]
