-- Exploration
-- MrAsync
-- June 28, 2020



local Exploration = {}

--//Api
local PlacementApi
local BuildModeApi

--//Services
local PlayerGui

--//Classes

--//Controllers
local FadeController

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
    if (not BuildModeApi.IsLoaded) then BuildModeApi.Loaded:Wait() end

    FadeController:SetBackgroundColor(Color3.fromRGB(255, 255, 255))

    ExplorationButton.Button.MouseButton1Click:Connect(function()
        local character = self.Player.Character or self.Player.CharacterAdded:Wait()
        IsExploring = not IsExploring

        if (IsExploring) then
            FadeController:Out(0.25)

            PlacementApi:StopPlacing()

            for _, value in pairs(VALUES) do
                character.Humanoid:FindFirstChild(value).Value = 0.1
            end

            FadeController:In(0.25)
        else
            FadeController:Out(0.5)

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
    BuildModeApi = self.Modules.Api.BuildModeApi
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    ExplorationButton = CoreGui:WaitForChild("Exploration")

end


return Exploration