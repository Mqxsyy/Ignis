local ParticleData = require(script.Parent.Parent.ParticleData)

export type Component = {
	_p: {
		Update: (self: any, step: number, particleData: ParticleData.ParticleData, props: {}) -> (),
		[string]: any,
	},
}

return nil
