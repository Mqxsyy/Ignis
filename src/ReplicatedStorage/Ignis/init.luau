local Position = require(script.Components.Position)
local ComponentMethods = require(script.Enums.ComponentMethods)
local ParticleSystem = require(script.ParticleSystem)

local _sys = ParticleSystem.New()
	:AddComponent(Position.New():Position(Vector3.zero):Method(ComponentMethods.SET))
	:AddComponent(Position.New():Method(ComponentMethods.UPDATE):Position(Vector3.yAxis))
