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
local MaidClass

--//Controllers

--//Locals


--//Constructor
function Building.new(pseudoPlayer, itemId, objectPosition, guid, saveData)
    if (not pseudoPlayer or not pseudoPlayer.Plot or not pseudoPlayer.Plot.Object) then return end

    local self = setmetatable({
        Player = pseudoPlayer.Player,
        ItemId = itemId,
        ObjectPosition = objectPosition,
        WorldPosition = pseudoPlayer.Plot.CFrame:ToWorldSpace(objectPosition),
        MetaData = MetaDataService:GetMetaData(itemId),

        Level = ((saveData and saveData.Level) or 1),
        Guid = (guid or HttpService:GenerateGUID(false)),

        _Maid = MaidClass.new()
    }, Building)

    self.PlotObject = pseudoPlayer.Plot.Object

    self.Object = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":" .. self.Level):Clone()
    self.Object.Name = self.Guid
    self.Object.Parent = pseudoPlayer.Plot.Object.Placements:FindFirstChild(self.MetaData.Type)
    self.Object:SetPrimaryPartCFrame(pseudoPlayer.Plot.CFrame:ToWorldSpace(objectPosition))

    self._Maid:GiveTask(self.Object)

    return self
end


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


function Building:Move(objectPosition)
    self.ObjectPosition = objectPosition
    self.WorldPosition = self.PlotObject.Main.CFrame:ToWorldSpace(objectPosition)

    self.Object:SetPrimaryPartCFrame(self.WorldPosition)
end


function Building:Upgrade(level, isSolvedRoad)
    level = (level or math.clamp(self.Level + 1, 1, #self.MetaData.Upgrades))

    --Only upgrade if level is available
    if (level > self.Level) then
        self.Level = level
        self._Maid:DoCleaning()

        --Clean up potential duplicates
        local objectClone = self.PlotObject.Placements:FindFirstChild(self.Guid, true) 
        if (objectClone) then
            objectClone:Destroy()
        end

        --Clone new model
        self.Object = ReplicatedStorage.Items.Buildings:FindFirstChild(self.ItemId .. ":" .. self.Level):Clone()
        self.Object.Name = self.Guid
        self.Object.Parent = self.PlotObject.Placements:FindFirstChild(self.MetaData.Type)
        self.Object:SetPrimaryPartCFrame(self.WorldPosition)

        self._Maid:GiveTaks(self.Object)
    end
end


--//Removes building from existance.  Thanos snap
function Building:Destroy()
    self._Maid:Destroy()
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
    MaidClass = self.Shared.Maid

    --//Controllers

    --//Locals

end


return Building