-- Placement Service
-- MrAsync
-- March 29, 2020


--[[

    Handles the Server-wise placement operations

    Methods
        public boolean SellPlacement(Player player, String guid)
        public boolean MovePlacement(Player player, String guid, CFrame localPosition)
        public boolean, object UpgradePlacement(Player player, String guid)
        public boolean PlaceObject(Player player, int itemId, CFrame localPosition)
        public void LoadPlacements(PlayerObject playerObject)

]]


local PlacementService = {Client = {}}


--//Api
local RoadIntersection
local CFrameSerializer
local TableUtil

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
    local playerObject = PlayerService:GetPlayerObject(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)

    if (ShoppingService:PurchaseItem(playerObject, itemId)) then
        --Construct a new placementObject, hash into playerObject.Placements
        local placementObject = PlacementClass.new(itemId, localPosition, playerObject)
        playerObject:SetPlacementObject(placementObject)

        --Edit player population
        playerObject:Set("Population", playerObject:Get("Population") + itemMetaData.Population)

        return true, placementObject.PlacedObject, "buildingPurchaseSuccess"
    else
        return false, nil, "noFundsError"
    end
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

    return true, "buildingSoldSuccess"
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

            return true, placementObject.PlacedObject, "buildingUpgradeSuccess"
        else
            return false, nil, "noFundsError"
        end
    else
        return false, nil, "maxLevelError"
    end
end


--//Moves a PlacementObject to the new localPosition
function PlacementService:MovePlacement(player, guid, localPosition)
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)

    --//Move object and update PlacementMap
    placementObject:Move(localPosition)
    playerObject:SetPlacementObject(placementObject)

    return true, "buildingMovedSuccess"
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
function PlacementService.Client:PlaceObject(...)
    return self.Server:PlaceObject(...)
end

function PlacementService.Client:MovePlacement(...)
    return self.Server:MovePlacement(...)
end

function PlacementService.Client:SellPlacement(...)
    return self.Server:SellPlacement(...)
end

function PlacementService.Client:UpgradePlacement(...)
    return self.Server:UpgradePlacement(...)
end


function PlacementService:Init()
    --//Api
    RoadIntersection = self.Modules.RoadIntersections
    CFrameSerializer = self.Shared.CFrameSerializer
    TableUtil = self.Shared.TableUtil

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