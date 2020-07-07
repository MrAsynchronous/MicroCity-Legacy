-- Clock
-- MrAsync
-- July 2, 2020



local Clock = {}

--//Api
local Roact

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local Element

function Clock:Start()
    local clockApp = Roact.mount(Element:render(0, 0), CoreGui)

    RunService.RenderStepped:Connect(function()
        local hour, minutes = math.modf(Lighting.ClockTime)
        hour = Lighting.ClockTime
        minutes = (minutes * 60)

        --Hour modifiers
        hour = (hour == 0 and 12 or hour)
        hour = (hour > 12 and hour - 12 or hour)
        
        --Update component
        Roact.update(clockApp, Element:render(
            (hour / 12) * 360,
            (minutes / 60) * 360
        ))
    end)
end


function Clock:Init()
    --//Api
    Roact = require(ReplicatedStorage.Roact)

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    Element = require(script.Element)

end


return Clock