local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Component = require(ReplicatedStorage.Ignis.Components._Component)

local ParticleSystem = {}

export type ParticleSystem = {
	_components: { _Component.Component },

	AddComponent: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
}

local function AddComponent(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._components, component)
	return self
end

function ParticleSystem.New(): ParticleSystem
	return {
		_components = {},

		AddComponent = AddComponent,
	}
end

return ParticleSystem
