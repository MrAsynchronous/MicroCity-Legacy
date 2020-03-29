-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local PlacementApi

function BuildingController:Start()
    PlacementApi.ObjectPlaced:Connect(function(itemId)
        PlacementApi:StopPlacing()
    end)

    wait(10)

    PlacementApi:StartPlacing(1)
end


function BuildingController:Init()
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController