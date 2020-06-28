-- Exploration
-- MrAsync
-- June 28, 2020



local Exploration = {}

--//Api
local PlacementApi

--//Services
local PlayerGui

--//Classes

--//Controllers
local FadeController
local BuildMode

--//Locals
local CoreGui
local ExplorationButton

local IsExploring = true

local VALUES = {
    "BodyDepthScale",
    "BodyHeightScale",
    "BodyWidthScale",
    "HeadScale"
}

function Exploration:Start()
    if (not BuildMode.IsLoaded) then BuildMode.Loaded:Wait() end

    FadeController:SetBackgroundColor(Color3.fromRGB(255, 255, 255))

    ExplorationButton.Button.MouseButton1Click:Connect(function()
        local character = self.Player.Character or self.Player.CharacterAdded:Wait()
        IsExploring = not IsExploring

        if (IsExploring) then
            FadeController:Out(0.25)

            BuildMode:StopBuilding()
            PlacementApi:StopPlacing()

            for _, value in pairs(VALUES) do
                character.Humanoid:FindFirstChild(value).Value = 0.1
            end

            FadeController:In(0.25)
        else
            FadeController:Out(0.5)

            BuildMode:StartBuilding()
            PlacementApi:StartPlacing(1)

            FadeController:In(0.25)
        end
    end)
end


function Exploration:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    
    --//Controllers
    FadeController = self.Controllers.Fade
    BuildMode = self.Controllers.Core.BuildMode
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    ExplorationButton = CoreGui:WaitForChild("Exploration")

end


return Exploration