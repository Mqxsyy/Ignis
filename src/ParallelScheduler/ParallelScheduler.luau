local SharedTableRegistry = game:GetService("SharedTableRegistry")
local Config = require(script.Parent.Parent.Config)

local ParallelScheduler = {
	ParticlesRegistryPrefix = "ignis_systems_",
	SystemsRegistryPrefix = "ignis_particles_",
}

function ParallelScheduler.Init()
	for i = 1, Config.workers do
		SharedTableRegistry:SetSharedTable(`ignis_systems_{i}`, SharedTable.new())
		SharedTableRegistry:SetSharedTable(`ignis_particles_{i}`, SharedTable.new())

		local actor = Instance.new("Actor")
		actor.Name = i
		actor.Parent = script.Parent.Workers

		local worker = script.Parent.Workers.Actor.Worker:Clone()
		worker.Parent = actor

		worker.Enabled = true
	end
end

local function GetNextIndex(tableName: string): number
	local index, smallestSize = 1, 1000000

	for i = 1, Config.workers do
		local tbl = SharedTableRegistry:GetSharedTable(`{tableName}{i}`)
		local size = SharedTable.size(tbl)

		if size < smallestSize then
			index = i
			smallestSize = size
		end
	end

	return index
end

function ParallelScheduler.GetNextParticleWorkerIndex(): number
	return GetNextIndex(ParallelScheduler.ParticlesRegistryPrefix)
end

function ParallelScheduler.GetNextSystemWorkerIndex(): number
	return GetNextIndex(ParallelScheduler.SystemsRegistryPrefix)
end

return ParallelScheduler
