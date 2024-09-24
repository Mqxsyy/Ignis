local Component = require(script.Parent.Parent.Component)
local Method = require(script.Parent.Parent.Parent.Enums.Method)
local ParticleData = require(script.Parent.Parent.Parent.ParticleData)

type Props = {
	method: Method.Method?,
	position: Vector3?,
}

type Self = Component.Component & {
	method: Method.Method,
	position: Vector3,
}

local DEFAULT_METHOD = Method.SET
local DEFAULT_POSITION = Vector3.zero

return function(props: Props): Self
	return {
		method = props.method or DEFAULT_METHOD,
		position = props.position or DEFAULT_POSITION,

		Step = function(self: Self, steps: number, particleData: ParticleData.ParticleData, props: {})
			if self.method == Method.SET then
				props["Position"] = self.position
			elseif self.method == Method.UPDATE then
				if props["Position"] then
					props["Position"] += self.position * steps
				else
					props["Position"] = particleData.particle.Position + self.position * steps
				end
			end
		end,
	}
end
