local Method = table.freeze({
	SET = 1,
	UPDATE = 2,
})

export type Method = typeof(Method)

return Method
