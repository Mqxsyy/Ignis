local SharedTableRegistry = game:GetService("SharedTableRegistry")
local Config = require(script.Parent.Parent.Config)

type Self = {
	Systems: SharedTable,
	Particles: { SharedTable },
}

local self = {}

self.Systems = SharedTable.new()
self.Particles = {}

for i = 1, Config.workers do
	self.Particles[i] = SharedTable.new()
	SharedTableRegistry:SetSharedTable(`ignis_particles_{i}`, self.Particles[i])

	local actor = Instance.new("Actor")
	actor.Name = i
	actor.Parent = script.Parent.Workers

	local worker = script.Parent.Worker:Clone()
	worker.Parent = actor

	worker.Enabled = true
end

return self
