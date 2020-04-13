-- Player Class
-- MrAsync
-- March 17, 2020


--[[

	Objects contain various getters and setters to make accessing and setting player information easier

	Methods
		public PlayerObject PlayerClass.new(Player player)

		public DataStore2Key GetData(String key)
		public void SetData(String key, Any value)

		public void AddPlacementObject(String guid, PlacementObject placementObject)
		public PlacementObject GetPlacementObject(String guid)
		public void RemovePlacementObject(String guid)
		public void CleanPlot()

]]


local PlayerClass = {}
PlayerClass.__index = PlayerClass


--//Api
local DataStore2
local TableUtil
local CFrameSerializer

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes
local PlacementClass

--//Locals
local PlayerMetaData

local VALUE_EXCHANGE = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["table"] = "StringValue",
}


function PlayerClass.new(player)
	local self = setmetatable({

		Player = player,
		Placements = {},
		PlacementStore = DataStore2("Placements", player),

		DataKeys = {},
		DataFolder = ReplicatedStorage.ReplicatedData:FindFirstChild(tonumber(player.UserId))
	}, PlayerClass)


	--Construct a new DataFolder
	--Allows client to easily access parts of PlayersData
	local dataFolder = Instance.new("Folder")
	dataFolder.Name = player.UserId
	dataFolder.Parent = ReplicatedStorage.ReplicatedData

	--Store DataStore2 DataKeys
	for key, value in pairs(PlayerMetaData) do
		self.DataKeys[key] = DataStore2(key, player)

		--Values beginning with '_' are not replicated to the Client
		if (string.sub(key, 1, 1) ~= '_') then
			--Construct a new serializedNode so client can detect changes efficiently
			local serializedNode = Instance.new(VALUE_EXCHANGE[type(value)])
			serializedNode.Name = key
			serializedNode.Parent = dataFolder

			--Tables are stored as encoded JSON, encode if needed
			--Else, set value like normal
			if (type(value) == "table") then
				serializedNode.Value = TableUtil.EncodeJSON( self:GetData(key) )
			else
				serializedNode.Value = self:GetData(key)
			end

			--Automatically update replicated values
			self.DataKeys[key]:OnUpdate(function(newValue)
				if (type(newValue) == "table") then
					serializedNode.Value = TableUtil.Encode(newValue)
				else
					serializedNode.Value = newValue
				end
			end)
		end
	end 
	self.DataFolder = dataFolder

	return self
end


--//Called when player resets plot of leaves the game
function PlayerClass:CleanPlot()
	for _, placementObject in pairs(self.Placements) do
		placementObject:Remove()

		wait()
	end
end


--//Sets the value at index placementGuid to key placementObject
--//Called when player places a new object
function PlayerClass:SetPlacementObject(placementObject)
	self.Placements[placementObject.Guid] = placementObject

	--Update placementStore
	self.PlacementStore:Update(function(oldTable)
		oldTable[placementObject.Guid] = placementObject:Encode()

		return oldTable
	end)
end


--//Sets the value at index placementGuid to nil
function PlayerClass:RemovePlacementObject(placementGuid)
	self.Placements[placementGuid] = nil

	--Update placementStore
	self.PlacementStore:Update(function(oldTable)
		oldTable[placementGuid] = nil

		return oldTable
	end)
end


--//Returns the value at index placementGuid
function PlayerClass:GetPlacementObject(placementGuid)
	return self.Placements[placementGuid]
end


--//Returns DataStore2 Data
function PlayerClass:GetData(key)
	return self.DataKeys[key]:Get(PlayerMetaData[key])
end


--//Sets DataStore2 Key Data
function PlayerClass:SetData(key, value)
	local leaderstatsValue = self.Player.leaderstats:FindFirstChild(key)
	if (leaderstatsValue) then 
		leaderstatsValue.Value = value 
	end

	return self.DataKeys[key]:Set(value)
end


function PlayerClass:Start()

	--Combine all keys to master PlayerData key
	for key, value in pairs(PlayerMetaData) do
		DataStore2.Combine("PlayerData", key)
	end
end


function PlayerClass:Init()
	--//Api
	DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
	TableUtil = self.Shared.TableUtil
	CFrameSerializer = self.Shared.CFrameSerializer

	--//Services
	
	--//Controllers
	
	--//Classes
	PlacementClass = self.Modules.Classes.PlacementClass
	
	--//Locals
	PlayerMetaData = require(ReplicatedStorage.MetaData:WaitForChild("Player"))

end


return PlayerClass