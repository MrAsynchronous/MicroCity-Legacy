-- Placement Service
-- MrAsync
-- March 29, 2020


--[[

    Handles the Server-wise placement operations

    Methods
        public boolean RequestSell(Player player, String guid)
        public boolean RequestMove(Player player, String guid, CFrame localPosition)
        public boolean, object RequestUpgrade(Player player, String guid)
        public boolean RequestPlacement(Player player, int itemId, CFrame localPosition)

]]


local PlacementService = {Client = {}}


--//Api
local GameSettings
local RoadApi
local Notices

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
local ShoppingService
local PlayerService

--//Controllers

--//Classes
local PlacementClass

--//Locals


--[[
    Server methods
]]
--//Places the requested object
function PlacementService:PlaceObject(player, itemId, localPosition)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player) 
    local itemMetaData = MetaDataService:GetMetaData(itemId)
    local levelOneMetaData = itemMetaData.Upgrades[1]

    --If player can afford placement, subtract cost
    if (pseudoPlayer[(levelOneMetaData.CostType or "Cash")]:Get(0) >= levelOneMetaData.Cost) then
        pseudoPlayer[(levelOneMetaData.CostType or "Cash")]:Update(function(currentValue)
            return currentValue - levelOneMetaData.Cost
        end)

        --Construct a new placementObject, hash into playerObject.Placements
        local placementObject = PlacementClass.new(pseudoPlayer, itemId, localPosition)
        pseudoPlayer:SetPlacementObject(placementObject)

        --Add population of new building to players population
        local levelMetaData = placementObject:GetLevelMetaData()
        pseudoPlayer.Population:Increment(levelMetaData.Population)

        -- --Adjacent road detection
        -- local adjacentRoads = RoadApi:GetAdjacentRoads(pseudoPlayer.PlotObject.Object, placementObject.PlacedObject, placementObject.PlacedObject)
        -- if (#adjacentRoads == 4) then
        --     placementObject:Upgrade(5)
        -- elseif (#adjacentRoads == 3) then
        --     placementObject:Upgrade(4)
        -- elseif (#adjacentRoads == 2) then
        --     placementObject:Upgrade(3)
        -- end

        -- for _, road in pairs(adjacentRoads) do
        --     local subPlacementObject = pseudoPlayer:GetPlacementObject(road.Name)
        --     local subAdjacentRoads = RoadApi:GetAdjacentRoads(pseudoPlayer.PlotObject.Object, road, road)

        --     if (#subAdjacentRoads == 4) then
        --         subPlacementObject:Upgrade(5)
        --     elseif (#subAdjacentRoads == 3) then
        --         subPlacementObject:Upgrade(4)
        --     elseif (#subAdjacentRoads == 2) then
        --         subPlacementObject:Upgrade(3)
        --     end
        -- end

        return {
            wasSuccess = true,
            placedObject = placementObject.PlacedObject,
            worldPosition = placementObject.WorldPosition,
            noticeObject = Notices.buildingPurchaseSuccess
        }
    else
        return {
            wasSuccess = false,
            noticeObject = Notices.noFundsError
        }
    end

    return {}
end


--//Sells a PlacedObject
function PlacementService:SellPlacement(player, guid)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    local placementObject = pseudoPlayer:GetPlacementObject(guid)
    
    local populationToRemove = 0
    local refundTypes = {}
    
    --Iterate to current level, increment populationToRemove
    for i = 1, placementObject.Level do
        local levelMetaData = placementObject:GetLevelMetaData(i)
        populationToRemove = populationToRemove + (levelMetaData.Population or 0)
        
        --Genius
        refundTypes[levelMetaData.CostType] = (refundTypes[levelMetaData.CostType] or 0) + levelMetaData.Cost
    end

    --Update Population
    pseudoPlayer.Population:Update(function(currentValue)
        return currentValue - populationToRemove
    end)

    --Update currencies to reflect change
    for costType, cost in pairs(refundTypes) do
        pseudoPlayer[costType]:Update(function(currentValue)
            return currentValue + (cost * GameSettings.BuildingBuybackRate)
        end)
    end

    --Remove placementObject from PlacementMap
    pseudoPlayer:RemovePlacementObject(guid)

    return {
        wasSuccess = true,
        noticeObject = Notices.buildingSoldSuccess
    }
end


--//Upgrades a placedObject
function PlacementService:UpgradePlacement(player, guid)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    local placementObject = pseudoPlayer:GetPlacementObject(guid)

    --Verify if object can be upgraded
    if (placementObject:CanUpgrade()) then
        local levelMetaData = placementObject:GetLevelMetaData(placementObject.Level + 1)
        
        --If player can afford upgrade, subtract cost
        if (pseudoPlayer[(levelMetaData.CostType or "Cash")]:Get(0) >= levelMetaData.Cost) then
            pseudoPlayer[(levelMetaData.CostType or "Cash")]:Update(function(currentValue)
                return currentValue - levelMetaData.Cost
            end)

            --Update population
            pseudoPlayer.Population:Update(function(currentValue)
                return currentValue + levelMetaData.Population
            end)

            --Upgrade and UpdatePlacementObject
            local currentObjectSpace = placementObject:Encode()

            placementObject:Upgrade()
            pseudoPlayer:UpdatePlacementObject(placementObject, currentObjectSpace)

            return {
                wasSuccess = true,
                newObject = placementObject.PlacedObject,
                worldPosition = placementObject.WorldPosition,
                noticeObject = Notices.buildingUpgradeSuccess
            }
        else
            return {
                wasSuccess = false,
                noticeObject = Notices.noFundsError
            }
        end
    else
        return {
            wasSuccess = false,
            noticeObject = Notices.maxLevelError
        }
    end

    return {}
end


--//Moves a PlacementObject to the new localPosition
function PlacementService:MovePlacement(player, guid, localPosition)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    local placementObject = pseudoPlayer:GetPlacementObject(guid)
    local currentObjectSpace = placementObject:Encode()

    --//Move object and update PlacementMap
    placementObject:Move(localPosition)
    pseudoPlayer:UpdatePlacementObject(placementObject, currentObjectSpace)

    return {
        wasSuccess = true,
        object = placementObject.PlacedObject,
        noticeObject = Notices.buildingMoveSuccess
    }
end


--[[
    Client-exposed methods
]]
function PlacementService.Client:RequestPlacement(...)
    return self.Server:PlaceObject(...)
end

function PlacementService.Client:RequestMove(...)
    return self.Server:MovePlacement(...)
end

function PlacementService.Client:RequestSell(...)
    return self.Server:SellPlacement(...)
end

function PlacementService.Client:RequestUpgrade(...)
    return self.Server:UpgradePlacement(...)
end


function PlacementService:Init()
    --//Api
    GameSettings = require(ReplicatedStorage.MetaData.Settings)
    RoadApi = self.Shared.API.RoadApi
    Notices = require(ReplicatedStorage.MetaData.Notices)

    --//Services
    MetaDataService = self.Services.MetaDataService
    ShoppingService = self.Services.ShoppingService
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    PlacementClass = self.Modules.Classes.PlacementClass

    --//Locals	
 
end


return PlacementService