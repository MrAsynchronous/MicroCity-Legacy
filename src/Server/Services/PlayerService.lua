-- Player Service
-- MrAsync
-- June 26, 2020



local PlayerService = {Client = {}}

--//Api

--//Services
local Players = game:GetService("Players")

--//Classes

--//Controllers

--//Lxocals


function PlayerService:Start()
    Players.PlayerAdded:Connect(function(player)
    
    end)

    Players.PlayerRemoving:Connect(function(player)
         
    end)
end


function PlayerService:Init()
	--//Api

    --//Services

    --//Classes

    --//Controllers

    --//Locals

end


return PlayerService