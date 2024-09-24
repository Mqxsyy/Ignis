local Spawner = require(script.Parent.Parent.Spawner)

type Props = {
	rate: number?,
}

type Self = Spawner.Spawner & {
	rate: number,
}

local DEFAULT_RATE = 10

return function(props: Props): Self
	return {
		rate = props.rate or DEFAULT_RATE,

		CalculateSpawnCountOnFrame = function(self: Self, step: number)
			return step % self.rate == 0 and 1 or 0
		end,
	}
end
