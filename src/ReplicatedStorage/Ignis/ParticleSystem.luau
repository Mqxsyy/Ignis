local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Component = require(ReplicatedStorage.Ignis.Components._Component)

local ParticleSystem = {}

export type ParticleSystem = {
	_p: {
		components: { _Component.Component },
	},

	AddComponent: (self: ParticleSystem, component: _Component.Component) -> ParticleSystem,
}

local function AddComponent(self: ParticleSystem, component: _Component.Component): ParticleSystem
	table.insert(self._p.components, component)
	return self
end

function ParticleSystem.New(): ParticleSystem
	local self: ParticleSystem = {
		_p = {
			components = {},
		},

		AddComponent = AddComponent,
	}

	return self
end

return ParticleSystem
