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
local plotSize
local isMoving
local dummyPart
local plotCFrame
local itemObject
local isColliding
local itemRotation
local localPosition
local worldPosition
local selectedObject

local GRID_SIZE = 2
local BUILD_HEIGHT = 1024
local UP = Vector3.new(0, 1, 0)
local BACK = Vector3.new(0, 0, 1)
local DAMPENING_SPEED = .2
local COLLISION_COLOR = Color3.fromRGB(231, 76, 60)
local NO_COLLISION_COLOR = Color3.fromRGB(46, 204, 113)

--[[
    PRIVATE METHODS
]]


--//Checks to see if model is touching another model
local function CheckCollision()
    local touchingParts = dummyPart:GetTouchingParts()

    --Iterate through touching parts
    for _, part in pairs(touchingParts) do
        local model = part:FindFirstAncestorOfClass("Model")

        --If part IsDescendantOf a placed object, return true
        if (model and model:IsDescendantOf(plotObject.Placements) and (model.PrimaryPart == part)) then
            return true
        end
    end

    return false
end


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


--//Fires the ObjectMoved signal
local function MoveObject(_, inputState)
    if (inputState == Enum.UserInputState.Begin) then
        if (not CheckCollision()) then
            self.Events.ObjectMoved:Fire(itemId, localPosition)
        end
    end
end


--//Fires the ObjectPlaced signal
local function PlaceObject(_, inputState)
    if (inputState == Enum.UserInputState.Begin) then
        if (not CheckCollision()) then
            self.Events.ObjectPlaced:Fire(itemId, localPosition)
        end
    end
end


--//Calculates the proper CFrame and Size for the canvas
--//Taking into consideration the rotation of the model
local function CalcCanvas()
	local canvasSize = plotObject.Main.Size

	-- want to create CFrame such that cf.lookVector == self.CanvasPart.CFrame.upVector
	-- do this by using object space and build the CFrame
	local back = Vector3.new(0, -1, 0)
	local top = Vector3.new(0, 0, -1)
	local right = Vector3.new(-1, 0, 0)

	-- convert to world space
	local cf = plotObject.Main.CFrame * CFrame.fromMatrix(-back*canvasSize/2, right, top, back)
	-- use object space vectors to find the width and height
	local size = Vector2.new((canvasSize * right).magnitude, (canvasSize * top).magnitude)

	return cf, size
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
            selectedObject = rayPart:FindFirstAncestorOfClass("Model")
                
            self.Events.PlacementSelectionStarted:Fire(selectedObject)
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
    local rayPart, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(mouseRay, {character, itemObject, dummyPart})

    --Calculate model size according to current itemRotation
	local modelSize = CFrame.fromEulerAnglesYXZ(0, itemRotation, 0) * itemObject.PrimaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))

	--Get model size and position relative to the plot
	local lpos = plotCFrame:pointToObjectSpace(hitPosition);
	local size2 = (plotSize - Vector2.new(modelSize.x, modelSize.z))/2

	--Constrain model withing the bounds of the plot
	local x = math.clamp(lpos.x, -size2.x, size2.x);
    local y = math.clamp(lpos.y, -size2.y, size2.y);

    --Align model GRID_SIZE
	x = math.sign(x)*((math.abs(x) - math.abs(x) % GRID_SIZE) + (size2.x % GRID_SIZE))
	y = math.sign(y)*((math.abs(y) - math.abs(y) % GRID_SIZE) + (size2.y % GRID_SIZE))

    --Calculate the worldSpace and ObjectSpace CFrame
    worldPosition = plotCFrame * CFrame.new(x, y, -modelSize.y/2) * CFrame.Angles(-math.pi/2, itemRotation, 0)
    localPosition = plotObject.Main.CFrame:ToObjectSpace(worldPosition)

    --Set the position of the object
    dummyPart.CFrame = worldPosition
    itemObject:SetPrimaryPartCFrame(itemObject.PrimaryPart.CFrame:Lerp(worldPosition, DAMPENING_SPEED))

    --Check collision
    isColliding = CheckCollision()

    --Color bounding box according to collision state
    if (isColliding) then
        itemObject.PrimaryPart.Color = COLLISION_COLOR
    else
        itemObject.PrimaryPart.Color = NO_COLLISION_COLOR
    end
end

--[[
    PUBLIC METHODS
]]



--//Starts the placing process
--//Clones the model
--//Binds function to renderStepped
function PlacementApi:StartPlacing(id, placementObject)
    self:StopPlacing()

    --If placementObject is a valid arg, player is moving object
    if (placementObject) then
        isMoving = true

        itemObject = placementObject
        itemObject.Parent = camera
    else
        --Clone model into current camera
        --IMPLEMENT LEVEL SELECTION
        itemObject = ReplicatedStorage.Items.Buildings:FindFirstChild(id .. ":1"):Clone()
        itemObject.Parent = camera
        itemId = id
    end

    --Create dummy part,used for checking collisions
    dummyPart = itemObject.PrimaryPart:Clone()
    dummyPart.Parent = camera
    dummyPart.Touched:Connect(function() end)

    --Show bounding box, set position to plot
    itemObject.PrimaryPart.Transparency = .5
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
    if (dummyPart) then dummyPart:Destroy() end

    --Reset locals
    localPosition = nil
    worldPosition = nil
    isColliding = false
    isMoving = false
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
    local playerPlotValue = self.Player:WaitForChild("PlayerPlot")
    plotObject = playerPlotValue.Value

    --Yield until Plot.Main exists
    while (not plotObject:FindFirstChild("Main")) do wait() end

    --Setup plot locals
    plotCFrame, plotSize = CalcCanvas()

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
    camera = workspace.CurrentCamera
    mouse = self.Player:GetMouse()

    --Register signals
    self.Events = {}
    self.Events.PlacementSelectionStarted = Instance.new("BindableEvent")
    self.Events.PlacementSelectionEnded = Instance.new("BindableEvent")
    self.Events.PlacementCancelled = Instance.new("BindableEvent")
    self.Events.ObjectPlaced = Instance.new("BindableEvent")
    self.Events.ObjectMoved = Instance.new("BindableEvent")

    self.ObjectMoved = self.Events.ObjectMoved.Event
    self.ObjectPlaced = self.Events.ObjectPlaced.Event
    self.PlacementCancelled = self.Events.PlacementCancelled.Event
    self.PlacementSelectionEnded = self.Events.PlacementSelectionEnded.Event
    self.PlacementSelectionStarted = self.Events.PlacementSelectionStarted.Event
end

return PlacementApi