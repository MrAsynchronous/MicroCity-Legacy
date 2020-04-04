-- RoadApi
-- MrAsync
-- April 3, 2020


--[[

    Used to convert localPositions of roads to cellPositions in roadIndex

    Methods
        public void AddRoad(LocalSpace localPosition)
        public void RemoveRoad(LocalSpace localPosition)

        private Vector2 GetCellPositionFromLocalPosition(LocalSpace localPosition)
]]


local RoadApi = {}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService

--//Controllers

--//Classes
local VehicleClass

--//Locals
local plotVisualizer
local plotObject

local roadIndex
local visualIndex


--//Converts localPosition to cellPosition
local function GetCellPositionFromLocalPosition(localPosition)
    local cornerPosition = plotObject.Main.CFrame - (plotObject.Main.Size / 2) + Vector3.new(1, 0, 1)
    local worldPosition = plotObject.Main.CFrame:ToWorldSpace(localPosition)
    localPosition = cornerPosition:ToObjectSpace(worldPosition)

    return Vector2.new(math.abs(localPosition.Z / 2) + 1, math.abs(localPosition.X / 2) + 1)
end


function RoadApi:GetAdjacentRoads(cellPosition)
    local front = roadIndex[cellPosition.Y - 1][cellPosition.X]
    local left = roadIndex[cellPosition.Y][cellPosition.X - 1]
    local right = roadIndex[cellPosition.Y][cellPosition.X + 1]

    return {left, right, front}
end


--//Adds node relative to localPosition
function RoadApi:AddRoad(localPosition)
    local cellPosition = GetCellPositionFromLocalPosition(localPosition)

    roadIndex[cellPosition.Y][cellPosition.X] = localPosition
    visualIndex[cellPosition.Y][cellPosition.X].BackgroundColor3 = Color3.fromRGB(0, 255, 0);
end


--//Removes node relative to localPosition
function RoadApi:RemoveRoad(localPosition)
    local cellPosition = GetCellPositionFromLocalPosition(localPosition)

    roadIndex[cellPosition.Y][cellPosition.X] = nil
    visualIndex[cellPosition.Y][cellPosition.X].BackgroundColor3 = Color3.fromRGB(255, 0, 0);
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    plotVisualizer = self.PlayerGui:WaitForChild("PlotVisualizer")
    plotObject = self.Player:WaitForChild("PlayerPlot").Value

    --Instantiate roadIndex
    for i=0, plotObject:WaitForChild("Main").Size.X, 2 do
        table.insert(roadIndex, {})
    end

    for a=1, 50 do
        visualIndex[a] = {}

        for b=1, 50 do
            visualIndex[a][b] = Instance.new("Frame")
            visualIndex[a][b].Parent = plotVisualizer.Container
            visualIndex[a][b].BackgroundColor3 = Color3.fromRGB(255, 0, 0);
        end
    end
end


function RoadApi:Init()
    --//Api

    --//Services
    MetaDataService = self.Services.MetaDataService

    --//Controllers

    --//Classes
    VehicleClass = self.Modules.Classes.VehicleClass

    --//Locals
    roadIndex = {}
    visualIndex = {}
end


return RoadApi