-- Pseudo Player
-- MrAsync
-- June 2, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer


--//Api
local DataStore2
local LogApi

--//Services

--//Classes

--//Controllers

--//Locals


function PseudoPlayer.new(player)
    LogApi:Log("Server | PseudoPlayerClass | Constructor: A new PseudoPlayer object is being created for " .. player.Name)

    local self = setmetatable({
        Player = player

    }, PseudoPlayer)

    return self
end


--//Cleans up object when player leaves
function PseudoPlayer:Unload()

end


function PseudoPlayer:Init()
    --//Api
    DataStore2 = self.Services.DataStore2
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes

    --//Controllers

    --//Locals

end


return PseudoPlayer