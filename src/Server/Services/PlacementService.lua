-- Placement Service
-- MrAsync
-- June 3, 2020


--[[

    Handle the placement related communications between the server and the client

]]


local PlacementService = {Client = {}}

--//Api
local CompressionApi
local LogApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
local PlayerService

--//Classes
local BuildingClass

--//Controllers

--//Local
local Notices


function PlacementService.Client:RequestPlacement(player, itemId, objectPosition)
    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)
    local level1MetaData = itemMetaData.Upgrades[1]

    if (pseudoPlayer.Cash:Get(0) >= level1MetaData.Cost) then
        local buildingObject = BuildingClass.new(pseudoPlayer, itemId, objectPosition)
        
        pseudoPlayer.BuildingStore:Update(function(currentIndex)
            currentIndex[buildingObject.Guid] = buildingObject:Encode()

            return currentIndex
        end)
    else

    end
end


function PlacementService:Start()
    Notices = MetaDataService:GetMetaData("Notices")
end


function PlacementService:Init()
    --//Api
    CompressionApi = self.Shared.Api.CompressionApi
    LogApi = self.Shared.Api.LogApi

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Classes
    BuildingClass = self.Modules.Classes.Building

    --//Controllers

    --//Locals

end

return PlacementService