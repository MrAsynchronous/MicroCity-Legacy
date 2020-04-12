-- Building Class
-- MrAsync
-- March 16, 2020


--[[

	Methods
		public PlacementObject PlacementClass.new(
			int ItemId,
			CFrame itemPosition,
			PlayerObject playerObject,
			Array saveData
		)

		public void MoveTo(CFrame itemPosition)
		public void Remove()
		public String Encode()

]]


local PlacementClass = {}
PlacementClass.__index = PlacementClass


--//Api
local CFrameSerializer
local TableUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local MetaDataService

--//Controllers

--//Classes

--//Locals


--//Constructor for PlacementClass
function PlacementClass.new(itemId, itemPosition, playerObject, saveData)
	local self = setmetatable({
		ItemId = itemId,
		Plot = playerObject.PlotObject,
		LocalPosition = itemPosition,
		WorldPosition = playerObject.PlotObject.Main.CFrame:ToWorldSpace(itemPosition),

		Level = 1,
		Age = 0,

		Guid = HttpService:GenerateGUID(false)
	}, PlacementClass)

	--If placement is being loaded, overwrite Level and Age attributes
	if (saveData) then
		self.Level = saveData.Level
		self.Age = saveData.Age
		self.Guid = saveData.Guid
	end

	--Grab MetaData
	self.MetaData = MetaDataService:GetMetaData(itemId)

	--Navigate to proper repo, clone item of passed level, or default level
	self.PlacedObject = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":" .. self.Level):Clone()
	self.PlacedObject.Parent = (self.Plot.Placements:FindFirstChild(self.MetaData.Type .. "s") or self.Plot.Placements)
	self.PlacedObject.Name = self.Guid

	self.LocalPosition = self:ConstructPosition(itemPosition)
	self.PlacedObject:SetPrimaryPartCFrame(self.Plot.Main.CFrame:ToWorldSpace(self.LocalPosition))

	return self
end


--//Returns the next available level
function PlacementClass:CanUpgrade()
	local nextLevel = (math.clamp(self.Level + 1, 1, (#self.MetaData.Upgrades + 1) or 1))

	--Return true if next upgrade is available, false otherwise
	if (nextLevel > self.Level) then
		return true
	else
		return false
	end
end


--//Updates the level and model of the placed object
--//Precondition: Object can be upgraded
function PlacementClass:Upgrade()
	local currentLevel = self.Level
	
	--Increase level but clamp between minimum and maximum levels
	self.Level = math.clamp(self.Level + 1, 1, ((#self.MetaData.Upgrades + 1) or 1))
	
	if (self.Level > currentLevel) then
		self.PlacedObject:Destroy()

		--Replace with new model
		self.PlacedObject = ReplicatedStorage.Items.Buildings:FindFirstChild(self.ItemId .. ":" .. self.Level):Clone()
		self.PlacedObject.Parent = (self.Plot.Placements:FindFirstChild(self.MetaData.Type .. "s") or self.Plot.Placements)
		self.PlacedObject.Name = self.Guid
	
		--Reconstruct CFrame to account for model size differences
		self.LocalPosition = self:ConstructPosition(self.LocalPosition)
		self.PlacedObject:SetPrimaryPartCFrame(self.Plot.Main.CFrame:ToWorldSpace(self.LocalPosition))
	end
end


--//Calculate proper position constrained to plot
function PlacementClass:ConstructPosition(itemPosition)
    --Clamp model to plotSize (anti-haxx)
    local xPosition, yPosition, zPosition, R00, R01, R02, R10, R11, R12, R20, R21, R22 = itemPosition:GetComponents()
	xPosition = math.clamp(xPosition, -(self.Plot.Main.Size.X / 2) + (self.PlacedObject.PrimaryPart.Size.X / 2), (self.Plot.Main.Size.X / 2) - (self.PlacedObject.PrimaryPart.Size.X / 2))
	yPosition = (self.Plot.Main.Size.Y / 2) + (self.PlacedObject.PrimaryPart.Size.Y / 2)
	zPosition = math.clamp(zPosition, -(self.Plot.Main.Size.Z / 2) + (self.PlacedObject.PrimaryPart.Size.Z / 2), (self.Plot.Main.Size.Z / 2) - (self.PlacedObject.PrimaryPart.Size.Z / 2))

	--Reconstruct CFrame
	return CFrame.new(xPosition, yPosition, zPosition, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end


--//Moves ItemObject to desired cframe
function PlacementClass:MoveTo(itemPosition)
	self.PlacedObject:SetPrimaryPartCFrame(self.Plot.Main.CFrame:ToWorldSpace(itemPosition))
	self.LocalPosition = itemPosition

	return true
end


--//Removes model from map
--//Cleans up MetaTable
function PlacementClass:Remove()
	self.PlacedObject:Destroy()
	self = nil
end


--//Returns a JSON table containing information to be saved
function PlacementClass:Encode()
	return TableUtil.EncodeJSON({
		Guid = self.Guid,
		ItemId = self.ItemId,
		CFrame = CFrameSerializer:EncodeCFrame(self.LocalPosition),
		Level = self.Level,
		Age = self.Age
	})
end


function PlacementClass:Init()
	--//Api
	CFrameSerializer = self.Shared.CFrameSerializer
	TableUtil = self.Shared.TableUtil

	--//Services
	MetaDataService = self.Services.MetaDataService

	--//Controllers

	--//Classes

	--//Locals

end

return PlacementClass