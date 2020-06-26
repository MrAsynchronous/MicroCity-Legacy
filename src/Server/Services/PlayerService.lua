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
    end)

    Players.PlayerRemoving:Connect(function(player)
         print(player.Name, "has left the game!")
    end)
end


--//Returns PseudoPlayer associated with player
function PlayerService:GetPseudoPlayer(player)
    return PseudoPlayerIndex[player]
end


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
    self.GetPlot = EventClass.new()
end


return PlayerService