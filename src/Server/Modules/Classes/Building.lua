-- Building
-- MrAsync
-- July 6, 2020



local Building = {}
Building.__index = Building

--//Api
local CFrameSerializer
local TableUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--//Classes
local MaidClass

--//Controllers

--//Locals


function Building.newFromSave(pseudoPlayer, guid, saveData)
    local decodedData = TableUtil.DecodeJSON(saveData)
    local decodedCFrame = CFrameSerializer:DecodeCFrame(decodedData.Position)

    return Building.new(
        pseudoPlayer,
        decodedData.ItemId,
        pseudoPlayer.Plot.Object.PrimaryPart.CFrame:ToWorldSpace(decodedCFrame),
        decodedCFrame,
        guid
    )
end


function Building.new(pseudoPlayer, itemId, worldCFrame, objectCFrame, guid)
    local self = setmetatable({
        Player = pseudoPlayer.Player,
        Id = itemId,

        WorldPosition = worldCFrame,
        ObjectPosition = objectCFrame,
        Guid = (guid or HttpService:GenerateGUID(false)),
        
        _Maid = MaidClass.new()
    }, Building)

    local object = ReplicatedStorage.Items:FindFirstChild(itemId):Clone()
    object.Parent = pseudoPlayer.Plot.Object.Placements
    object.PrimaryPart.CFrame = self.WorldPosition

    self.Object = object
    self._Maid:GiveTask(object)

    return self
end


function Building:Encode()
    return TableUtil.EncodeJSON({
        Position = CFrameSerializer:EncodeCFrame(self.ObjectPosition),
        ItemId = self.Id,
    })
end


function Building:Init()
    --//Api
    CFrameSerializer = self.Shared.CFrameSerializer
    TableUtil = self.Shared.TableUtil
    
    --//Services
    
    --//Classes
    MaidClass = self.Shared.Maid

    --//Controllers
    
    --//Locals
    
end


return Building