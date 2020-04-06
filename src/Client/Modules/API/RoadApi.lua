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
        
        --Only add model if model is not currentRoad model is not already in index, and if it is directly adjacent
        if ((model ~= currentRoad) and (model ~= lastRoad) and (not table.find(modelsInRegion, model)) and (roadPosition.X == position.X or roadPosition.Z == position.Z)) then
            table.insert(modelsInRegion, model)
        end
    end

    return modelsInRegion
end


--//Returns a random road from the returned array of adjacent roads
--//Returns nil of no roads are found
local function GetNextRoad(currentRoad, lastRoad)
    local adjacentRoads = GetAdjacentRoads(currentRoad, lastRoad)
    print(#adjacentRoads)

    return adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end


--//Generates a path for a vehicle to follow
--//Traces roads until roads end
local function GeneratePath(startingRoad)
    local currentRoad = GetNextRoad(startingRoad)
    local roads = {startingRoad, currentRoad}

    repeat
        currentRoad = GetNextRoad(currentRoad, roads[#roads - 1])
        table.insert(roads, currentRoad)
    until (not currentRoad)

    for _, road in pairs(roads) do
        road.PrimaryPart.Transparency = 0
        road.PrimaryPart.Color = Color3.fromRGB(0, 255, 0)

        wait()
    end
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    wait(10)

    GeneratePath(PlotObject.Placements.Roads:GetChildren()[9])
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