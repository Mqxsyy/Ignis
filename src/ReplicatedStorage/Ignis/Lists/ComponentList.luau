local root = script.Parent.Parent

local Position = require(root.Components:WaitForChild("Position"))

return table.freeze({
	Position = Position.New(),
})
