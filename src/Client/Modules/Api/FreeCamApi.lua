-- Free Cam Api
-- MrAsync
-- June 27, 2020


--[[

    Used for putting players into building mode

    Methods:
        BuildModeApi:Enter()
        BuildModeApi:Exit(Boolean isFormality)

    Events:
        Entered => Void
        Exited => Void

]]--


local FreeCamApi = {}
FreeCamApi.IsLoaded = false

--//Api
local PlacementApi

--//Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerService

--//Classes
local EventClass
local MaidClass

--//Controllers

--//Locals
local _Maid
local Camera
local Plot

local PlotPosition
local PlotCFrame
local PlotSize
local PlotMin
local PlotMax

local originalCharacterCFrame
local originalCameraCFrame
local focalPoint

local zDistance = 10
local yAngle = 30
local zAngle = 0


local CAMERA_SETTINGS = {
    YSensitivity = 0.25,
    Angle1 = 45,
    Angle2 = 0,
    TransZ = 30,
    MaxZ = 150,
    MinZ = 2,

    PanSpeed = 2,
    ScrollSpeed = 5,
    CameraSpeed = 30
}


--//Updates the cameras CFrame based on position relative to focal point
local function UpdateCamera()
    zDistance = math.clamp(zDistance, CAMERA_SETTINGS.MinZ, CAMERA_SETTINGS.MaxZ)
    local finalAngle = CAMERA_SETTINGS.Angle1

    if (zDistance <= CAMERA_SETTINGS.TransZ) then
        local alpha = math.clamp((zDistance - CAMERA_SETTINGS.MinZ) / (CAMERA_SETTINGS.TransZ - CAMERA_SETTINGS.MinZ), 0, 1)
        finalAngle = CAMERA_SETTINGS.Angle2 + (CAMERA_SETTINGS.Angle1 - CAMERA_SETTINGS.Angle2) * alpha
    end

    Camera.CFrame = CFrame.new(focalPoint) * CFrame.Angles(0, math.rad(yAngle), 0) * CFrame.Angles(math.rad(-finalAngle), 0, 0) * CFrame.new(0, 0, zDistance) * CFrame.Angles(0, 0, math.rad(zAngle))
end


--//Updates the focal point based on the focusDelta
local function UpdateFocalPoint(focalDelta)
    local sterilizedFocalDelta = Vector3.new(
        math.clamp(focalPoint.X + focalDelta.X, PlotMin.X, PlotMax.X),
        focalPoint.Y + focalDelta.Y,
        math.clamp(focalPoint.Z + focalDelta.Z, PlotMin.Z, PlotMax.Z)
    )

    focalPoint = focalPoint + focalDelta
end


function FreeCamApi:EnterAsMenu()
    _Maid:GiveTask(RunService.RenderStepped:Connect(function(t)
        yAngle = yAngle - (0.125 * (t * 60))

        focalPoint = Vector3.new(-7.604, 8.44, 491.829)
        UpdateCamera()
    end))
end


--//Puts player's camera into build mode
function FreeCamApi:Enter()
    FreeCamApi:Exit(true)

    --Localize character, yield until character is ready
    local character = self.Player.Character or self.Player.CharacterAdded:Wait()
    while (not character.PrimaryPart) do wait() end

    --Cache character and camera positions
    originalCharacterCFrame = character.PrimaryPart.CFrame
    originalCameraCFrame = Camera.CFrame

    --Set's up camera, moves character
    Camera.CameraType = Enum.CameraType.Scriptable
    character.PrimaryPart.Anchored = true
    character:SetPrimaryPartCFrame(PlotCFrame - Vector3.new(0, 25, 0))

    --Create dummy value for tweening zDistance
    local zTweenValue = Instance.new("NumberValue")
    zTweenValue.Value = zDistance
    zTweenValue.Changed:Connect(function(newValue)
        zDistance = zTweenValue.Value
    end)
    
    _Maid:GiveTask(zTweenValue)

    _Maid:GiveTask(UserInputService.InputChanged:Connect(function(inputObject, gameProcessed)
        if (gameProcessed) then return end

        if (inputObject.UserInputType == Enum.UserInputType.MouseWheel) then
            local targetDistance = math.clamp(zDistance - (inputObject.Position.Z * CAMERA_SETTINGS.ScrollSpeed), CAMERA_SETTINGS.MinZ, CAMERA_SETTINGS.MaxZ)

            TweenService:Create(zTweenValue, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Value = targetDistance}):Play()
        elseif (inputObject.UserInputType == Enum.UserInputType.MouseMovement) then
            if (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition

                local delta = UserInputService:GetMouseDelta()
                local sensitivity = UserSettings().GameSettings.MouseSensitivity * CAMERA_SETTINGS.YSensitivity

                yAngle = yAngle - (delta.X * sensitivity)
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end
    end))

    _Maid:GiveTask(RunService.RenderStepped:Connect(function(t)
        local focalDelta = Vector3.new(0, 0, 0)
        local nv = Vector3.new()
        local angleDelta = 0
        local projFrontVec = Vector3.new(math.sin(math.rad(yAngle)), 0, math.cos(math.rad(yAngle)))

        focalDelta = focalDelta + (UserInputService:IsKeyDown(Enum.KeyCode.W) and -projFrontVec or nv)
        focalDelta = focalDelta + (UserInputService:IsKeyDown(Enum.KeyCode.A) and -Camera.CFrame.RightVector or nv)
        focalDelta = focalDelta + (UserInputService:IsKeyDown(Enum.KeyCode.S) and projFrontVec or nv)
        focalDelta = focalDelta + (UserInputService:IsKeyDown(Enum.KeyCode.D) and Camera.CFrame.RightVector or nv)
        angleDelta = angleDelta + (UserInputService:IsKeyDown(Enum.KeyCode.Q) and CAMERA_SETTINGS.PanSpeed or 0)
        angleDelta = angleDelta + (UserInputService:IsKeyDown(Enum.KeyCode.E) and -CAMERA_SETTINGS.PanSpeed or 0)

        focalDelta = (focalDelta.Magnitude >= 0.01 and focalDelta.Unit * CAMERA_SETTINGS.CameraSpeed * t or nv)

        yAngle = yAngle - (angleDelta * (t * 60))

        UpdateFocalPoint(focalDelta)
        UpdateCamera()
    end))

    self.Entered:Fire()
end


--//Cleans up, moves player to original place, resets camera
function FreeCamApi:Exit(isFormality)
    _Maid:DoCleaning()
    if (isFormality) then return end

    local character = self.Player.Character or self.Player.CharacterAdded:Wait()

    --Fix camera
    Camera.CameraSubject = character.Humanoid
    Camera.CFrame = originalCameraCFrame or character.Head.CFrame
    Camera.CameraType = Enum.CameraType.Custom

    --Reset character
    character:SetPrimaryPartCFrame(originalCharacterCFrame or PlotCFrame + Vector3.new(0, 10, 0))
    character.PrimaryPart.Anchored = false

    self.Exited:FireW()
end


function FreeCamApi:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())

    PlotPosition = Plot.PrimaryPart.Position
    PlotCFrame = Plot.PrimaryPart.CFrame
    PlotSize = Plot.PrimaryPart.Size
    PlotMin = PlotPosition - (PlotSize / 2)
    PlotMax = PlotPosition + (PlotSize / 2)

    focalPoint = PlotPosition + Vector3.new(0, 5, 0)
    zDistance = CAMERA_SETTINGS.MaxZ / 2

    _Maid = MaidClass.new()

    self.IsLoaded = true
    self.Loaded:Fire()
end


function FreeCamApi:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    EventClass = self.Shared.Event
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    Camera = Workspace.CurrentCamera
    
    self.Loaded = EventClass.new()
    self.Entered = EventClass.new()
    self.Exited = EventClass.new()
end


return FreeCamApi