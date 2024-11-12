local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local ParallelScheduler = require(script.Parent.Parent.Parent.ParallelScheduler)
local Config = require(script.Parent.Parent.Parent.Parent.Config)
local NodeList = require(script.Parent.Parent.Parent.Parent.Nodes.NodeList)
local ObjectPool = require(script.Parent.Parent.Parent.Parent.ObjectPool)
local Types = require(script.Parent.Parent.Parent.Parent.Types)
local ParticleContainer = require(script.Parent.Parent.Parent.ParticleContainer)

local index = tonumber(script.Parent.Name)

local function UpdateSystem(system: Types.ParticleSystemData, dt: number)
	if system.isPaused or not system.isEnabled then
		system.stepDelta = 0
		return
	end

	system.runningTime += dt

	local currentstep = math.floor(system.runningTime / Config.frametime)
	local delta = currentstep - system.currentStep

	if delta == 0 then
		return
	end

	system.stepDelta = delta
	system.currentStep = currentstep
end

local function CreateNewParticles(system: Types.ParticleSystemData, systemIndex: number): { Types.ParticleData }
	local amount = NodeList.GetNode(system.spawner.name)(system.currentStep, system.stepDelta, {})

	local newParticles: { Types.ParticleData } = {}

	for _ = 1, amount do
		local particleData: Types.ParticleData = {
			particleId = -1,

			systemWorkerIndex = index,
			systemIndex = systemIndex,

			lifetime = 60,
			alivetime = 0,

			props = {
				position = ObjectPool.standbyLocation,
			},
		}

		if system.stepDelta > particleData.lifetime then
			continue
		end

		local props = {}
		for _, component in system.initializers do
			NodeList.GetNode(component.name)(system.stepDelta, particleData, props)
		end

		for _, component in system.updaters do
			NodeList.GetNode(component.name)(system.stepDelta, particleData, props)
		end

		particleData.updates = props
		table.insert(newParticles, particleData)
	end

	return newParticles
end

-- Step systems & create new particles
RunService.PreSimulation:ConnectParallel(function(dt)
	local systemsShared = SharedTableRegistry:GetSharedTable(`{ParallelScheduler.SystemsRegistryPrefix}{index}`)
	if SharedTable.size(systemsShared) == 0 then
		return
	end

	local systems = SharedTable.clone(systemsShared, true)

	for systemIndex, system: Types.ParticleSystemData in systems do
		UpdateSystem(system, dt)

		if system.isStopping or system.stepDelta == 0 then
			continue
		end

		local newParticles = CreateNewParticles(system, systemIndex)

		if #newParticles == 0 then
			continue
		end

		local particlesShared = SharedTableRegistry:GetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`)
		local particles = SharedTable.clone(particlesShared, true)
		for _, newParticle in newParticles do
			table.insert(particles, newParticle)
		end

		SharedTableRegistry:SetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`, particles)
	end

	SharedTableRegistry:SetSharedTable(`{ParallelScheduler.SystemsRegistryPrefix}{index}`, systems)
end)

-- Update all particles
RunService.PostSimulation:ConnectParallel(function()
	local particlesShared = SharedTableRegistry:GetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`)
	local particleCount = SharedTable.size(particlesShared)

	if particleCount == 0 then
		return
	end

	local particles = SharedTable.clone(particlesShared, true)

	for i = particleCount, 1, -1 do
		local particle: Types.ParticleData = particles[i]
		local tblName = `{ParallelScheduler.SystemsRegistryPrefix}{particle.systemWorkerIndex}`
		local system = SharedTableRegistry:GetSharedTable(tblName)[particle.systemIndex]

		if system.stepDelta == 0 then
			continue
		end

		particle.alivetime += system.stepDelta

		if particle.alivetime > particle.lifetime then
			table.remove(particles, i)
			continue
		end

		local props = {}
		for _, component in system.updaters do
			component.Step(component, system.stepDelta, particle, props)
		end

		particle.updates = props
	end

	SharedTableRegistry:SetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`, particles)
end)

-- Apply updates to particles
RunService.Heartbeat:Connect(function()
	local particlesShared = SharedTableRegistry:GetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`)
	local particleCount = SharedTable.size(particlesShared)

	if particleCount == 0 then
		return
	end

	local particles = SharedTable.clone(particlesShared)

	local bulkMoveToParts = {}
	local bulkMoveToCFrames = {}

	for i = particleCount, 1, -1 do
		local particle: Types.ParticleData = particles[i]
		local tblName = `{ParallelScheduler.SystemsRegistryPrefix}{particle.systemWorkerIndex}`
		local system = SharedTableRegistry:GetSharedTable(tblName)[particle.systemIndex]

		local part
		if particle.particleId == -1 then
			ParticleContainer.idTracker += 1
			particle.particleId = ParticleContainer.idTracker

			part = ObjectPool.GetItem(system.objectPool)
			ParticleContainer.particles[particle.particleId] = part
		else
			part = ParticleContainer[particle.particleId]
		end

		if particle.alivetime > particle.lifetime then
			ObjectPool.RemoveItem(system.objectPool, part)
			table.insert(bulkMoveToParts, part)
			table.insert(bulkMoveToCFrames, ObjectPool.standbyLocation)
			table.remove(particles, i)

			ParticleContainer[particle.particleId] = nil
			continue
		end

		if particle.updates == nil then
			warn("Ignis: empty update table")
			continue
		end

		for k, v in particle.updates do
			if k == "CFrame" then
				table.insert(bulkMoveToParts, part)
				table.insert(bulkMoveToCFrames, v)
				continue
			end

			part[k] = v
		end

		for k, _ in particle.props do
			particle.props[k] = particle[k]
		end
	end

	workspace:BulkMoveTo(bulkMoveToParts, bulkMoveToCFrames)
	SharedTableRegistry:SetSharedTable(`{ParallelScheduler.ParticlesRegistryPrefix}{index}`, particles)
end)
