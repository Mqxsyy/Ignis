local Enums = require(script.Parent.Enums)

export type ObjectPool = {
	object: BasePart,
	folder: Folder,
	activeItems: { BasePart },
	standbyItems: { BasePart },
}

export type ParticleData = {
	serialSystem: ParticleSystem?,

	particle: BasePart,
	lifetime: number, -- Frames
	aliveFrames: number,
}

export type Node = {
	nodeType: Enums.NodeType?,
}

export type Spawner = Node & {
	CalculateSpawnCountOnFrame: (self: any, currentStep: number, stepDelta: number) -> number,
}

export type Component = Node & {
	Step: (self: any, steps: number, particleData: ParticleData, props: {}) -> (),
}

export type Renderer = Node & {
	particle: BasePart,
}

export type ParticleSystem = {
	runParallel: boolean,

	spawner: Spawner,
	initializers: { Component },
	updaters: { Component },

	objectPool: ObjectPool,

	stepDelta: number,
	currentStep: number,
	runningTime: number,

	isEnabled: boolean,
	isStopping: boolean,
	isPaused: boolean,

	Start: (self: ParticleSystem) -> (),
	Pause: (self: ParticleSystem) -> (),
	Unpause: (self: ParticleSystem) -> (),
	Stop: (self: ParticleSystem) -> (),
	Restart: (self: ParticleSystem) -> (),
}

return nil
