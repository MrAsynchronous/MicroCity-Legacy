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
    while (not character.PrimaryPart) do wait() end
    BuildModeApi:Enter()

    character.Humanoid.Died:Connect(function()
        self.Player.CharacterAdded:Wait()
        BuildModeApi:Enter()
    end)

    character:SetPrimaryPartCFrame(
        Plot.PrimaryPart.CFrame + ((Plot.PrimaryPart.Size * Plot.PrimaryPart.CFrame.LookVector) / 2) - Vector3.new(0, 25, 0))
end


function CharacterController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())
    
    SetupCharacter(self.Player.Character or self.Player.CharacterAdded:Wait())

    self.Player.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
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