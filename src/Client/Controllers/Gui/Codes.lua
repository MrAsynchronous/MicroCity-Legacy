-- Codes
-- MrAsync
-- May 7, 2020



local Codes = {}

--//Api

--//Services
local PlayerGui

local NotificationDispatch
local CodeService

--//Controllers
local NavigationController

--//Classes
local GuiClass  

--//Locals
local DEFAULT_INPUTBOX_MESSAGE = "Enter Code Here"

function Codes:Start()
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    local CodesGui = PlayerGui.Codes
    local GuiObject = GuiClass.new(CodesGui)

    --Bind Submit button, onClick, invokeServer
    GuiObject:BindButton(CodesGui.Container.Submit, function()
        local playerInput = CodesGui.Container.InputBox.Text
        if (playerInput == "" or playerInput == DEFAULT_INPUTBOX_MESSAGE) then return end

        local returnData = CodeService:RedeemCode(playerInput)
        NotificationDispatch:Dispatch(returnData.noticeObject)
    end)

    --Navigation Button Bind
    NavigationController.CodesButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()

        CodesGui.Container.InputBox.Text = DEFAULT_INPUTBOX_MESSAGE
    end)
end


function Codes:Init()
    --//Api

    --//Services
    PlayerGui = self.Player.PlayerGui

    NotificationDispatch = self.Controllers.NotificationDispatcher
    CodeService = self.Services.CodeService

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass

    --//Locals

end


return Codes