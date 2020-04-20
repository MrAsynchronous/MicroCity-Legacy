-- Placement Controller
-- MrAsync
-- April 3, 2020


--[[

    Handle signals and method calls from and to the PlacementApi

    Methods
        private void ShowQueue()
        private void HideQueue()
        private void SetSelection(placementObject)

]]



local PlacementController = {}


--//Api
local PlacementApi
local RoadApi

--//Services
local TweenService = game:GetService("TweenService")

local PlacementService
local MetaDataService

--//Controllers
local NotificationDispatcher

--//Classes

--//Locals
local PlotObject

local PlayerGui
local PlacementSelectionQueue

local selectedPlacement



--Shows the selection queue
local function ShowQueue()
    PlacementSelectionQueue.Container.Size = UDim2.new(0, 0, 0, 0)

    PlacementSelectionQueue.Enabled = true
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
end


--Hides the selection queue
--Does not change adornee
local function HideQueue(isReset)
    PlacementSelectionQueue.Container:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.25, true, function()
        PlacementSelectionQueue.Enabled = false

        if (isReset) then
            PlacementSelectionQueue.Adornee = nil
            selectedPlacement = nil
        end
    end)
end


--Adornee's selectionQueue to placementObject
local function SetSelection(placementObject)
    PlacementSelectionQueue.Adornee = placementObject.PrimaryPart
    PlacementSelectionQueue.Enabled = true

    --Only tween UI if selectedPlacement fresh, or hot-selecting a different placementObject
    if (not selectedPlacement or (selectedPlacement and (placementObject ~= selectedPlacement))) then
        ShowQueue()
    end
    
    selectedPlacement = placementObject
end


function PlacementController:Start()
    --[[
        Selection Queue
    ]]
    --When player selects placed object, setup PlacementSelectionQueue, tween
    PlacementApi.PlacementSelectionStarted:Connect(function(placementObject)
        SetSelection(placementObject)
    end)

    --When player stops selecting a placedObject, tween, cleanup PlacementSelectionQueue
    PlacementApi.PlacementSelectionEnded:Connect(function(placementObject)
        HideQueue(true)
    end)


    --[[
        SelectionQueue buttons
    ]]
    local actionButtons = PlacementSelectionQueue.Container

    --Invoke server to sell object
    actionButtons.Sell.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            local actionData = PlacementService:RequestSell(selectedPlacement.Name)
            NotificationDispatcher:Dispatch(actionData.noticeObject)
        end
    end)

    --Invoke server to upgrade object 
    actionButtons.Upgrade.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            local actionData = PlacementService:RequestUpgrade(selectedPlacement.Name)
            NotificationDispatcher:Dispatch(actionData.noticeObject)

            --Reset selection queue to new model
            if (actionData.wasSuccess) then
                SetSelection(actionData.newObject)
            end
        end
    end)

    --Tell placementApi to start moving object
    actionButtons.Move.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            HideQueue()

            PlacementApi:StartPlacing(selectedPlacement)
        end
    end)


    --[[
        PlacementApi intereaction
    ]]
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local actionData = PlacementService:RequestPlacement(itemId, localPosition)
        NotificationDispatcher:Dispatch(actionData.noticeObject)
     end)

    --When player finishes moving an object, tell server
    PlacementApi.ObjectMoved:Connect(function(guid, localPosition)
        local actionData = PlacementService:RequestMove(guid, localPosition)
        NotificationDispatcher:Dispatch(actionData.noticeObject)

        --Show selectonQueue
        ShowQueue()

        --If move success, stop placing object
        if (actionData.wasSuccess) then
            PlacementApi:StopPlacing()
        else
            PlacementApi:StopPlacing(true)
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
    NotificationDispatcher = self.Controllers.NotificationDispatcher

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")

    PlotObject = self.Player:WaitForChild("PlotObject").Value
        
end


return PlacementController