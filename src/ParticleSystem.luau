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

		stepperConnection: RBXScriptConnection?,
		currentStep: number,
		runningTime: number,

		isStopping: boolean,
		isPaused: boolean,
	},

	SetSpawner: (self: ParticleSystem, spawner: _Spawner.Spawner) -> ParticleSystem,
	AddInitializer: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	AddUpdater: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	SetRenderer: (self: ParticleSystem, renderer: _Renderer.Renderer) -> ParticleSystem,

	Start: (self: ParticleSystem) -> (),
	Pause: (self: ParticleSystem) -> (),
	Unpause: (self: ParticleSystem) -> (),
	Stop: (self: ParticleSystem) -> (),
	Restart: (self: ParticleSystem) -> (),
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

local function _ConnectStepper(self: ParticleSystem)
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

local function Start(self: ParticleSystem)
	if RunService:IsServer() then
		warn("Failed to start particle system! Particle systems can only be used on the client!")
		return
	end

	if self._p.isPaused then
		warn("Failed to start particle syetem! Particle system us paused!")
		return
	end

	if self._p.isStopping then
		self._p.isStopping = false

		if not self._p.stepperConnection then
			_ConnectStepper(self)
		end

		return
	end

	if self._p.stepperConnection then
		warn("Failed to start particle system! Particle system is already running!")
		return
	end

	_ConnectStepper(self)
end

local function Pause(self: ParticleSystem)
	if not self._p.stepperConnection then
		warn("Failed to pause particle system! Particle system isn't running!")
		return
	end

	self._p.isPaused = true

	self._p.stepperConnection:Disconnect()
	self._p.stepperConnection = nil
end

local function Unpause(self: ParticleSystem)
	if self._p.stepperConnection then
		warn("Failed to unpause particle system! Particle system is already running!")
		return
	end

	self._p.isPaused = false
	_ConnectStepper(self)
end

local function Stop(self: ParticleSystem)
	self._p.isStopping = true
end

local function Restart(self: ParticleSystem)
	if self._p.stepperConnection then
		self._p.stepperConnection:Disconnect()
		self._p.stepperConnection = nil
	end

	self._p.runningTime = 0
	self._p.currentStep = 0

	Start(self)
end

function ParticleSystem.New(): ParticleSystem
	local self: ParticleSystem = {
		_p = {
			spawner = Constant.New(),
			initializers = {},
			updaters = {},

			objectPool = ObjectPool.New(RendererList.Mesh.New()._p.particle),
			particleData = {},

			stepperConnection = nil,
			currentStep = 0,
			runningTime = 0,

			isStopping = false,
			isPaused = false,
		},

		SetSpawner = SetSpawner,
		AddInitializer = AddInitializer,
		AddUpdater = AddUpdater,
		SetRenderer = SetRenderer,

		Start = Start,
		Pause = Pause,
		Unpause = Unpause,
		Stop = Stop,
		Restart = Restart,
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

			if not self._p.isStopping then
				continue
			end

			if #self._p.particleData > 0 then
				continue
			end

			if not self._p.stepperConnection then
				continue
			end

			self._p.stepperConnection:Disconnect()
			self._p.stepperConnection = nil
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
	if not self._p.isStopping then
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
	end

	workspace:BulkMoveTo(bulkMoveToParts, bulkMoveToCFrames)
end

return ParticleSystem
