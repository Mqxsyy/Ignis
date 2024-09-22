local ObjectPool = {}

local standbyLocation = Vector3.new(0, 10000, 0)

export type ObjectPool = {
	object: BasePart,
	activeItems: { BasePart },
	standbyItems: { BasePart },
}

local function CreateFolder()
	local folder = Instance.new("Folder")
	folder.Name = "ObjectPool"
	folder.Parent = workspace

	return folder
end

function ObjectPool.New(object: BasePart): ObjectPool
	object.Position = standbyLocation
	object.Parent = CreateFolder()

	return {
		object = object,
		activeItems = {},
		standbyItems = {},
	}
end

function ObjectPool.OverrideObject(objectPool: ObjectPool, object: BasePart)
	objectPool.object = object
end

function ObjectPool.GetItem(objectPool: ObjectPool)
	local size = #objectPool.standbyItems

	if size == 0 then
		local object = objectPool.object:Clone()
		object.Parent = objectPool.object.Parent

		return object
	end

	local instance = table.remove(objectPool.standbyItems, #objectPool.standbyItems)
	table.insert(objectPool.activeItems, instance)

	return instance
end

function ObjectPool.RemoveItem(objectPool: ObjectPool, instance: BasePart)
	local index = table.find(objectPool, instance)
	if index == nil then
		error(`${instance} not found in ObjectPool!`)
	end

	table.remove(objectPool.activeItems, index)
	table.insert(objectPool.standbyItems, instance)
end

function ObjectPool.Cleanup(objectPool: ObjectPool)
	for _, object in objectPool.activeItems do
		object:Destroy()
	end

	for _, object in objectPool.standbyItems do
		object:Destroy()
	end
end

return ObjectPool
