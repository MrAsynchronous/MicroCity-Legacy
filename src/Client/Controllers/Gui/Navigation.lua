-- Core Gui
-- MrAsync
-- May 4, 2020


--[[

    Handles the core gui (sidebar and mobile topbar)

    Events:
        ButtonClicked -> String buttonName

]]


local Navigation = {}

--//Api
local UserInput

--//Services
local PlayerGui

local PlayerService

--//Controllers

--//Classes
local GuiClass

--//Locals
local isLoaded = false


function Navigation:Start()
    local NavigationGui = PlayerGui.Navigation
    local PcContainer = NavigationGui.PC
    local MobileContainer

    --Create bindableEvent
    self.Events.ButtonClicked = Instance.new("BindableEvent")
    self.ButtonClicked = self.Events.ButtonClicked.Event

    if (UserInput:GetPreferred() == UserInput.Preferred.Touch) then
        local MobileGuiObject
        print("MOBILE")
    else
        local PcGuiObject = GuiClass.new(PcContainer, true)

        for _, button in pairs(PcContainer.Buttons:GetChildren()) do
            if (not button:IsA("Frame")) then continue end

            --Create bindableEvent
            local appendedName = button.Name .. "ButtonClicked"
            self.Events[appendedName] = Instance.new("BindableEvent")
            self[appendedName] = self.Events[appendedName].Event

            --Fire corresponding event when button is clicked
            PcGuiObject:BindButton(button, function()
                self.Events[appendedName]:Fire()
                self.Events.ButtonClicked:Fire(button.Name)
            end)
        end
    end 

    isLoaded = true
    self.Events.IsLoaded:Fire()
end


function Navigation:HasLoaded()
    return isLoaded
end


function Navigation:Init()
    if (not game:IsLoaded()) then
        game.IsLoaded:Wait()
    end

    --//Api
    UserInput = self.Controllers.UserInput

    --//Services
    PlayerGui = self.Player.PlayerGui

    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass

    --//Locals
    self.Events = {}
    self.Events.IsLoaded = Instance.new("BindableEvent")
    self.IsLoaded = self.Events.IsLoaded.Event

end

return Navigation