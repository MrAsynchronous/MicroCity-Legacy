-- Building
-- MrAsync
-- June 4, 2020



local Building = {}
Building.__index = Building


--//Api
local CFrameSerializer
local TableUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local MetaDataService

--//Classes

--//Controllers

--//Locals


--//Overload constructor for creating buildings based of off persisted data
function Building.newFromSave(pseudoPlayer, guid, saveData)
    local decodedData = TableUtil.DecodeJSON(saveData)

    return Building.new(
        pseudoPlayer, 
        decodedData.ItemId, 
        CFrameSerializer:DecodeCFrame(decodedData.Position),
        guid,
        decodedData
    )
end


--//Constructor
function Building.new(pseudoPlayer, itemId, objectPosition, guid, saveData)
    local self = setmetatable({
        Player = pseudoPlayer.Player,
        ItemId = itemId,
        ObjectPosition = objectPosition,
        WorldPosition = pseudoPlayer.Plot.CFrame:ToWorldSpace(objectPosition),
        MetaData = MetaDataService:GetMetaData(itemId),

        Level = ((saveData and saveData.Level) or 1),
        Guid = (guid or HttpService:GenerateGUID(false))
    }, Building)

    self.Object = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":" .. self.Level):Clone()
    self.Object.Name = self.Guid
    self.Object.Parent = pseudoPlayer.Plot.Object.Placements:FindFirstChild(self.MetaData.Type)
    self.Object:SetPrimaryPartCFrame(pseudoPlayer.Plot.CFrame:ToWorldSpace(objectPosition))

    return self
end


function Building:Move(objectPosition)

end


function Building:Upgrade()
    
end


--//Returns a JSON table containing information to be saved
function Building:Encode()
	return TableUtil.EncodeJSON({
		Position = CFrameSerializer:EncodeCFrame(self.ObjectPosition),
		ItemId = self.ItemId,
		Level = self.Level
	})
end


function Building:Init()
    --//Api
    CFrameSerializer = self.Shared.CFrameSerializer
    TableUtil = self.Shared.TableUtil

    --//Services
    MetaDataService = self.Services.MetaDataService

    --//Classes

    --//Controllers

    --//Locals

end


return Building