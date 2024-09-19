local Position = require(script.Parent.Components:WaitForChild("Position"))

return table.freeze({
	Position = Position.New(),
})
