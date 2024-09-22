local RunService = game:GetService("RunService")
local _Component = require(script.Parent.Components._Component)
local Config = require(script.Parent.Config)
local RendererList = require(script.Parent.Lists.RendererList)
local ObjectPool = require(script.Parent.ObjectPool)
local ParticleData = require(script.Parent.ParticleData)
local _Renderer = require(script.Parent.Renderers._Renderer)
local Constant = require(script.Parent.Spawners.Constant)
local _Spawner = require(script.Parent.Spawners._Spawner)

local ParticleSystem = {}

export type ParticleSystem = {
	_p: {
		spawner: _Spawner.Spawner,
		initializers: { _Component.Component },
		updaters: { _Component.Component },

		objectPool: ObjectPool.ObjectPool,
		particleData: { ParticleData.ParticleData },
		currentStep: number,
		stepperConnection: RBXScriptConnection?,
		runningTime: number,
	},

	SetSpawner: (self: ParticleSystem, spawner: _Spawner.Spawner) -> ParticleSystem,
	AddInitializer: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	AddUpdater: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	SetRenderer: (self: ParticleSystem, renderer: _Renderer.Renderer) -> ParticleSystem,
	Start: (self: ParticleSystem) -> (),
	-- Stop: (self: ParticleSystem) -> (),
}

local function SetSpawner(self: ParticleSystem, spawner: _Spawner.Spawner)
	self._p.spawner = spawner
	return self
end

local function AddInitializer(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._p.initializers, component)
	return self
end

local function AddUpdater(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._p.updaters, component)
	return self
end

local function SetRenderer(self: ParticleSystem, renderer: _Renderer.Renderer): ParticleSystem
	ObjectPool.Cleanup(self._p.objectPool)
	ObjectPool.OverrideObject(self._p.objectPool, renderer._p.particle)
	return self
end

local function Start(self: ParticleSystem)
	if RunService:IsServer() then
		warn("Particle systems should only be used on the client!")
		return
	end

	if self._p.stepperConnection then
		warn("Particle system is already running!")
		return
	end

	self._p.stepperConnection = RunService.Heartbeat:Connect(function(dt)
		self._p.runningTime += dt

		local currentstep = math.floor(self._p.runningTime / Config.frametime)
		local delta = currentstep - self._p.currentStep

		if delta > 0 then
			ParticleSystem.Step(self, delta)
			self._p.currentStep = currentstep
		end
	end)
end

-- local function Stop(self: ParticleSystem) end

function ParticleSystem.New(): ParticleSystem
	local self: ParticleSystem = {
		_p = {
			spawner = Constant.New(),
			initializers = {},
			updaters = {},

			objectPool = ObjectPool.New(RendererList.Mesh.New()._p.particle),
			particleData = {},
			currentStep = 0,
			stepperConnection = nil,
			runningTime = 0,
		},

		SetSpawner = SetSpawner,
		AddInitializer = AddInitializer,
		AddUpdater = AddUpdater,
		SetRenderer = SetRenderer,

		Start = Start,
		-- Stop = Stop,
	}

	return self
end

function ParticleSystem.Step(self: ParticleSystem, steps: number)
	local bulkMoveToParts = {}
	local bulkMoveToCFrames = {}

	-- Update Existing Particles
	for i = #self._p.particleData, 1, -1 do
		local particleData = self._p.particleData[i]
		particleData.aliveFrames += steps

		if particleData.aliveFrames > particleData.lifetime then
			ObjectPool.RemoveItem(self._p.objectPool, particleData.particle)
			table.remove(self._p.particleData, i)

			table.insert(bulkMoveToParts, particleData.particle)
			table.insert(bulkMoveToCFrames, ObjectPool.standbyLocation)
			continue
		end

		local props = {}
		for _, component in self._p.updaters do
			component._p.Update(component, steps, particleData, props)
		end

		for k, v in props do
			if k == "CFrame" then
				table.insert(bulkMoveToParts, particleData.particle)
				table.insert(bulkMoveToCFrames, v)
				continue
			end

			particleData.particle[k] = v
		end
	end

	-- Create New Particles
	for i = 1, steps do
		local newCount = self._p.spawner._p.CalculateSpawnCountOnFrame(self._p.spawner, self._p.currentStep + steps)

		for _ = 1, newCount do
			local particleData: ParticleData.ParticleData = {
				particle = ObjectPool.GetItem(self._p.objectPool),
				lifetime = 60,
				aliveFrames = 0,
			}

			if steps > particleData.lifetime then
				continue
			end

			table.insert(self._p.particleData, particleData)

			local props = {}
			for _, component in self._p.initializers do
				component._p.Update(component, 0, particleData, props)
			end

			for _, component in self._p.updaters do
				component._p.Update(component, i - 1, particleData, props)
			end

			for k, v in props do
				if k == "CFrame" then
					table.insert(bulkMoveToParts, particleData.particle)
					table.insert(bulkMoveToCFrames, v)
					continue
				end

				particleData.particle[k] = v
			end
		end
	end

	workspace:BulkMoveTo(bulkMoveToParts, bulkMoveToCFrames)
end

return ParticleSystem
