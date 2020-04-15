-- Traffic Controller
-- MrAsync
-- April 4, 2020


--[[

    Handles the mapping of placed roads and the creation of AI vehicles

    Methods
        private void SpawnVehicle()
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

local vehicles
local roadIndex
local spawnCount
local randomObject

local SPEED = 0.06
local POLICE_SPEED = 0.1


--//Returns a road model randomly picked from all adjacent roads
local function GetAdjacentRoads()
    --Update building index, pick random building, localize position and base
    roadIndex = RoadContainer:GetChildren()
    local buildingIndex = BuildingContainer:GetChildren()
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


local function UpdateVehicles()
    spawnCount = spawnCount + 1
        
    --If spawnCount is above threshold, spawn vehicle
    if (spawnCount >= 50) then
        spawnCount = 1

        --Grab adjacentRoad
        local baseBuilding, startingRoad = GetAdjacentRoads()
        if (not baseBuilding or not startingRoad) then return end

        --Create vehicle path with more than 5 nodes
        local vehiclePath = RoadApi:GeneratePath(startingRoad)

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
        vehicleModel:SetPrimaryPartCFrame(CFrame.new(baseBuilding.PrimaryPart.Position, vehiclePath[1].PrimaryPart.Position))
        vehicleModel.Parent = PlotObject.Vehicles
        sound.Parent = vehicleModel.PrimaryPart
        sound:Play()

        --Add vehicle to index
        vehicles[vehicleModel] = {
            CurrentRoad = 1,
            Path = vehiclePath
        }
    end

    --Move all vehicles
    for vehicleModel, info in pairs(vehicles) do
        local vehiclePath = info.Path
        local road = vehiclePath[info.CurrentRoad]

        --If reached the end of path, destroy vehicle
        if (not road) then 
            vehicles[vehicleModel] = nil
            vehicleModel:Destroy()
        else
            --If vehicle is close to next road, update counter
            if ((vehicleModel.PrimaryPart.Position - road.PrimaryPart.Position).magnitude <= 2) then
                vehicles[vehicleModel].CurrentRoad = vehicles[vehicleModel].CurrentRoad + 1
            end

            --If vehicle is a police car, update every 10 frames
            --Woot woot it's the sound of da police
            if (vehicleModel.Name == "Police" and (spawnCount % 10) == 0) then
                vehicleModel.Lights.Red.SurfaceLight.Enabled = not vehicleModel.Lights.Red.SurfaceLight.Enabled
                vehicleModel.Lights.Blue.SurfaceLight.Enabled = not vehicleModel.Lights.Blue.SurfaceLight.Enabled
            end

            --Lerp from current position to CurrentRoadPosition facing the nextRoadPosition
            local nextRoadPosition = vehiclePath[math.clamp(info.CurrentRoad + 1, 1, #vehiclePath)].PrimaryPart.Position
            vehicleModel:SetPrimaryPartCFrame(vehicleModel.PrimaryPart.CFrame:Lerp(
                CFrame.new(road.PrimaryPart.Position, nextRoadPosition),
                SPEED
            ))
        end
    end
end


function TrafficController:Start()
    --Start spawning vehicles once plot is fully loaded
    PlacementService.OnPlotLoadComplete:Connect(function()
    --    RunService:BindToRenderStep("VehicleMovement", 3, UpdateVehicles)
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

    vehicles = {}
    spawnCount = 1;
    roadIndex = RoadContainer:GetChildren()
    randomObject = Random.new(os.time())

end


return TrafficController