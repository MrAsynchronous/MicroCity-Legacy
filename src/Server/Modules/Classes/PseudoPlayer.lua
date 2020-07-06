-- Pseudo Player
-- MrAsync
-- June 26, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

--//Api
local DataStore2

--//Services
local ServerScriptService = game:GetService("ServerScriptService")

local MetaDataService

--//Classes
local MaidClass
local PlotClass

--//Controllers

--//Locals
local DefaultPlayerData


function PseudoPlayer.new(player)
    local self = setmetatable({
        Player = player,

        JoinTime = os.time(),

        _Maid = MaidClass.new()
    }, PseudoPlayer)

    -- Begin loading data
    for key, value in pairs(DefaultPlayerData) do
        self[key] = DataStore2(key, player)

        print(key, self[key]:Get(value))
    end

    --Construct a new plotObject
    self.Plot = PlotClass.new(self)


    return self
end


--//Unload's and cleans up PseudoPlayer
function PseudoPlayer:Unload()
    self._Maid:Destroy()
    self.Plot:Unload()
end


function PseudoPlayer:Start()
    DefaultPlayerData = MetaDataService:GetMetaData("DefaultPlayerData")

end


function PseudoPlayer:Init()
    --//Api
    DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

    --//Services
    MetaDataService = self.Services.MetaDataService
    
    --//Classes
    MaidClass = self.Shared.Maid
    PlotClass = self.Modules.Classes.Plot

    --//Controllers
    
    --//Locals
    
end


return PseudoPlayer