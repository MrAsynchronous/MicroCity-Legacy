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


local function GetCFrameFromCell(cellPosition)
    local relativeToCorner = CFrame.new(Vector3.new(
        (cellPosition.Row * 2) + 1,
        0,
        -(cellPosition.Column * 2) + 1
    ))

    local relativeToWorld = plotCornerPosition:ToWorldSpace(relativeToCorner)

    return relativeToWorld
end


--//Indexes adjacent cell's and packs them into an array
local function GetAdjacentRoads(baseCell)
    local nonUsedAdjacentCells = {}

    --Create new array with adjacentCells
    --Front, back, left, right
    local adjacentCells = {
        {Row = math.clamp(baseCell.Row - 1, 1, #roadMap), Column = baseCell.Column},
        {Row = math.clamp(baseCell.Row + 1, 1, #roadMap), Column = baseCell.Column},
        {Row = baseCell.Row, Column = baseCell.Column - 1, 1, #roadMap},
        {Row = baseCell.Row, Column = baseCell.Column + 1, 1, #roadMap}
    }
    
    --Insert valid, non-used cells into array
    for _, adjacentCell in pairs(adjacentCells) do
        if ((adjacentCell.Row and adjacentCell.Column) and (adjacentCell.Row ~= baseCell.Row and adjacentCell.Column ~= baseCell.Column)) then
            table.insert(nonUsedAdjacentCells, adjacentCell)
        end
    end

    return nonUsedAdjacentCells
end


local function GetNearestRoad(previousCell, baseCell)
    local adjacentRoads = GetAdjacentRoads(previousCell, baseCell)

    --If no adjacent roads exist, return
    if (#adjacentRoads == 0) then return end


end


--//Pathfinding Algorithm
--//Generates a random path for a vehicle to follow
function RoadApi:GeneratePath(startingCell)
    local vehiclePath = {startingCell}

    GetNearestRoad(startingCell, startingCell)
end


--//Adds node relative to localPosition
function RoadApi:AddRoad(localPosition)
    local cellPosition = GetCellFromCFrame(localPosition)

    print(#GetAdjacentRoads(cellPosition))

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