-- Gamepad Cursor
-- MrAsync
-- April 10, 2020



local GamepadCursor = {}

--//Api
local UserInput
local Gamepad

--//Services
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local PlayerScripts
local PlayerGui

--//Controllers
local PlayerModule
local PlayerControl

--//Classes

--//Locals
local CursorGui
local Cursor

local leftThumbstick
local isInCursorMode
local currentPosition
local currentMoveDirection

local SENSITIVIY = 10
local THUMBSTICK_KEY = Enum.KeyCode.Thumbstick1
local ACTIVATION_KEY = Enum.KeyCode.ButtonSelect
local THUMBSTICK_DEADZONE = 0.25

--[[
    Private Methods
]]

--//Updates the position of the Cursor
local function UpdateCursor()
    --Update move direction by polling position
    if (leftThumbstick.Position.Magnitude > THUMBSTICK_DEADZONE) then
        currentMoveDirection = Vector2.new(leftThumbstick.Position.X, -leftThumbstick.Position.Y) * SENSITIVIY
    else
        currentMoveDirection = Vector2.new(0, 0)
    end

    --Construct a new UDim2 position
    currentPosition = currentPosition + UDim2.new(0, currentMoveDirection.X, 0, currentMoveDirection.Y)

    --Constrain with screen bounds
    currentPosition = UDim2.new(0,
        math.clamp(currentPosition.X.Offset, 0, CursorGui.AbsoluteSize.X), 0,
        math.clamp(currentPosition.Y.Offset, 0, CursorGui.AbsoluteSize.Y)
    )

    --Update position of Cursor
    Cursor.Position = currentPosition
end


--//Set's up client to begin pointing
local function Setup()
    UserInputService.MouseIconEnabled = false
    GuiService.GuiNavigationEnabled = false
    GuiService.AutoSelectGuiEnabled = false
    Cursor.Visible = true

    PlayerControl:Disable()

    currentPosition = UDim2.new(0, CursorGui.AbsoluteSize.X / 2, 0, CursorGui.AbsoluteSize.Y / 2)
    RunService:BindToRenderStep("CursorUpdate", 4, UpdateCursor)
end


--//Cleans up client to stop pointing
local function Cleanup()
    UserInputService.MouseIconEnabled = true
    GuiService.GuiNavigationEnabled = true
    GuiService.AutoSelectGuiEnabled = true
    Cursor.Visible = false

    GuiService.SelectedObject = nil
    PlayerControl:Enable()

    RunService:UnbindFromRenderStep("CursorUpdate")
end


function GamepadCursor:Start()
    Gamepad = UserInput:Get("Gamepad").new(Enum.UserInputType.Gamepad1)
    leftThumbstick = Gamepad:GetState(THUMBSTICK_KEY)

    Gamepad.ButtonDown:Connect(function(keyCode)
        if (keyCode == ACTIVATION_KEY) then
            isInCursorMode = not isInCursorMode

            if (isInCursorMode) then
                Setup()
                
            else
                Cleanup()
            end
        end
    end)
end


function GamepadCursor:Init()
    --//Api
    UserInput = self.Controllers.UserInput

    --//Services
    PlayerScripts = self.Player:WaitForChild("PlayerScripts")
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers
    PlayerModule = PlayerScripts:WaitForChild("PlayerModule")
    PlayerControl = require(PlayerModule:WaitForChild("ControlModule"))

    --//Classes

    --//Locals
    CursorGui = PlayerGui:WaitForChild("GamepadCursor")
    Cursor = CursorGui.Pointer

    isInCursorMode = false
    currentPosition = UDim2.new(0, 0, 0, 0)
    currentMoveDirection = Vector2.new(0, 0)

end


return GamepadCursor