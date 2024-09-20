local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis)

local ParticleSystem = Ignis.ParticleSystem
local Components = Ignis.Components
local Renderers = Ignis.Renderers
local Enums = Ignis.Enums

local _sys = ParticleSystem.New()
	:AddComponent(Components.Position.New():Method(Enums.ComponentMethods.SET):Position(Vector3.new(0, 5, 0)))
	:AddComponent(Components.Position.New():Method(Enums.ComponentMethods.UPDATE):Position(Vector3.new(0, 2, 0)))
	:SetRenderer(Renderers.Mesh)

_sys._p.Step(_sys, 10)
