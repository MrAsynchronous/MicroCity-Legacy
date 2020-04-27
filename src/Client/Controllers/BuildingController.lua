-- Building Controller
-- MrAsync
-- March 25, 2020


--Tests the PlacementApi until a more robust inventory system is built


local BuildingController = {}

local UserInputService = game:GetService("UserInputService")

local NotificationDispatch
local CodeService

local PlayerGui
local CoreInterface
local PlacementApi

function BuildingController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    CoreInterface = PlayerGui:WaitForChild("CoreInterface")

    CoreInterface.PC.PersonButton.MouseButton1Click:Connect(function()
        PlacementApi:StartPlacing(4)
    end)

    CoreInterface.PC.MenuButton.MouseButton1Click:Connect(function()
        local returnData = CodeService:RedeemCode("RELEASE")

        NotificationDispatch:Dispatch(returnData.noticeObject)
    end)
end


function BuildingController:Init()
    NotificationDispatch = self.Controllers.NotificationDispatcher
    CodeService = self.Services.CodeService
    PlacementApi = self.Modules.API.PlacementApi
end


return BuildingController