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
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, .25, true)
end


local function HideQueue()
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, .25, true, function()        
        PlacementSelectionQueue.Enabled = false
        PlacementSelectionQueue.Adornee = nil
    end)
end


function PlacementController:Start()

    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local placementSuccess = PlacementService:PlaceObject(itemId, localPosition)

        --If placement was successful and placementType was a road ,
        if (placementSuccess) then
            local itemMetaData = MetaDataService:GetMetaData(itemId)

            --Add road to roadMap
            if (itemMetaData.Type == "Road") then
                RoadApi:AddRoad(localPosition)
            end
        end
    end)

    PlacementApi.ObjectMoved:Connect(function(guid, localPosition, oldPosition)
        local moveSuccess = PlacementService:MoveObject(guid, localPosition)

        if (moveSuccess) then
            local itemMetaData = MetaDataService:GetMetaData(guid)
            PlacementApi:StopPlacing()

            --Add road to roadMap
            if (itemMetaData.Type == "Road") then
                RoadApi:AddRoad(localPosition)
                RoadApi:RemoveRoad(oldPosition)
            end            
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

            --Cache MetaData and the objects CFrame
            local objectMetaData = MetaDataService:GetMetaData(selectedPlacement.Name)
            local objectCFrame = selectedPlacement.PrimaryPart.CFrame
            local success = PlacementService:SellObject(selectedPlacement.Name)

            --If selloff is a success
            if (success) then
                --And object sold was a Road
                if (objectMetaData.Type == "Road") then
                    --Remove road from roadMap
                    RoadApi:RemoveRoad(PlotObject.Main.CFrame:ToObjectSpace(objectCFrame))
                end
            end
        end
    end)

    actionButtons.Move.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            PlacementApi:StartPlacing(selectedPlacement)

            PlacementSelectionQueue.Adornee = nil
            selectedPlacement = nil
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

    PlotObject = self.Player:WaitForChild("PlayerPlot").Value
        
end


return PlacementController