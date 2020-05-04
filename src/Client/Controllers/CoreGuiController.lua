-- Core Gui Controller
-- MrAsync
-- May 3, 2020

--[[

    Controls the core interfaces

]]


local CoreGuiController = {}

--//Api
local UserInput

--//Services
local StarterGui = game:GetService("StarterGui")
local PlayerGui

--//Controllers

--//Classes

--//Locals
local CoreGui


function CoreGuiController:Start()
    local preferredInput = UserInput:GetPreferred()
    StarterGui:SetCore("TopbarEnabled", false)
    CoreGui.Container.Position = UDim2.new(0.5, 0, 0, -36)

    -- if (preferredInput == UserInput.Preferred.Touch) then
    --     CoreGui.Mobile.Visible = true
    --     CoreGui.PC.Visible = false
    -- else
    --     CoreGui.PC.Visible = true
    --     CoreGui.Mobile.Visible = false
    -- end
end


function CoreGuiController:Init()
    --//Api
    UserInput = self.Controllers.UserInput

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers

    --//Classes

    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")

end


return CoreGuiController