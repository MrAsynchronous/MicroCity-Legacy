-- Player Service
-- MrAsync
-- June 26, 2020



local PlayerService = {Client = {}}

--//Api
local DataApi
local DataStore2
local TableUtil

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local MetaDataService

--//Classes
local PseudoPlayerClass
local EventClass

--//Controllers

--//Locals
local GameSettings

local PseudoPlayerIndex = {}


function PlayerService:Start()
    GameSettings = MetaDataService:GetMetaData("GameSettings")

    Players.PlayerAdded:Connect(function(player)
        print(player.Name, "has joined the game!")

        local pseudoPlayer = PseudoPlayerClass.new(player)
        PseudoPlayerIndex[player] = pseudoPlayer

        if (not player.Character) then player.CharacterAdded:Wait() end
    end)

    Players.PlayerRemoving:Connect(function(player)
        print(player.Name, "has left the game!")

        local pseudoPlayer = self:RemovePseudoPlayer(player)
        if (not pseudoPlayer) then return end

        --Save data
        pseudoPlayer.SaveIndex:SaveAll():Then(function()
            if (not pseudoPlayer.Data) then return end

            pseudoPlayer.Data:SaveAll():Catch(function(err)
                warn(err)
            end)
        end):Finally(function()
            pseudoPlayer:Unload()
        end)
    end)
end


--//Handles incoming requests for retrieving a save
function PlayerService.Client:RequestSave(player, saveId)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return end

    --Construct response
    local response = {}
    response.Plot = pseudoPlayer.Plot.Object

    pseudoPlayer.SaveIndex:Get(GameSettings.SaveDB, {}):Then(function(saveIndex)
        response.Success = true
    
        --Handle creation of new saves
        if (not table.find(saveIndex, saveId)) then
            table.insert(saveIndex, saveId)

            --Update table, mark as dirty
            pseudoPlayer.SaveIndex:Set(GameSettings.SaveDB, saveIndex):Then(function()
                pseudoPlayer.SaveIndex:MarkDirty(GameSettings.SaveDB)
            end)

            pseudoPlayer:LoadSave(saveId) 
        end        
    end, function(err)
        response.Success = false
        response.Error = err
    end):Await()

    return response
end


--//Handles requests for SaveIndex
function PlayerService.Client:RequestSaveIndex(player)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return end

    --Construct response
    local response = {}

    --SaveIndex promise
    pseudoPlayer.SaveIndex:Get(GameSettings.SaveDB, {}):Then(function(saveIndex)
        response.SaveIndex = saveIndex
        response.Success = true
    end, function(err)
        response.Success = false
        response.Error = err
    end):Await()

    return response
end


--//Returns the plot model, or nil if plot isn't loaded
function PlayerService.Client:RequestPlot(player)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return false end
    if (not pseudoPlayer.Plot) then return false end
    if (not pseudoPlayer.Plot.Loaded) then return false end

    return pseudoPlayer.Plot.Object
end


function PlayerService.Client:IsPlotLoaded(player)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return false end
    if (not pseudoPlayer.Plot) then return false end

    return not pseudoPlayer.Plot.IsLoading
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


function PlayerService:Init()
    --//Api
    DataApi = self.Modules.Data
    DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
    TableUtil = self.Shared.TableUtil

    --//Services
    MetaDataService = self.Services.MetaDataService

    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayer
    EventClass = self.Shared.Event

    --//Controllers

    --//Locals
    self:RegisterClientEvent("PlotLoaded")

end


return PlayerService