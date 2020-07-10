-- Pseudo Player
-- MrAsync
-- June 26, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

--//Api
local DataStore2
local DataApi

--//Services
local ServerScriptService = game:GetService("ServerScriptService")

local MetaDataService
local PlayerService

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
        SaveIndex = DataStore2("SaveIndex", player),

        _Maid = MaidClass.new()
    }, PseudoPlayer)

    --Construct a new plotObject
    self.Plot = PlotClass.new(self)

    return self
end


function PseudoPlayer:LoadSave(saveName)

end


--//Unload's and cleans up PseudoPlayer
function PseudoPlayer:Unload()
    self._Maid:Destroy()
    self.Plot:Unload()
end


function PseudoPlayer:Start()
    DefaultPlayerData = MetaDataService:GetMetaData("DefaultPlayerData")

    for key, value in pairs(DefaultPlayerData) do
        DataStore2.Combine("PlayerData", key)
    end
end


function PseudoPlayer:Init()
    --//Api
    DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
    DataApi = self.Modules.Data

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService


    --//Classes
    MaidClass = self.Shared.Maid
    PlotClass = self.Modules.Classes.Plot

    --//Controllers

    --//Locals

end


return PseudoPlayer