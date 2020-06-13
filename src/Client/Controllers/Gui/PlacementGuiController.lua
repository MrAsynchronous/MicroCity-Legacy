-- Placement Gui Controller
-- MrAsync
-- June 13, 2020



local PlacementGuiController = {}

--//Api
local SelectionApi
local PlacementApi

--//Services

--//Classes

--//Controllers
local UserInputController

--//Locals
local PlayerGui
local PlacementGui

local visibleGui
local GUI_SIZE = UDim2.new(0.625, 0, 0.112, 0)
local GUI_POSITION = UDim2.new(0.5, 0, 0.95, 0)


function PlacementGuiController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementGui = PlayerGui:WaitForChild("PlacementInterface")

    PlacementApi.PlacementBegan:Connect(function()
        local preferredInput = UserInputController:GetPreferred()
         
        if (preferredInput == 0 or preferredInput == 1) then
            --We are on PC
            visibleGui = PlacementGui.PC
        elseif (preferredInput == 2) then
            --We are on console
            visibleGui = PlacementGui.Console
        end

        visibleGui:TweenSizeAndPosition(GUI_SIZE, GUI_POSITION, "Out", "Quint", 0.25, true)
    end) 

    PlacementApi.PlacementEnded:Connect(function()
        visibleGui:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true)
    end)
end


function PlacementGuiController:Init()
    --//Api
    SelectionApi = self.Modules.Api.SelectionApi
    PlacementApi = self.Modules.Api.PlacementApi

    --//Services

    --//Classes

    --//Controllers
    UserInputController = self.Controllers.UserInput

    --//Locals

end


return PlacementGuiController