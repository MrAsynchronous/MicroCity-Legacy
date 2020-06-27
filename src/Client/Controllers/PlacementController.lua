-- Placement Controller
-- MrAsync
-- June 26, 2020



local PlacementController = {}

--//Api
local PlacementApi

--//Services
local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot


function PlacementController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())

    wait(5)
    
    PlacementApi:StartPlacing(1)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return PlacementController