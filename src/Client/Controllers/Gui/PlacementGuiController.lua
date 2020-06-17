-- Placement Gui Controller
-- MrAsync
-- June 13, 2020



local PlacementGuiController = {}

--//Api
local SelectionApi
local PlacementApi

--//Services

--//Classes
local GuiClass

--//Controllers
local UserInputController

--//Locals
local PlayerGui
local PlacementGui
local SelectionGui

local visibleGui
local GUI_SIZE = UDim2.new(0.625, 0, 0.112, 0)
local GUI_POSITION = UDim2.new(0.5, 0, 0.95, 0)
local SELECTION_GUI_SIZE = UDim2.new(1, 0, 1, 0)


function PlacementGuiController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    PlacementGui = PlayerGui:WaitForChild("PlacementInterface")
    SelectionGui = PlayerGui:WaitForChild("PlacementSelectionQueue")

    local SelectionGuiObject = GuiClass.new(SelectionGui.Container, true)
    
    SelectionGuiObject:BindButton(SelectionGui.Container.Sell, function()
        print("Selling!")
    end)
    
    SelectionGuiObject:BindButton(SelectionGui.Container.Upgrade, function()
        print("Upgrading")
    end)

    SelectionGuiObject:BindButton(SelectionGui.Container.Move, function()
        print("Moving")
    end)

    --Selection GUI
    SelectionApi.BuildingSelectionStarted:Connect(function(buildingObject)
        local character = (self.Player.Character or self.Player.CharacterAdded:Wait())
        local hipHeight = character.Humanoid.HipHeight
        local objectSize = buildingObject.PrimaryPart.Size
        local yOffset = -((objectSize.Y / 2) - hipHeight)

        SelectionGui.StudsOffsetWorldSpace = Vector3.new(0, yOffset, 0)

        SelectionGui.Container.Size = UDim2.new(0, 0, 0, 0)
        SelectionGui.Adornee = buildingObject.PrimaryPart
        SelectionGui.Enabled = true
        SelectionGui.Container:TweenSize(SELECTION_GUI_SIZE, "Out", "Quint", 0.25, true)
    end)

    SelectionApi.BuildingSelectionEnded:Connect(function(buildingObject)
        SelectionGui.Container:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true, function()
            SelectionGui.Enabled = false
            SelectionGui.Adornee = nil
        end)
    end)

    --Placement GUI
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
    GuiClass = self.Modules.Classes.GuiClass

    --//Controllers
    UserInputController = self.Controllers.UserInput

    --//Locals

end


return PlacementGuiController