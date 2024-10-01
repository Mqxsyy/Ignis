local Enums = table.freeze({
	Method = {
		SET = 1,
		UPDATE = 2,
	},
	NodeType = {
		Spawn = 1,
		Initialize = 2,
		Update = 3,
		Render = 4,
	},
})

export type Method = typeof(Enums.Method)
export type NodeType = typeof(Enums.NodeType)

return Enums
