-- Traffic Controller
-- MrAsync
-- April 4, 2020


--[[

    Handles the mapping of placed roads and the creation of AI vehicles

    Methods
        private void UpdateVehicles()
        private Table SpawnVehicle(Object homeBuilding, Object baseRoad)
        private Object, Object GetAdjacentRoads(Table roadIndex, Table buildingIndex)
]]


local TrafficController = {}

--//Api
local RoadApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlacementService
local MetaDataService

--//Controllers

--//Classes
local QueueClass

--//Locals
local PlotObject
local TrafficVehicles

local spawnedVehicles
local frameCount
local randomObject

local TOLERANCE = 1.5

local BUS_SPEED = 0.04
local POLICE_SPEED = 0.1
local DEFAULT_SPEED = 0.06


--//Returns a road model randomly picked from all adjacent roads
local function GetAdjacentRoads(roadIndex, buildingIndex)
    --ick random building
    local baseBuilding = buildingIndex[randomObject:NextInteger(1, #buildingIndex)]
    if (not baseBuilding) then return end

    local basePosition = baseBuilding.PrimaryPart.Position
    local baseSize = baseBuilding.PrimaryPart.Size

    --Construct region3 and get adjacentParts
    local adjacentRegion = Region3.new(basePosition - (baseSize / 2) - Vector3.new(2, 2, 2), basePosition + (baseSize / 2) + Vector3.new(2, 2, 2))
    local adjacentParts = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, roadIndex, math.huge)
    local adjacentRoads = {}

    --Iterate through all adjacent parts
    for _, roadPart in pairs(adjacentParts) do
        --Localize model and model's posiiton
        local parentModel = roadPart:FindFirstAncestorOfClass("Model")

        --If road is not already in array, add it
        if (not table.find(adjacentRoads, parentModel)) then
            table.insert(adjacentRoads, parentModel)
        end
    end

    return baseBuilding, adjacentRoads[randomObject:NextInteger(1, #adjacentRoads)]
end


--//Spawns a vehicle at the homeBuilding position moving towards baseRoad
local function SpawnVehicle(roads, buildings)
    local homeBuilding, baseRoad = GetAdjacentRoads(roads, buildings)

    --Clone random vehicle, get vehicle MetaData
    local vehicleModel = TrafficVehicles[randomObject:NextInteger(1, #TrafficVehicles)]:Clone()
    local vehicleMetaData = MetaDataService:GetMetaData(tonumber(vehicleModel.Name))

    --Create sound
    local sound = Instance.new("Sound")
    sound.SoundId = vehicleMetaData.SoundId

    --Parent vehicle, sound, play sound
    vehicleModel.PrimaryPart.CFrame = (CFrame.new(homeBuilding.PrimaryPart.Position, baseRoad.PrimaryPart.Position))
    vehicleModel.Parent = PlotObject.Vehicles
    sound.Parent = vehicleModel.PrimaryPart

    --Only sometimes activate police siren
    if ((vehicleMetaData.Id == 1002 and (randomObject:NextInteger(1, 10) == 7)) or (vehicleMetaData.Id ~= 1002)) then
        sound:Play()
    end

    --Return previousRoad, currentRoad
    return {
        MetaData = vehicleMetaData,
        Model = vehicleModel,
        CurrentRoad = baseRoad,
        NextRoad = RoadApi:GetNextRoad(baseRoad, baseRoad)
    }
end


local function UpdateVehicles()
    frameCount = frameCount + 1

    --Update road and building index, calculate maximum vehicles
    local roads = PlotObject.Placements.Roads:GetChildren()
    local buildings = PlotObject.Placements.Buildings:GetChildren()
    local maxVehicles = #buildings * 2

    --If spawnFrame reached, and cars are able to be spawned, spawn a vehicle
    if ((frameCount >= 50) and (#spawnedVehicles < maxVehicles)) then
        frameCount = 0

        local vehicleTable = SpawnVehicle(roads, buildings)
        table.insert(spawnedVehicles, vehicleTable)
    end

    --Update all vehicles
    for i, vehicleTable in pairs(spawnedVehicles) do
        local metaData = vehicleTable.MetaData
        local vehicle = vehicleTable.Model
        local currentRoad = vehicleTable.CurrentRoad
        local nextRoad = vehicleTable.NextRoad

        --If vehicle is close to currentRoad, get next road, continue to 
        if ((vehicle.PrimaryPart.Position - currentRoad.PrimaryPart.Position).magnitude <= TOLERANCE) then
            --Find new road, update current and next roads
            local newNext = RoadApi:GetNextRoad(nextRoad, currentRoad)
            currentRoad = nextRoad
            nextRoad = newNext
        end

        --Lazy police lights
        if (metaData.ItemId == 1002 and (frameCount % 10) == 0) then
            vehicle.Lights.Red.SurfaceLight.Enabled = not vehicle.Lights.Red.SurfaceLight.Enabled
            vehicle.Lights.Blue.SurfaceLight.Enabled = not vehicle.Lights.Blue.SurfaceLight.Enabled
        end

        if (currentRoad and nextRoad) then
            --Construct and set CFrame
            vehicle.PrimaryPart.CFrame = vehicle.PrimaryPart.CFrame:Lerp(
                CFrame.new(currentRoad.PrimaryPart.Position, nextRoad.PrimaryPart.Position),
                metaData.Speed
            )
            
            --Re-construct table
            spawnedVehicles[i] = {
                MetaData = metaData,
                Model = vehicle,
                CurrentRoad = currentRoad,
                NextRoad = nextRoad
            }
        else
            vehicle:Destroy()
            table.remove(spawnedVehicles, i)
        end
    end
end


function TrafficController:Start()
    --Start spawning vehicles once plot is fully loaded
    PlacementService.OnPlotLoadComplete:Connect(function()
        RunService:BindToRenderStep("VehicleMovement", 3, UpdateVehicles)
    end)
end


function TrafficController:Init()
    --//Api
    RoadApi = self.Modules.API.RoadApi

    --//Services
    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService

    --//Controllers

    --//Classes
    QueueClass = self.Shared.Queue

    --//Locals
    PlotObject = self.Player:WaitForChild("PlotObject").Value
    TrafficVehicles = ReplicatedStorage.Items.Vehicles.Traffic:GetChildren()
    
    frameCount = 0
    spawnedVehicles = {}
    randomObject = Random.new(os.time())

end


return TrafficController