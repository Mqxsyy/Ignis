local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Component = require(script.Parent._Component)
local Methods = require(ReplicatedStorage.Ignis.Enums.Methods)

local Position = {}

export type Position = {
	_p: {
		method: Methods.Methods,
		position: Vector3,

		Update: (self: any, particle: BasePart, props: {}) -> (),
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

local function Update(self: Position, particle: BasePart, props: {})
	if self._p.method == Methods.SET then
		props["Position"] = self._p.position
	elseif self._p.method == Methods.UPDATE then
		if props["Position"] then
			props["Position"] += self._p.position
		else
			props["Position"] = particle.Position + self._p.position
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
