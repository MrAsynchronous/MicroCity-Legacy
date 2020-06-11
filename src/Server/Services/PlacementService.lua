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
local Workspace = game:GetService("Workspace")

local MetaDataService
local PlayerService

--//Classes
local BuildingClass

--//Controllers

--//Local
local Notices


local function IsColliding(pseudoPlayer, objectCFrame, itemSize)
    local worldCFrame = pseudoPlayer.Plot.Object.Main.CFrame:ToWorldSpace(objectCFrame)

    local collisionRegion = Region3.new(worldCFrame.Position - (itemSize / 2), worldCFrame.Position + (itemSize / 2))
    local parts = Workspace:FindPartsInRegion3WithIgnoreList(collisionRegion, {})

    for _, part in pairs(parts) do
        if (part:IsDescendantOf(pseudoPlayer.Plot.Object.Placements)) then
            return true
        end
    end
    return false
end


function PlacementService.Client:RequestRoadPlacement(player, roadPositions)
    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(100)
    local level1MetaData = itemMetaData.Upgrades[1]

    for _, position in pairs(roadPositions) do
        if (pseudoPlayer.Cash:Get(0) >= level1MetaData.Cost) then
        --    if (IsColliding(pseudoPlayer, position, ReplicatedStorage.Items.Buildings:FindFirstChild("100:1").PrimaryPart.Size)) then continue end
    
            local buildingObject = BuildingClass.new(pseudoPlayer, 100, position)
            pseudoPlayer.Plot:AddBuildingObject(buildingObject)
        end        
    end
end


function PlacementService.Client:RequestPlacement(player, itemId, objectPosition)
    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)
    local level1MetaData = itemMetaData.Upgrades[1]

    if (pseudoPlayer.Cash:Get(0) >= level1MetaData.Cost) then
        if (IsColliding(pseudoPlayer, objectPosition, ReplicatedStorage.Items.Buildings:FindFirstChild(itemId).PrimaryPart.Size)) then return end

        local buildingObject = BuildingClass.new(pseudoPlayer, itemId, objectPosition)
        pseudoPlayer.Plot:AddBuildingObject(buildingObject)
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