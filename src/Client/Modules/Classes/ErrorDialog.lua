-- Error
-- MrAsync
-- July 9, 2020



local Error = {}
Error.__index = Error

--//Api

--//Services
local PlayerGui

--//Classes
local GuiClass

--//Controllers

--//Locals
local CoreGui
local ErrorDialog


--//Constructor
function Error.new(textContent)
    local object = ErrorDialog:Clone()
    object.Parent = CoreGui
    object.Title.Text = textContent

    local self = setmetatable(GuiClass.new(object), Error)

    self:Show()
    self:AddAcceptCallback(function()
        self:Destroy()
    end)

    return self
end


--//Add Callback to Yes button
function Error:AddAcceptCallback(callback)
    self:BindButton(self.ButtonContainer.Ok, callback)
end


function Error:Destroy()
    self:Hide(function()
        self.Object:Destroy()
    end)
end


function Error:Init()
    --//Api

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    GuiClass = self.Modules.Classes.Gui

    --//Controllers

    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    ErrorDialog = CoreGui.ErrorDialog

    --Inheritence
    setmetatable(self, GuiClass)
end


return Error