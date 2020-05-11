-- RoadApi
-- MrAsync
-- April 3, 2020


--[[

    Used to convert localPositions of roads to cellPositions in roadIndex

    Methods
        public Model GetNextRoad(Model currentRoad, Model lastRoad)
        public Array GetAdjacentRoads(Model currentRoad, Model lastRoad)
        public Model, Model GetStartingRoad(Array buildings)
]]


local RoadApi = {}
local self = RoadApi

--//Api

--//Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementService
local MetaDataService

--//Controllers

--//Classes

--//Locals
local RandomObject


--[[
    PRIVATE METHODS
]]


--//Returns an array containing all adjacent roads
--//Region3 based
function  RoadApi:GetAdjacentRoads(plotObject, currentRoad, lastRoad, ingoreOrientation)
    local roadPosition = currentRoad.PrimaryPart.Position
    local roadOrientation = math.abs(currentRoad.PrimaryPart.Orientation.Y)
    local adjacentRegion = Region3.new(roadPosition - Vector3.new(1, 1, 1), roadPosition + Vector3.new(1, 1, 1))
    local roadsInRegion = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, plotObject.Placements.Road:GetChildren(), math.huge)
    local modelsInRegion = {}

    --Iterate through all parts in Region3
    for i, part in pairs(roadsInRegion) do
        --Find model and localize positions
        local model = part:FindFirstAncestorOfClass("Model")
        local position = model.PrimaryPart.Position
        local orientation = math.abs(model.PrimaryPart.Orientation.Y)
        local positionDifference = roadPosition - position

        if ((roadPosition.X == position.X and roadPosition.Z ~= position.Z) and roadOrientation == orientation and (not ingoreOrientation)) then continue end
        if ((roadPosition.Z == position.Z and roadPosition.X ~= roadPosition.X) and roadOrientation == orientation and (not ingoreOrientation)) then continue end

        --Only add model if model is not currentRoad model is not already in index, and if it is directly adjacent with a tolerance of .25 studs
        if ((model ~= currentRoad) and (model ~= lastRoad) and (not table.find(modelsInRegion, model)) and (math.abs(positionDifference.X) <= 0.25 or math.abs(positionDifference.Z) <= 0.25)) then
            table.insert(modelsInRegion, model)
        end
    end

    return modelsInRegion
end


--[[
    PUBLIC METHODS
]]
--//Returns a random road from the returned array of adjacent roads
--//Returns nil of no roads are found
function RoadApi:GetNextRoad(plotObject, currentRoad, lastRoad)
    local adjacentRoads = RoadApi:GetAdjacentRoads(plotObject, currentRoad, lastRoad)
    return adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end


--//Picks a random building to position new vehicle at
--//Picks a random adjacent road as the first road position
function RoadApi:GetStartingRoad(plotObject, buildingIndex)
    local startingBuilding = buildingIndex[RandomObject:NextInteger(1, #buildingIndex)]
    if (not startingBuilding) then return end

    --Localize position and size
    local basePosition = startingBuilding.PrimaryPart.Position
    local baseSize = startingBuilding.PrimaryPart.Size

    --Generate a new region3 and get the surrounding road parts
    local adjacentRegion = Region3.new((basePosition - (baseSize / 2)) - Vector3.new(1.5, 0, 1.5), (basePosition + (baseSize / 2)) + Vector3.new(1.5, 0, 1.5))
    local adjacentParts = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, plotObject.Placements.Road:GetChildren(), math.huge)
    local adjacentRoads = {}

    --Iterate through all road parts, if road is not already in index, add it
    for _, roadPart in pairs(adjacentParts) do
        local parentModel = roadPart:FindFirstAncestorOfClass("Model")

        if (not table.find(adjacentRoads, parentModel)) then
            table.insert(adjacentRoads, parentModel)
        end
    end

    return startingBuilding, adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end


function RoadApi:Init()
    --//Api

    --//Services
    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService

    --//Controllers

    --//Classes

    --//Locals
    RandomObject = Random.new(os.time())

end


return RoadApi