local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseClientTroop = require(ReplicatedStorage.Shared.Classes.Troops.BaseClientTroop)
local BaseNpc = require(ReplicatedStorage.Shared.Classes.Troops.Troop)

local packets = require(ReplicatedStorage.Shared.Modules.Core.Packets)
local ragdollService = require(ReplicatedStorage.Shared.Services.Ragdoll.RaqdollService)

local SwordMan = BaseClientTroop.new({
	Name = "SwordMan",
	Model = ReplicatedStorage.Assets.Troops.DefaultRig,
	HealthGui = ReplicatedStorage.Assets.Gui.HealthGui,
	NpcClass = BaseNpc,
	Packets = packets,
	RagdollService = ragdollService,
})

return SwordMan
