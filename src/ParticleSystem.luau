local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local NodeType = require(script.Parent.Enums.NodeType)
local Component = require(script.Parent.Nodes.Component)
local Mesh = require(script.Parent.Nodes.Renderers.Mesh)
local Spawner = require(script.Parent.Nodes.Spawner)
local Constant = require(script.Parent.Nodes.Spawners.Constant)
local ObjectPool = require(script.Parent.ObjectPool)
local ParticleData = require(script.Parent.ParticleData)

local ParticleSystem = {}

export type ParticleSystem = {
	spawner: Spawner.Spawner,
	initializers: { Component.Component },
	updaters: { Component.Component },

	objectPool: ObjectPool.ObjectPool,
	particleData: { ParticleData.ParticleData },

	stepperConnection: RBXScriptConnection?,
	currentStep: number,
	runningTime: number,

	isStopping: boolean,
	isPaused: boolean,

	Start: (self: ParticleSystem) -> (),
	Pause: (self: ParticleSystem) -> (),
	Unpause: (self: ParticleSystem) -> (),
	Stop: (self: ParticleSystem) -> (),
	Restart: (self: ParticleSystem) -> (),
}

local function _ConnectStepper(self: ParticleSystem)
	self.stepperConnection = RunService.Heartbeat:Connect(function(dt)
		self.runningTime += dt

		local currentstep = math.floor(self.runningTime / Config.frametime)
		local delta = currentstep - self.currentStep

		if delta > 0 then
			ParticleSystem.Step(self, delta)
			self.currentStep = currentstep
		end
	end)
end

local function Start(self: ParticleSystem)
	if RunService:IsServer() then
		warn("Failed to start particle system! Particle systems can only be used on the client!")
		return
	end

	if self.isPaused then
		warn("Failed to start particle syetem! Particle system us paused!")
		return
	end

	if self.isStopping then
		self.isStopping = false

		if not self.stepperConnection then
			_ConnectStepper(self)
		end

		return
	end

	if self.stepperConnection then
		warn("Failed to start particle system! Particle system is already running!")
		return
	end

	_ConnectStepper(self)
end

local function Pause(self: ParticleSystem)
	if not self.stepperConnection then
		warn("Failed to pause particle system! Particle system isn't running!")
		return
	end

	self.isPaused = true

	self.stepperConnection:Disconnect()
	self.stepperConnection = nil
end

local function Unpause(self: ParticleSystem)
	if self.stepperConnection then
		warn("Failed to unpause particle system! Particle system is already running!")
		return
	end

	self.isPaused = false
	_ConnectStepper(self)
end

local function Stop(self: ParticleSystem)
	self.isStopping = true
end

local function Restart(self: ParticleSystem)
	if self.stepperConnection then
		self.stepperConnection:Disconnect()
		self.stepperConnection = nil
	end

	self.runningTime = 0
	self.currentStep = 0

	Start(self)
end

function ParticleSystem.New(props: { [unknown]: unknown }): ParticleSystem
	local self: ParticleSystem = {
		spawner = Constant {},
		initializers = {},
		updaters = {},

		objectPool = ObjectPool.New(Mesh {}.particle),
		particleData = {},

		stepperConnection = nil,
		currentStep = 0,
		runningTime = 0,

		isStopping = false,
		isPaused = false,

		Start = Start,
		Pause = Pause,
		Unpause = Unpause,
		Stop = Stop,
		Restart = Restart,
	}

	for _, prop in props do
		if typeof(prop) == "table" then
			if prop.nodeType == NodeType.Spawn then
				self.spawner = prop
			elseif prop.nodeType == NodeType.Initialize then
				table.insert(self.initializers, prop)
			elseif prop.nodeType == NodeType.Update then
				table.insert(self.updaters, prop)
			elseif prop.nodeType == NodeType.Render then
				ObjectPool.Cleanup(self.objectPool)
				ObjectPool.OverrideObject(self.objectPool, prop.particle)
			end
		end
	end

	return self
end

function ParticleSystem.Step(self: ParticleSystem, steps: number)
	local bulkMoveToParts = {}
	local bulkMoveToCFrames = {}

	-- Update Existing Particles
	for i = #self.particleData, 1, -1 do
		local particleData = self.particleData[i]
		particleData.aliveFrames += steps

		if particleData.aliveFrames > particleData.lifetime then
			ObjectPool.RemoveItem(self.objectPool, particleData.particle)
			table.remove(self.particleData, i)

			table.insert(bulkMoveToParts, particleData.particle)
			table.insert(bulkMoveToCFrames, ObjectPool.standbyLocation)

			if not self.isStopping then
				continue
			end

			if #self.particleData > 0 then
				continue
			end

			if not self.stepperConnection then
				continue
			end

			self.stepperConnection:Disconnect()
			self.stepperConnection = nil
			continue
		end

		local props = {}
		for _, component in self.updaters do
			component.Step(component, steps, particleData, props)
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
	if not self.isStopping then
		for i = 1, steps do
			local newCount = self.spawner.CalculateSpawnCountOnFrame(self.spawner, self.currentStep + steps)

			for _ = 1, newCount do
				local particleData: ParticleData.ParticleData = {
					particle = ObjectPool.GetItem(self.objectPool),
					lifetime = 60,
					aliveFrames = 0,
				}

				if steps > particleData.lifetime then
					continue
				end

				table.insert(self.particleData, particleData)

				local props = {}
				for _, component in self.initializers do
					component.Step(component, 0, particleData, props)
				end

				for _, component in self.updaters do
					component.Step(component, i - 1, particleData, props)
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

	workspace:BulkMoveTo(bulkMoveToParts, bulkMoveToCFrames, Enum.BulkMoveMode.FireCFrameChanged)
end

return ParticleSystem
