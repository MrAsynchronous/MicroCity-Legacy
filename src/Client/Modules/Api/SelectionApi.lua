-- Selection Api
-- MrAsync
-- June 13, 2020


--[[

    Handle the user selection of placed buildings

    Events:
        BuildingSelectionStarted -> Instance buildingObject
        BuildingSelectionEnded -> Instance buildingObject

]]


local SelectionApi = {}

--//Api
local PlacementApi

--//Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerService

--//Classes
local EventClass

--//Controllers
local UserInputController
local MouseController

--//Locals
local Plot
local Camera
local SelectionBox

local selectedBuilding


local function CleanupSelection()
    SelectionBox.Adornee = nil
end


local function GetModelFromRayPart(rayPart)
    local mouseRay = MouseController:GetRay(250)
    local partOnRay = Workspace:FindPartOnRayWithIgnoreList(mouseRay, {(SelectionApi.Player.Character or SelectionApi.Player.CharacterAdded:Wait())})

    if (partOnRay) then
        local parentModel = partOnRay:FindFirstAncestorOfClass("Model")

        if (parentModel and parentModel:IsDescendantOf(Plot.Placements)) then
            return parentModel
        else
            return false
        end
    else
        return false
    end
end


function SelectionApi:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.RequestPlot:Wait())
    MouseController = UserInputController:Get("Mouse")

    --Create the selectionBox
    SelectionBox = Instance.new("SelectionBox")
    SelectionBox.Parent = Camera
    SelectionBox.Color3 = Color3.fromRGB(52, 152, 219)
    SelectionBox.LineThickness = 0.05

    --Check selection every heartbeat
    RunService.Heartbeat:Connect(function()
        if (PlacementApi.IsPlacing) then return end
        
        local building = GetModelFromRayPart()

        if (building) then
            SelectionBox.Adornee = building.PrimaryPart
        else
            CleanupSelection()
        end
    end)

    --Detect input, validate input
    UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (gameProcessed or PlacementApi.IsPlacing) then return end

        if (inputObject.KeyCode == Enum.KeyCode.ButtonR2 or inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch) then
            local building = GetModelFromRayPart()

            if (building) then
                self.BuildingSelectionStarted:Fire(building)

                selectedBuilding = building
            else
                if (selectedBuilding) then
                    self.BuildingSelectionEnded:Fire(selectedBuilding)
                    selectedBuilding = nil
                end
            end
        end
    end)
end


function SelectionApi:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    EventClass = self.Shared.Event
    
    --//Controllers
    UserInputController = self.Controllers.UserInput
    
    --//Locals
    Camera = Workspace.CurrentCamera
    
    self.BuildingSelectionStarted = EventClass.new()
    self.BuildingSelectionEnded = EventClass.new()
end


return SelectionApi