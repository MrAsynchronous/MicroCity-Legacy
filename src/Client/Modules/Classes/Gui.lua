-- Gui
-- MrAsync
-- July 8, 2020



local Gui = {}
Gui.__index = Gui

--//Api

--//Services

--//Classes
local MaidClass

--//Controllers

--//Locals
local STOWED_SIZE = UDim2.new(0, 0, 0, 0)
local STOWED_POSITION = UDim2.new(0.5, 0, 1.5, 0)


function Gui.new(Frame)
    local self = setmetatable({
        Object = Frame,
        Size = Frame.Size,
        Position = Frame.Position,
        Visible = false,

        Binds = {},
        ButtonContainer = Frame:FindFirstChild("ButtonContainer"),

        _Maid = MaidClass.new()
    }, Gui)

    Frame.Position = STOWED_POSITION

    return self
end


function Gui:Show()
    self.Visible = true
    self.Object.Visible = true
    self.Object:TweenPosition(self.Position, "Out", "Quint", 0.35, true)
end


function Gui:Hide(callback)
    self.Object:TweenPosition(STOWED_POSITION, "Out", "Quint", 0.35, true, function()
        self.Object.Visible = false
        self.Visible = false

        if (callback) then
            coroutine.wrap(callback)()
        end
    end)
end


function Gui:BindButton(button, callback)
    local __Maid = MaidClass.new()
    __Maid:GiveTask(button.MouseButton1Click:Connect(callback))

    self.Binds[button] = __Maid
end


function Gui:UnbindButton(button)
    if (not self.Binds[button]) then return end

    self.Binds[button]:Destroy()
    self.Binds[button] = nil
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