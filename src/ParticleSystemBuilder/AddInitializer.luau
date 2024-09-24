local NodeType = require(script.Parent.Parent.Enums.NodeType)
local Component = require(script.Parent.Parent.Nodes.Component)
local Position = require(script.Parent.Parent.Nodes.Mixed.Position)

type InitializerNode = "Position"

type Initializers = {
	[InitializerNode]: (props: { unknown }) -> Component.Component,
}

local initializers: Initializers = {
	Position = Position,
}

return function(initializer: InitializerNode)
	return function(props: { unknown })
		local node = initializers[initializer](props)
		node.nodeType = NodeType.Initialize

		return node
	end
end
