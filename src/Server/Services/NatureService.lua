-- Nature Service
-- MrAsync
-- July 2, 2020



local NatureService = {Client = {}}

--//Api

--//Services
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

--//Classes

--//Controllers

--//Locals
local TIME_PER_STEP = 0.25


function NatureService:Start()

    --Adjust time of day every step
    RunService.Stepped:Connect(function()
        Lighting:SetMinutesAfterMidnight(Lighting:GetMinutesAfterMidnight() + TIME_PER_STEP)
    end)
end


function NatureService:Init()
	--//Api
    
    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return NatureService