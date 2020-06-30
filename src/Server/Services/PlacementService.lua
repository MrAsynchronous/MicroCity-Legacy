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
    if (not orientation or (orientation and not typeof(orientation) == "nunmber")) then return end
    if (not rawVector or (rawVector and not typeof(rawVector) == "Vector3")) then return end
    if (not itemId or (itemId and not typeof(itemId) == "number")) then return end
    if (not canvas or (canvas and not canvas:IsA("Instance"))) then return end
    if (not player) then return end

    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    if (not pseudoPlayer) then return end

    local model 

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