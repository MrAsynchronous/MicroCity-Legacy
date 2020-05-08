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

--//Controllers

--//Classes

--//Locals
local NavigationGui
local PcContainer
local MobileContainer


function Navigation:Start()
    if (UserInput:GetPreferremd() == UserInput.Preferred.Touch) then
        print("MOBILE")
    else
        for _, button in pairs(PcContainer.Buttons:GetChildren()) do
            if (not button:IsA("Frame")) then continue end

            local defaultSize = button.Button.Size
            local hoverSize = UDim2.new(defaultSize.X.Scale * 1.2, 0, defaultSize.Y.Scale * 1.2, 0)
            local clickSize = UDim2.new(defaultSize.X.Scale * 0.85, 0, defaultSize.Y.Scale * 0.85, 0)

            button.MouseEnter:Connect(function()
                button.Button:TweenSize(hoverSize, "Out", "Quint", 0.1, true)
            end)

            button.MouseLeave:Connect(function()
                button.Button:TweenSize(defaultSize, "In", "Quint", 0.1, true)
            end)

            button.Button.MouseButton1Down:Connect(function()
                button.Button:TweenSize(clickSize, "Out", "Quint", 0.1, true)
            end)

            button.Button.MouseButton1Up:Connect(function()
                button.Button:TweenSize(hoverSize, "In", "Quint", 0.1, true)
            end)

            button.Button.MouseButton1Click:Connect(function()
                self.Events.ButtonClicked:Fire(button.Name)
            end)
        end
    end 
end


function Navigation:Init()
    --//Api
    UserInput = self.Controllers.UserInput

    --//Services
    PlayerGui = self.Player.PlayerGui

    --//Controllers

    --//Classes

    --//Locals
    PcContainer = PlayerGui.Navigation.PC

    self.Events = {}
    self.Events.ButtonClicked = Instance.new("BindableEvent")
    self.ButtonClicked = self.Events.ButtonClicked.Event

end

return Navigation