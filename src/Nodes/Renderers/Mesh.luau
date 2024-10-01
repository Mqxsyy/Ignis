local Types = require(script.Parent.Parent.Parent.Types)

export type Props = {}

export type Self = Types.Renderer

return function(props: Props): Self
	local particle = Instance.new("MeshPart")
	particle.Anchored = true
	particle.Size = Vector3.one
	particle.CanCollide = false
	particle.CanQuery = false
	particle.CanTouch = false

	return {
		particle = particle,
	}
end
