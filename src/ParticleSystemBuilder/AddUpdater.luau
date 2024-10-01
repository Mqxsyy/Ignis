local Enums = require(script.Parent.Parent.Enums)
local Position = require(script.Parent.Parent.Nodes.Mixed.Position)
local Types = require(script.Parent.Parent.Types)

type UpdaterNode = "Position"

type Updaters = {
	[UpdaterNode]: (props: { unknown }) -> Types.Component,
}

local updaters: Updaters = {
	Position = Position,
}

return function(updater: UpdaterNode)
	return function(props: { unknown })
		local node = updaters[updater](props)
		node.nodeType = Enums.NodeType.Update

		return node
	end
end
