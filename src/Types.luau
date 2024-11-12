export type ObjectPool = {
	id: number,
	object: BasePart,
	folder: Folder,
	activeItems: { BasePart },
	standbyItems: { BasePart },
}

export type ParticleData = {
	particleId: number,

	systemWorkerIndex: number,
	systemIndex: number,

	lifetime: number, -- In frames
	alivetime: number, -- In frames

	props: {
		position: Vector3,
	},
	updates: {
		position: Vector3?,
	}?,
}

export type ParticleSystemData = {
	spawner: { name: string },
	initializers: { { name: string } },
	updaters: { { name: string } },

	objectPoolId: number,

	stepDelta: number,
	currentStep: number,
	runningTime: number,

	isEnabled: boolean,
	isStopping: boolean,
	isPaused: boolean,
}

return nil
