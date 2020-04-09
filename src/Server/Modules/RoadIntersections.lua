-- Road Intersections
-- MrAsync
-- April 8, 2020


--[[

    Handles the auto-intersection of ajdacent raods

]]


local RoadIntersections = {}

--//Api

--//Services

--//Controllers

--//Classes

--//Locals



--//Returns an array containing all adjacent roads
--//Region3 based
function RoadIntersections:GetAdjacentRoads(playerObject, placedRoad)
    local roadPosition = placedRoad.PrimaryPart.Position
    local adjacentRegion = Region3.new(roadPosition - Vector3.new(1, 1, 1), roadPosition + Vector3.new(1, 1, 1))
    local roadsInRegion = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, playerObject.PlotObject.Placements.Roads:GetChildren(), math.huge)
    local modelsInRegion = {}

    --Iterate through all parts in Region3
    for i, part in pairs(roadsInRegion) do
        --Find model and localize positions
        local model = part:FindFirstAncestorOfClass("Model")
        local position = model.PrimaryPart.Position
        local positionDifference = roadPosition - position

        --Only add model if model is not currentRoad model is not already in index, and if it is directly adjacent with a tolerance of .25 studs
        if ((model ~= placedRoad) and (not table.find(modelsInRegion, model)) and (math.abs(positionDifference.X) <= 0.25 or math.abs(positionDifference.Z) <= 0.25)) then
            table.insert(modelsInRegion, model)
        end
    end

    return modelsInRegion
end


--//Attempts to create valid intersections around placementObject
function RoadIntersections:AttemptIntersection(playerObject, placementObject, adjacentRoads)
    for _, road in pairs(adjacentRoads) do
        local roadObject = playerObject:GetPlacementObject(road.Name)

        roadObject:Upgrade()
    end

    return true
end


function RoadIntersections:Start()
    
end


function RoadIntersections:Init()

end


return RoadIntersections