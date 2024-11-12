local Enums = require(script.Parent.Parent.Parent.Enums)
local Types = require(script.Parent.Parent.Parent.Types)

type Props = {
	method: Enums.Method?,
	position: Vector3?,
}

local DEFAULT_METHOD = Enums.Method.SET
local DEFAULT_POSITION = Vector3.zero

return function(steps: number, particleData: Types.ParticleData, props: Props)
	local method = props.method or DEFAULT_METHOD
	local position = props.position or DEFAULT_POSITION

	if method == Enums.Method.SET then
		props["Position"] = position
	elseif method == Enums.Method.UPDATE then
		if props["Position"] then
			props["Position"] += position * steps
		else
			props["Position"] = particleData.props.position + position * steps
		end
	end
end
