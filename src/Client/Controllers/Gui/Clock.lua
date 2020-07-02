-- Clock
-- MrAsync
-- July 2, 2020



local Clock = {}

--//Api

--//Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local ClockGui


function Clock:Start()
    RunService.RenderStepped:Connect(function()
        local hour, minutes = math.modf(Lighting.ClockTime)
        hour = Lighting.ClockTime
        minutes = (minutes * 60)

        --Hour modifiers
        hour = (hour == 0 and 12 or hour)
        hour = (hour > 12 and hour - 12 or hour)
        
        --Grab stringified time | to Text
        local timeTable = string.split(Lighting.TimeOfDay, ":")
        ClockGui.Digital.Text = timeTable[1] .. ":" .. timeTable[2] .. (hour == 12 and "pm" or "am")
        ClockGui.Hour.Rotation = (hour / 12) * 360
        ClockGui.Minute.Rotation = (minutes / 60) * 360
    end)
end


function Clock:Init()
    --//Api
    
    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui") 
    ClockGui = CoreGui:WaitForChild("Clock")

end


return Clock