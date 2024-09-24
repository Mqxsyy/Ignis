local NodeType = table.freeze({
	Spawn = 1,
	Initialize = 2,
	Update = 3,
	Render = 4,
})

export type NodeType = typeof(NodeType)

return NodeType
