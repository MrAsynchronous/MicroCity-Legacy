-- Gamepad Cursor
-- MrAsync
-- April 10, 2020



local GamepadCursor = {}

--//Api

--//Services
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local PlayerScripts
local PlayerGui

--//Controllers
local PlayerModule
local ControlModule

--//Classes

--//Locals
local CursorGui
local Cursor

local isInCursorMode
local currentPosition
local currentMoveDirection
local inputChangedConnection

local SENSITIVIY = 10
local THUMBSTICK_KEY = Enum.KeyCode.Thumbstick1
local ACTIVATION_KEY = Enum.KeyCode.ButtonSelect
local THUMBSTICK_DEADZONE = 0.25

--[[
    Private Methods
]]

--//Updates the position of the Cursor
local function UpdateCursor()
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
    ControlModule:Disable()
    Cursor.Visible = true

    --Create new connection to input changed to detect thumbstick movements
    inputChangedConnection = UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if (input.KeyCode == THUMBSTICK_KEY) then
            if (input.Position.Magnitude > THUMBSTICK_DEADZONE) then
                currentMoveDirection = Vector2.new(input.Position.X, -input.Position.Y) * SENSITIVIY
            else
                currentMoveDirection = Vector2.new(0, 0)
            end
        end
    end)

    Cursor.Position = UDim2.new(0, CursorGui.AbsoluteSize.X / 2, 0, CursorGui.AbsoluteSize.Y / 2)
    RunService:BindToRenderStep("CursorUpdate", 4, UpdateCursor)
end


--//Cleans up client to stop pointing
local function Cleanup()
    UserInputService.MouseIconEnabled = true
    GuiService.GuiNavigationEnabled = true
    GuiService.AutoSelectGuiEnabled = true
    ControlModule:Enable()
    Cursor.Visible = false
    
    --Disconnect InputChanged event
    if (inputChangedConnection) then
        inputChangedConnection:Disconnect()
    end

    RunService:UnbindToRenderStep("CursorUpdate", 4, UpdateCursor)
end


function GamepadCursor:Start()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if (input.KeyCode == ACTIVATION_KEY) then
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

    --//Services
    PlayerScripts = PlayerGui:WaitForChild("PlayerScripts")
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers
    PlayerModule = PlayerScripts:WaitForChild("PlayerModule")
    ControlModule = require(PlayerModule:WaitForChild("ControlModule"))

    --//Classes

    --//Locals
    CursorGui = PlayerGui:WaitForChild("ControllerCursor")
    Cursor = CursorGui.Pointer

    isInCursorMode = false
    currentPosition = UDim2.new(0, 0, 0, 0)
    currentMoveDirection = Vector2.new(0, 0)

end


return GamepadCursor