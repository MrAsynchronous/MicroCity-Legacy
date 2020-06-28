-- Placement Service
-- MrAsync
-- June 27, 2020



local PlacementService = {Client = {}}

--//Api
local SnapApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService

--//Classes

--//Controllers

--//Locals


function PlacementService.Client:RequestItemPlacement(player, canvas, itemId, rawVector, orientation)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)

    local adjustedCFrame = SnapApi:SnapVector(pseudoPlayer.Plot.Object, canvas, ReplicatedStorage.Items:FindFirstChild(itemId):Clone(), rawVector, orientation)

    local model = ReplicatedStorage.Items:FindFirstChild(itemId):Clone()
    model.Parent = pseudoPlayer.Plot.Object.Placements
    model:SetPrimaryPartCFrame(pseudoPlayer.Plot.Object.PrimaryPart.CFrame:ToWorldSpace(adjustedCFrame))
end


function PlacementService:Start()
	
end


function PlacementService:Init()
    --//Api
    SnapApi = self.Shared.Api.SnapApi
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    
end


return PlacementService