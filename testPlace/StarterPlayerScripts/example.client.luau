local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ignis = require(ReplicatedStorage.Ignis) -- not sure how to fix this error (external edito)

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

-- task.wait(3)
sys:Start()
-- task.wait(1)
-- sys:Pause()
-- task.wait(1)
-- sys:Unpause()
-- task.wait(1)
-- sys:Stop()
-- task.wait(1)
-- sys:Restart()
