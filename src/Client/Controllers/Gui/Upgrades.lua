-- Upgrades
-- MrAsync
-- May 15, 2020



local Upgrades = {}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui

local NotificationDispatch
local MetaDataService
local PlayerService

--//Controllers

--//Classes
local GuiClass

--//Locals
local GuiObject


--//Public facing Show
function Upgrades:Show(guid)
    --Viewport!
    local itemId = PlayerService:GetItemIdFromGuid(guid)
    local metaData = MetaDataService:GetMetaData(itemId)

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
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass
    
    --//Locals
    
end

return Upgrades