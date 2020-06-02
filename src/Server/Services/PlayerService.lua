-- Player Service
-- MrAsync
-- June 2, 2020


--[[

    Handle the PlayerAdded and PlayerRemoving events

]]


local PlayerService = {Client = {}}

--//Api
local LogApi

--//Services
local Players = game:GetService("Players")

--//Classes
local PseudoPlayerClass
local PlotClass

--//Controllers

--//Locals
local PseudoPlayers = {}

function PlayerService:Start()
    LogApi:Log("Server | PlayerService | Start: Binding to PlayerService PlayerAdded and PlayerRemoving")

    Players.PlayerAdded:Connect(function(player)
        LogApi:Log("Server | PlayerService | PlayerAdded: " .. player.Name .. " has joined the game")

        local pseudoPlayer = PseudoPlayerClass.new(player)
            PseudoPlayers[player.Name] = pseudoPlayer

        local plotObject = PlotClass.new(pseudoPlayer)
            pseudoPlayer.Plot = plotObject


        --Leaderstats
        local leaderstats = Instance.new("Folder")
        leaderstats.Parent = player
        leaderstats.Name = "leaderstats"

        local cashValue = Instance.new("NumberValue")
        cashValue.Parent = leaderstats
        cashValue.Name = "Cash"

        local populationValue = Instance.new("NumberValue")
        populationValue.Parent = leaderstats
        populationValue.Name = "Population"

    end)

    Players.PlayerRemoving:Connect(function(player)
        LogApi:Log("Server | PlayerService | PlayerRemoving: " .. player.Name .. " has left the game")

        local pseudoPlayer = self:GetPseudoPlayerFromPlayer(player)
        pseudoPlayer.Plot:Unload()

    end)

    LogApi:Log("Server | PlayerService | Start: Completed")
end


--//Returns the pseudoPlayer for the given player
function PlayerService:GetPseudoPlayerFromPlayer(player)
    LogApi:Log("Server | PlayerService | GetPseudoPlayerFromPlayer: Fulfilling request for PseudoPlayer associated with " .. player.Name)

    return PseudoPlayers[player.Name]
end


--//Server method to fulfill a request for the players plot
function PlayerService:GetPlot(player)
    LogApi:Log("Server | PlayerService | GetPlot: Fulfilling request for Plot from " .. player.Name)

    local pseudoPlayer = self:GetPseudoPlayerFromPlayer(player)
    return pseudoPlayer.Plot.Object
end


--//Client facing method to retrieve the players plot
function PlayerService.Client:RequestPlot(...)
    LogApi:Log("Server | PlayerService | RequestPlot: Received request for Plot")
    return self.Server:GetPlot(...)
end


function PlayerService:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayer
    PlotClass = self.Modules.Classes.Plot

    --//Controllers

    --//Locals	

end


return PlayerService