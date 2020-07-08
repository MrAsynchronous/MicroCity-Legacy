-- Gui
-- MrAsync
-- July 8, 2020



local Gui = {}
Gui.__index = gui

--//Api

--//Services

--//Classes
local MaidClass

--//Controllers

--//Locals
local STOWED_SIZE = UDim2.new(0, 0, 0, 0)
local STOWED_POSITION = UDim2.new(0.5, 0, 1, 0)


function Gui.new(Frame, visible)
    local self = setmetatable({
        Object = Frame,
        Size = Frame.Size,
        Position = Frame.Position,
        Visible = false,

        _Maid = MaidClass.new()
    }, Gui)

    Frame.Position = STOWED_POSITION
    Frame.Size = STOWED_SIZE

    return Gui
end


function Gui:Show()
    self.Visible = true
    self.Object.Visible = true
    self.Object:TweenSizeAndPosition(self.Size, self.Position, "Out", "Quint", 0.25, true)
end


function Gui:Hide()
    self.Object:TweenSizeAndPosition(STOWED_SIZE, STOWED_POSITION, "Out", "Quint", 0.25, true, function()
        self.Object.Visible = false
        self.Visible = false
    end)
end


function Gui:BindButton(button, callback)
    button.MouseButton1Click:Connect(callback)
end


function Gui:Init()
    --//Api
    
    --//Services
    
    --//Classes
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Gui