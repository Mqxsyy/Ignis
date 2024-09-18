local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ComponentMethods = require(ReplicatedStorage.Ignis.Enums.ComponentMethods)

local Position = {}
Position.__index = Position

export type Position = typeof(setmetatable({}, Position))

function Position.New()
	local self = setmetatable({}, Position)

	self._method = ComponentMethods.SET
	self._position = Vector3.zero

	return self
end

function Position.Method(self: Position, method: ComponentMethods.ComponentMethods)
	self._method = method
	return self
end

function Position.Position(self: Position, position: Vector3)
	self._position = Vector3
	return self
end

function Position._Update(self: Position, particle: BasePart, props: {})
	if self.method == ComponentMethods.SET then
		props["Position"] = self.position
	elseif self.method == ComponentMethods.UPDATE then
		if props["Position"] then
			props["Position"] += self.position
		else
			props["Position"] = particle.Position + self.position
		end
	end
end

return Position
