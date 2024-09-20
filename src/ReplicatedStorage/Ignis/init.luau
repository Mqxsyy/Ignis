local lists = script.Lists
local enums = script.Enums

local Ignis = table.freeze({
	ParticleSystem = require(script:WaitForChild("ParticleSystem")),
	Components = require(lists:WaitForChild("ComponentList")),
	Renderers = require(lists:WaitForChild("RendererList")),
	Enums = {
		ComponentMethods = require(enums:WaitForChild("Methods")),
	},
})

return Ignis
