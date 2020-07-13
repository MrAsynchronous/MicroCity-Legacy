-- Player Service
-- MrAsync
-- June 26, 2020



local PlayerService = {Client = {}}

--//Api
local DataApi
local DataStore2

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
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

    local success, saveIndex = pseudoPlayer.SaveIndex:Get("Saves", {}):Await()
    response.Success = success
    response.SaveIndex = saveIndex
    response.Error = (not success and saveIndex or nil)

    if (not table.find(saveIndex, saveId)) then
        table.insert(saveIndex, saveId)

        --Update table, mark as dirty
        pseudoPlayer.SaveIndex:Set("Saves", saveIndex):Then(function()
            pseudoPlayer.SaveIndex:MarkDirty("Saves")
        end)

        response.Plot = pseudoPlayer.Plot.Object
    end

    pseudoPlayer:LoadSave(saveId)

    return response
end


--//Handles requests for SaveIndex
function PlayerService.Client:RequestSaveIndex(player)
    local pseudoPlayer = self.Server:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return end

    --Construct response
    local response = {}

    local success, saveIndex = pseudoPlayer.SaveIndex:Get("Saves", {}):Await()
    response.Success = success
    response.SaveIndex = saveIndex
    response.Error = (not success and saveIndex or nil)

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

    --//Services

    --//Classes
    PseudoPlayerClass = self.Modules.Classes.PseudoPlayer
    EventClass = self.Shared.Event

    --//Controllers

    --//Locals
    self:RegisterClientEvent("PlotLoaded")
end


return PlayerService