local ObjectPool = {}

type ObjectPool = {
	object: Instance,
	activeItems: { Instance },
	standbyItems: { Instance },
}

function ObjectPool.New(object: Instance): ObjectPool
	return {
		object = object,
		activeItems = {},
		standbyItems = {},
	}
end

function ObjectPool.GetItem(objectPool: ObjectPool)
	local size = #objectPool.standbyItems

	if size == 0 then
		return objectPool.object:Clone()
	end

	local instance = table.remove(objectPool.standbyItems, #objectPool.standbyItems)
	table.insert(objectPool.activeItems, instance)

	return instance
end

function ObjectPool.RemoveItem(objectPool: ObjectPool, instance: Instance)
	local index = table.find(objectPool, instance)
	if index == nil then
		error(`${instance} not found in ObjectPool!`)
	end

	table.remove(objectPool.activeItems, index)
	table.insert(objectPool.standbyItems, instance)
end

return ObjectPool
