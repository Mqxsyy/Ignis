local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local Enums = require(script.Parent.Enums)
local NodeList = require(script.Parent.Nodes.NodeList)
local ObjectPool = require(script.Parent.ObjectPool)
local ParallelScheduler = require(script.Parent.ParallelScheduler.ParallelScheduler)
local Types = require(script.Parent.Types)

local ParticleSystem = {}

local function Start(self: Types.ParticleSystemData)
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
end

local function Pause(self: Types.ParticleSystemData)
	if RunService:IsServer() then
		warn("Failed to pause particle system! Particle systems can only be used on the client!")
		return
	end

	if not self.isEnabled then
		warn("Failed to pause particle system! Particle system is not running!")
		return
	end

	if self.isPaused then
		warn("Failed to pause particle system! Particle system is already paused!")
		return
	end

	self.isPaused = true
end

local function Unpause(self: Types.ParticleSystemData)
	if RunService:IsServer() then
		warn("Failed to unpause particle system! Particle systems can only be used on the client!")
		return
	end

	if not self.isEnabled then
		warn("Failed to unpause particle system! Particle system is not running!")
		return
	end

	if not self.isPaused then
		warn("Failed to unpause particle system! Particle system is not paused!")
		return
	end

	self.isPaused = false
end

local function Stop(self: Types.ParticleSystemData)
	if RunService:IsServer() then
		warn("Failed to stop particle system! Particle systems can only be used on the client!")
		return
	end

	if self.isStopping then
		warn("Failed to stop particle system! Particle system is already stopped!")
		return
	end

	self.isStopping = true
end

local function Restart(self: Types.ParticleSystemData)
	self.runningTime = 0
	self.currentStep = 0

	Start(self)
end

function ParticleSystem.New(nodes: { [unknown]: unknown })
	local particleSystemData: Types.ParticleSystemData = {
		spawner = { name = "Constant" },
		initializers = {},
		updaters = {},

		objectPoolId = -1,

		stepDelta = 0,
		currentStep = 0,
		runningTime = 0,

		isEnabled = false,
		isStopping = false,
		isPaused = false,
	}

	for _, node in nodes do
		if node.nodeType == Enums.NodeType.Spawn then
			particleSystemData.spawner = node.data
		elseif node.nodeType == Enums.NodeType.Initialize then
			table.insert(particleSystemData.initializers, node.data)
		elseif node.nodeType == Enums.NodeType.Update then
			table.insert(particleSystemData.updaters, node.data)
		elseif node.nodeType == Enums.NodeType.Render then
			if particleSystemData.objectPoolId == -1 then
				local renderNode = NodeList.GetNode(node.data.name)
				local objectPool = ObjectPool.New(renderNode())
				particleSystemData.objectPoolId = objectPool.id
			else
				local objectPool = ObjectPool.GetById(particleSystemData.objectPoolId)
				local renderNode = NodeList.GetNode(node.data.name)
				ObjectPool.Cleanup(objectPool)
				ObjectPool.OverrideObject(objectPool, renderNode())
			end
		end
	end

	local systemWorkerId = ParallelScheduler.GetNextSystemWorkerIndex()
	local tblName = `{ParallelScheduler.SystemsRegistryPrefix}{systemWorkerId}`
	local systemsShared = SharedTableRegistry:GetSharedTable(tblName)
	systemsShared[SharedTable.size(systemsShared) + 1] = particleSystemData

	return {
		Start = function()
			Start(particleSystemData)
		end,
		Pause = function()
			Pause(particleSystemData)
		end,
		Unpause = function()
			Unpause(particleSystemData)
		end,
		Stop = function()
			Stop(particleSystemData)
		end,
		Restart = function()
			Restart(particleSystemData)
		end,
	}
end

function ParticleSystem.AddNode(nodeType: Enums.NodeType)
	return function(name: string)
		return function(props: { unknown })
			return { nodeType = nodeType, data = { name = name, props = props } }
		end
	end
end

return ParticleSystem
