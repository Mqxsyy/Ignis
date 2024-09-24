local Renderer = require(script.Parent.Parent.Renderer)

export type Props = {}

export type Self = Renderer.Renderer

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
