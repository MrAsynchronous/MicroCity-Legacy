-- Client Controller
-- MrAsync
-- March 29, 2020


--[[

    General purpose controller than controls the initialization of the client

]]


local ClientController = {}

--//Api

--//Services
local PlayerService

--//Controllers

--//Classes

--//Locals
local plotCFrame


function ClientController:Start()
    local playerPlotValue = self.Player:WaitForChild("PlayerPlot")
    local playerPlot = playerPlotValue.Value

    --Yield until Plot.Main exists
    while (not playerPlot:FindFirstChild("Main")) do wait() end

    --Move character to plot
    local character = (self.Player.Character or self.Player.CharacterAdded:Wait())
    character:SetPrimaryPartCFrame(playerPlot.Main.CFrame + Vector3.new(0, 5, 0))

    --Spawn character at plot on character reload
    self.Player.CharacterAdded:Connect(function(newCharacter)
        newCharacter:SetPrimaryPartCFrame(playerPlot.Main.CFrame + Vector3.new(0, 5, 0))
    end)
end


function ClientController:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals	
    
end


return ClientController