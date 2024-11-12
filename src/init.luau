local Enums = require(script.Enums)
local ParallelScheduler = require(script.ParallelScheduler.ParallelScheduler)
local ParticleSystem = require(script.ParticleSystem)

ParallelScheduler.Init()

local Ignis = table.freeze({
	ParticleSystem = ParticleSystem.New,

	SetSpawner = ParticleSystem.AddNode(Enums.NodeType.Spawn),
	AddInitializer = ParticleSystem.AddNode(Enums.NodeType.Initialize),
	AddUpdater = ParticleSystem.AddNode(Enums.NodeType.Update),
	SetRenderer = ParticleSystem.AddNode(Enums.NodeType.Render),

	Enums = {
		Method = Enums.Method,
	},
})

return Ignis
