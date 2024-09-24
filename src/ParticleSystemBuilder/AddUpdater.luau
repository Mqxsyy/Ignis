local NodeType = require(script.Parent.Parent.Enums.NodeType)
local Component = require(script.Parent.Parent.Nodes.Component)
local Position = require(script.Parent.Parent.Nodes.Mixed.Position)

type UpdaterNode = "Position"

type Updaters = {
	[UpdaterNode]: (props: { unknown }) -> Component.Component,
}

local updaters: Updaters = {
	Position = Position,
}

return function(updater: UpdaterNode)
	return function(props: { unknown })
		local node = updaters[updater](props)
		node.nodeType = NodeType.Update

		return node
	end
end
