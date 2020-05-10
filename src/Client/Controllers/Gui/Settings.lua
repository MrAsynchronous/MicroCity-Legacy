-- Settings
-- MrAsync
-- May 8, 2020


--[[

    Controls the settings GUI

]]


local Settings = {}
local self = Settings

--//Api

--//Services
local PlayerGui

local SettingsService
local PlayerService

--//Controllers
local NavigationController

--//Classes
local GuiToggleClass
local GuiClass

--//Locals
local GuiObject


--//Updates all toggles
local function UpdateSettings(settingsCache)
    for settingName, isEnabled in pairs(settingsCache) do
        local settingFrame = GuiObject.Container.List:FindFirstChild(settingName)
        if (not settingName) then continue end

        local toggleObject = self[settingFrame.Name]
        toggleObject:SetState(isEnabled)
    end
end


function Settings:Start()  
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    local SettingsGui = PlayerGui.Settings
    GuiObject = GuiClass.new(SettingsGui)

    NavigationController.SettingsButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()
    end)

    --Create ToggleObject for each toggle
    for _, settingFrame in pairs(GuiObject.Container.List:GetChildren()) do
        if (not settingFrame:IsA("Frame")) then continue end

        local toggleObject = GuiToggleClass.new(settingFrame.Toggle)
        self[settingFrame.Name] = toggleObject

        toggleObject.Toggled:Connect(function(newValue)
            SettingsService:ChangeSetting(settingFrame.Name, newValue)

            --Quality of life aesthetic feature (only change when settings gui is active)
            if (settingFrame.Name == "Blur" and GuiObject.Visible) then
                workspace.CurrentCamera.Blur.Enabled = newValue
            end
        end)
    end

    --Request settings from server
    local gameSettings = PlayerService:GetSettings()
    UpdateSettings(gameSettings)
end


function Settings:Init()
    --//Api

    --//Services
    PlayerGui = self.Player.PlayerGui

    SettingsService = self.Services.SettingsService
    PlayerService = self.Services.PlayerService

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiToggleClass = self.Modules.Classes.GuiToggleClass
    GuiClass = self.Modules.Classes.GuiClass

end


return Settings