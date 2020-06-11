-- Placement Api
-- MrAsync
-- June 3, 2020


--[[

    Handles the static management of placing an item

    Methods
        public void PlacemementApi:StartPlacing(Integer itemId)
        public void PlacementApi:StopPlacing()

        private void Update()
        private void Place()
        private void Rotate()
        private boolean CheckCollisions()
        private void DisableCollisions()
        private CFrame plotCFrame, Vector2 plotSize CalculatePlotData()

    Events
        PlacementBegan -> Integer itemId
        PlacementEnded -> Integer itemId
        ObjectPlaced -> Integer itemId, CFrame objectPosition
        ObjectMoved -> CFrame newObjectPosition
        RoadsPlaced -> Array <CFrame> roadPositions
        
]]

local PlacementApi = {}
local self = PlacementApi
self.IsLoaded = false

--//Api
local UserInputApi
local NumberUtil
local EventApi
local LogApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MetaDataService
local PlayerService

--//Classes
local MaidClass

--//Controllers

--//Locals
local Plot
local MouseInputApi

local Camera = Workspace.CurrentCamera
local Session = {}

local DEFAULT_PART_COLOR = Color3.fromRGB(52, 152, 219)
local INVALID_PART_COLOR = Color3.fromRGB(231, 76, 60)
local DUMMY_ROAD_COLOR = Color3.fromRGB(52, 152, 219)

local KEYBOARD_ROTATE = Enum.KeyCode.R
local KEYBOARD_CANCEL = Enum.KeyCode.X
local GAMEPAD_ROTATE = Enum.KeyCode.ButtonR1
local GAMEPAD_ROTATE_ALT = Enum.KeyCode.ButtonL1
local GAMEPAD_CANCEL = Enum.KeyCode.ButtonB


--//Returns a table of models to ignore
--//Character, Model and DummyPart, all placed objects
local function ConstructIgnoreList()
    Session.IgnoreList = {}

    local ignoreList = {self.Player.Character, Session.Model, Session.DummyPart}
    local buildings = Plot.Placements.Building:GetChildren()
    local roads = Plot.Placements.Road:GetChildren()
    
    for _, model in pairs(buildings) do
        table.insert(Session.IgnoreList, model)
    end
    for _, model in pairs(roads) do
        table.insert(Session.IgnoreList, model)
    end

    return ignoreList
end


--//Returns true if DummyPart is colliding with another object
local function CheckCollisions()
    local touchingParts = Session.DummyPart:GetTouchingParts()
    
    for _, part in pairs(touchingParts) do
        local parentModel = part:FindFirstAncestorOfClass("Model")

        if (parentModel and (parentModel.PrimaryPart == part and parentModel.PrimaryPart ~= Session.Model.PrimaryPart)) then
            return true
        end
    end

    return false
end


--//Disables collisions for all parts of Session.Model
local function DisableCollisions()
    for _, part in pairs(Session.Model.Decor:GetChildren()) do
        part.CanCollide = false
    end

    if (Session.Model:FindFirstChild("Base")) then
        Session.Model.Base.CanCollide = false
    end

    Session.Model.PrimaryPart.CanCollide = false
    Session.DummyPart.CanCollide = false
 end


--//Called on RunTime and when the VisualPart changes
--//Calculates the proper Size and CFrame of the plot
local function CalculatePlotData()
    local plotSize = Plot.VisualPart.Size

    local back = Vector3.new(0, -1, 0)
    local top = Vector3.new(0, 0, -1)
    local right = Vector3.new(-1, 0, 0)

    local plotCFrame = Plot.VisualPart.CFrame * CFrame.fromMatrix(-back * plotSize / 2, right, top, back)
    local plotSize = Vector2.new((plotSize * right).magnitude, (plotSize * top).magnitude)

    return plotCFrame, plotSize
end


--//Updates the Session.Rotation
local function Rotate()
    Session.Rotation = Session.Rotation - (math.pi / 2)
end


--//Fires event to signal a placed event
local function Place(roadPositions)
    if (CheckCollisions() and (not roadPositions)) then return end

    if (not roadPositions) then
        self.ObjectPlaced:Fire(Session.ItemId, Session.ObjectPosition)
    else
        self.RoadsPlaced:Fire(roadPositions)
    end
end


--//Updates the model and dummy part
local function Update()
    local ray = MouseInputApi:GetRay(250)
    local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, Session.IgnoreList)

    --DevCrut corrected me because i didn't know math.sin was pronounced different from math.sign
    local hitPositionObjectSpace = Plot.Main.CFrame:PointToObjectSpace(hitPosition)
--    hitPosition = hitPosition - (Vector3.new(math.sign(hitPositionObjectSpace.X), 0, math.sign(hitPositionObjectSpace.Z)) * Session.GridSize / 2)

    --Calculate model size
    local modelSize = CFrame.fromEulerAnglesYXZ(0, Session.Rotation, 0) * Session.Model.PrimaryPart.Size
    modelSize = Vector3.new(math.abs(NumberUtil.Round(modelSize.X)), math.abs(NumberUtil.Round(modelSize.Y)), math.abs(NumberUtil.Round(modelSize.Z)))

    --Get size and position relative to plot
    local lpos = Session.PlotCFrame:PointToObjectSpace(hitPosition)
    local size2 = (Session.PlotSize - Vector2.new(modelSize.X, modelSize.Z)) / 2

    --Constrain model within the bounds of the plot
    local x = math.clamp(lpos.X, -size2.X, size2.X)
    local y = math.clamp(lpos.Y, -size2.Y, size2.Y)

    --Snap model to grid
    x = math.sign(x) * ((math.abs(x) - math.abs(x) % Session.GridSize) + (size2.X % Session.GridSize))
    y = math.sign(y) * ((math.abs(y) - math.abs(y) % Session.GridSize) + (size2.Y % Session.GridSize))

    --Calculate final CFrame
    local newPosition = Session.PlotCFrame * CFrame.new(x, y, -modelSize.Y / 2) * CFrame.Angles(-math.pi / 2, Session.Rotation, 0)

    if (Session.WorldPosition and (Session.WorldPosition ~= newPosition)) then
        self.ObjectMoved:Fire(Plot.Main.CFrame:ToObjectSpace(newPosition))
    end

    --Cache position
    Session.WorldPosition = newPosition
    Session.ObjectPosition = Plot.Main.CFrame:ToObjectSpace(newPosition)

    --Move dummyPart to proper location
    Session.DummyPart.CFrame = newPosition
    Session.Model.PrimaryPart.CFrame = (not Session.HasRan and newPosition or Session.Model.PrimaryPart.CFrame:Lerp(newPosition, Session.DampeningSpeed))

    --Collision detection
    Session.Model.PrimaryPart.Color = (CheckCollisions() and INVALID_PART_COLOR or DEFAULT_PART_COLOR)

    Session.HasRan = true
end


function PlacementApi:StartPlacing(itemId)
    LogApi:Log("Client | PlacementApi | StartPlacing: Initiating Placement")

    Session._Maid = MaidClass.new()
    
    Session.ItemId = itemId
    Session.MetaData = MetaDataService:RequestMetaData(itemId)

    --Clone the model
    Session.Model = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":1")
        Session.Model.Parent = Camera
        Session.Model.PrimaryPart.Transparency = 0.5
        Session.Model.PrimaryPart.Color = DEFAULT_PART_COLOR
        Session._Maid:GiveTask(Session.Model)

    --Clone the dummyPart
    Session.DummyPart = Session.Model.PrimaryPart:Clone()
        Session.DummyPart.Parent = Camera
        Session.DummyPart.Anchored = true
        Session.DummyPart.Transparency = 1
        Session._Maid:GiveTask(Session.DummyPart)
        Session._Maid:GiveTask(Session.DummyPart.Touched:Connect(function() end))

    --Disable collisions
    DisableCollisions()

    --Setup session
    Session.PlotCFrame, Session.PlotSize = CalculatePlotData()
    Session.DampeningSpeed = 0.25
    Session.Rotation = 0
    Session.GridSize = 2
    Session.IgnoreList = ConstructIgnoreList()
    Session.RoadPositions = {}
    Session.RoadModels = {}

    --Grids
    Plot.VisualPart.Grid.Transparency = 0
    Plot.VisualPart.GridDash.Transparency = 0

    LogApi:Log("Client | PlacementApi | StartPlacing: Began updating Placement")

    --Begin updating
    Session._Maid:GiveTask(RunService.Heartbeat:Connect(function()
        Update()
    end))

    LogApi:Log("Client | PlacementApi | StartPlacing: Began listening to Input")

    --Input detection
    Session._Maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (not gameProcessed) then
            if (inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.KeyCode == Enum.KeyCode.ButtonR2) then
                if (Session.MetaData.Type == "Road") then
                    table.insert(Session.RoadPositions, Session.ObjectPosition)

                    --Bind to position changes to cache position to eventaully invoke server
                    Session.RoadConnection = self.ObjectMoved:Connect(function(objectPosition)
                        local cachedPosition = table.find(Session.RoadPositions, objectPosition)

                        --Don't add position twice
                        if (not cachedPosition) then
                            if (#Session.RoadPositions < 15) then
                                table.insert(Session.RoadPositions, objectPosition)
    
                                --Clone road to visualize placed raods
                                local dummyRoad = Session.DummyPart:Clone()
                                dummyRoad.Parent = Camera
                                dummyRoad.Transparency = 0.5
                                dummyRoad.Color = DUMMY_ROAD_COLOR
    
                                table.insert(Session.RoadModels, dummyRoad)
                            end
                        end
                    end)
                else
                    Place()
                end
            elseif (inputObject.KeyCode == KEYBOARD_ROTATE or (inputObject.KeyCode == GAMEPAD_ROTATE or inputObject.KeyCode == GAMEPAD_ROTATE_ALT)) then
                Rotate()
            elseif (inputObject.KeyCode == KEYBOARD_CANCEL or inputObject.KeyCode == GAMEPAD_CANCEL) then
                self:StopPlacing()
            end
        end
    end))

    Session._Maid:GiveTask(UserInputService.InputEnded:Connect(function(inputObject, gameProcessed)
        if (not gameProcessed) then
            if (inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.KeyCode == Enum.KeyCode.ButtonR2) then
                if (Session.RoadConnection) then
                    Session.RoadConnection:Disconnect()

                    --Fire events
                    Place(Session.RoadPositions)

                    --Remove all cloned RoadModels
                    Session.RoadPositions = {}
                    for _, dummyRoad in pairs(Session.RoadModels) do
                        dummyRoad:Destroy()
                    end
                end
            end
        end
    end))

    self.PlacementBegan:Fire(Session.ItemId)
    
    LogApi:Log("Client | PlacementApi | StartPlacing: Completed")
end


function PlacementApi:StopPlacing()
    LogApi:Log("Client | PlacementApi | StopPlacing: StopPlacing has been called!")

    if (Session._Maid) then
        Session._Maid:DoCleaning()
    end

    --Remove all cloned RoadModels
    Session.RoadPositions = {}
    for _, dummyRoad in pairs(Session.RoadModels) do
        dummyRoad:Destroy()
    end

    --Grids
    Plot.VisualPart.Grid.Transparency = 1
    Plot.VisualPart.GridDash.Transparency = 1

    self.PlacementEnded:Fire(Session.ItemId)

    LogApi:Log("Client | PlacementApi | StopPlacing: Completed")
end


function PlacementApi:Start()
    LogApi:Log("Client | PlacementApi | Start: Initiating PlacementApi")

    Plot = (PlayerService:RequestPlot() or PlayerService.RequestPlot:Wait())

    --Setup constants
    MouseInputApi = UserInputApi:Get("Mouse")

    --Register events
    self.PlacementBegan = EventApi.new()
    self.PlacementEnded = EventApi.new()
    self.ObjectPlaced = EventApi.new()
    self.ObjectMoved = EventApi.new()
    self.RoadsPlaced = EventApi.new()

    --Loaded event
    self.IsLoaded = true
    self.Loaded:Fire()

    LogApi:Log("Client | PlacementApi | Start: Completed")
end


function PlacementApi:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi
    EventApi = self.Shared.Event
    NumberUtil = self.Shared.NumberUtil
    UserInputApi = self.Controllers.UserInput

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Classes
    MaidClass = self.Shared.Maid

    --//Controllers

    --//Locals

    self.Loaded = EventApi.new()
end


return PlacementApi