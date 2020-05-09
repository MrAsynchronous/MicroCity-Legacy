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

--//Controllers
local NavigationController

--//Classes
local GuiClass

--//Locals


function Settings:Start()
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    local SettingsGui = PlayerGui.Settings
    local GuiObject = GuiClass.new(SettingsGui)

    NavigationController.SettingsButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()
    end)
end


function Settings:Init()
    --//Api

    --//Services
    PlayerGui = self.Player.PlayerGui

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass

end


return Settings