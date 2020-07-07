-- Player Service
-- MrAsync
-- June 26, 2020



local PlayerService = {Client = {}}

--//Api

--//Services
local Players = game:GetService("Players")

--//Classes
local PseudoPlayerClass
local EventClass

--//Controllers

--//Locals
local PseudoPlayerIndex = {}


function PlayerService:Start()
    Players.PlayerAdded:Connect(function(player)
        print(player.Name, "has joined the game!")

        local pseudoPlayer = PseudoPlayerClass.new(player)
        PseudoPlayerIndex[player] = pseudoPlayer

        if (not player.Character) then player.CharacterAdded:Wait() end

        wait(3)

        pseudoPlayer.Plot:LoadBuildings(pseudoPlayer)
    end)

    Players.PlayerRemoving:Connect(function(player)
         print(player.Name, "has left the game!")

         local pseudoPlayer = self:RemovePseudoPlayer(player)
         if (not pseudoPlayer) then return end

         pseudoPlayer:Unload()
    end)
end


--//Returns PseudoPlayer associated with player
function PlayerService:GetPseudoPlayer(player)
    return PseudoPlayerIndex[player]
end


--//Removes and returns PseudoPlayer associated with player
function PlayerService:RemovePseudoPlayer(player)
    local pseudoPlayer = self:GetPseudoPlayer(player)
    PseudoPlayerIndex[player] = nil

    return pseudoPlayer
end


--//Returns the plot model, or nil if plot isn't loaded
function PlayerService.Client:RequestPlot(player)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return false end
    if (not pseudoPlayer.Plot) then return false end
    if (not pseudoPlayer.Plot.Loaded) then return false end

    return pseudoPlayer.Plot.Object
end


function PlayerService:Init()
	--//Api

    --//Services

    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayer
    EventClass = self.Shared.Event

    --//Controllers

    --//Locals
    self:RegisterClientEvent("PlotRequest")
end


return PlayerService