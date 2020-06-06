-- Plot
-- MrAsync
-- June 2, 2020


--[[

    Handle the dispertion of plots as well as anything plot and placement related

]]


local Plot = {}
Plot.__index = Plot

--//Api
local LogApi

--//Services
local Workspace = game:GetService("Workspace")

--//Classes
local BuildingClass

--//Controllers

--//Locals
local PlotContainer
local AvailablePlots = {}


function Plot.new(pseudoPlayer)
    LogApi:Log("Server | PlotClass | Constructor: A new Plot object is being created for " .. pseudoPlayer.Player.Name)

    local self = setmetatable({
        Player = pseudoPlayer.Player

    }, Plot)

    --Pop last plot and give it to player
    self.Object = table.remove(AvailablePlots, #AvailablePlots)
    if (not self.Object) then LogApi:LogWarn("Server | PlotCass | Constructor: No plot object was given to " .. pseudoPlayer.Player.Name .. "!") end

    self.CFrame = self.Object.Main.CFrame
    self.MainSize = self.Object.Main.Size
    self.VisualPartSize = self.Object.VisualPart.Size

    return self
end


--//Loads buildings from a save list
function Plot:LoadBuildings(pseudoPlayer, buildingList)
    pseudoPlayer.BuildingStore:Update(function(serialized)
        serialized = {}

        for guid, JSONData in pairs(buildingList) do
            serialized[guid] = BuildingClass.newFromSave(pseudoPlayer, guid, JSONData)
        end

        return serialized
    end)
end


--//Cleans up plot when player leaves
function Plot:Unload()
    LogApi:Log("Server | PlotClass | Unload: Unloading player-plot for " .. self.Player.Name)

    table.insert(AvailablePlots, self.Object)

    self.Object.Placements.Building:ClearAllChildren()
    self.Object.Placements.Road:ClearAllChildren()
    self.Object = nil

    LogApi:Log("Server | PlotClass | Unload: Completed")
end


function Plot:Start()
    LogApi:Log("Server | PlotClass | Startup: Indexing available plots, pushing them into the PlotStack")

    for _, plot in pairs(PlotContainer:GetChildren()) do
        if (not plot:IsA("Folder")) then continue end

        table.insert(AvailablePlots, plot)
    end

    LogApi:Log("Server | PlotClass | Startup: Completed")
end


function Plot:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes
    BuildingClass = self.Modules.Classes.Building

    --//Controllers

    --//Locals
    PlotContainer = Workspace:WaitForChild("Plots")

end


return Plot