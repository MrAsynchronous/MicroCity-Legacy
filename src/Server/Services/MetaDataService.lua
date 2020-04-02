-- Meta Data Service
-- MrAsync
-- February 14, 2020

--[[

    Allows server and clients to easily retrieve MetaData

]]


local MetaDataService = {Client = {}}

--//Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--//Controllers

--//Classes

--//Data
local MetaDataContainer

--//Locals
local DataNodes
local PlayerData


--Client expoded method
--Calls server method
function MetaDataService.Client:GetMetaData(player, itemId)
    return self.Server:GetMetaData(itemId)
end


--Returns the indexed itemId
--Returns MetaData array if found
--Otherwise return nil
function MetaDataService:GetMetaData(itemId)
    return DataNodes[itemId]
end


function MetaDataService:Start()
    DataNodes = MetaDataContainer.Indexable:GetChildren()

    table.foreach(DataNodes, function(_, rawNode)
        rawNode = require(rawNode)

        DataNodes[rawNode.ItemId] = rawNode       
    end)
end

function MetaDataService:Init()
    --//Services

    --//Controllers

    --//Classes

    --//Data
    MetaDataContainer = ReplicatedFirst:WaitForChild("MetaData")

    --//Locals
    DataNodes = {}

end

return MetaDataService

--[[

--//Retrives MetaData bound to passed itemId
--//Returns Array if find is successful
--//Returns 0 if Array is not found
function MetaDataService:GetMetaData(itemId)
    --Wait until DataNodes are loaded
    while (#DataNodes <= 0 ) do wait() end

    --Iterate through all dataNodes
    for _, dataNode in pairs(DataNodes) do
        local MetaData = dataNode.MetaData

        --Don't throw exception because MetaData does not contain any MetaData
        if (#MetaData == 0) then
            continue
        end

        --Get the minimum metaDataId and maximum metaDataId
        local minId = MetaData[1].Id
        local maxId = MetaData[#MetaData].Id

        --Compare id's
        if (itemId == minId) then
            return MetaData[1]
        elseif (itemId == maxId) then
            return MetaData[#MetaData]
        elseif ((itemId > minId) or (itemId < maxId)) then
            for index, metaData in pairs(MetaData) do
                if (metaData.Id == itemId) then
                    return metaData
                end
            end
        end
    end

    return 0
end

]]