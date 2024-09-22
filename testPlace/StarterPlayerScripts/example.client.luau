local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis) -- not sure how to fix this error

local ParticleSystem = Ignis.ParticleSystem
local Spawners = Ignis.Spawners
local Components = Ignis.Components
local Renderers = Ignis.Renderers
local Enums = Ignis.Enums

local _sys = ParticleSystem.New()
	:SetSpawner(Spawners.Constant.New():Rate(6))
	:AddInitializer(Components.Position.New():Method(Enums.ComponentMethods.SET):Position(Vector3.new(0, 5, 0)))
	:AddUpdater(Components.Position.New():Method(Enums.ComponentMethods.UPDATE):Position(Vector3.new(0, 0.5, 0)))
	:SetRenderer(Renderers.Mesh.New())

task.wait(3)
_sys:Start()
task.wait(1)
_sys:Pause()
task.wait(1)
_sys:Unpause()
task.wait(1)
_sys:Stop()
task.wait(1)
_sys:Restart()
