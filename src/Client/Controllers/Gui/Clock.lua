-- Clock
-- MrAsync
-- July 2, 2020



local Clock = {}

--//Api

--//Services
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local ClockGui


function Clock:Start()
    Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
        local timeTable = string.split(Lighting.TimeOfDay, ":")
        local hour, minute = tonumber(timeTable[1]), tonumber(timeTable[2])
        hour = (hour > 12 and hour - 12 or hour)


        local minuteRotation = ((360 / 60) * minute) % 360
        local hourRotation = ((360 / 12) * hour) % 360
        

        ClockGui.Minute.Rotation = minuteRotation
        ClockGui.Hour.Rotation = hourRotation
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