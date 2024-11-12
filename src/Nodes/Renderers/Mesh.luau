local Types = require(script.Parent.Parent.Parent.Types)

return function(): BasePart
	local part = Instance.new("Part")
	part.Size = Vector3.one
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	return part
end
