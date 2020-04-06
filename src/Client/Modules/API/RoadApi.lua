-- RoadApi
-- MrAsync
-- April 3, 2020


--[[

    Used to convert localPositions of roads to cellPositions in roadIndex

    Methods
        public void AddRoad(LocalSpace localPosition)
        public void RemoveRoad(LocalSpace localPosition)

        private Vector2 GetCellFromCFrame(LocalSpace localPosition)
        private Array GetAdjacentRoads(Vector2 cellPosition)
]]


local RoadApi = {}

--//Api

--//Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementService
local MetaDataService

--//Controllers

--//Classes
local VehicleClass

--//Locals
local PlotObject
local RandomObject


--//Returns an array containing all adjacent roads
--//Region3 based
local function GetAdjacentRoads(currentRoad, lastRoad)
    local roadPosition = currentRoad.PrimaryPart.Position
    local adjacentRegion = Region3.new(roadPosition - Vector3.new(1, 1, 1), roadPosition + Vector3.new(1, 1, 1))
    local roadsInRegion = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, PlotObject.Placements.Roads:GetChildren(), math.huge)
    local modelsInRegion = {}

    --Iterate through all parts in Region3
    for i, part in pairs(roadsInRegion) do
        --Find model and localize positions
        local model = part:FindFirstAncestorOfClass("Model")
        local position = model.PrimaryPart.Position
        local positionDifference = roadPosition - position

        --Only add model if model is not currentRoad model is not already in index, and if it is directly adjacent with a tolerance of .25 studs
        if ((model ~= currentRoad) and (model ~= lastRoad) and (not table.find(modelsInRegion, model)) and (math.abs(positionDifference.X) <= 0.25 or math.abs(positionDifference.Z) <= 0.25)) then
            table.insert(modelsInRegion, model)
        end
    end

    return modelsInRegion
end


--//Returns a random road from the returned array of adjacent roads
--//Returns nil of no roads are found
local function GetNextRoad(currentRoad, lastRoad)
    local adjacentRoads = GetAdjacentRoads(currentRoad, lastRoad)
    return adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end


--//Generates a path for a vehicle to follow
--//Traces roads until roads end
local function GeneratePath(startingRoad)
    local currentRoad = GetNextRoad(startingRoad)
    local roads = {startingRoad, currentRoad}

    repeat
        currentRoad = GetNextRoad(currentRoad, roads[math.clamp(#roads - 1, 1, #roads)])
        table.insert(roads, currentRoad)

        if (currentRoad) then
            currentRoad.PrimaryPart.Transparency = 0
            currentRoad.PrimaryPart.Color = Color3.fromRGB(0, 255, 0)
        end

        wait()
    until (not currentRoad)
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (inputObject.KeyCode == Enum.KeyCode.B) then
            for _, road in pairs(PlotObject.Placements.Roads:GetChildren()) do
                road.PrimaryPart.Transparency = 1
                road.PrimaryPart.Color = Color3.fromRGB(0, 0, 0)
            end
        
            GeneratePath(PlotObject.Placements.Roads:GetChildren()[1])
        end
    end)
end


function RoadApi:Init()
    --//Api

    --//Services
    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService

    --//Controllers

    --//Classes

    --//Locals
    PlotObject = self.Player.PlayerPlot.Value
    RandomObject = Random.new(os.time())

end


return RoadApi