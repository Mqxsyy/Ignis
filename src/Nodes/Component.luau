local Node = require(script.Parent.Node)
local ParticleData = require(script.Parent.Parent.ParticleData)

export type Component = Node.Node & {
	Step: (self: any, steps: number, particleData: ParticleData.ParticleData, props: {}) -> (),
}

return nil
