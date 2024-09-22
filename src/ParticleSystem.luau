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
		components: { _Component.Component },
		objectPool: ObjectPool.ObjectPool,
		particleData: { ParticleData.ParticleData },
		currentStep: number,
		stepperConnection: RBXScriptConnection?,
		runningTime: number,
	},

	SetSpawner: (self: ParticleSystem, spawner: _Spawner.Spawner) -> ParticleSystem,
	AddComponent: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	SetRenderer: (self: ParticleSystem, renderer: _Renderer.Renderer) -> ParticleSystem,
	Start: (self: ParticleSystem) -> (),
	-- Stop: (self: ParticleSystem) -> (),
}

local function SetSpawner(self: ParticleSystem, spawner: _Spawner.Spawner)
	self._p.spawner = spawner
	return self
end

local function AddComponent(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._p.components, component)
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
			components = {},
			objectPool = ObjectPool.New(RendererList.Mesh.New()._p.particle),
			particleData = {},
			currentStep = 0,
			stepperConnection = nil,
			runningTime = 0,
		},

		SetSpawner = SetSpawner,
		AddComponent = AddComponent,
		SetRenderer = SetRenderer,

		Start = Start,
		-- Stop = Stop,
	}

	return self
end

function ParticleSystem.Step(self: ParticleSystem, steps: number)
	local newParticles = self._p.spawner._p.CalculateSpawnCountOnFrame(self._p.spawner, self._p.currentStep + steps)
	print(newParticles)
	-- for i = 0, amount - 1 do
	-- 	local particleData: ParticleData.ParticleData = {
	-- 		particle = ObjectPool.GetItem(self._p.objectPool),
	-- 		lifetime = 60,
	-- 		aliveFrames = 0,
	-- 	}
	--
	-- 	table.insert(self._p.particleData, particleData)
	--
	-- 	local props = {}
	-- 	for _, component in self._p.components do
	-- 		component._p.Update(component, i, particleData, props)
	-- 	end
	--
	-- 	for k, v in props do
	-- 		particleData.particle[k] = v
	-- 	end
	-- end
end

return ParticleSystem
