-- Pseudo Player
-- MrAsync
-- June 2, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer


function PseudoPlayer.new()
    local self = setmetatable({
        
    }, PseudoPlayer)

    return self
end


return PseudoPlayer