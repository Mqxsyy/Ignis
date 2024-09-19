local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis)

local ParticleSystem = Ignis.ParticleSystem
local Components = Ignis.Components
local Enums = Ignis.Enums

local _sys = ParticleSystem.New()
	:AddComponent(Components.Position:Method(Enums.ComponentMethods.SET):Position(Vector3.zero))
