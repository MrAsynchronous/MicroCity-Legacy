-- Placement Controller
-- MrAsync
-- April 3, 2020


--[[

    Handle signals and method calls from and to the PlacementApi

]]



local PlacementController = {}


--//Api
local PlacementApi

--//Services
local PlacementService

--//Controllers

--//Classes

--//Locals
local PlayerGui
local PlacementSelectionQueue

local selectedPlacement


function PlacementController:Start()
    
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local placementSuccess = PlacementService:PlaceObject(itemId, localPosition)

    end)

    PlacementApi.ObjectMoved:Connect(function(itemId, localPosition, oldPosition)
        local moveSuccess = PlacementService:MoveObject(itemId, localPosition)

        if (moveSuccess) then
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
            PlacementSelectionQueue.Container.Size = UDim2.new(0, 0, 0, 0)
            PlacementSelectionQueue.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, .25, true)
        end
        
        selectedPlacement = placementObject
    end)

    --When player stops selecting a placedObject, tween, cleanup PlacementSelectionQueue
    PlacementApi.PlacementSelectionEnded:Connect(function(placementObject)
        --Tween UI out, when tween finished, reset placementSelectionQueue
        PlacementSelectionQueue.Container:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, .25, true, function()        
            PlacementSelectionQueue.Enabled = false
            PlacementSelectionQueue.Adornee = nil
        end)

        selectedPlacement = nil
    end)


    --[[

        PLACEMENTSELECTIONQUEUE BUTTON BINDS

    ]]
    local actionButtons = PlacementSelectionQueue.Container.Buttons

    actionButtons.Sell.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            local success = PlacementService:SellObject(selectedPlacement.Name)

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

    --//Services
    PlacementService = self.Services.PlacementService

    --//Controllers

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")
        
end


return PlacementController