local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local Types = require(script.Parent.Parent.Types)

local index = tonumber(script.Parent.Name)

RunService.Heartbeat:ConnectParallel(function(dt)
	local particles: { Types.ParticleData } = SharedTableRegistry:GetSharedTable(`ignis_particles_{index}`)

	for _, particle in particles do
	end
end)
