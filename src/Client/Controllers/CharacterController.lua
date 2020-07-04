-- Character Controller
-- MrAsync
-- June 26, 2020



local CharacterController = {}
local self = CharacterController

--//Api
local BuildModeApi

--//Services
local PlayerService

--//Classes

--//Controllers
local FadeController

--//Locals
local Plot


--//Positions player's character in front of their plot
local function SetupCharacter(character)
    BuildModeApi:Enter()
end


function CharacterController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())
    BuildModeApi:Enter()
    
    SetupCharacter(self.Player.Character or self.Player.CharacterAdded:Wait())
    self.Player.CharacterAdded:Connect(function(character)
        SetupCharacter(character)

        character.Humanoid.Died:Connect(function()
            character.PrimaryPart.Anchored = false
            character:SetPrimaryPartCFrame(Plot.PrimaryPart.Position - Plot.PrimaryPart.Size)
        end)
    end)
end


function CharacterController:Init()
    --//Api
    BuildModeApi = self.Modules.Api.BuildModeApi
    
    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes
    
    --//Controllers
    FadeController = self.Controllers.Fade
    
    --//Locals
    
end


return CharacterController