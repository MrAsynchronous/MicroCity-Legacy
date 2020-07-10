-- Pseudo Player
-- MrAsync
-- June 26, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

--//Api

--//Services
local ServerScriptService = game:GetService("ServerScriptService")

local MetaDataService
local PlayerService
local DataService

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

    --Construct a new plotObject
    self.Plot = PlotClass.new(self)

    return self
end


function PseudoPlayer:Setup(saveName)
    self.DataContainer = DataService.new(self.Player.UserId, saveName)  

    self.Plot:Load(self.DataContainer)
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

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService
    DataService = self.Services.DataService
    
    --//Classes
    MaidClass = self.Shared.Maid
    PlotClass = self.Modules.Classes.Plot

    --//Controllers
    
    --//Locals
    
end


return PseudoPlayer