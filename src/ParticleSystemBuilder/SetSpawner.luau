local NodeType = require(script.Parent.Parent.Enums.NodeType)
local Spawner = require(script.Parent.Parent.Nodes.Spawner)
local Constant = require(script.Parent.Parent.Nodes.Spawners.Constant)

type SpawnerNode = "Constant"

type Spawners = {
	[SpawnerNode]: (props: { unknown }) -> Spawner.Spawner,
}

local spawners: Spawners = {
	Constant = Constant,
}

return function(spawner: SpawnerNode)
	return function(props: { unknown })
		local node = spawners[spawner](props)
		node.nodeType = NodeType.Spawn

		return node
	end
end
