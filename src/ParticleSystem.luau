local _Component = require(script.Parent.Components._Component)
local RendererList = require(script.Parent.Lists.RendererList)
local ObjectPool = require(script.Parent.ObjectPool)
local ParticleData = require(script.Parent.ParticleData)
local _Renderer = require(script.Parent.Renderers._Renderer)

local ParticleSystem = {}

export type ParticleSystem = {
	_p: {
		components: { _Component.Component },
		objectPool: ObjectPool.ObjectPool,
		particleData: { ParticleData.ParticleData },

		Step: (self: ParticleSystem, amount: number?) -> (),
	},

	AddComponent: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
	SetRenderer: (self: ParticleSystem, renderer: _Renderer.Renderer) -> ParticleSystem,
	-- Start: (self: ParticleSystem) -> (),
	-- Stop: (self: ParticleSystem) -> (),
}

local function AddComponent(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._p.components, component)
	return self
end

local function SetRenderer(self: ParticleSystem, renderer: _Renderer.Renderer): ParticleSystem
	ObjectPool.Cleanup(self._p.objectPool)
	ObjectPool.OverrideObject(self._p.objectPool, renderer._p.particle)
	return self
end

local function Step(self: ParticleSystem, _amount: number?)
	local amount = _amount or 1

	for i = 0, amount - 1 do
		local particleData: ParticleData.ParticleData = {
			particle = ObjectPool.GetItem(self._p.objectPool),
		}

		table.insert(self._p.particleData, particleData)

		local props = {}
		for _, component in self._p.components do
			component._p.Update(component, i, particleData, props)
		end

		for k, v in props do
			particleData.particle[k] = v
		end
	end
end

-- local function Start(self: ParticleSystem) end
--
-- local function Stop(self: ParticleSystem) end

function ParticleSystem.New(): ParticleSystem
	local self: ParticleSystem = {
		_p = {
			components = {},
			objectPool = ObjectPool.New(RendererList.Mesh._p.particle),
			particleData = {},

			Step = Step,
		},

		AddComponent = AddComponent,
		SetRenderer = SetRenderer,

		-- Start = Start,
		-- Stop = Stop,
	}

	return self
end

return ParticleSystem
