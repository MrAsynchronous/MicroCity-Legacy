-- Gui Toggle Class
-- MrAsync
-- May 9, 2020


--[[

    Objects created are toggleable UI elements used for settings

    Methods:
        public Toggle()
        public Enable()
        public Disable()
        public ToggleToBoolean()

]]


local GuiToggleClass = {}
GuiToggleClass.__index = GuiToggleClass

--//Services
local TweenService = game:GetService("TweenService")

--//Locals
local ACTIVE_TOGGLE_POSITION = UDim2.new(0.73, 0, 0.5, 0)
local INACTIVE_TOGGLE_POSITION = UDim2.new(0.26, 0, 0.5, 0)
local ACTIVE_TOGGLE_COLOR = Color3.fromRGB(88, 214, 141)
local INACTIVE_TOGGLE_COLOR = Color3.fromRGB(236, 112, 99)

local EASING_STYLE = Enum.EasingStyle.Quint
local EASING_DIRECTION = Enum.EasingDirection.Out


--//Constuctor for guiToggleClass
function GuiToggleClass.new(guiObject, isEnabled)
    local self = setmetatable({
        Object = guiObject,
        Enabled = isEnabled,

        _Toggled = Instance.new("BindableEvent")
    }, GuiToggleClass)

    --Setup event
    self.Toggled = self._Toggled.Event

    if (not self.Enabled) then
        self:Disable()
    end

    self.Object.Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    self.Object.Background.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    return self
end


--//Toggles the button to reflect an inverse state
function GuiToggleClass:Toggle()
    self.Enabled = not self.Enabled

    if (self.Enabled) then
        self:Enable()
    else
        self:Disable()
    end
end


--//Visually updates the toggle to reflect an enabled state
function GuiToggleClass:Enable()
    self.Enabled = true

    local colorTween = TweenService:Create(self.Object.Background, TweenInfo.new(0.25, EASING_STYLE, EASING_DIRECTION), {ImageColor3 = ACTIVE_TOGGLE_COLOR})
    colorTween.Completed:Connect(function()
        colorTween:Destroy()
    end)

    self.Object.Button:TweenPosition(ACTIVE_TOGGLE_POSITION, EASING_DIRECTION, EASING_STYLE, 0.25, true)
    colorTween:Play()

    self._Toggled:Fire(self.Enabled)
end


--//Visually updates the toggle to reflect a disabled state
function GuiToggleClass:Disable()
    self.Enabled = false

    local colorTween = TweenService:Create(self.Object.Background, TweenInfo.new(0.25, EASING_STYLE, EASING_DIRECTION), {ImageColor3 = INACTIVE_TOGGLE_COLOR})
    colorTween.Completed:Connect(function()
        colorTween:Destroy()
    end)

    self.Object.Button:TweenPosition(INACTIVE_TOGGLE_POSITION, EASING_DIRECTION, EASING_STYLE, 0.25, true)
    colorTween:Play()

    self._Toggled:Fire(self.Enabled)
end


--//Sets the state of the toggle to the passed boolean
function GuiToggleClass:SetState(isEnabled)
    if (isEnabled) then
        self:Enable()
    else
        self:Disable()
    end
end


return GuiToggleClass