-- Player Class
-- MrAsync
-- March 17, 2020


--[[

	Objects contain various getters and setters to make accessing and setting player information easier

	Methods
		public PseudoPlayer PseudoPlayer.new(Player player)

		public DataStore2Key GetData(String key)
		public void SetData(String key, Any value)

		public void DepositCash(Number amount)
		public boolean WithdrawCash(Number amount)

		public void AddPlacementObject(String guid, PlacementObject placementObject)
		public void UpdatePlacementObject(PlacementObject placementObject, String oldObjectSpace)
		public PlacementObject GetPlacementObject(String guid)
		public void RemovePlacementObject(String guid)

]]


local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer


--//Api
local DataStore2
local TableUtil
local GameSettings

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes
local MaidClass

--//Locals
local PlayerMetaData

local VALUE_EXCHANGE = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["table"] = "StringValue",
}


function PseudoPlayer.new(player)
	local self = setmetatable({
		Player = player,
		IsLoaded = false,
		PlacementStore = DataStore2(GameSettings.PlayerPlacementsToken, player),

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
					serializedNode.Value = TableUtil.EncodeJSON(newValue)
				else
					serializedNode.Value = newValue
				end
			end)
		end
	end 

	return self
end


--//Fully removes PseudoPlayer, placementObjects and event listeners from existence
--*thanos snap*
function PseudoPlayer:Destroy()
	self.PlotObject:Destroy()
	self._Maid:Destroy()
end


function PseudoPlayer:Start()
	--Combine all keys to master PlayerData key
	for key, value in pairs(PlayerMetaData) do
		DataStore2.Combine(GameSettings.PlayerDataToken, key)
	end
end


function PseudoPlayer:Init()
	--//Api
	DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
	TableUtil = self.Shared.TableUtil
	GameSettings = require(ReplicatedStorage.MetaData.Settings)

	--//Services
	
	--//Controllers
	
	--//Classes
	MaidClass = self.Shared.Maid
	
	--//Locals
	PlayerMetaData = require(ReplicatedStorage.MetaData:WaitForChild("Player"))

end


return PseudoPlayer