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
local self = PlacementController

--//Api
local PlacementApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlacementService

--//Controllers
local NotificationDispatcher
local GamepadCursor

--//Classes

--//Locals
local Particles

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

    local modelSize = placementObject.PrimaryPart.Size
    local hipHeight = self.Player.Character.Humanoid.HipHeight
    local yOffset = -((modelSize.Y / 2) - hipHeight)

    PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, yOffset, 0)

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

    PlacementApi.PlacementBegan:Connect(function()
        HideQueue()
        GamepadCursor:HideCursor()
    end)

    --[[
        SelectionQueue buttons
    ]]
    local actionButtons = PlacementSelectionQueue.Container

    --Invoke server to sell object
    actionButtons.Sell.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            HideQueue(true)

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

                --Tween and particle effect
                --Clone particle effect
                local newParticle = Particles.PlacementEffect:Clone()
                newParticle.Parent = actionData.newObject.PrimaryPart
                newParticle.Enabled = true

                actionData.newObject.PrimaryPart.CFrame = actionData.worldPosition - Vector3.new(0, actionData.newObject.PrimaryPart.Size.Y, 0)
                local effectTween = TweenService:Create(actionData.newObject.PrimaryPart, TweenInfo.new(1), {CFrame = actionData.worldPosition})
                effectTween:Play()
        
                effectTween.Completed:Connect(function()
                    effectTween:Destroy()
                    newParticle:Destroy()
                end)          
            end
        end
    end)

    --Tell placementApi to start moving object
    actionButtons.Move.MouseButton1Click:Connect(function()
        if (selectedPlacement) then
            HideQueue(true)

            PlacementApi:StartPlacing(selectedPlacement)
        end
    end)


    --[[
        PlacementApi intereaction
    ]]
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local actionData = PlacementService:RequestPlacement(itemId, localPosition)
        NotificationDispatcher:Dispatch(actionData.noticeObject)

        --Tween and particle effect
        if (actionData.wasSuccess and actionData.placedObject) then
            --Clone particle effect
            local newParticle = Particles.PlacementEffect:Clone()
            newParticle.Parent = actionData.placedObject.PrimaryPart
            newParticle.Enabled = true

            --Give the tween effect
            actionData.placedObject.PrimaryPart.CFrame = actionData.worldPosition - Vector3.new(0, actionData.placedObject.PrimaryPart.Size.Y, 0)
            local effectTween = TweenService:Create(actionData.placedObject.PrimaryPart, TweenInfo.new(1), {CFrame = actionData.worldPosition})
            effectTween:Play()

            --When tween completes, destroy tween and particle 
            effectTween.Completed:Connect(function()
                effectTween:Destroy()
                newParticle:Destroy()
            end)
        end
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

    --//Services
    PlacementService = self.Services.PlacementService

    --//Controllers
    NotificationDispatcher = self.Controllers.NotificationDispatcher
    GamepadCursor = self.Controllers.CursorModule

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    Particles = ReplicatedStorage:WaitForChild("Items").Particles
    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")
        
end


return PlacementController