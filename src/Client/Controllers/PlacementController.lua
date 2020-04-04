-- Placement Controller
-- MrAsync
-- March 30, 2020


--[[

    Medium between UI and PlacementApi. Controls the selectionQueue of placements

]]


local PlacementController = {}


--//Api
local PlacementApi
local RoadApi

--//Services
local ContextActionService = game:GetService("ContextActionService")

local PlacementService
local PlayerService

--//Controllers

--//Classes

--//Locals
local plotObject
local selectedModel

local PlacementSelectionQueue


function PlacementController:Start()
    while (not plotObject.Main) do wait() end

    --Load objects into roadIndex
    for _, road in pairs(plotObject.Placements.Roads:GetChildren()) do
        local localPosition = plotObject.Main.CFrame:ToObjectSpace(road.PrimaryPart.CFrame)

        RoadApi:AddRoad(localPosition)
    end

    --Bind to ObjectPlaced signal
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local success = PlacementService:PlaceObject(itemId, localPosition)

        --If place successful
        if (success) then

            --Add road to roadIndex
            RoadApi:AddRoad(localPosition)
        end
    end)


    --Bind to ObjectMoved signal
    PlacementApi.ObjectMoved:Connect(function(itemGuid, newLocalPosition, originalLocalPosition)
        local success = PlacementService:MoveObject(itemGuid, newLocalPosition)

        --If move successful
        if (success) then
            PlacementApi:StopPlacing(false)

            --Remove road from roadIndex
            --Add road to roadIndex
            RoadApi:RemoveRoad(originalLocalPosition)
            RoadApi:AddRoad(newLocalPosition)
        else
            PlacementApi:StopPlacing(true)
        end
    end)


    --When player selects placement, show GUI
    PlacementApi.PlacementSelectionStarted:Connect(function(placementObject)
        PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, placementObject.PrimaryPart.Size.Y, 0)
        PlacementSelectionQueue.Adornee = placementObject.PrimaryPart
        PlacementSelectionQueue.Enabled = true

        selectedModel = placementObject
    end)


    --When player stops selecting placement, hide GUI
    PlacementApi.PlacementSelectionEnded:Connect(function()
        PlacementSelectionQueue.Enabled = false
        PlacementSelectionQueue.Adornee = nil

        selectedModel = nil
    end)


    --Button binds
    local buttonContainer = PlacementSelectionQueue.Container.Buttons

    --Move object
    buttonContainer.Move.MouseButton1Click:Connect(function()
        if (selectedModel) then
            PlacementApi:StartPlacing(selectedModel)

            PlacementSelectionQueue.Adornee = nil
            selectedModel = nil
        end
    end)

    --Sell object
    buttonContainer.Sell.MouseButton1Click:Connect(function()
        local oldLocalPosition = plotObject.Main.CFrame:ToObjectSpace(selectedModel.PrimaryPart.CFrame)
        local success = PlacementService:SellObject(selectedModel.Name)

        PlacementSelectionQueue.Adornee = nil
        selectedModel = nil

        --If sell is a success, remove road from roadIndex
        if (success) then
            RoadApi:RemoveRoad(oldLocalPosition)
        end
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.API.PlacementApi
    RoadApi = self.Modules.API.RoadApi

    --//Services
    PlacementService = self.Services.PlacementService
    PlayerService = self.Services.PlayerService

    --//Controllers
    
    --//Classes

    --//Locals
    plotObject = self.Player:WaitForChild("PlayerPlot").Value
    PlacementSelectionQueue = self.PlayerGui:WaitForChild("PlacementSelectionQueue")

end


return PlacementController