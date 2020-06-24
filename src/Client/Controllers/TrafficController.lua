-- Traffic Controller
-- MrAsync
-- June 15, 2020



local TrafficController = {}

--//Api
local NumberUtil
local PIDController

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot
local MaxVehicles

local PlotSize
local TotalRows
local PlotCFrame
local PlotCorner
local RandomObject
local VehicleIndex
local BuildingIndex

local lastSpawn = 0
local spawnDelay = 1

local Vehicles = {}
local RoadIndex = {}
local RoadNetwork = {}


local function WorldToGridSpace(worldSpace)
    local cornerSpace = PlotCorner:ToObjectSpace(worldSpace)

    return Vector3.new(
        NumberUtil.Round(math.abs(cornerSpace.X / 2) + 1),
        0,
        NumberUtil.Round(math.abs(cornerSpace.Z / 2) + 1)
    )
end

local function GetRoadsAdjacentToHome(homeBuilding)
    local validRoads = {}

    local buildingSize = homeBuilding.PrimaryPart.Size
    local buildingPosition = homeBuilding.PrimaryPart.Position
    local roadRegion = Region3.new((buildingPosition - (buildingSize / 2)) - Vector3.new(1, 0, 1), (buildingPosition + (buildingSize / 2)) + Vector3.new(1, 0, 1))
    local roads = workspace:FindPartsInRegion3WithWhiteList(roadRegion, Plot.Placements.Road:GetChildren(), math.huge)

    for _, road in pairs(roads) do
        local model = road:FindFirstAncestorOfClass("Model")
        if (not model) then return end

        if (not table.find(validRoads, model)) then
            table.insert(validRoads, model)
        end
    end

    return validRoads
end

local function GetAdjacentRoads(gridSpace)
    local validRoads = {}
    local rawRoads = {
        RoadNetwork[math.clamp(gridSpace.Z - 1, 1, TotalRows)][gridSpace.X],
        RoadNetwork[math.clamp(gridSpace.Z + 1, 1, TotalRows)][gridSpace.X],
        RoadNetwork[gridSpace.Z][math.clamp(gridSpace.X - 1, 1, TotalRows)],
        RoadNetwork[gridSpace.Z][math.clamp(gridSpace.X + 1, 1, TotalRows)]
    }

    for index, road in pairs(rawRoads) do
        if (road) then
            table.insert(validRoads, road)
        end
    end

    return validRoads
end

local function AddRoadToNetwork(buildingObject)
    while (buildingObject.PrimaryPart == nil) do wait() end

    local gridSpace = WorldToGridSpace(buildingObject.PrimaryPart.CFrame)
    RoadIndex[buildingObject.Name] = gridSpace

    RoadNetwork[gridSpace.Z][gridSpace.X] = buildingObject
end

local function RemoveRoadFromNetwork(buildingObject)
    local gridSpace = RoadIndex[buildingObject.Name]
    if (not gridSpace) then return end

    RoadNetwork[gridSpace.Z][gridSpace.X] = nil
    RoadIndex[buildingObject.Name] = nil
end

local function RoadInit()
    BuildingIndex = Plot.Placements.Building:GetChildren()
    PlotSize = Plot.Main.Size
    PlotCFrame = Plot.Main.CFrame
    PlotCorner = PlotCFrame * CFrame.new(PlotSize / 2) + Vector3.new(1, 0, 1)

    --Calculate all possible rows, setup RoadNetwork
    TotalRows = PlotSize.Z / 2
    for i=1, TotalRows do
        table.insert(RoadNetwork, {})
    end

    --Make connections to listen for road and building changes
    Plot.Placements.Road.ChildAdded:Connect(function(newChild)
        AddRoadToNetwork(newChild)
    end)
    Plot.Placements.Road.ChildRemoved:Connect(function(oldChild)
        RemoveRoadFromNetwork(oldChild)
    end)

    Plot.Placements.Building.ChildAdded:Connect(function(newChild)
        BuildingIndex = Plot.Placements.Building:GetChildren()

        MaxVehicles = math.ceil(#Plot.Placements.Building:GetChildren() * 1.25)
    end)
    Plot.Placements.Building.ChildRemoved:Connect(function()
        BuildingIndex = Plot.Placements.Building:GetChildren()

        MaxVehicles = math.ceil(#Plot.Placements.Building:GetChildren() * 1.25)
    end)

    --Populate the index
    for _, buildingObject in pairs(Plot.Placements.Road:GetChildren()) do
        AddRoadToNetwork(buildingObject)
    end
end

local function GetNextRoad(nextRoad, currentRoad)
    local gridSpace = WorldToGridSpace(nextRoad.PrimaryPart.CFrame)
    local adjacentRoads = GetAdjacentRoads(gridSpace)

    for index, road in pairs(adjacentRoads) do
        if (road == nextRoad or road == currentRoad) then
            table.remove(adjacentRoads, index)
        end
    end

    return adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end

local function SpawnVehicle()
    RandomObject = Random.new(tick())

    local homeBuilding = BuildingIndex[RandomObject:NextInteger(1, #BuildingIndex)]
    if (not homeBuilding) then return end

    local adjacentRoads = GetRoadsAdjacentToHome(homeBuilding)
    local homeRoad = adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
    if (not homeRoad) then return end

    local vehicle =  VehicleIndex[RandomObject:NextInteger(1, #VehicleIndex)]:Clone()
    if (not vehicle) then return end

    local vehicleTable = {
        Model = vehicle,
        Home = homeBuilding,
        CurrentRoad = homeBuilding,
        NextRoad = homeRoad
    }

    vehicle.Parent = Plot.Vehicles
    vehicle:SetPrimaryPartCFrame(homeBuilding.PrimaryPart.CFrame + ((homeBuilding.PrimaryPart.Size / 2) * homeBuilding.PrimaryPart.CFrame.LookVector))

    table.insert(Vehicles, vehicleTable)
end

function TrafficController:Start()
    VehicleIndex = ReplicatedStorage.Items.Vehicles:GetChildren()

    --Yield for both the plot object, and for the plot to load, setup roads
    Plot = (PlayerService:RequestPlot() or PlayerService.RequestPlot:Wait())
    MaxVehicles = math.ceil(#Plot.Placements.Building:GetChildren() * 1.25)

    local PlotLoaded = (PlayerService:PlotLoaded() or PlayerService.PlotHasLoaded:Wait())
    RoadInit()

    lastSpawn = tick()
    RunService.Stepped:Connect(function()
        --Debounce for spawning vehicles
        if (tick() - lastSpawn >= spawnDelay and (#Vehicles < MaxVehicles)) then
            lastSpawn = tick() + spawnDelay

            SpawnVehicle()
        end

        for index, vehicleTable in pairs(Vehicles) do
            local currentPosition = vehicleTable.Model.PrimaryPart.CFrame
            
            if ((currentPosition.Position - vehicleTable.CurrentRoad.PrimaryPart.Position).magnitude <= 1.5) then
                local newNext = GetNextRoad(vehicleTable.NextRoad, vehicleTable.CurrentRoad)
                
                vehicleTable.CurrentRoad = vehicleTable.NextRoad
                vehicleTable.NextRoad = newNext
            end

            Vehicles[index] = vehicleTable

            local rightVector = vehicleTable.Model.PrimaryPart.CFrame.RightVector
            vehicleTable.Model.PrimaryPart.CFrame = vehicleTable.Model.PrimaryPart.CFrame:Lerp(
                CFrame.new(vehicleTable.CurrentRoad.PrimaryPart.Position + (rightVector / 2), (vehicleTable.NextRoad or vehicleTable.CurrentRoad).PrimaryPart.Position + (vehicleTable.CurrentRoad.PrimaryPart.CFrame.LookVector * 2) + (rightVector / 2)),
                0.05
            )

            if (not vehicleTable.NextRoad or not vehicleTable.CurrentRoad) then
                vehicleTable.Model:Destroy()
                table.remove(Vehicles, index)
            end
        end
    end)
end



function TrafficController:Init()
    --//Api
    NumberUtil = self.Shared.NumberUtil
    
    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes
    
    --//Controllers
    PIDController = self.Controllers.PID

    --//Locals
    
end


return TrafficController