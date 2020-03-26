-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local PlacementApi

function BuildingController:Start()
    self.Player.CharacterAdded:Wait()

    PlacementApi:StartPlacement(1)

end


function BuildingController:Init()
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController