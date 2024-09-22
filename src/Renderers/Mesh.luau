local Mesh = {}

export type Mesh = {
	_p: {
		particle: MeshPart,
	},
}

function Mesh.New(): Mesh
	local particle = Instance.new("MeshPart")
	particle.Anchored = true
	particle.Size = Vector3.one
	particle.CanCollide = false
	particle.CanQuery = false
	particle.CanTouch = false

	local self: Mesh = {
		_p = {
			particle = particle,
		},
	}

	return self
end

return Mesh
