-- local Config = require(script.Parent.Config)
local Types = require(script.Parent.Types)

type Self = {
    SerialSystems: { Types.ParticleSystem },
    SerialParticles: { Types.ParticleData },
}

local Scheduler = {}

Scheduler.SerialSystems = {}
Scheduler.SerialParticles = {}

-- Scheduler.ParallelSystems = SharedTable.new()
--
-- for i = 1, #Config.workers do
-- 	Scheduler[`ParallelParticles{i}`] = SharedTable.new()
-- end

return Scheduler
