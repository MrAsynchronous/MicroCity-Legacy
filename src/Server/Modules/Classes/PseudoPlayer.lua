-- Pseudo Player
-- MrAsync
-- June 2, 2020



local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer


--//Api
local DataStore2
local TableUtil
local LogApi

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaDataService
local PlayerService

--//Classes
local MaidClass

--//Controllers

--//Locals
local DefaultPlayerData
local GameSettings


local VALUE_TO_NODE_KEY = {
    ["number"] = "NumberValue",
    ["string"] = "StringValue",
    ["table"] = "StringValue",
    ["boolean"] = "BoolValue"
}


function PseudoPlayer.new(player)
    LogApi:Log("Server | PseudoPlayerClass | Constructor: A new PseudoPlayer object is being created for " .. player.Name)

    local self = setmetatable({
        Player = player,

        _Maid = MaidClass.new()
    }, PseudoPlayer)

    --Initiate DataStore2
    self.ReplicatedDataContainer = Instance.new("Folder")
    self.ReplicatedDataContainer.Parent = ReplicatedStorage.ReplicatedData
    self.ReplicatedDataContainer.Name = player.UserId

    LogApi:Log("Server | PseudoPlayerClass | Constructor: Generating data replication keys")

    --Iterate through all keys
    for key, value in pairs(DefaultPlayerData) do
        self[key] = DataStore2(key, player)

        local serializedNode = Instance.new(VALUE_TO_NODE_KEY[type(key)])
        serializedNode.Name = key
        serializedNode.Parent = self.ReplicatedDataContainer

        --Replicate initial value to client
        local value = self[key]:Get(value)
        if (type(value) == "table") then
            value = TableUtil.EncodeJSON(value)
        end

        serializedNode.Value = TableUtil.EncodeJSON(value)

        --Listen for changes to the key, replicate changes to client
        self[key]:OnUpdate(function(newValue) 
            if (type(newValue) == "table") then
                newValue = TableUtil.EncodeJSON(newValue)
            end
            
            serializedNode.Value = TableUtil.EncodeJSON(newValue)
        end)
    end

    return self
end


--//Cleans up object when player leaves
function PseudoPlayer:Unload()
    
end


function PseudoPlayer:Start()
    DefaultPlayerData = MetaDataService:GetMetaData("Player")
    GameSettings = MetaDataService:GetMetaData("Settings")
    
    for key, _ in pairs(DefaultPlayerData) do
        DataStore2.Combine(GameSettings.PlayerDataToken, key)
    end
end


function PseudoPlayer:Init()
    --//Api
    DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
    TableUtil = self.Shared.TableUtil
    LogApi = self.Shared.Api.LogApi

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Classes
    MaidClass = self.Shared.Maid

    --//Controllers

    --//Local

end


return PseudoPlayer