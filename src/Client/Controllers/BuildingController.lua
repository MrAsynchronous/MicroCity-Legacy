-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local UserInputService = game:GetService("UserInputService")

local PlacementApi

function BuildingController:Start()
    UserInputService.InputBegan:Connect(function(inputObject, gameProccessed)
        if (not gameProccessed) then
            if (inputObject.KeyCode == Enum.KeyCode.One) then
                PlacementApi:StartPlacing(1)
            elseif (inputObject.KeyCode == Enum.KeyCode.Two) then
                PlacementApi:StartPlacing(2)
            elseif (inputObject.KeyCode == Enum.KeyCode.Three) then
                PlacementApi:StartPlacing(3)
            elseif (inputObject.KeyCode == Enum.KeyCode.Four) then
                PlacementApi:StartPlacing(4)
            elseif (inputObject.KeyCode == Enum.KeyCode.Five) then
                PlacementApi:StartPlacing(5)
            elseif (inputObject.KeyCode == Enum.KeyCode.Six) then
                PlacementApi:StartPlacing(6)
            end
        end
    end)
end


function BuildingController:Init()
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController