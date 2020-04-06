-- Placement Service
-- MrAsync
-- March 29, 2020


--[[

    Handles the Server-wise placement operations

    Methods
        public boolean SellObject(Player player, String guid)
        public boolean MoveObject(Player player, String guid, CFrame localPosition)
        public boolean PlaceObject(Player player, int itemId, CFrame localPosition)
        public void LoadPlacements(PlayerObject playerObject)

]]


local PlacementService = {Client = {}}


--//Api
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
--//Sells a PlacedObject
function PlacementService:SellObject(player, guid)
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)

    --If placementObject doesn't exits, return false
    if (not placementObject) then 
        return false, "The requested PlacementObject does not exist!"
    end

    local itemMetaData = MetaDataService:GetMetaData(placementObject.ItemId)
    local discountedProfit = itemMetaData.Cost * SELL_EXCHANGE_RATE
    ShoppingService:SellItem(playerObject, discountedProfit)

    --Remove placementObject from PlacementMap
    --Remove MetaTable
    playerObject:RemovePlacementObject(guid)
    placementObject:Remove()

    return true
end

--//Moves a PlacementObject to the new localPosition
function PlacementService:MoveObject(player, guid, localPosition)
    local playerObject = PlayerService:GetPlayerObject(player)
    local placementObject = playerObject:GetPlacementObject(guid)

    --If placementObject doesn't exist, return false
    if (not placementObject) then
        return false, "The requested PlacementObject does not exist!"
    end

    --//Move object and update PlacementMap
    placementObject:MoveTo(localPosition)
    playerObject:SetPlacementObject(placementObject)

    return true
end


--//Places the requested object
function PlacementService:PlaceObject(player, itemId, localPosition)
    local playerObject = PlayerService:GetPlayerObject(player)

    if (ShoppingService:PurchaseItem(playerObject, itemId)) then
        --Construct a new placementObject, hash into playerObject.Placements
        local placementObject = PlacementClass.new(itemId, localPosition, playerObject)
        playerObject:SetPlacementObject(placementObject)

        --Auto intersection
        local adjacentRegion3 = Region3.new(
            
        )


    end

    return true
end


--//Handle the loading of the players placements
function PlacementService:LoadPlacements(playerObject)
	local placementData = playerObject.PlacementStore:Get({})

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
        
        wait()
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

function PlacementService.Client:MoveObject(...)
    return self.Server:MoveObject(...)
end

function PlacementService.Client:SellObject(...)
    return self.Server:SellObject(...)
end

function PlacementService.Client:UpgradeObject(...)

end


function PlacementService:Init()
    --//Api
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