-- Client Controller
-- MrAsync
-- March 29, 2020


--[[

    General purpose controller than controls the initialization of the client

]]


local ClientController = {}

--//Api

--//Services
local PlayerService

--//Controllers

--//Classes

--//Locals
local plotObject


function ClientController:Start()
    --Move character to plot
    local character = (self.Player.Character or self.Player.CharacterAdded:Wait())
    while (not character.PrimaryPart) do wait() end

    character:SetPrimaryPartCFrame(plotObject.Main.CFrame + Vector3.new(0, 5, 0))

    --Spawn character at plot on character reload
    self.Player.CharacterAdded:Connect(function(newCharacter)
        newCharacter:SetPrimaryPartCFrame(plotObject.Main.CFrame + Vector3.new(0, 5, 0))
    end)
end


function ClientController:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals	
    plotObject = self.Player:WaitForChild("PlotObject").Value
    
end


return ClientController