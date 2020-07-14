-- Placement Controller
-- MrAsync
-- June 26, 2020



local PlacementController = {}

--//Api
local PlacementApi
local FreeCamApi

--//Services
local PlacementService
local PlayerService

--//Classes

--//Controllers
local SetupController

--//Locals
local Plot


function PlacementController:Start()
    PlacementApi.ObjectPlaced:Connect(function(...)
        local response = PlacementService:RequestItemPlacement(...)
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    FreeCamApi = self.Modules.Api.FreeCamApi

    --//Services
    PlacementService = self.Services.PlacementService
    PlayerService = self.Services.PlayerService

    --//Classes

    --//Controllers

    --//Locals

end


return PlacementController