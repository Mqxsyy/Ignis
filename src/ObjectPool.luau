local Types = require(script.Parent.Types)

local ObjectPool = {}

ObjectPool.standbyLocation = CFrame.new(0, 10000, 0)

local function CreateFolder()
	local folder = Instance.new("Folder")
	folder.Name = "ObjectPool"
	folder.Parent = workspace

	return folder
end

function ObjectPool.New(object: BasePart): Types.ObjectPool
	object.CFrame = ObjectPool.standbyLocation

	local folder = CreateFolder()
	object.Parent = folder

	return {
		object = object,
		folder = folder,
		activeItems = {},
		standbyItems = {},
	}
end

function ObjectPool.OverrideObject(objectPool: Types.ObjectPool, object: BasePart)
	objectPool.object = object
	object.CFrame = ObjectPool.standbyLocation
	object.Parent = objectPool.folder
end

function ObjectPool.GetItem(objectPool: Types.ObjectPool)
	local size = #objectPool.standbyItems

	if size == 0 then
		local object = objectPool.object:Clone()
		object.Parent = objectPool.object.Parent

		table.insert(objectPool.activeItems, object)
		return object
	end

	local instance = table.remove(objectPool.standbyItems, #objectPool.standbyItems)
	table.insert(objectPool.activeItems, instance)

	return instance
end

function ObjectPool.RemoveItem(objectPool: Types.ObjectPool, instance: BasePart)
	local index = table.find(objectPool.activeItems, instance)
	if index == nil then
		error(`{instance} not found in ObjectPool!`)
	end

	table.remove(objectPool.activeItems, index)
	table.insert(objectPool.standbyItems, instance)
end

function ObjectPool.Cleanup(objectPool: Types.ObjectPool)
	for _, object in objectPool.activeItems do
		object:Destroy()
	end

	for _, object in objectPool.standbyItems do
		object:Destroy()
	end
end

return ObjectPool
