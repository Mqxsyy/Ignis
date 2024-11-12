type Props = {
	rate: number?,
}

local DEFAULT_RATE = 10

return function(currentStep: number, stepDelta: number, props: Props): number
	local rate = props.rate or DEFAULT_RATE
	local spawnAmount = 0

	for i = 0, stepDelta - 1 do
		local step = currentStep - i

		if step % rate == 0 then
			spawnAmount += 1
		end
	end

	return spawnAmount
end
