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
local SnapApi
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


--//Caches the current position for a raod
local function CacheRoad(rawPosition)
    local cachedPosition = table.find(Session.RoadPositions, rawPosition)
    if (cachedPosition) then return end

    if (#Session.RoadPositions < 15) then
        table.insert(Session.RoadPositions, rawPosition)

        --Clone road to visualize placed raods
        local dummyRoad = Session.DummyPart:Clone()
        dummyRoad.Parent = Camera
        dummyRoad.Transparency = 0.5
        dummyRoad.Color = DUMMY_ROAD_COLOR

        table.insert(Session.RoadModels, dummyRoad)
    end
end


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


--//Fires event to signal a placed event
local function Place(roadPositions)
    if (CheckCollisions() and (not roadPositions)) then return end

    if (not roadPositions) then
        self.ObjectPlaced:Fire(Session.ItemId, Session.RawPosition, Session.Rotation)
    else
        self.RoadsPlaced:Fire(roadPositions)
    end
end


--//Updates the model and dummy part
local function Update()
    local ray = MouseInputApi:GetRay(250)
    local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, Session.IgnoreList)

    --Call SnapApi to get a snapped position
    local worldPosition = SnapApi:SnapVector(Plot, Session.Model, hitPosition, Session.Rotation)

    --Fire PositionChanged event
    if (Session.WorldPosition and (Session.WorldPosition ~= worldPosition)) then
        self.PositionChanged:Fire(hitPosition)
    end

    --Cache position
    Session.RawPosition = hitPosition
    Session.WorldPosition = worldPosition

    --Move dummyPart to proper location
    Session.DummyPart.CFrame = worldPosition
    Session.Model.PrimaryPart.CFrame = (not Session.HasRan and worldPosition or Session.Model.PrimaryPart.CFrame:Lerp(worldPosition, Session.DampeningSpeed))

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
    Session.PlotCFrame, Session.PlotSize =  SnapApi:GetPlotData(Plot)
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

    --Input detection, handles road placement
    Session._Maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (not gameProcessed) then
            if (inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.KeyCode == Enum.KeyCode.ButtonR2) then
                if (Session.MetaData.Type == "Road") then
                    CacheRoad(Session.RawPosition)

                    --Bind to position changes to cache position to eventaully invoke server
                    Session.RoadConnection = self.PositionChanged:Connect(function(rawPosition)
                        CacheRoad(rawPosition)
                    end)
                else
                    Place()
                end
            elseif (inputObject.KeyCode == KEYBOARD_ROTATE or (inputObject.KeyCode == GAMEPAD_ROTATE or inputObject.KeyCode == GAMEPAD_ROTATE_ALT)) then
                Session.Rotation = SnapApi:Rotate(Session.Rotation)
            elseif (inputObject.KeyCode == KEYBOARD_CANCEL or inputObject.KeyCode == GAMEPAD_CANCEL) then
                self:StopPlacing()
            end
        end
    end))

    --Handles the cleanup when a user is placing roads
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
    self.PositionChanged = EventApi.new()
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
    SnapApi = self.Shared.Api.SnapApi
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