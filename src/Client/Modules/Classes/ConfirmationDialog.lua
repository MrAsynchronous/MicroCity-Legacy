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


--//Constructor
function Confirmation.new(textContent)
    local object = ConfirmationDialog:Clone()
    object.Parent = CoreGui
    object.Title.Text = textContent

    local self = setmetatable(GuiClass.new(object), Confirmation)

    self:Show()

    return self
end


--//Add Callback to Yes button
function Confirmation:AddAcceptCallback(callback)
    self:BindButton(self.ButtonContainer.Yes, callback)
end


--//Add Callback to No button
function Confirmation:AddDenyCallback(callback)
    self:BindButton(self.ButtonContainer.No, callback)
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