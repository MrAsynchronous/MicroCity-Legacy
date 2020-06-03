-- Plot Controller
-- MrAsync
-- June 2, 2020


--[[

    Handle client side operations that deal with the plot

]]


local PlotController = {}


--//Api
local LogApi

--//Services
local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot


local function MoveCharToPlot(character)
    LogApi:Log("Client | PlotController | MoveCharToPlot: Moving character to plot")

    --Yield for HumanoidRootPart because Roblox is dumb and fires the CharacterAdded event before the primarypart is set
    if (character.PrimaryPart == nil) then character:WaitForChild("HumanoidRootPart") end

    character:SetPrimaryPartCFrame(Plot.Main.CFrame + Vector3.new(0, 15, 0))
end


function PlotController:Start()
    LogApi:Log("Client | PlotController | Start: Requesting Plot from server")
    
    Plot = (PlayerService:RequestPlot() or PlayerService.RequestPlot:Wait())

    --Grab or wait for character to be added
    local Character = (self.Player.Character or self.Player.CharacterAdded:Wait())
    MoveCharToPlot(Character)

    --Listen for CharacterAdded event to move new character to plot
    self.Player.CharacterAdded:Connect(function(char)
        MoveCharToPlot(char)
    end)
end


function PlotController:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi

    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes

    --//Controllers

    --//Locals
        
end


return PlotController