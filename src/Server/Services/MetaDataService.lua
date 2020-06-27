-- Meta Data Service
-- MrAsync
-- June 26, 2020



local MetaDataService = {Client = {}}

--//Api
local TableUtil

--//Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--//Classes

--//Controllers

--//Locals
local ItemDataIndex = {}
local DataIndex = {}


--//Returns MetaData / Data for a given ItemId / StringId
function MetaDataService:GetMetaData(itemId, player)
    if (not typeof(itemId) == "number" or not typeof(itemId) == "string") then return end

    local data = (typeof(itemId == "number") and ItemDataIndex or DataIndex)[itemId]
    if (not data) then return false end

    return (player and data or TableUtil.Copy(data))
end


--//Client facing method for Server:GetMetaData
function MetaDataService.Client:RequestMetaData(player, itemId)
    return self.Server:GetMetaData(itemId, player)
end


function MetaDataService:Start()

    --Populate ItemData + Data Index's
	for _, dataModule in pairs(ReplicatedFirst.MetaData:GetChildren()) do
        if (dataModule:IsA("ModuleScript")) then
            DataIndex[dataModule.Name] = require(dataModule)
        else
            for _, itemDataModule in pairs(dataModule:GetChildren()) do
                ItemDataIndex[dataModule.Name] = require(itemDataModule)
            end
        end
    end
end


function MetaDataService:Init()
	--//Api
    TableUtil = self.Shared.TableUtil

    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return MetaDataService