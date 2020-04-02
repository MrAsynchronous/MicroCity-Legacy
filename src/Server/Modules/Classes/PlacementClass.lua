-- Building Class
-- MrAsync
-- March 16, 2020



local PlacementClass = {}
PlacementClass.__index = PlacementClass


--//Api

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

		Level = 1,
		Age = 0,

		Guid = HttpService:GenerateGUID(false)
	}, PlacementClass)

	--If placement is being loaded, overwrite Level and Age attributes
	if (saveData) then
		self.Level = saveData.Level
		self.Age = saveData.Age
	end

	--Grab MetaData
	self.MetaData = MetaDataService:GetMetaData(itemId)

	--Navigate to proper repo, clone item of passed level, or default level
	self.PlacedObject = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":" .. self.Level):Clone()
	self.PlacedObject.Parent = self.Plot.Placements
	self.PlacedObject:SetPrimaryPartCFrame(self.Plot.Main.CFrame:ToWorldSpace(self.LocalPosition))
	
	return self
end

--//Moves ItemObject to desired cframe
function PlacementClass:MoveTo(itemPosition)
	self.ItemObject:SetPrimaryPartCFrame(self.Plot.Main.CFrame:ToWorldSpace(itemPosition))

	self.LocalPosition = itemPosition
end


function PlacementClass:Remove()
	self.ItemObject:Destroy()
end


function PlacementClass:Init()
	--//Api

	--//Services
	MetaDataService = self.Services.MetaDataService

	--//Controllers

	--//Classes

	--//Locals

end

return PlacementClass