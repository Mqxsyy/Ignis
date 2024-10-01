local Enums = require(script.Parent.Parent.Enums)
local Mesh = require(script.Parent.Parent.Nodes.Renderers.Mesh)
local Types = require(script.Parent.Parent.Types)

type RendererNode = "Mesh"

type Renderers = {
	[RendererNode]: (props: { unknown }) -> Types.Renderer,
}

local renderers: Renderers = {
	Mesh = Mesh,
}

return function(renderer: RendererNode)
	return function(props: { unknown })
		local node = renderers[renderer](props)
		node.nodeType = Enums.NodeType.Render

		return node
	end
end
