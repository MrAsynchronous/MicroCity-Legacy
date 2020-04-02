-- Plot Service
-- MrAsync
-- March 22, 2020

--[[

    Handles the allocation and de-allocation of plots to players

]]


local PlotService = {Client = {}}

--//Api

--//Services

--//Controllers

--//Classes

--//Locals
local plotStack
local plotContainer


--//Removes and returns the last possible plot in PlotStack
function PlotService:GetPlot(player)
    return table.remove(plotStack, #plotStack) 
end


--//Inserts the plotObject at lastPosition in Stack
function PlotService:AddPlot(plotObject)
    return table.insert(plotStack, #plotStack+1, plotObject)
end


--//Iterates through physical world plots, allocations plotStack space for plot
function PlotService:Start()
    for _, plotObject in pairs(plotContainer:GetChildren()) do
        table.insert(plotStack, #plotStack + 1, plotObject)
    end
end


function PlotService:Init()
    --//Api

    --//Services

    --//Controllers

    --//Classes

    --//Locals
    plotStack = {}
    plotContainer = workspace.Plots
	
end


return PlotService