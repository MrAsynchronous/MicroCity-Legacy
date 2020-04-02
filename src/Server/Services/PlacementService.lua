-- Placement Service
-- MrAsync
-- March 29, 2020



local PlacementService = {Client = {}}


--//Api

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
    Client-exposed methods
]]

function PlacementService.Client:PlaceObject(...)
    return self.Server:PlaceObject(...)
end

--[[
    Server methods
]]
function PlacementService:PlaceObject(player, itemId, localPosition)
    local playerObject = PlayerService:GetPlayerObject(player)

    if (ShoppingService:PurchaseItem(playerObject, itemId)) then
        --Construct a new placementObject, hash into playerObject.Placements
        local placementObject = PlacementClass.new(itemId, localPosition, playerObject)
        playerObject.Placements[placementObject.Guid] = placementObject
    end

    return true
end


function PlacementService:Start()
	
end


function PlacementService:Init()
    --//Api

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