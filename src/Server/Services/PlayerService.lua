-- Player Service
-- MrAsync
-- March 16, 2020



local PlayerService = {Client = {}}


--//Api

--//Services
local PlotService

--//Controllers

--//Classes
local PlayerClass

--//Locals
local playerObjects


function PlayerService:Start()
    
    game.Players.PlayerAdded:Connect(function(newPlayer)
        --Create playerObject
        local playerObject = PlayerClass.new(newPlayer)

        --Grab plotObject
        local plotObject = PlotService:GetPlot(newPlayer)
        playerObject.PlotObject = plotObject

        --Create leaderstats
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

        --Send plot to player and cache playerObject
        playerObjects[newPlayer] = playerObject
        self:FireClientEvent("SendPlotToClient", newPlayer, plotObject)
    end)

    game.Players.PlayerRemoving:Connect(function(oldPlayer)
        local playerObject = self:GetPlayerObject(oldPlayer)
        PlotService:AddPlot(playerObject.PlotObject)

        self:RemovePlayerObject(oldPlayer)
    end)

end


--//Removes PlayerObject from PlayerObjects array
--//WILL DELETE PLAYER OBJECT
--//ONLY CALL AFTER DATA HAS BEEN SAVED
function PlayerService:RemovePlayerObject(player)
    playerObjects[player] = nil
end


--//Returns the PlayerObject associated with Player
function PlayerService:GetPlayerObject(player)
    return playerObjects[player]
end


function PlayerService:Init()
    --//Api
    
    --//Services
    PlotService = self.Services.PlotService
    
    --//Controllers
    
    --//Classes
    PlayerClass = self.Modules.Classes.PlayerClass
    
    --//Locals
    playerObjects = {}

    self:RegisterClientEvent("SendPlotToClient")
end


return PlayerService