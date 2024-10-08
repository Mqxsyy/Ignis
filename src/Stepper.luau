local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local ObjectPool = require(script.Parent.ObjectPool)
local Scheduler = require(script.Parent.Scheduler)
local Types = require(script.Parent.Types)

type PropsTableEntry = { particle: BasePart, props: { [string]: unknown } }

local Stepper = {}

local function StepSerial(): { PropsTableEntry }
	local propsTable: { PropsTableEntry } = {}

	-- Update Existing particles
	for i = #Scheduler.SerialParticles, 1, -1 do
		local particleData: Types.ParticleData = Scheduler.SerialParticles[i]
		local system = particleData.serialSystem

		if system.stepDelta == 0 then
			continue
		end

		particleData.aliveFrames += system.stepDelta

		if particleData.aliveFrames > particleData.lifetime then
			ObjectPool.RemoveItem(system.objectPool, particleData.particle)
			table.remove(Scheduler.SerialParticles, i)

			table.insert(
				propsTable,
				{ particle = particleData.particle, props = { CFrame = ObjectPool.standbyLocation } }
			)

			continue
		end

		local props = {}
		for _, component in system.updaters do
			component.Step(component, system.stepDelta, particleData, props)
		end

		table.insert(propsTable, { particle = particleData.particle, props = props })
	end

	-- Create new particles
	for _, system: Types.ParticleSystem in Scheduler.SerialSystems do
		if system.isStopping then
			continue
		end

		if system.stepDelta == 0 then
			continue
		end

		local newCount = system.spawner.CalculateSpawnCountOnFrame(system.spawner, system.currentStep)

		for _ = 1, newCount do
			local particleData: Types.ParticleData = {
				particle = ObjectPool.GetItem(system.objectPool),
				lifetime = 60,
				aliveFrames = 0,
			}

			if system.stepDelta > particleData.lifetime then
				continue
			end

			table.insert(Scheduler.SerialParticles, particleData)

			local props = {}
			for _, component in system.initializers do
				component.Step(component, 0, particleData, props)
			end

			for _, component in system.updaters do
				component.Step(component, system.stepDelta - 1, particleData, props)
			end

			table.insert(propsTable, { particle = particleData.particle, props = props })
		end
	end

	return propsTable
end

local serialConenction: RBXScriptConnection?

function Stepper.Run()
	if serialConenction ~= nil then
		return
	end

	serialConenction = RunService.Heartbeat:Connect(function(dt)
		for _, system: Types.ParticleSystem in Scheduler.SerialSystems do
            if system.isPaused or not system.isEnabled then
                system.stepDelta = 0
                continue
            end

			system.runningTime += dt

			local currentstep = math.floor(system.runningTime / Config.frametime)
			local delta = currentstep - system.currentStep

			if delta > 0 then
				system.stepDelta = delta
				system.currentStep = currentstep
				continue
			end

			system.stepDelta = 0
		end

		local propsTable = StepSerial()

		local bulkMoveToParts = {}
		local bulkMoveToCFrames = {}

		for _, entry in propsTable do
			for k, v in entry.props do
				if k == "CFrame" then
					table.insert(bulkMoveToParts, entry.particle)
					table.insert(bulkMoveToCFrames, v)
					continue
				end

				entry.particle[k] = v
			end
		end

		workspace:BulkMoveTo(bulkMoveToParts, bulkMoveToCFrames)

		if #Scheduler.SerialParticles == 0 then
			if serialConenction then
				serialConenction:Disconnect()
				serialConenction = nil
			end
		end
	end)
end

return Stepper
