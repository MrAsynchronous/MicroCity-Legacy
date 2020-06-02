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


function PlotController:Start()
    LogApi:Log("Client | PlotController | Start: Requesting Plot from server")
    
    Plot = PlayerService:RequestPlot()
    
    LogApi:Log("Client | PlotController | Start: Moving player-character to plot")

    --Move character to plot
    local character = self.Player.Character or self.Player.CharacterAdded:Wait()
    character:SetPrimaryPartCFrame(Plot.Main.CFrame + Vector3.new(0, 15, 0))

    --Listen for CharacterAdded to move player to plot
    self.Player.CharacterAdded:Connect(function(newCharacter)
        while (newCharacter.PrimaryPart == nil) do wait() end
        
        LogApi:Log("Client | PlotController | Start: Moving player-character to plot after reset")
        newCharacter:SetPrimaryPartCFrame(Plot.Main.CFrame + Vector3.new(0, 15, 0))
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