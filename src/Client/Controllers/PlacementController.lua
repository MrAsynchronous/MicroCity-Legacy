-- Placement Controller
-- MrAsync
-- April 3, 2020


--[[

    Handle signals and method calls from and to the PlacementApi

    Methods
        private void ShowQueue()
        private void HideQueue()
        
]]



local PlacementController = {}


--//Api
local PlacementApi
local RoadApi

--//Services
local PlacementService
local MetaDataService

--//Controllers

--//Classes

--//Locals
local PlotObject

local PlayerGui
local PlacementSelectionQueue

local selectedPlacement


local function ShowQueue()
    PlacementSelectionQueue.Container.Size = UDim2.new(0, 0, 0, 0)
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
end


local function HideQueue()
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.25, true, function()        
        PlacementSelectionQueue.Enabled = false
        PlacementSelectionQueue.Adornee = nil
    end)
end

local function ResetSelection()
    PlacementSelectionQueue.Adornee = nil
    selectedPlacement = nil
end


local function HandleIntersections(baseRoad)
    if (not baseRoad.PrimaryPart) then return end

    local adjacentRoads = RoadApi:GetAdjacentRoads(baseRoad, baseRoad)

    for _, road in pairs(adjacentRoads) do
        PlacementService:UpgradeObject(road.Name)
    end
end


function PlacementController:Start()

    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local placementSuccess, model = PlacementService:PlaceObject(itemId, localPosition)

        --If placement was successful and placementType was a road, 
        if (placementSuccess) then
            local itemMetaData = MetaDataService:GetMetaData(itemId)

            if (itemMetaData.Type == "Road") then
                HandleIntersections(model)
            end
        end
    end)

    PlacementApi.ObjectMoved:Connect(function(guid, localPosition, oldPosition)
        local moveSuccess = PlacementService:MoveObject(guid, localPosition)

        if (moveSuccess) then
            local itemMetaData = MetaDataService:GetMetaData(guid)
            PlacementApi:StopPlacing()
        else
            PlacementApi:StopPlacing(true)
        end
    end)
    
    --When player selects placed object, setup PlacementSelectionQueue, tween
    PlacementApi.PlacementSelectionStarted:Connect(function(placementObject)
        PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, placementObject.PrimaryPart.Size.Y, 0)
        PlacementSelectionQueue.Adornee = placementObject.PrimaryPart
        PlacementSelectionQueue.Enabled = true

        --Only tween UI if selectedPlacement fresh, or hot-selecting a different placementObject
        if (not selectedPlacement or (selectedPlacement and (placementObject ~= selectedPlacement))) then
            ShowQueue()
        end
        
        selectedPlacement = placementObject
    end)

    --When player stops selecting a placedObject, tween, cleanup PlacementSelectionQueue
    PlacementApi.PlacementSelectionEnded:Connect(function(placementObject)
        selectedPlacement = nil
        HideQueue()
    end)


    --[[

        PLACEMENTSELECTIONQUEUE BUTTON BINDS

    ]]
    local actionButtons = PlacementSelectionQueue.Container.Buttons

    actionButtons.Sell.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            HideQueue()

            local success = PlacementService:SellObject(selectedPlacement.Name)
        end
    end)

    actionButtons.Move.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            PlacementApi:StartPlacing(selectedPlacement)

            ResetSelection()
        end
    end)

    actionButtons.Upgrade.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            ResetSelection()
        end
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.API.PlacementApi
    RoadApi = self.Modules.API.RoadApi

    --//Services
    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService

    --//Controllers

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")

    PlotObject = self.Player:WaitForChild("PlotObject").Value
        
end


return PlacementController