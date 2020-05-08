-- Codes
-- MrAsync
-- May 7, 2020



local Codes = {}

--//Api

--//Services
local PlayerGui

--//Controllers
local NavigationController

--//Classes
local GuiClass

--//Locals
local CodesGui
local GuiObject

function Codes:Start()
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    CodesGui = PlayerGui.Codes
    GuiObject = GuiClass.new(CodesGui)

    NavigationController.CodesButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()
    end)
end


function Codes:Init()
    --//Api

    --//Services
     PlayerGui = self.Player.PlayerGui

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass

    --//Locals

end


return Codes