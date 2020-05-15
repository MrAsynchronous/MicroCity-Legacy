-- Gui Class
-- MrAsync
-- May 8, 2020


--[[

    Subclass inherited by GuiControllers.  Allows UI to be easily hidden and shown

    Methods:
        public BindButton(GuiObject buttonObject, Function callback)
        public Show()
        public Hide()
        public Destroy()
        public ChangeVisibility(Boolean isVisible)
]]


local GuiClass = {}
GuiClass.__index = GuiClass

--//Controllers
local SettingsController

--//Classes
local MaidClass

--//Locals
local CLOSED_POSITION = UDim2.new(0.5, 0, 1, 0)
local CLOSED_SIZE = UDim2.new(0, 0, 0, 0)

local TWEEN_LENGTH = 0.25


--//Constructor
function GuiClass.new(guiObject, isVisible)
    local self = setmetatable({
        Object = guiObject,
        IsVisible = false,
        IsTweening = false,

        _Maid = MaidClass.new()
    }, GuiClass)

    self.Container = guiObject:FindFirstChild("Container")
    if (not self.Container and (guiObject:IsA("Frame"))) then
        self.Container = guiObject
    end

    self.IsVisible = isVisible
    self.Container.Visible = isVisible

    self.OriginalSize = self.Container.Size
    self.OriginalPosition = self.Container.Position

    --Set to inactive state if guiObject is not visible
    if (not isVisible) then
        self.Container.Position = CLOSED_POSITION
        self.Container.Size = CLOSED_SIZE
    end

    --Bind close button if needed
    local closeButton = self.Container:FindFirstChild("Close")
    if (closeButton) then
        self:BindButton(closeButton, function()
            self.IsVisible = false
            self:Hide()

            --Call closeButton callBack
            if (self.CloseButtonCallback) then
                coroutine.wrap(self.CloseButtonCallback)()
            end
        end)
    end

    return self
end 


--//Binds a button for effects, calls callback function when button is clicked
function GuiClass:BindButton(buttonObject, callback)
    local defaultSize = buttonObject.Button.Size
    local hoverSize = UDim2.new(defaultSize.X.Scale * 1.2, 0, defaultSize.Y.Scale * 1.2, 0)
    local clickSize = UDim2.new(defaultSize.X.Scale * 0.85, 0, defaultSize.Y.Scale * 0.85, 0)

    self._Maid:GiveTask(buttonObject.MouseEnter:Connect(function()
        buttonObject.Button:TweenSize(hoverSize, "Out", "Quint", 0.1, true)
    end))

    self._Maid:GiveTask(buttonObject.MouseLeave:Connect(function()
        buttonObject.Button:TweenSize(defaultSize, "In", "Quint", 0.1, true)
    end))

    self._Maid:GiveTask(buttonObject.Button.MouseButton1Down:Connect(function()
        buttonObject.Button:TweenSize(clickSize, "Out", "Quint", 0.1, true)
    end))

    self._Maid:GiveTask(buttonObject.Button.MouseButton1Up:Connect(function()
        buttonObject.Button:TweenSize(hoverSize, "In", "Quint", 0.1, true)
    end))

    self._Maid:GiveTask(buttonObject.Button.MouseButton1Click:Connect(function()
        if (callback) then
            coroutine.wrap(callback)()
        end
    end))
end


--//Overwrite the default CloseButtonCallback
function GuiClass:AddCallbackToClose(callback)
    self.CloseButtonCallback = callback
end


--//Receives the isVisible bool from controller, shows or hides GUI according to inverse boolean
function GuiClass:ChangeVisibility()
    if (self.IsTweening) then return end
    self.IsVisible = not self.IsVisible

    if (self.IsVisible) then
        self:Show()
    else
        self:Hide()
    end
end


--//Shows the GUI
function GuiClass:Show()
    self.Container.Visible = true
    self.IsTweening = true
    self.Container:TweenSizeAndPosition(self.OriginalSize, self.OriginalPosition, "Out", "Quint", TWEEN_LENGTH, true, function()
        self.IsTweening = false
    end)

    --Settings permitting, enable blur
    if (SettingsController.Blur.Enabled) then
        workspace.CurrentCamera.Blur.Enabled = true
    end
end


--//Hides the GUI
function GuiClass:Hide()
    self.IsTweening = true
    self.Container:TweenSizeAndPosition(CLOSED_SIZE, CLOSED_POSITION, "Out", "Quint", TWEEN_LENGTH, true, function()
        self.IsTweening = false
        self.Container.Visible = false
    end)

    workspace.CurrentCamera.Blur.Enabled = false
end


--//Cleans all parts of self._Maid
function GuiClass:Destroy()
    self._Maid:Destroy()
end


function GuiClass:Init()
    --//Controllers
    SettingsController = self.Controllers.Gui.Settings

    --//Classes
    MaidClass = self.Shared.Maid

end


return GuiClass