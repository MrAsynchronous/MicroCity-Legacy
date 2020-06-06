-- Meta Data Service
-- MrAsync
-- June 2, 2020


--[[

    Handles the fulfillment of MetaData requests

]]


local MetaDataService = {Client = {}}

--//Api
local LogApi

--//Services
local ServerStorage = game:GetService("ServerStorage")

--//Classes

--//Controllers

--//Locals
local MetaDataContainer
local IndexableMetaData = {}
local MiscMetaData = {}


--//Returns MetaData for a give itemId
function MetaDataService:GetMetaData(itemId)
    LogApi:Log("Server | MetaDataService | GetMetaData: Fulfilling MetaData request for " .. itemId)

    if (typeof(itemId) == "string") then
        return MiscMetaData[itemId]
    elseif (typeof(itemId) == "number") then
        return IndexableMetaData[itemId]
    else
        LogApi:LogWarn("Server | MetaDataService | GetMetaData: Invalid itemId provided!  Expected type 'string' or 'number' but received type '" .. typeof(itemId) .. "' instead!")
    end
end


--//Client patch
function MetaDataService.Client:RequestMetaData(player, itemId)
    LogApi:Log("Server | MetaDataService | RequestMetaData: Received request for MetaData")

    return self.Server:GetMetaData(itemId)
end


function MetaDataService:Start()
    LogApi:Log("Server | MetaDataService | Startup: Indexing and requiring MetaData modules")

    for _, metaDataModule in pairs(MetaDataContainer:GetChildren()) do
        if (not metaDataModule:IsA("ModuleScript")) then continue end

        MiscMetaData[metaDataModule.Name] = require(metaDataModule)
    end

    for _, metaDataModule in pairs(MetaDataContainer.Indexable:GetChildren()) do
        local requiredModule = require(metaDataModule)
        IndexableMetaData[requiredModule.ItemId] = requiredModule
    end

    LogApi:Log("Server | MetaDataService | Startup: Completed")
end


function MetaDataService:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes

    --//Controllers

    --//Locals
    MetaDataContainer = ServerStorage:WaitForChild("MetaData")
end


return MetaDataService