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
        public void LoadPlacements(PlayerObject playerObject)

]]


local PlacementService = {Client = {}}


--//Api
local RoadIntersection
local CFrameSerializer
local TableUtil
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
local SELL_EXCHANGE_RATE = 40 --percent


--[[
    Server methods
]]
--//Places the requested object
function PlacementService:PlaceObject(player, itemId, localPosition)
    print("Server: ", "client has invoked a placement request")
    print("Server: ", "handling request!")

    local playerObject = PlayerService:GetPlayerObject(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)

    if (ShoppingService:PurchaseItem(playerObject, itemId)) then
        --Construct a new placementObject, hash into playerObject.Placements
        local placementObject = PlacementClass.new(itemId, localPosition, playerObject)
        playerObject:SetPlacementObject(placementObject)

        --Edit player population
    --    playerObject:Set("Population", playerObject:Get("Population") + itemMetaData.Population)

        return {
            wasSuccess = true,
            placedObject = placementObject.PlacedObject,
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
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)
    local itemMetaData = MetaDataService:GetMetaData(placementObject.ItemId)

    --Update population to reflect change
    --Takes into account current level
    playerObject:SetData("Population", playerObject:GetData("Population") - (itemMetaData.Population * placementObject.Level))

    --Remove placementObject from PlacementMap
    --Remove MetaTable
    playerObject:RemovePlacementObject(guid)
    placementObject:Remove()

    --Calculate return 
    local discountedProfit = itemMetaData.Cost * SELL_EXCHANGE_RATE
    ShoppingService:SellItem(playerObject, discountedProfit)

    return {
        wasSuccess = true,
        noticeObject = Notices.buildingSoldSuccess
    }
end


--//Upgrades a placedObject
function PlacementService:UpgradePlacement(player, guid)
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)
    local itemMetaData = MetaDataService:GetMetaData(placementObject.ItemId)

    --Verify if object can be upgraded
    if (placementObject:CanUpgrade()) then
        --Localize upgrade cost
        local upgradeData = itemMetaData.Upgrades[placementObject.Level]
        
        --If player can afford upgrade
        if (ShoppingService:CanAffordCost(playerObject, upgradeData.Cost)) then
            placementObject:Upgrade()

            return {
                wasSuccess = true,
                newObject = placementObject.PlacedObject,
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
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)

    --//Move object and update PlacementMap
    placementObject:Move(localPosition)
    playerObject:SetPlacementObject(placementObject)

    return {
        wasSuccess = true,
        object = placementObject.PlacedObject,
        noticeObject = Notices.buildingMoveSuccess
    }
end


--//Handle the loading of the players placements
function PlacementService:LoadPlacements(playerObject)
    local placementData = playerObject.PlacementStore:Get({})
    local objectsLoaded = 0

    --Iterate through all the placements
	for guid, encodedData in pairs(placementData) do
		local decodedData = TableUtil.DecodeJSON(encodedData)

		--Create new placementObject and add it to index
		playerObject:SetPlacementObject(PlacementClass.new(
			decodedData.ItemId,
			CFrameSerializer:DecodeCFrame(decodedData.CFrame),
			playerObject,
			decodedData
        ))
 
        --Load objects in triplets
        objectsLoaded = objectsLoaded + 1;
        if (objectsLoaded % 3 == 0) then
            wait()
        end
    end
    
    --Tell client that their plot has been loaded
    self:FireClientEvent("OnPlotLoadComplete", playerObject.Player)
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
    RoadIntersection = self.Modules.RoadIntersections
    CFrameSerializer = self.Shared.CFrameSerializer
    TableUtil = self.Shared.TableUtil
    Notices = require(ReplicatedStorage.MetaData.Notices)

    --//Services
    MetaDataService = self.Services.MetaDataService
    ShoppingService = self.Services.ShoppingService
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    PlacementClass = self.Modules.Classes.PlacementClass

    --//Locals	
    SELL_EXCHANGE_RATE = SELL_EXCHANGE_RATE / 100

    self:RegisterClientEvent("OnPlotLoadComplete")
end


return PlacementService