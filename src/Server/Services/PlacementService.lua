-- Placement Service
-- MrAsync
-- June 27, 2020



local PlacementService = {Client = {}}

--//Api
local SnapApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
local PlayerService
local ItemService

--//Classes
local BuildingClass

--//Controllers

--//Locals


--//Handles incoming request for placing objects
function PlacementService.Client:RequestItemPlacement(player, plate, itemId, rawVector, orientation)
    if (not orientation or (orientation and not typeof(orientation) == "number")) then return end
    if (not rawVector or (rawVector and not typeof(rawVector) == "Vector3")) then return end
    if (not itemId or (itemId and not typeof(itemId) == "number")) then return end
    if (not plate or (plate and not plate:IsA("BasePart"))) then return end
    if (not player) then return end

    -- Localize pseudoPlayer
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)
    local modelSize = ItemService:GetItemSize(itemId)

    -- Sterilization
    if (not pseudoPlayer) then return end
    if (not itemMetaData) then return end
    if (not plate:IsDescendantOf(pseudoPlayer.Plot.Object.Plates)) then return end
    if (SnapApi:IsColliding(pseudoPlayer.Plot.Object, rawVector, orientation, modelSize)) then return end

    local worldCFrame, objectCFrame = SnapApi:SnapVector(pseudoPlayer.Plot.Object, plate, modelSize, rawVector, orientation)
    
    -- Validate player cash
    if (pseudoPlayer.Cash:Get() >= itemMetaData.Cost) then
        pseudoPlayer.Cash:Update(function(currentValue)
            return currentValue - itemMetaData.Cost
        end)

        -- Create new building Object
        local buildingObject = BuildingClass.new(pseudoPlayer, itemId, worldCFrame, objectCFrame)
        pseudoPlayer.Plot:AddBuildingObject(buildingObject)

        print("Purchasing!")
    else
        print("You ain't got no money!")
    end
end


function PlacementService:Init()
    --//Api
    SnapApi = self.Shared.Api.SnapApi
    
    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService
    ItemService = self.Services.ItemService
    
    --//Classes
    BuildingClass = self.Modules.Classes.Building
    
    --//Controllers
    
    --//Locals
    
end


return PlacementService