local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis) -- not sure how to fix this error

local ParticleSystem = Ignis.ParticleSystem
local Spawners = Ignis.Spawners
local Components = Ignis.Components
local Renderers = Ignis.Renderers
local Enums = Ignis.Enums

local _sys = ParticleSystem.New()
	:SetSpawner(Spawners.Constant.New():Rate(6))
	:AddComponent(Components.Position.New():Method(Enums.ComponentMethods.SET):Position(Vector3.new(0, 5, 0)))
	:AddComponent(Components.Position.New():Method(Enums.ComponentMethods.UPDATE):Position(Vector3.new(0, 2, 0)))
	:SetRenderer(Renderers.Mesh.New())
	:Start()
