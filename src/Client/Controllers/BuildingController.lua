-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local UserInputService = game:GetService("UserInputService")

local PlacementApi

function BuildingController:Start()
    wait(20)

    PlacementApi:StartPlacing(3)

    UserInputService.InputBegan:Connect(function(inputObject, gameProccessed)
        if (not gameProccessed) then
            if (inputObject.KeyCode == Enum.KeyCode.One) then
                PlacementApi:StartPlacing(1)
            elseif (inputObject.KeyCode == Enum.KeyCode.Two) then
                PlacementApi:StartPlacing(2)
            elseif (inputObject.KeyCode == Enum.KeyCode.Three) then
                PlacementApi:StartPlacing(3)
            elseif (inputObject.KeyCode == Enum.KeyCode.Four) then
                PlacementApi:StartPlacing(100)
            end
        end
    end)
end


function BuildingController:Init()
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController