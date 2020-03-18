-- Player Service
-- MrAsync
-- March 16, 2020



local PlayerService = {Client = {}}


--//Api

--//Services

--//Controllers

--//Classes
local PlayerClass

--//Locals


function PlayerService:Start()
    
    game.Players.PlayerAdded:Connect(function(newPlayer)
        local playerObject = PlayerClass.new(newPlayer)

        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = newPlayer

        local cashValue = Instance.new("NumberValue")
        cashValue.Name = "Cash"
        cashValue.Value = playerObject:GetData("Cash")
        cashValue.Parent = leaderstats

        local populationValue = Instance.new("NumberValue")
        populationValue.Name = "Population"
        populationValue.Value = playerObject:GetData("Population")
        populationValue.Parent = leaderstats
    end)

    game.Players.PlayerRemoving:Connect(function(oldPlayer)
    
    end)

end


function PlayerService:Init()
    --//Api
    
    --//Services
    
    --//Controllers
    
    --//Classes
    PlayerClass = self.Modules.Classes.PlayerClass
    
    --//Locals
    
end


return PlayerService