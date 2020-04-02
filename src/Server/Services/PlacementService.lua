-- Placement Service
-- MrAsync
-- March 29, 2020



local PlacementService = {Client = {}}


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
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

    local placementObject = PlacementClass.new(itemId, localPosition, playerObject)

    return true
end


function PlacementService:Start()
	
end


function PlacementService:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    MetaDataService = self.Services.MetaDataService
    PlacementClass = self.Modules.Classes.PlacementClass

    --//Locals	
    
end


return PlacementService