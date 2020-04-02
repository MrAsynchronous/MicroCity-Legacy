-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local PlacementService
local PlacementApi

function BuildingController:Start()
    PlacementApi.ObjectPlaced:Connect(function(itemId, localPosition)
        local success = PlacementService:PlaceObject(itemId, localPosition)

        if (success) then
        --    PlacementApi:StopPlacing()
        end
    end)

    wait(10)

    PlacementApi:StartPlacing(1)
end


function BuildingController:Init()
    PlacementService = self.Services.PlacementService
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController