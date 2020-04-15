-- Meta Data Service
-- MrAsync
-- February 14, 2020

--[[

    Allows server and clients to easily retrieve MetaData

]]


local MetaDataService = {Client = {}}

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService

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
    return self.Server:GetMetaData(itemId, player)
end


--Returns the indexed itemId
--Returns MetaData array if found
--Otherwise return nil
function MetaDataService:GetMetaData(itemId, player)
    --If itemId parameter is a valid itemId, return indexed table
    if (type(itemId) == "number") then
        return DataNodes[itemId]
    else
        local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
        local placementObject = pseudoPlayer:GetPlacementObject(itemId)

        return DataNodes[placementObject.ItemId]
    end
end


function MetaDataService:Start()
    local rawNodes = MetaDataContainer.Indexable:GetChildren()
    
    for _, rawNode in pairs(rawNodes) do
        local metaData = require(rawNode)

        DataNodes[metaData.ItemId] = metaData
    end
end


function MetaDataService:Init()
    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Data
    MetaDataContainer = ReplicatedStorage:WaitForChild("MetaData")

    --//Locals
    DataNodes = {}

end

return MetaDataService