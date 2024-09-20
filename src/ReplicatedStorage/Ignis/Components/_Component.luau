local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParticleData = require(ReplicatedStorage.Ignis.ParticleData)

export type Component = {
	_p: {
		Update: (self: any, step: number, particleData: ParticleData.ParticleData, props: {}) -> (),
		[string]: any,
	},
}

return nil
