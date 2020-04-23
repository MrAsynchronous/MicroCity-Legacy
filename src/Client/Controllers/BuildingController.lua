-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local UserInputService = game:GetService("UserInputService")

local PlayerGui
local CoreInterface
local PlacementApi

function BuildingController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    CoreInterface = PlayerGui:WaitForChild("CoreInterface")

    CoreInterface.PC.PersonButton.MouseButton1Click:Connect(function()
        PlacementApi:StartPlacing(100)
    end)
end


function BuildingController:Init()
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController