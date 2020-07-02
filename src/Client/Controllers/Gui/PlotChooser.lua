-- Plot Chooser
-- MrAsync
-- July 2, 2020

local SaveSelect = {}

--//Api

--//Services
local PlayerService
local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local SaveSelectorGui


function SaveSelect:Start()

    

end


function SaveSelect:Init()
    --//Api
    
    --//Services
    PlayerService = self.Services.PlayerService
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("PlayerGui")
    SaveSelectorGui = CoreGui:WaitForChild("SaveSelector")

end


return SaveSelect