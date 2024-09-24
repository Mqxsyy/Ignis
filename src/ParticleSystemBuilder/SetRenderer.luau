local NodeType = require(script.Parent.Parent.Enums.NodeType)
local Renderer = require(script.Parent.Parent.Nodes.Renderer)
local Mesh = require(script.Parent.Parent.Nodes.Renderers.Mesh)

type RendererNode = "Mesh"

type Renderers = {
	[RendererNode]: (props: { unknown }) -> Renderer.Renderer,
}

local renderers: Renderers = {
	Mesh = Mesh,
}

return function(renderer: RendererNode)
	return function(props: { unknown })
		local node = renderers[renderer](props)
		node.nodeType = NodeType.Render

		return node
	end
end
