-- Character Controller
-- MrAsync
-- June 26, 2020



local CharacterController = {}

--//Api

--//Services
local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot


--//Positions player's character in front of their plot
local function MoveCharacterToPlot(character)
    while (not character.PrimaryPart) do wait() end

    character:SetPrimaryPartCFrame(Plot.PrimaryPart.CFrame + ((Plot.PrimaryPart.Size * Plot.PrimaryPart.CFrame.LookVector) / 2) + Vector3.new(0, 10, 0))
end


function CharacterController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())
    
    MoveCharacterToPlot(self.Player.Character or self.Player.CharacterAdded:Wait())
    self.Player.CharacterAdded:Connect(function(character)
        MoveCharacterToPlot(character)
    end)
end


function CharacterController:Init()
	--//Api
    
    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return CharacterController