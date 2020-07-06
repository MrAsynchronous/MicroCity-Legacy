-- Character Controller
-- MrAsync
-- June 26, 2020



local CharacterController = {}
local self = CharacterController

--//Api
local FreeCamApi

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
    FreeCamApi:Enter()

    character:SetPrimaryPartCFrame(Plot.PrimaryPart.CFrame - Vector3.new(0, 25, 0))
end


function CharacterController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())
    
    SetupCharacter(self.Player.Character or self.Player.CharacterAdded:Wait())
end


function CharacterController:Init()
    --//Api
    FreeCamApi = self.Modules.Api.FreeCamApi
    
    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes
    
    --//Controllers
    FadeController = self.Controllers.Fade
    
    --//Locals
    
end


return CharacterController