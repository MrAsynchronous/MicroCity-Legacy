-- Placement Controller
-- MrAsync
-- March 30, 2020


--[[

    Medium between UI and PlacementApi. Controls the selectionQueue of placements

]]


local PlacementController = {}


--//Api
local PlacementApi

--//Services
local ContextActionService = game:GetService("ContextActionService")

local PlacementService
local PlayerService
local PlayerGui

--//Controllers

--//Classes

--//Locals
local camera
local plotObject

local PlacementSelectionQueue


function PlacementController:Start()

    --When player selects placement, show GUI
    PlacementApi.PlacementSelectionStarted:Connect(function(placementObject)
        PlacementSelectionQueue.StudsOffsetWorldSpace = Vector3.new(0, placementObject.PrimaryPart.Size.Y, 0)
        PlacementSelectionQueue.Adornee = placementObject.PrimaryPart
        PlacementSelectionQueue.Enabled = true
    end)

    --When player stops selecting placement, hide GUI
    PlacementApi.PlacementSelectionEnded:Connect(function()
        PlacementSelectionQueue.Enabled = false
        PlacementSelectionQueue.Adornee = nil
    end)

    --Button binds
    local buttonContainer = PlacementSelectionQueue.Buttons

    --Invoke PlacementApi
    buttonContainer.Move.MouseButton1Click:Connect(function()
        if (PlacementSelectionQueue.Adornee) then
            PlacementService:StartPlacing(nil, true, PlacementSelectionQueue.Adornee:FindFirstAncestorOfClass("Model"))
        end
    end)
end


function PlacementController:Init()
    --//Api
    PlacementApi = self.Modules.API.PlacementApi

    --//Services
    PlacementService = self.Services.PlacementService
    PlayerService = self.Services.PlayerService
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers

    --//Classes

    --//Locals
    camera = workspace.CurrentCamera

    PlacementSelectionQueue = PlayerGui:WaitForChild("PlacementSelectionQueue")
    
end


return PlacementController