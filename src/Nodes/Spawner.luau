local Node = require(script.Parent.Node)

export type Spawner = Node.Node & {
	CalculateSpawnCountOnFrame: (self: any, step: number) -> number,
}

return nil
