local root = script.Parent.Parent

local Mesh = require(root.Renderers:WaitForChild("Mesh"))

return table.freeze({
	Mesh = Mesh.New(),
})
