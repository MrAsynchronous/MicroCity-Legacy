-- Player Class
-- MrAsync
-- March 17, 2020


--[[

	Objects contain various getters and setters to make accessing and setting player information easier

	Methods
		public PseudoPlayer PseudoPlayer.new(Player player)

		public DataStore2Key GetData(String key)
		public void SetData(String key, Any value)

		public void AddPlacementObject(String guid, PlacementObject placementObject)
		public void UpdatePlacementObject(PlacementObject placementObject, String oldObjectSpace)
		public PlacementObject GetPlacementObject(String guid)
		public void RemovePlacementObject(String guid)
		public void CleanPlot()

]]


local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer


--//Api
local DataStore2
local TableUtil

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes
local MaidClass

--//Locals
local PlayerMetaData

local PLACEMENT_DATA_KEY = "MicroCity_Placements_Pre-Alpha_1"
local PLAYERDATA_DATA_KEY = "MicroCity_PlayerData_Pre-Alpha_1"

local VALUE_EXCHANGE = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["table"] = "StringValue",
}


function PseudoPlayer.new(player)
	local self = setmetatable({
		Player = player,
		Placements = {},
		
		PlacementStore = DataStore2(PLACEMENT_DATA_KEY, player),

		_Maid = MaidClass.new(),
	}, PseudoPlayer)


	--Construct a new DataFolder
	--Allows client to easily access parts of PlayersData
	self.DataFolder = Instance.new("Folder")
	self.DataFolder.Name = player.UserId
	self.DataFolder.Parent = ReplicatedStorage.ReplicatedData

	--Store DataStore2 DataKeys
	for key, value in pairs(PlayerMetaData) do
		self[key] = DataStore2(key, player)

		--Values beginning with '_' are not replicated to the Client
		if (string.sub(key, 1, 1) ~= '_') then
			--Construct a new serializedNode so client can detect changes efficiently
			local serializedNode = Instance.new(VALUE_EXCHANGE[type(value)])
			serializedNode.Name = key
			serializedNode.Parent = self.DataFolder

			--Tables are stored as encoded JSON, encode if needed
			--Else, set value like normal
			if (type(value) == "table") then
				serializedNode.Value = TableUtil.EncodeJSON( self[key]:Get(PlayerMetaData[key]) )
			else
				serializedNode.Value = self[key]:Get(PlayerMetaData[key])
			end

			--Automatically update replicated values
			self._Maid[key] = self[key]:OnUpdate(function(newValue)
				if (type(newValue) == "table") then
					serializedNode.Value = TableUtil.Encode(newValue)
				else
					serializedNode.Value = newValue
				end
			end)
		end
	end 

	return self
end


--//Called when player resets plot of leaves the game
--//Destroys all player objects, doesn't remove placements from data
function PseudoPlayer:CleanPlot()
	for _, placementObject in pairs(self.Placements) do
		placementObject:Destroy()
	end
end


--//Sets the value at index placementGuid to key placementObject
--//Called when player places a new object
function PseudoPlayer:SetPlacementObject(placementObject)
	self.Placements[placementObject.Guid] = placementObject

	--Update placementStore
	self.PlacementStore:Update(function(oldTable)
		local objectSpace, objectData = placementObject:Encode()
		oldTable[objectSpace] = objectData

		return oldTable
	end)
end


--//Updates a stored placement object on both the server
--//and on the DataStore
function PseudoPlayer:UpdatePlacementObject(placementObject, oldObjectSpace)
	self.Placements[placementObject.Guid] = placementObject

	--Remove old key and insert new key
	self.PlacementStore:Update(function(oldTable)
		local objectSpace, objectData = placementObject:Encode()
		oldTable[oldObjectSpace] = nil
		oldTable[objectSpace] = objectData

		return oldTable
	end)
end


--//Sets the value at index placementGuid to nil
function PseudoPlayer:RemovePlacementObject(placementGuid)
	local placementObject = self:GetPlacementObject(placementGuid)
	local objectSpace = placementObject:Encode()

	placementObject:Destroy()
	
	--Update placementStore
	self.PlacementStore:Update(function(oldTable)
		oldTable[objectSpace] = nil

		return oldTable
	end)
end


--//Returns the value at index placementGuid
function PseudoPlayer:GetPlacementObject(placementGuid)
	return self.Placements[placementGuid]
end


--//Fully removes PseudoPlayer, placementObjects and event listeners from existence
--*thanos snap*
function PseudoPlayer:Destroy()
	self:CleanPlot()

	self._Maid:Destroy()
end


function PseudoPlayer:Start()
	--Combine all keys to master PlayerData key
	for key, value in pairs(PlayerMetaData) do
		DataStore2.Combine(PLAYERDATA_DATA_KEY, key)
	end
end


function PseudoPlayer:Init()
	--//Api
	DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
	TableUtil = self.Shared.TableUtil

	--//Services
	
	--//Controllers
	
	--//Classes
	MaidClass = self.Shared.Maid
	
	--//Locals
	PlayerMetaData = require(ReplicatedStorage.MetaData:WaitForChild("Player"))

end


return PseudoPlayer