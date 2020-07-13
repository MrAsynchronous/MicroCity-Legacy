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
local ItemDataIndex
local DataIndex

--//Returns MetaData / Data for a given ItemId / StringId
function MetaDataService:GetMetaData(itemId, player)
    if (not typeof(itemId) == "number" or not typeof(itemId) == "string") then return end

    local metaData = (typeof(itemId) == "number" and ItemDataIndex[itemId] or DataIndex[itemId])
    if (not metaData) then return false end

    return (player and metaData or TableUtil.Copy(metaData))
end


--//Client facing method for Server:GetMetaData
function MetaDataService.Client:RequestMetaData(player, itemId)
    return self.Server:GetMetaData(itemId, player)
end


function MetaDataService:Init()
	--//Api
    TableUtil = self.Shared.TableUtil

    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    ItemDataIndex = {}
    DataIndex = {}    

    --Populate ItemData + Data Index's
	for _, dataModule in pairs(ReplicatedFirst.MetaData:GetChildren()) do
        if (dataModule:IsA("ModuleScript")) then
            DataIndex[dataModule.Name] = require(dataModule)
        else
            for _, itemDataModule in pairs(dataModule:GetChildren()) do
                local metaData = require(itemDataModule)

                ItemDataIndex[metaData.Id] = metaData
            end
        end
    end    
end


return MetaDataService