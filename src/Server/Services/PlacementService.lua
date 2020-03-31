-- Placement Service
-- MrAsync
-- March 29, 2020



local PlacementService = {Client = {}}


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService

--//Controllers

--//Classes

--//Locals

--[[
    Client-exposed methods
]]

function PlacementService.Client:PlaceObject(...)
    return self.Server:PlaceObject(...)
end

--[[
    Server methods
]]
function PlacementService:PlaceObject(player, itemId, localPosition)
    local playerObject = PlayerService:GetPlayerObject(player)

    local newObject = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId).Lvl1:Clone()
    newObject.Parent = playerObject.PlotObject.Placements
    newObject:SetPrimaryPartCFrame(playerObject.PlotObject.Main.CFrame:ToWorldSpace(localPosition))

    return true
end


function PlacementService:Start()
	
end


function PlacementService:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals	
    
end


return PlacementService