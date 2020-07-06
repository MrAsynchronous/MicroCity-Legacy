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
local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local StateGui

local Plot


function PlacementController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())

    PlacementApi.ObjectPlaced:Connect(function(...)
        local response = PlacementService:RequestItemPlacement(...)
    end)

    StateGui.PlacementMode.MouseButton1Click:Connect(function()
        PlacementApi:StartPlacing(1)
    end)

    StateGui.PlatePurchaseMode.MouseButton1Click:Connect(function()
        FreeCamApi:EnterPlatePurchaseMode()
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    FreeCamApi = self.Modules.Api.FreeCamApi
    
    --//Services
    PlacementService = self.Services.PlacementService
    PlayerService = self.Services.PlayerService
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    StateGui = CoreGui:WaitForChild("State")

end


return PlacementController