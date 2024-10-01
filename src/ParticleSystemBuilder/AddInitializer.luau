local Enums = require(script.Parent.Parent.Enums)
local Position = require(script.Parent.Parent.Nodes.Mixed.Position)
local Types = require(script.Parent.Parent.Types)

type InitializerNode = "Position"

type Initializers = {
	[InitializerNode]: (props: { unknown }) -> Types.Component,
}

local initializers: Initializers = {
	Position = Position,
}

return function(initializer: InitializerNode)
	return function(props: { unknown })
		local node = initializers[initializer](props)
		node.nodeType = Enums.NodeType.Initialize

		return node
	end
end
