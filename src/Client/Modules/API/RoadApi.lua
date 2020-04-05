-- RoadApi
-- MrAsync
-- April 3, 2020


--[[

    Used to convert localPositions of roads to cellPositions in roadIndex

    Methods
        public void AddRoad(LocalSpace localPosition)
        public void RemoveRoad(LocalSpace localPosition)

        private Vector2 GetCellFromCFrame(LocalSpace localPosition)
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
local PlayerGui
local PlotVisualizer

local PlotObject

local roadMap
local visualIndex
local plotCornerPosition


--//Converts localPosition to cellPosition
local function GetCellFromCFrame(localPosition)
    local worldPosition = PlotObject.Main.CFrame:ToWorldSpace(localPosition)
    localPosition = plotCornerPosition:ToObjectSpace(worldPosition)

    return {
        Row = math.abs(localPosition.X / 2) + 1,
        Column = math.abs(localPosition.Z / 2) + 1
    }
end


--//Adds node relative to localPosition
function RoadApi:AddRoad(localPosition)
    local cellPosition = GetCellFromCFrame(localPosition)

    print(cellPosition.Row, cellPosition.Column)

    roadMap[cellPosition.Row][cellPosition.Column] = localPosition
    visualIndex[cellPosition.Row][cellPosition.Column].BackgroundColor3 = Color3.fromRGB(0, 255, 0);
end


--//Removes node relative to localPosition
function RoadApi:RemoveRoad(localPosition)
    local cellPosition = GetCellFromCFrame(localPosition)

    roadMap[cellPosition.Row][cellPosition.Column] = nil
    visualIndex[cellPosition.Row][cellPosition.Column].BackgroundColor3 = Color3.fromRGB(255, 0, 0);
end


--//Creates interval to spawn vehicles
function RoadApi:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlotVisualizer = PlayerGui:WaitForChild("PlotVisualizer")

    PlacementService.OnPlotLoadComplete:Connect(function()
        --Populate roadMap with previously placed roads
        for _, placementObject in pairs(PlotObject.Placements.Roads:GetChildren()) do
            self:AddRoad(PlotObject.Main.CFrame:ToObjectSpace(placementObject.PrimaryPart.CFrame))
        end
    end)

    --Populate RoadMap
    for i=0, PlotObject.Main.Size.X, 2 do
        table.insert(roadMap, {})
    end

    --Initiate visualizer
    for a=1, 50 do
        visualIndex[a] = {}

        for b=1, 50 do
            visualIndex[a][b] = Instance.new("Frame")
            visualIndex[a][b].Parent = PlotVisualizer.Container
            visualIndex[a][b].BackgroundColor3 = Color3.fromRGB(255, 0, 0);
        end
    end
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

    roadMap = {}
    visualIndex = {}
    plotCornerPosition = PlotObject.Main.CFrame - (PlotObject.Main.Size / 2) + Vector3.new(1, 0, 1)
end


return RoadApi