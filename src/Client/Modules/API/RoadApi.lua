-- RoadApi
-- MrAsync
-- April 3, 2020


--[[

    Used to convert localPositions of roads to cellPositions in roadIndex

    Methods
        public Model GetNextRoad(Model currentRoad, Model lastRoad)
        public Array GeneratePath(Model startingRoad) DEPRECATED
        
        private Array GetAdjacentRoads(Model currentRoad, Model lastRoad)
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
local VehicleClass

--//Locals
local PlotObject
local RandomObject


--[[
    PUBLIC METHODS
]]


--//Returns the String relationShip of road to baseRoad
--//Top, Bottom, Left and Right
function RoadApi:GetRelationOfRoad(baseRoad, road)
    local basePosition = PlotObject.Main.CFrame:ToObjectSpace(baseRoad.PrimaryPart.CFrame)
    local roadPosition = PlotObject.Main.CFrame:ToObjectSpace(road.PrimaryPart.CFrame)
    local positionDifference = basePosition.Position - roadPosition.Position

    --Compare positionDifference
    if (positionDifference.X == 0) then
        if (positionDifference.Z > 0) then
            return "Bottom"
        else
            return "Top"
        end
    else
        if (positionDifference.X < 0) then
            return "Left"
        else
            return "Right"
        end
    end
end


--//Returns an array containing all adjacent roads
--//Region3 based
function RoadApi:GetAdjacentRoads(currentRoad, lastRoad)
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


--[[
    PRIVATE METHODS
]]
--//Returns a random road from the returned array of adjacent roads
--//Returns nil of no roads are found
function RoadApi:GetNextRoad(currentRoad, lastRoad)
    local adjacentRoads = self:GetAdjacentRoads(currentRoad, lastRoad)
    return adjacentRoads[RandomObject:NextInteger(1, #adjacentRoads)]
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    PlotObject = self.Player:WaitForChild("PlotObject").Value
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