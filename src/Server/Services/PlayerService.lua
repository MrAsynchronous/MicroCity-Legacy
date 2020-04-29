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
local PromiseApi

--//Services
local PlacementService
local PlotService

--//Controllers

--//Classes
local PseudoPlayerClass
local PlotClass

--//Locals
local pseudoPlayers
local cmdrCommand


function PlayerService:Start()
    
    game.Players.PlayerAdded:Connect(function(newPlayer)
        --Create pseudoPlayer
        local pseudoPlayer = PseudoPlayerClass.new(newPlayer)
        pseudoPlayer.PlotObject = PlotClass.new(pseudoPlayer)

        --Load placements, tell client plot has been loaded
        pseudoPlayer.PlotObject:LoadPlacements(pseudoPlayer)

        --Create plotValue
        local plotValue = Instance.new("ObjectValue")
        plotValue.Name = "PlotObject"
        plotValue.Parent = newPlayer
        plotValue.Value = pseudoPlayer.PlotObject.Object

        --Create leaderstats
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = newPlayer

        local cashValue = Instance.new("NumberValue")
        cashValue.Name = "Cash"
        cashValue.Value = pseudoPlayer.Cash:Get(0)
        cashValue.Parent = leaderstats

        pseudoPlayer._Maid.CashUpdate = pseudoPlayer.Cash:OnUpdate(function(newValue)
            cashValue.Value = newValue
        end)

        local populationValue = Instance.new("NumberValue")
        populationValue.Name = "Population"
        populationValue.Value = pseudoPlayer.Population:Get(0)
        populationValue.Parent = leaderstats

        pseudoPlayer._Maid.PopulationUpdate = pseudoPlayer.Population:OnUpdate(function(newValue)
            populationValue.Value = newValue
        end)

        --Cache playerObject
        pseudoPlayers[newPlayer] = pseudoPlayer
    end)

    game.Players.PlayerRemoving:Connect(function(oldPlayer)
        local pseudoPlayer = self:GetPseudoPlayer(oldPlayer)
        pseudoPlayer:Destroy()

        self:RemovePseudoPlayer(oldPlayer)
    end)

end


--//Returns the PlayerObject associated with Player
function PlayerService:GetPseudoPlayer(player)
    return pseudoPlayers[player]
end


--//Removes PlayerObject from PlayerObjects array
--//WILL DELETE PLAYER OBJECT
--//ONLY CALL AFTER DATA HAS BEEN SAVED
function PlayerService:RemovePseudoPlayer(player)
    pseudoPlayers[player] = nil
end


function PlayerService:Init()
    --//Api
    PromiseApi = self.Shared.Promise
    
    --//Services
    PlacementService = self.Services.PlacementService
    PlotService = self.Services.PlotService
    
    --//Controllers
    
    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayerClass
    PlotClass = self.Modules.Classes.PlotClass

    --//Locals
    pseudoPlayers = {}

    self:RegisterClientEvent("PlotSizeChanged")
    self:RegisterClientEvent("PlotLoadCompleted")
end


return PlayerService