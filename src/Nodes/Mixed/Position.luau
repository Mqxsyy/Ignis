local Enums = require(script.Parent.Parent.Parent.Enums)
local Types = require(script.Parent.Parent.Parent.Types)

type Props = {
	method: Enums.Method?,
	position: Vector3?,
}

type Self = Types.Component & {
	method: Enums.Method,
	position: Vector3,
}

local DEFAULT_METHOD = Enums.Method.SET
local DEFAULT_POSITION = Vector3.zero

return function(props: Props): Self
	return {
		method = props.method or DEFAULT_METHOD,
		position = props.position or DEFAULT_POSITION,

		Step = function(self: Self, steps: number, particleData: Types.ParticleData, props: {})
			if self.method == Enums.Method.SET then
				props["Position"] = self.position
			elseif self.method == Enums.Method.UPDATE then
				if props["Position"] then
					props["Position"] += self.position * steps
				else
					props["Position"] = particleData.particle.Position + self.position * steps
				end
			end
		end,
	}
end
