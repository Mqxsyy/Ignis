local Ignis = table.freeze({
	ParticleSystem = require(script:WaitForChild("ParticleSystem")),
	Components = require(script:WaitForChild("ComponentList")),
	Enums = {
		ComponentMethods = require(script:WaitForChild("Enums"):WaitForChild("ComponentMethods")),
	},
})

return Ignis
