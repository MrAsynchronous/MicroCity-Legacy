-- Confirmation
-- MrAsync
-- July 9, 2020



local Confirmation = {}
Confirmation.__index = Confirmation

--//Api

--//Services
local PlayerGui

--//Classes
local GuiClass

--//Controllers

--//Locals
local CoreGui
local ConfirmationDialog


function Confirmation.new(isShowing)
    local object = ConfirmationDialog:Clone()
    object.Parent = CoreGui

    local self = setmetatable(GuiClass.new(object), Confirmation)

    --Show if Confirmation is to be showns
    if (isShowing) then
        self:Show()
    end

    return self
end

function Confirmation:Destroy()
    self:Hide(function()
        self.Object:Destroy()
    end)
end


function Confirmation:Init()
    --//Api
    
    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    GuiClass = self.Modules.Classes.Gui

    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    ConfirmationDialog = CoreGui.ConfirmationDialog

    --Inheritence
    setmetatable(self, GuiClass)
end


return Confirmation