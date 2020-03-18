-- Player Class
-- MrAsync
-- March 17, 2020



local PlayerClass = {}
PlayerClass.__index = PlayerClass


--//Api
local DataStore2

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--//Controllers

--//Classes

--//Locals
local PlayerMetaData


function PlayerClass.new(player)

	local self = setmetatable({

		Player = player,
		DataKeys = {}

	}, PlayerClass)


	--Store DataStore2 DataKeys
	for key, value in pairs(PlayerMetaData.MetaData) do
		self.DataKeys[key] = DataStore2(key, player)
	end


	return self
end


function PlayerClass:GetData(key)
	return self.DataKeys[key]:Get(PlayerMetaData.MetaData[key])
end


function PlayerClass:SetData(key, value)
	return self.DataKeys[key]:Set(value)
end



function PlayerClass:Start()

	--Combine all keys to master PlayerData key
	for key, value in pairs(PlayerMetaData.MetaData) do
		DataStore2.Combine("PlayerData", key)
	end
end


function PlayerClass:Init()
	--//Api
	DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
	
	--//Services
	
	--//Controllers
	
	--//Classes
	
	--//Locals
	PlayerMetaData = require(ReplicatedFirst.MetaData:WaitForChild("Player"))

end


return PlayerClass