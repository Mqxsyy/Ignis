local Enums = require(script.Enums)
local ParticleSystem = require(script.ParticleSystem)
local AddInitializer = require(script.ParticleSystemBuilder.AddInitializer)
local AddUpdater = require(script.ParticleSystemBuilder.AddUpdater)
local SetRenderer = require(script.ParticleSystemBuilder.SetRenderer)
local SetSpawner = require(script.ParticleSystemBuilder.SetSpawner)

local Ignis = table.freeze({
	ParticleSystem = ParticleSystem.New,

	SetSpawner = SetSpawner,
	AddInitializer = AddInitializer,
	AddUpdater = AddUpdater,
	SetRenderer = SetRenderer,

	Enums = {
		Method = Enums.Method,
	},
})

return Ignis
