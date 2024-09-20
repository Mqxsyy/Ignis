local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RendererList = require(ReplicatedStorage.Ignis.Lists.RendererList)
local _Component = require(ReplicatedStorage.Ignis.Components._Component)
local _Renderer = require(ReplicatedStorage.Ignis.Renderers._Renderer)
local ObjectPool = require(script.Parent.ObjectPool)

local ParticleSystem = {}

export type ParticleSystem = {
	_p: {
		components: { _Component.Component },
		objectPool: ObjectPool.ObjectPool,

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

local function SetRenderer(self: ParticleSystem, renderer: _Renderer.Renderer)
	ObjectPool.Cleanup(self._p.objectPool)
	ObjectPool.OverrideObject(self._p.objectPool, renderer._p.particle)
end

local function Step(self: ParticleSystem, amount: number?)
	amount = amount or 1
end

-- local function Start(self: ParticleSystem) end
--
-- local function Stop(self: ParticleSystem) end

function ParticleSystem.New(): ParticleSystem
	local self: ParticleSystem = {
		_p = {
			components = {},
			objectPool = ObjectPool.New(RendererList.Mesh._p.particle),

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
