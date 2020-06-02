-- Player Service
-- MrAsync
-- June 2, 2020


--[[

    Handle the PlayerAdded and PlayerRemoving events

]]


local PlayerService = {Client = {}}

--//Api

--//Services
local Players = game:GetService("Players")

--//Classes

--//Controllers

--//Locals

function PlayerService:Start()
    Players.PlayerAdded:Connect(function(player)
        
    end)
end


function PlayerService:Init()
	
end


return PlayerService