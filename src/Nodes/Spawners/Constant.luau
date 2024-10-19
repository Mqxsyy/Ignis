local Types = require(script.Parent.Parent.Parent.Types)

type Props = {
	rate: number?,
}

type Self = Types.Spawner & {
	rate: number,
}

local DEFAULT_RATE = 10

return function(props: Props): Self
	return {
		rate = props.rate or DEFAULT_RATE,

		CalculateSpawnCountOnFrame = function(self: Self, currentStep: number, stepDelta: number)
			local spawnAmount = 0

			for i = 0, stepDelta - 1 do
				local step = currentStep - i

				if step % self.rate == 0 then
					spawnAmount += 1
				end
			end

			return spawnAmount
		end,
	}
end
