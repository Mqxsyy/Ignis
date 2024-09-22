local Methods = table.freeze({
	SET = 1,
	UPDATE = 2,
})

export type Methods = typeof(Methods)

return Methods
