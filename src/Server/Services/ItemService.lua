-- Item Service
-- MrAsync
-- July 6, 2020



local ItemService = {Client = {}}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Classes

--//Controllers

--//Locals

function ItemService:GetItemSize(itemId)
    local object = ReplicatedStorage.Items:FindFirstChild(itemId)
    if (not object) then return false end

    return object.PrimaryPart.Size
end

function ItemService:Init()
	--//Api
    
    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return ItemService