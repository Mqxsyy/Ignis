local SharedTableRegistry = game:GetService("SharedTableRegistry")
local Config = require(script.Parent.Parent.Config)

type Self = {
	currentSystemIndex: number,
	currentParticleIndex: number,
}

for i = 1, Config.workers do
	SharedTableRegistry:SetSharedTable(`ignis_systems_{i}`, {})
	SharedTableRegistry:SetSharedTable(`ignis_particles_{i}`, {})

	local actor = Instance.new("Actor")
	actor.Name = i
	actor.Parent = script.Parent.Workers

	local worker = script.Parent.Worker:Clone()
	worker.Parent = actor

	worker.Enabled = true
end

local self: Self = {
	currentSystemIndex = 1,
	currentParticleIndex = 1,
}

return self
