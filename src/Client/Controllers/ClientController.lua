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
    --Update local plotObject when and if plotObject changes
    PlayerService.SendPlotToClient:Connect(function(newPlot)
        plotCFrame = newPlot.PrimaryPart.CFrame
    end)

    --Spawn character at plot on character reload
    self.Player.CharacterAdded:Connect(function(newCharacter)
        while (not newCharacter or not newCharacter.PrimaryPart or not plotCFrame) do wait() end

        newCharacter:SetPrimaryPartCFrame(plotCFrame + Vector3.new(0, 5, 0))
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