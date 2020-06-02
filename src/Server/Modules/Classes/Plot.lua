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

    return self
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

    --//Controllers

    --//Locals
    PlotContainer = Workspace:WaitForChild("Plots")

end


return Plot