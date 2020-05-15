-- Upgrades
-- MrAsync
-- May 15, 2020



local Upgrades = {}

--//Api

--//Services
local PlayerGui

local NotificationDispatch

--//Controllers

--//Classes
local GuiClass

--//Locals
local GuiObject


--//Public facing Show
function Upgrades:Show()
    return GuiObject:Show()
end


function Upgrades:Start()
    local UpgradesGui = PlayerGui.Upgrades
    GuiObject = GuiClass.new(UpgradesGui)

    GuiObject:BindButton(UpgradesGui.Container.Back)
    GuiObject:BindButton(UpgradesGui.Container.Forward)
    GuiObject:BindButton(UpgradesGui.Container.Purchase)
end


function Upgrades:Init()
    --//Api
    
    --//Services
    PlayerGui = self.Player.PlayerGui

    NotificationDispatch = self.Controllers.NotificationDispatcher

    --//Controllers

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass
    
    --//Locals
    
end

return Upgrades