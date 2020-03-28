-- Placement Api
-- MrAsync
-- March 24, 2020


--[[

    Interface for controlling the players ability to place objects, edit objects

    Events:
        ObjectPlaced => itemId
        PlacementCancelled => itemId

    Methods:
        StartPlacement
            int itemId
            
        StopPlacement   

]]



local PlacementApi = {}
local self = PlacementApi

--//Api

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
local initialized

local plotMin
local plotMax
local plotCFrame
local itemObject
local itemRotation
local worldPosition
local localPosition

local UP = Vector3.new(0, 1, 0)
local BACK = Vector3.new(0, 0, 1)
local GRID_SIZE = 1
local BUILD_HEIGHT = 1024


--//Bound to RenderStep
--//Checks if player is hovering over a placed object
local function CheckSelection()

end

--//Bound to RenderStep
--//Moves model to position of mouse
--//Big maths
local function UpdatePlacement()
    if (not initialized) then return end

    --Raycasting via mousePosition
    local mousePos = UserInputService:GetMouseLocation()
    local mouseUnitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y - 30)
    local mouseRay = Ray.new(mouseUnitRay.Origin, (mouseUnitRay.Direction * 100))
    local rayPart, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(mouseRay, {(self.Player.Character or self.Player.CharacterAdded:Wait()), itemObject})

    --Calculate model size according to current itemRotation
    local modelSize = CFrame.fromEulerAnglesYXZ(0, itemRotation, 0) * itemObject.PrimaryPart.Size
    modelSize = Vector3.new(self:Round(math.abs(modelSize.X)), self:Round(math.abs(modelSize.Y)), self:Round(math.abs(modelSize.Z)))

    --If itemObject.PrimaryPart.Size is odd, we must place it evenly on the grid
    --A E S T H E T I C S
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
    --A E S T H E T I C S
    xPosition = math.clamp(xPosition, plotMin.X + (modelSize.X / 2), plotMax.X - (modelSize.X / 2))
    zPosition = math.clamp(zPosition, plotMin.Z + (modelSize.Z / 2), plotMax.Z - (modelSize.Z / 2))

    worldPosition = CFrame.new(xPosition, yPosition, zPosition) * CFrame.Angles(0, itemRotation, 0)
    localPosition = worldPosition:ToObjectSpace(plotCFrame)

    itemObject:SetPrimaryPartCFrame(itemObject.PrimaryPart.CFrame:Lerp(worldPosition, .2))
end

PlacementApi.RotateObject = function(actionName, inputState, inputObject)
    if (inputState == Enum.UserInputState.Begin) then
        if (inputObject.KeyCode == Enum.KeyCode.R or inputObject.KeyCode == Enum.KeyCode.ButtonR1) then
            itemRotation = itemRotation - (math.pi / 2)
        else
            itemRotation = itemRotation + (math.pi / 2)
        end
    end
end


--//Starts the placing process
--//Clones the model
--//Binds function to renderStepped
function PlacementApi:StartPlacement(itemId)
    while (not initialized) do wait() end

    --Clone model into current camera
    itemObject = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId).Lvl1:Clone()
    itemObject.Parent = camera

    --Setup rotation
    itemRotation = math.pi / 2

    --Setup grid
    plotObject.PrimaryPart.Grid.Transparency = 0
    plotObject.PrimaryPart.GridDash.Transparency = 0

    --Bind Actions
    ContextActionService:BindAction("PlaceObject", self.StopPlacement, true, Enum.KeyCode.ButtonR2, Enum.UserInputType.MouseButton1)
    ContextActionService:BindAction("RotateObject", self.RotateObject, true, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1, Enum.KeyCode.R)
    ContextActionService:BindAction("CancelPlacement", self.StopPlacement, true, Enum.KeyCode.X, Enum.KeyCode.ButtonB)

    RunService:BindToRenderStep("UpdatePlacement", 1, UpdatePlacement)
end

--//Stops placing object
function PlacementApi:StopPlacement()
    if (itemObject) then itemObject:Destroy() end
    worldPosition = nil
    localPosition = nil

    --Cleanup grid
    plotObject.PrimaryPart.Grid.Transparency = 1
    plotObject.PrimaryPart.GridDash.Transparency = 1

    --Unbind actions
    ContextActionService:UnbindAction("PlaceObject")
    ContextActionService:UnbindAction("CancelPlacement")
    ContextActionService:UnbindAction("RotateObject")

    RunService:UnbindFromRenderStep("UpdatePlacement")
end

function PlacementApi:PlaceObject()

end


--//Simple smart-rounding method
function PlacementApi:Round(num)
    return (num % 1 >= 0.5 and math.ceil(num) or math.floor(num))
end


function PlacementApi:Start()
    character = (self.Player.Character or self.Player.CharacterAdded:Wait())

    --Update local plotObject when and if plotObject changes
    PlayerService.SendPlotToClient:Connect(function(newPlot)
        plotObject = newPlot

        plotCFrame = plotObject.PrimaryPart.CFrame
        plotMin = plotCFrame - (plotObject.PrimaryPart.Size / 2)
        plotMax = plotCFrame + (plotObject.PrimaryPart.Size / 2)

        --Teleport player to plot
        character:SetPrimaryPartCFrame(plotCFrame + Vector3.new(0, 5, 0))

        initialized = true
    end)

    self.Player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter

        --Teleport player to plot
        character:SetPrimaryPartCFrame(plotCFrame + Vector3.new(0, 5, 0))
    end)

    RunService:BindToRenderStep("SelectionChecking", 0, CheckSelection)
end


function PlacementApi:Init()
    --//Api
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Controllers
    
    --//Classes
    
    --//Locals
    mouse = self.Player:GetMouse()
    camera = workspace.CurrentCamera
    initialized = false

    --Register signals
    self.Events = {}
    self.Events.ObjectPlaced = Instance.new("BindableEvent")
    self.Events.PlacementCancelled = Instance.new("BindableEvent")

    self.Events.PlacementCancelled.Parent = script
    self.Events.ObjectPlaced.Parent = script

    self.PlacementCancelled = self.Events.PlacementCancelled.Event
    self.ObjectPlaced = self.Events.ObjectPlaced.Event

end

return PlacementApi