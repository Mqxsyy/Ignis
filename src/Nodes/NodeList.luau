local NodeList = {
	list = {},
}

local function AddNodes(nodes: { ModuleScript })
	for _, node in nodes do
		NodeList.list[node.Name] = require(node)
	end
end

function NodeList.Init()
	AddNodes(script.Parent.Spawners:GetChildren())
	AddNodes(script.Parent.Mixed:GetChildren())
	AddNodes(script.Parent.Renderers:GetChildren())
end

function NodeList.GetNode(name: string)
	local node = NodeList.list[name]
	if not node then
		error("Node not found!")
	end

	return node
end

return NodeList
