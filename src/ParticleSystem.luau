local RunService = game:GetService("RunService")
local Enums = require(script.Parent.Enums)
local Mesh = require(script.Parent.Nodes.Renderers.Mesh)
local Constant = require(script.Parent.Nodes.Spawners.Constant)
local ObjectPool = require(script.Parent.ObjectPool)
local Scheduler = require(script.Parent.Scheduler)
local Stepper = require(script.Parent.Stepper)
local Types = require(script.Parent.Types)

local ParticleSystem = {}

local function Start(self: Types.ParticleSystem)
	if RunService:IsServer() then
		warn("Failed to start particle system! Particle systems can only be used on the client!")
		return
	end

	if self.isPaused then
		warn("Failed to start particle syetem! Particle system is paused!")
		return
	end

	if self.isStopping then
		self.isStopping = false
		self.isEnabled = true
		return
	end

	if self.isEnabled then
		warn("Failed to start particle system! Particle system is already running!")
		return
	end

	self.isEnabled = true
	Stepper.Run()
end

local function Pause(self: Types.ParticleSystem)
	if not self.isEnabled then
		warn("Failed to pause particle system! Particle system isn't running!")
		return
	end

	self.isPaused = true
end

local function Unpause(self: Types.ParticleSystem)
	if self.isEnabled then
		warn("Failed to unpause particle system! Particle system is not paused!")
		return
	end

	self.isPaused = false
end

local function Stop(self: Types.ParticleSystem)
	self.isStopping = true
end

local function Restart(self: Types.ParticleSystem)
	self.runningTime = 0
	self.currentStep = 0

	Start(self)
end

local idTracker = 0
function ParticleSystem.New(props: { [unknown]: unknown }): Types.ParticleSystem
	idTracker += 1

	local self: Types.ParticleSystem = {
		runParallel = false,

		spawner = Constant {},
		initializers = {},
		updaters = {},

		particleCount = 0,
		objectPool = ObjectPool.New(Mesh {}.particle),

		stepDelta = 0,
		currentStep = 0,
		runningTime = 0,

		isEnabled = false,
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
			if prop.nodeType == Enums.NodeType.Spawn then
				self.spawner = prop
			elseif prop.nodeType == Enums.NodeType.Initialize then
				table.insert(self.initializers, prop)
			elseif prop.nodeType == Enums.NodeType.Update then
				table.insert(self.updaters, prop)
			elseif prop.nodeType == Enums.NodeType.Render then
				ObjectPool.Cleanup(self.objectPool)
				ObjectPool.OverrideObject(self.objectPool, prop.particle)
			end
		end
	end

	if self.runParallel then
		-- insert into parallel table
	else
		table.insert(Scheduler.SerialSystems)
	end

	return self
end

return ParticleSystem
