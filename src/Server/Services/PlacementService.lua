-- Placement Service
-- MrAsync
-- June 3, 2020


--[[

    Handle the placement related communications between the server and the client

    Methods
        private boolean IsColliding(PseudoPlayer pseudoPlayer, CFrame objectCFrame, int itemId, Array itemMetaData)
        public client RequestRoadPlacement(Player player, Array<Vector3> rawPositions)
        public client RequestPlacement(Player player, int itemId, Vector3 rawVector, int rotation)

]]


local PlacementService = {Client = {}}

--//Api
local CompressionApi
local SnapApi
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


--//Returns boolean reflecting state of object vs collision
local function IsColliding(pseudoPlayer, objectCFrame, itemMetaData)
    local worldCFrame = pseudoPlayer.Plot.Object.Main.CFrame:ToWorldSpace(objectCFrame)

    --If object is a road, use the road network verificatio
    if (itemMetaData.Type == "Road") then
        local gridSpace = pseudoPlayer.Plot:WorldToGridSpace(worldCFrame)

        if (pseudoPlayer.Plot.RoadNetwork[gridSpace.Z][gridSpace.X] ~= nil) then
            return true
        else
            return false
        end
    end
end


--//Handles the selling process
function PlacementService.Client:RequestSell(player, buildingGuid)
    if (not player) then return end
    if (not buildingGuid or (buildingGuid and type(buildingGuid) ~= "string")) then return end

    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local buildingObject = pseudoPlayer.Plot:GetBuildingObject(buildingGuid)
        if (not buildingObject) then return { wasSuccess = false } end

    --Remove road from index
    pseudoPlayer.Plot:RemoveBuildingObject(buildingObject)

    --If building object is a road, remove it from network
    if (buildingObject.MetaData.Type == "Road") then
        pseudoPlayer.Plot:RemoveRoadFromNetwork(buildingObject)
    end

    --Totally remove buildingObject
    buildingObject:Destroy()
end


--//Handles the placement of roads
function PlacementService.Client:RequestRoadPlacement(player, roadPositions)
    if (not player) then return end
    if (not roadPositions or (roadPositions and type(roadPositions) ~= "table")) then return end

    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(100)
    local level1MetaData = itemMetaData.Upgrades[1]

    --Iterate through all vectors
    for _, rawVector in pairs(roadPositions) do
        if (pseudoPlayer.Cash:Get(0) >= level1MetaData.Cost) then
            local temporaryModel = ReplicatedStorage.Items.Buildings:FindFirstChild("100:1"):Clone()
            local adjustedPosition = SnapApi:SnapVector(pseudoPlayer.Plot.Object, temporaryModel, rawVector, 0) 
            
            --Return false if item is colliding
            if (IsColliding(pseudoPlayer, adjustedPosition, itemMetaData)) then
                continue
            end

            --Construict buildingObject and cache it
            local buildingObject = BuildingClass.new(pseudoPlayer, 100, adjustedPosition)
            pseudoPlayer.Plot:AddBuildingObject(buildingObject)

            pseudoPlayer.Plot:AddRoadToNetwork(buildingObject)
        end
    end
end


--//Handles the placement of non road buildings
function PlacementService.Client:RequestPlacement(player, itemId, rawVector, rotation)
    if (not player) then return end
    if (not itemId or (itemId and type(itemId) ~= "number"))then return end
    if (not rawVector or (rawVector and type(rawVector) ~= "Vector3")) then return end
    if (not rotation or (rotation and type(rotation) ~= "number")) then return end

    local pseudoPlayer = PlayerService:GetPseudoPlayerFromPlayer(player)
    local itemMetaData = MetaDataService:GetMetaData(itemId)
        if (not itemMetaData) then 
            return {wasSuccess = false}
        end

    local level1MetaData = itemMetaData.Upgrades[1]

    if (pseudoPlayer.Cash:Get(0) >= level1MetaData.Cost) then
        local temporaryModel = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":1"):Clone()
        local adjustedPosition = SnapApi:SnapVector(pseudoPlayer.Plot.Object, temporaryModel, rawVector, rotation)

        --Construct buildingObject and cache it
        local buildingObject = BuildingClass.new(pseudoPlayer, itemId, adjustedPosition)
        pseudoPlayer.Plot:AddBuildingObject(buildingObject)
    end
end


function PlacementService:Start()
    Notices = MetaDataService:GetMetaData("Notices")
end


function PlacementService:Init()
    --//Api
    CompressionApi = self.Shared.Api.CompressionApi
    SnapApi = self.Shared.Api.SnapApi
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