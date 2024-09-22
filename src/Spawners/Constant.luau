local Constant = {}

export type Constant = {
	_p: {
		rate: number,

		CalculateSpawnCountOnFrame: (self: Constant, step: number) -> number,
	},

	Rate: (self: Constant, rate: number) -> Constant,
}

local function Rate(self: Constant, rate: number)
	self._p.rate = rate
	return self
end

local function CalculateSpawnCountOnFrame(self: Constant, step: number)
	return step % self._p.rate == 0 and 1 or 0
end

function Constant.New(): Constant
	local self: Constant = {
		_p = {
			rate = 6,

			CalculateSpawnCountOnFrame = CalculateSpawnCountOnFrame,
		},

		Rate = Rate,
	}

	return self
end

return Constant
