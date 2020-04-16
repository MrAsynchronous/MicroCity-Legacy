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

--//Controllers

--//Classes
local QueueClass

--//Locals
local PlotObject
local SoundLibrary
local RoadContainer
local TrafficVehicles
local EmergencyVehicles
local BuildingContainer

local spawnedVehicles
local roadIndex
local frameCount
local randomObject

local SPEED = 0.06
local POLICE_SPEED = 0.1


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

    --1/25 chance of a police car
    local sound
    local vehicleModel
    if (randomObject:NextInteger(1, 25) == 13) then
        sound = SoundLibrary.Siren:Clone()
        vehicleModel = EmergencyVehicles.Police:Clone()
    else
        sound = SoundLibrary.Car:Clone()
        vehicleModel = TrafficVehicles[randomObject:NextInteger(1, #TrafficVehicles)]:Clone()
    end

    --Parent vehicle, sound, play sound
    vehicleModel.PrimaryPart.CFrame = (CFrame.new(homeBuilding.PrimaryPart.Position, baseRoad.PrimaryPart.Position))
    vehicleModel.Parent = PlotObject.Vehicles
    sound.Parent = vehicleModel.PrimaryPart
    sound:Play()

    --Return previousRoad, currentRoad
    return {
        Model = vehicleModel,
        PreviousRoad = baseRoad,
        CurrentRoad = baseRoad,
        NextRoad = RoadApi:GetNextRoad(baseRoad, baseRoad)
    }
end


local function UpdateVehicles()
    frameCount = frameCount + 1

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
        local vehicle = vehicleTable.Model
        local previousRoad = vehicleTable.PreviousRoad
        local currentRoad = vehicleTable.CurrentRoad
        local nextRoad = vehicleTable.NextRoad

        --If vehicle is close to currentRoad, get next road, continue to 
        if ((vehicle.PrimaryPart.Position - nextRoad.PrimaryPart.Position).magnitude <= 1) then
            --If nextRoad does not exist, destroy vehicle            
            if (not nextRoad) then
                vehicle:Destroy()

                table.remove(spawnedVehicles, i)
            end

            --Find new road, update current and next roads
            local newNext = RoadApi:GetNextRoad(currentRoad, nextRoad)
            previousRoad = currentRoad
            currentRoad = nextRoad
            nextRoad = newNext
        end

        --Lazy police lights
        if (vehicle.Name == "Police" and (frameCount % 10) == 0) then
            vehicle.Lights.Red.SurfaceLight.Enabled = not vehicle.Lights.Red.SurfaceLight.Enabled
            vehicle.Lights.Blue.SurfaceLight.Enabled = not vehicle.Lights.Blue.SurfaceLight.Enabled
        end

        --Construct and set CFrame
        vehicle.PrimaryPart.CFrame = vehicle.PrimaryPart.CFrame:Lerp(
            CFrame.new(currentRoad.PrimaryPart.Position, nextRoad.PrimaryPart.Position),
            SPEED
        )

        vehicleTable[i] = {
            Model = vehicle,
            PreviousRoad = previousRoad,
            CurrentRoad = currentRoad,
            NextRoad = nextRoad
        }
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

    --//Controllers

    --//Classes
    QueueClass = self.Shared.Queue

    --//Locals
    PlotObject = self.Player:WaitForChild("PlotObject").Value
    SoundLibrary = self.Player.PlayerScripts:WaitForChild("SoundLibrary")
    RoadContainer = PlotObject.Placements.Roads
    BuildingContainer = PlotObject.Placements.Buildings

    TrafficVehicles = ReplicatedStorage.Items.Vehicles.Traffic:GetChildren()
    EmergencyVehicles = ReplicatedStorage.Items.Vehicles.Emergency
    
    frameCount = 0
    spawnedVehicles = {}
    roadIndex = RoadContainer:GetChildren()
    randomObject = Random.new(os.time())

end


return TrafficController