local Enums = require(script.Parent.Parent.Enums)
local Constant = require(script.Parent.Parent.Nodes.Spawners.Constant)
local Types = require(script.Parent.Parent.Types)

type SpawnerNode = "Constant"

type Spawners = {
	[SpawnerNode]: (props: { unknown }) -> Types.Spawner,
}

local spawners: Spawners = {
	Constant = Constant,
}

return function(spawner: SpawnerNode)
	return function(props: { unknown })
		local node = spawners[spawner](props)
		node.nodeType = Enums.NodeType.Spawn

		return node
	end
end
