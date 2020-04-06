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


--//Returns an array containing all adjacent roads
function RoadApi:GetAdjacentRoads(currentRoad)
    local roadPosition = currentRoad.PrimaryPart.Position
    local adjacentRegion = Region3.new(roadPosition - Vector3.new(1, 1, 1), roadPosition + Vector3.new(1, 1, 1))
    local roadsInRegion = workspace:FindPartsInRegion3WithWhiteList(adjacentRegion, PlotObject.Placements.Roads:GetChildren(), math.huge)
    local modelsInRegion = {}

    --Iterate through all parts in Region3
    for i, part in pairs(roadsInRegion) do
        --Find model and localize positions
        local model = part:FindFirstAncestorOfClass("Model")
        local position = model.PrimaryPart.Position
        
        --Only add model if model is not currentRoad, model is not already in index, and if it is directly adjacent
        if ((model ~= currentRoad) and (not table.find(modelsInRegion, model)) and (roadPosition.X == position.X or roadPosition.Z == position.Z)) then
            table.insert(modelsInRegion, model)
        end
    end

    return modelsInRegion
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    PlotObject.Placements.Roads.ChildAdded:Connect(function(newChild)
        while (not newChild.PrimaryPart) do wait() end

        print(#self:GetAdjacentRoads(newChild))
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

end


return RoadApi