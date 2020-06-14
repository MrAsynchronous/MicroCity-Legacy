-- Player Service
-- MrAsync
-- June 2, 2020


--[[

    Handle the PlayerAdded and PlayerRemoving events

]]


local PlayerService = {Client = {}}

--//Api
local Scheduler
local LogApi

--//Services
local Players = game:GetService("Players")

--//Classes
local PseudoPlayerClass
local PromiseClass
local PlotClass

--//Controllers

--//Locals
local PseudoPlayers = {}

function PlayerService:Start()
    LogApi:Log("Server | PlayerService | Start: Binding to PlayerService PlayerAdded and PlayerRemoving")

    Players.PlayerAdded:Connect(function(player)
        LogApi:Log("Server | PlayerService | PlayerAdded: " .. player.Name .. " has joined the game")

        --Construct a new PseudoPlayer
        local pseudoPlayer = PseudoPlayerClass.new(player)
            PseudoPlayers[player] = pseudoPlayer

       --Construct a new plotObject
        pseudoPlayer.Plot = PlotClass.new(pseudoPlayer)
        self:FireClientEvent("RequestPlot", player, pseudoPlayer.Plot.Object)

        --Loadbuildings
        pseudoPlayer.Plot:LoadBuildings(pseudoPlayer, pseudoPlayer.Plot.BuildingStore:Get({}))
    end)    

    Players.PlayerRemoving:Connect(function(player)
        LogApi:Log("Server | PlayerService | PlayerRemoving: " .. player.Name .. " has left the game")

        local pseudoPlayer = self:GetPseudoPlayerFromPlayer(player)
        if (not pseudoPlayer) then return end

        pseudoPlayer:Unload()
        self:RemovePseudoPlayer(player)
    end)

    LogApi:Log("Server | PlayerService | Start: Completed")
end


--//Returns the pseudoPlayer for the given player
function PlayerService:GetPseudoPlayerFromPlayer(player)
    LogApi:Log("Server | PlayerService | GetPseudoPlayerFromPlayer: Fulfilling request for PseudoPlayer associated with " .. player.Name)
    
    return PseudoPlayers[player]
end


function PlayerService:RemovePseudoPlayer(player)
    PseudoPlayers[player] = nil
    return true
end


--//Server method to fulfill a request for the players plot
function PlayerService.Client:RequestPlot(player)
    LogApi:Log("Server | PlayerService | GetPlot: Fulfilling request for Plot from " .. player.Name)

    while (not PseudoPlayers[player]) do LogApi:LogWarn("Server | PlayerService | GetPlot: Yielding for PseudoPlayer!") Scheduler.Wait() end
    local pseudoPlayer = self.Server:GetPseudoPlayerFromPlayer(player)

    return (pseudoPlayer.Plot and pseudoPlayer.Plot.Object or nil)
end


function PlayerService:Init()
    --//Api
    Scheduler = self.Shared.Scheduler
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayer
    PromiseClass = self.Shared.Promise
    PlotClass = self.Modules.Classes.Plot

    --//Controllers

    --//Locals	
    self:RegisterClientEvent("RequestPlot")

end


return PlayerService