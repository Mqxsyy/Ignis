local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis) -- not sure how to fix this error

local ParticleSystem = Ignis.ParticleSystem
local SetSpawner = Ignis.SetSpawner
local AddInitializer = Ignis.AddInitializer
local AddUpdater = Ignis.AddUpdater
local SetRenderer = Ignis.SetRenderer
local Enums = Ignis.Enums

local sys = ParticleSystem {
	SetSpawner "Constant" {
		rate = 10,
	},

	AddInitializer "Position" {
		method = Enums.Method.SET,
		position = Vector3.yAxis * 5,
	},

	AddUpdater "Position" {
		method = Enums.Method.UPDATE,
		position = Vector3.yAxis,
	},

	SetRenderer "Mesh" {},
}

sys:Start()

-- task.wait(3)
-- _sys:Start()
-- task.wait(1)
-- _sys:Pause()
-- task.wait(1)
-- _sys:Unpause()
-- task.wait(1)
-- _sys:Stop()
-- task.wait(1)
-- _sys:Restart()
