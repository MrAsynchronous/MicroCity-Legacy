-- Pseudo Player
-- MrAsync
-- June 26, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

--//Api

--//Services
local DataStore2

--//Classes
local MaidClass
local PlotClass

--//Controllers

--//Locals


function PseudoPlayer.new(player)
    local self = setmetatable({
        Player = player,
        

        JoinTime = os.time(),

        _Maid = MaidClass.new()
    }, PseudoPlayer)


    --Construct a new plotObject
    self.Plot = PlotClass.new(self)

    return self
end


function PseudoPlayer:Start()

end


function PseudoPlayer:Init()
    --//Api
    
    --//Services
    DataStore2 = self.Services.DataStore2
    
    --//Classes
    MaidClass = self.Shared.Maid
    PlotClass = self.Modules.Classes.Plot

    --//Controllers
    
    --//Locals
    
end


return PseudoPlayer