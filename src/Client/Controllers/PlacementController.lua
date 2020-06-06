-- Placement Controller
-- MrAsync
-- June 4, 2020



local PlacementController = {}

--//Api
local PlacementApi
local LogApi

--//Services
local PlacementService

--//Classes

--//Controllers
local NotificationController

--//Locals


function PlacementController:Start()
    LogApi:Log("Client | PlacementController | Start: Initializing")

    if (not PlacementApi.IsLoaded) then
        PlacementApi.Loaded:Wait()
    end

    PlacementApi.ObjectPlaced:Connect(function(itemId, objectPosition)
        LogApi:Log("Client | PlacementController | ObjectPlaced.Listener: Received signal, client wants to place an item!")

        local actionData = PlacementService:RequestPlacement(itemId, objectPosition)
        NotificationController:Dispatch(actionData.noticeObject)

    end)

    PlacementApi:StartPlacing(3)

    LogApi:Log("Client | PlacementController | Start: Completed")
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    LogApi = self.Shared.Api.LogApi

    --//Services
    PlacementService = self.Services.PlacementService

    --//Classes

    --//Controllers
    NotificationController = self.Controllers.NotificationController

    --//Locals

end


return PlacementController