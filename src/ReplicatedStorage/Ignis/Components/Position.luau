local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Component = require(script.Parent._Component)
local Methods = require(ReplicatedStorage.Ignis.Enums.Methods)
local ParticleData = require(ReplicatedStorage.Ignis.ParticleData)

local Position = {}

export type Position = {
	_p: {
		method: Methods.Methods,
		position: Vector3,

		Update: (self: Position, step: number, particleData: ParticleData.ParticleData, props: {}) -> (),
	},

	Method: (self: Position, method: Methods.Methods) -> Position,
	Position: (self: Position, position: Vector3) -> Position,
}

local function SetMethod(self: Position, method: Methods.Methods)
	self._p.method = method
	return self
end

local function SetPosition(self: Position, position: Vector3)
	self._p.position = position
	return self
end

local function Update(self: Position, step: number, particleData: ParticleData.ParticleData, props: {})
	if self._p.method == Methods.SET then
		props["Position"] = self._p.position
	elseif self._p.method == Methods.UPDATE then
		if props["Position"] then
			props["Position"] += self._p.position * step
		else
			props["Position"] = particleData.particle.Position + self._p.position * step
		end
	end
end

function Position.New(): Position
	local self: Position = {
		_p = {
			method = Methods.SET,
			position = Vector3.zero,

			Update = Update,
		},

		Method = SetMethod,
		Position = SetPosition,
	}

	return self
end

return Position
