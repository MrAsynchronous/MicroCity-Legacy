-- Placement Api
-- MrAsync
-- March 24, 2020


--[[

    Interface for controlling the players ability to place objects, edit objects

    Events:
        ObjectPlaced => itemId
        PlacementCancelled => itemId

        PlacementSelectionStarted => Object
        PlacementSelectionEnded => Object

    Methods:
        public void StartPlacing(int ItemId)
        public void StopPlacing()

        private int Round(int num)
        private void RotateObject(String actionName, Enum inputState, InputObject inputObject)
        private void PlaceObject(String actionName, Enum inputState, InputObject inputObject)

        private void CheckSelection()
        private void UpdatePlacement()

]]



local PlacementApi = {}
local self = PlacementApi

--//Api
local Platform

--//Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")
local RunService = game:GetService("RunService")

local PlayerService

--//Controllers

--//Classes

--//Locals
local mouse
local camera
local character
local plotObject

local itemId
local plotMin
local plotMax
local mouseRay
local plotCFrame
local itemObject
local itemRotation
local localPosition
local worldPosition
local selectedObject

local UP = Vector3.new(0, 1, 0)
local BACK = Vector3.new(0, 0, 1)
local GRID_SIZE = 1
local BUILD_HEIGHT = 1024

--[[
    PRIVATE METHODS
]]

--//Rotates the object according to input
local function RotateObject(actionName, inputState, inputObject)
    if (inputState == Enum.UserInputState.Begin) then
        if (inputObject.KeyCode == Enum.KeyCode.R or inputObject.KeyCode == Enum.KeyCode.ButtonR1) then
            itemRotation = itemRotation - (math.pi / 2)
        else
            itemRotation = itemRotation + (math.pi / 2)
        end
    end
end


--//Fires the ObjectPlaced signal
local function PlaceObject(_, inputState)
    if (inputState == Enum.UserInputState.Begin) then
        self.Events.ObjectPlaced:Fire(itemId, localPosition)
    end
end


--//Simple smart-rounding method
local function Round(num)
    return (num % 1 >= 0.5 and math.ceil(num) or math.floor(num))
end


--//Bound to RenderStep
--//Checks if player is hovering over a placed object
local function CheckSelection(_, inputState)
    if (inputState == Enum.UserInputState.Begin) then
        --Create newMouseRay
        local mousePos = UserInputService:GetMouseLocation()
        local mouseUnitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y - 30)
        local mouseRay = Ray.new(mouseUnitRay.Origin, (mouseUnitRay.Direction * 100))
        local rayPart, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(mouseRay, {character})

        --Fire StartedSignal if rayPart is being selected for the first time,
        --Fire EndedSignal if rayPart is not longer selected
        if (rayPart and rayPart:IsDescendantOf(plotObject.Placements)) then
            if (not selectedObject) then
                selectedObject = rayPart:FindFirstAncestorOfClass("Model")
                
                self.Events.PlacementSelectionStarted:Fire(selectedObject)
            end
        else
            if (selectedObject) then
                selectedObject = nil

                self.Events.PlacementSelectionEnded:Fire()
            end
        end
    end
end


--//Bound to RenderStep
--//Moves model to position of mouse
--//Big maths
local function UpdatePlacement()
    local mousePos = UserInputService:GetMouseLocation()
    local mouseUnitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y - 30)
    local mouseRay = Ray.new(mouseUnitRay.Origin, (mouseUnitRay.Direction * 100))
    local rayPart, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(mouseRay, {character, itemObject})

    --Calculate model size according to current itemRotation
    local modelSize = CFrame.fromEulerAnglesYXZ(0, itemRotation, 0) * itemObject.PrimaryPart.Size
    modelSize = Vector3.new(Round(math.abs(modelSize.X)), Round(math.abs(modelSize.Y)), Round(math.abs(modelSize.Z)))

    --If itemObject.PrimaryPart.Size is odd, we must place it evenly on the grid
    local xAppend = 0
    local zAppend = 0

    if (((modelSize.X / 2) % 2) > 0) then
        xAppend = 0.5
    end
    if (((modelSize.Z / 2) % 2) > 0) then
        zAppend = 0.5
    end

    --Allow messy placement on the side of previously placed objects
    hitPosition = hitPosition + (normal * (modelSize / 2))

    --Allign placement positions to GRID_SIZE
    local xPosition = (math.floor(hitPosition.X / GRID_SIZE) * GRID_SIZE) + xAppend
    local yPosition = plotMax.Y + (modelSize.Y / 2)
    local zPosition = (math.floor(hitPosition.Z / GRID_SIZE) * GRID_SIZE) + zAppend

    --Clamp positions inside of plot so players cannot scrub outside of plot
    xPosition = math.clamp(xPosition, plotMin.X + (modelSize.X / 2), plotMax.X - (modelSize.X / 2))
    zPosition = math.clamp(zPosition, plotMin.Z + (modelSize.Z / 2), plotMax.Z - (modelSize.Z / 2))

    --Construct worldPosition and get a localPosition
    worldPosition = CFrame.new(xPosition, yPosition, zPosition) * CFrame.Angles(0, itemRotation, 0)
    localPosition = plotObject.Main.CFrame:ToObjectSpace(worldPosition)

    --Set the position of the object
    itemObject:SetPrimaryPartCFrame(itemObject.PrimaryPart.CFrame:Lerp(worldPosition, .2))
end

--[[
    PUBLIC METHODS
]]

--//Starts the placing process
--//Clones the model
--//Binds function to renderStepped
function PlacementApi:StartPlacing(id)
    --Clone model into current camera
    --IMPLEMENT LEVEL SELECTION
    itemObject = ReplicatedStorage.Items.Buildings:FindFirstChild(id).Lvl1:Clone()
    itemObject.Parent = camera
    itemId = id
    itemObject:SetPrimaryPartCFrame(plotObject.Main.CFrame)

    --Setup rotation
    itemRotation = math.pi / 2

    --Setup grid
    plotObject.Main.Grid.Transparency = 0
    plotObject.Main.GridDash.Transparency = 0

    --Bind Actions
    ContextActionService:BindAction("PlaceObject", PlaceObject, true, Enum.KeyCode.ButtonR2, Enum.UserInputType.MouseButton1)
        ContextActionService:SetImage("PlaceObject", "rbxassetid://4835092139")

    ContextActionService:BindAction("RotateObject", RotateObject, true, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.R)
        ContextActionService:SetImage("RotateObject", "rbxassetid://4834696114")

    ContextActionService:BindAction("CancelPlacement", PlacementApi.StopPlacing, true, Enum.KeyCode.X, Enum.KeyCode.ButtonB)
        ContextActionService:SetImage("CancelPlacement", "rbxassetid://4834678852")

    RunService:BindToRenderStep("UpdatePlacement", 1, UpdatePlacement)
end


--//Stops placing object
--//Cleans up client
function PlacementApi:StopPlacing()
    if (itemObject) then itemObject:Destroy() end

    --Reset locals
    localPosition = nil
    worldPosition = nil
    itemId = 0

    --Cleanup grid
    plotObject.Main.Grid.Transparency = 1
    plotObject.Main.GridDash.Transparency = 1

    --Unbind actions
    ContextActionService:UnbindAction("PlaceObject")
    ContextActionService:UnbindAction("CancelPlacement")
    ContextActionService:UnbindAction("RotateObject")

    RunService:UnbindFromRenderStep("UpdatePlacement")
end


function PlacementApi:Start()
    --Update local plotObject when and if plotObject changes
    PlayerService.SendPlotToClient:Connect(function(newPlot)
        plotCFrame = newPlot.Main.CFrame
        plotMin = plotCFrame - (newPlot.Main.Size / 2)
        plotMax = plotCFrame + (newPlot.Main.Size / 2)

        plotObject = newPlot
    end)

    --Initially grab character, and grab character when player resets
    character = (self.Player.Character or self.Player.CharacterAdded:Wait())
    self.Player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
    end)
    
    --When player clicks, check if they are selection a previously placed object
    ContextActionService:BindAction("SelectionChecking", CheckSelection, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
end


function PlacementApi:Init()
    --//Api
    Platform = self.Shared.Platform
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Controllers
    
    --//Classes
    
    --//Locals
    mouse = self.Player:GetMouse()
    camera = workspace.CurrentCamera

    --Register signals
    self.Events = {}
    self.Events.ObjectPlaced = Instance.new("BindableEvent")
    self.Events.PlacementCancelled = Instance.new("BindableEvent")
    self.Events.PlacementSelectionStarted = Instance.new("BindableEvent")
    self.Events.PlacementSelectionEnded = Instance.new("BindableEvent")

    self.Events.PlacementCancelled.Parent = script
    self.Events.ObjectPlaced.Parent = script
    self.Events.PlacementSelectionEnded.Parent = script
    self.Events.PlacementSelectionStarted.Parent = script

    self.PlacementSelectionStarted = self.Events.PlacementSelectionStarted.Event
    self.PlacementSelectionEnded = self.Events.PlacementSelectionEnded.Event
    self.PlacementCancelled = self.Events.PlacementCancelled.Event
    self.ObjectPlaced = self.Events.ObjectPlaced.Event
end

return PlacementApi