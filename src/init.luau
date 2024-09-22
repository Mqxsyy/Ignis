local lists = script.Lists
local enums = script.Enums

local Ignis = table.freeze({
	ParticleSystem = require(script.ParticleSystem),
	Components = require(lists.ComponentList),
	Renderers = require(lists.RendererList),
	Enums = {
		ComponentMethods = require(enums.Methods),
	},
})

return Ignis
