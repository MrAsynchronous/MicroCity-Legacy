-- Player Service
-- MrAsync
-- March 16, 2020


--[[

    Handles the initialization of incoming players and the cleanup of outgoing players

    Methods
        public PlayerObject GetPlayerObject(Player player)
        public void RemovePlayerObject(Player player)

]]


local PlayerService = {Client = {}}


--//Api

--//Services
local PlacementService
local PlotService

--//Controllers

--//Classes
local PlayerClass

--//Locals
local playerObjects


function PlayerService:Start()
    
    game.Players.PlayerAdded:Connect(function(newPlayer)
        --Create playerObject
        local plotObject = PlotService:GetPlot(newPlayer)
        local playerObject = PlayerClass.new(newPlayer)
        playerObject.PlotObject = plotObject

        --Load placements
        PlacementService:LoadPlacements(playerObject)

        --Create plotValue
        local plotValue = Instance.new("ObjectValue")
        plotValue.Name = "PlayerPlot"
        plotValue.Value = plotObject
        plotValue.Parent = newPlayer

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

        --Cache playerObject
        playerObjects[newPlayer] = playerObject
    end)

    game.Players.PlayerRemoving:Connect(function(oldPlayer)
        local playerObject = self:GetPlayerObject(oldPlayer)

        --Push plot into PlotStack, remove PlayerObject
        PlotService:AddPlot(playerObject.PlotObject)
        self:RemovePlayerObject(oldPlayer)
    end)

end


--//Returns the PlayerObject associated with Player
function PlayerService:GetPlayerObject(player)
    return playerObjects[player]
end


--//Removes PlayerObject from PlayerObjects array
--//WILL DELETE PLAYER OBJECT
--//ONLY CALL AFTER DATA HAS BEEN SAVED
function PlayerService:RemovePlayerObject(player)
    playerObjects[player] = nil
end


function PlayerService:Init()
    --//Api
    
    --//Services
    PlacementService = self.Services.PlacementService
    PlotService = self.Services.PlotService
    
    --//Controllers
    
    --//Classes
    PlayerClass = self.Modules.Classes.PlayerClass
    
    --//Locals
    playerObjects = {}

end


return PlayerService