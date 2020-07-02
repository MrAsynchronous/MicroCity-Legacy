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

    for _, saveButton in pairs(SaveSelectorGui.Container:GetChildren()) do
        saveButton.Button.MouseButton1Click:Connect(function()
            PlayerService:RequestSaveSelect(tonumber(saveButton.Name))
        end)
    end

end


function SaveSelect:Init()
    --//Api
    
    --//Services
    PlayerService = self.Services.PlayerService
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    SaveSelectorGui = CoreGui:WaitForChild("SaveSelector")

end


return SaveSelect