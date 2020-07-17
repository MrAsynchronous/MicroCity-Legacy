-- Pseudo Player
-- MrAsync
-- June 26, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

--//Api
local TableUtil
local DataApi

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
local PlayerService

--//Classes
local MaidClass
local PlotClass

--//Controllers

--//Locals
local DefaultPlayerData

local EXCHANGE_TABLE = {
    ["string"] = "StringValue",
    ["number"] = "NumberValue",
    ["table"] = "StringValue",
    ["boolean"] = "BoolValue"
}


function PseudoPlayer.new(player)
    local self = setmetatable({
        Player = player,

        JoinTime = os.time(),
        SaveIndex = DataApi.ForPlayer(player.UserId),

        _Maid = MaidClass.new()
    }, PseudoPlayer)

    --Construct a new plotObject
    self.Plot = PlotClass.new(self)

    self.ReplicatedDataFolder = Instance.new("Folder")
    self.ReplicatedDataFolder.Name = player.UserId
    self.ReplicatedDataFolder.Parent = ReplicatedStorage.ReplicatedData

    return self
end


--//Handles the loading of specific data
function PseudoPlayer:LoadSave(saveName)
    self.Data = DataApi.new(tostring(self.Player.UserId), saveName)

    print("printing")
    print(self.Data:Get("Visits", 0))
    self.Data:Update("Visits", function(currentValue)
        return currentValue + 1
    end)

    self.Plot.Data = self.Data
    self.Plot:LoadSave(self)

    --Replicate data to client
    for key, value in pairs(DefaultPlayerData) do
        local replicatedValue = Instance.new(EXCHANGE_TABLE[typeof(value)])
        replicatedValue.Name = key
        replicatedValue.Parent = self.ReplicatedDataFolder

        if (typeof(value) == "table") then
            replicatedValue.Value = TableUtil.EncodeJSON(self.Data:Get(key, value))
        else
            replicatedValue.Value = self.Data:Get(key, value)
        end
    end
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
    TableUtil = self.Shared.TableUtil
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