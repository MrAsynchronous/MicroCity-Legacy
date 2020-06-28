-- Placement Controller
-- MrAsync
-- June 26, 2020



local PlacementController = {}

--//Api
local PlacementApi

--//Services
local PlacementService
local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot


function PlacementController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())

    PlacementApi.ObjectPlaced:Connect(function(...)
        local response = PlacementService:RequestItemPlacement(...)
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlacementService = self.Services.PlacementService
    PlayerService = self.Services.PlayerService
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return PlacementController