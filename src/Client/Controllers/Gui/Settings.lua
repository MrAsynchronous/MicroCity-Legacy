-- Settings
-- MrAsync
-- May 8, 2020


--[[

    Controls the settings GUI

]]


local Settings = {}

--//Api

--//Services
local PlayerGui

local PlayerService

--//Controllers
local NavigationController

--//Classes
local GuiToggleClass
local GuiClass

--//Locals
local toggleObjectCache = {}


function Settings:Start()
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    local SettingsGui = PlayerGui.Settings
    local GuiObject = GuiClass.new(SettingsGui)

    NavigationController.SettingsButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()
    end)

    PlayerService.GameSettingsLoaded:Connect(function(settingsTable)
        for settingName, isEnabled in pairs(settingsTable) do
            local settingFrame = 
        end
    end)

    --Setup all toggles, create GuiToggleObjects, load settings
    for _, settingFrame in pairs(SettingsGui.Container.List:GetChildren()) do
        if (not settingFrame:IsA("Frame")) then continue end

        local toggleObject = GuiToggleClass.new(settingFrame.Toggle)
        toggleObjectCache[settingFrame] = toggleObject
    end
end


function Settings:Init()
    --//Api

    --//Services
    PlayerGui = self.Player.PlayerGui

    PlayerService = self.Services.PlayerService

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiToggleClass = self.Modules.Classes.GuiToggleClass
    GuiClass = self.Modules.Classes.GuiClass

end


return Settings