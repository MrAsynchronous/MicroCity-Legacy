-- Placement Service
-- MrAsync
-- June 27, 2020



local PlacementService = {Client = {}}

--//Api
local SnapApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService
local ItemService

--//Classes
local BuildingClass

--//Controllers

--//Locals


function PlacementService.Client:RequestItemPlacement(player, plate, itemId, rawVector, orientation)
    if (not orientation or (orientation and not typeof(orientation) == "number")) then return end
    if (not rawVector or (rawVector and not typeof(rawVector) == "Vector3")) then return end
    if (not itemId or (itemId and not typeof(itemId) == "number")) then return end
    if (not plate or (plate and not plate:IsA("BasePart"))) then return end
    if (not player) then return end

    -- Localize pseudoPlayer
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return end

    -- Validate plate
    if (not plate:IsDescendantOf(pseudoPlayer.Plot.Object.Plates)) then return end

    -- Grab modelSize, and reset cframe in bounds
    local modelSize = ItemService:GetItemSize(itemId)
    local worldCFrame, objectCFrame = SnapApi:SnapVector(pseudoPlayer.Plot.Object, plate, modelSize, rawVector, orientation)

    -- Create new building Object
    local buildingObject = BuildingClass.new(pseudoPlayer, itemId, worldCFrame, objectCFrame)
    pseudoPlayer.Plot:AddBuildingObject(buildingObject)
end


function PlacementService:Start()
	
end


function PlacementService:Init()
    --//Api
    SnapApi = self.Shared.Api.SnapApi
    
    --//Services
    PlayerService = self.Services.PlayerService
    ItemService = self.Services.ItemService
    
    --//Classes
    BuildingClass = self.Modules.Classes.Building
    
    --//Controllers
    
    --//Locals
    
end


return PlacementService