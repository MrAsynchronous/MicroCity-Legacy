-- Plot Class
-- MrAsync
-- March 16, 2020


--[[

	Methods:
		public PlotObject PlotClass.new(PseudoPlayer pseudoPlayer)
		public void Upgrade(Integer newLevel)
		public void ChangeSize()
		public boolean LoadPlacements(PseudoPlayer pseudoPlayer)

]]


local PlotClass = {}
PlotClass.__index = PlotClass


--//Api
local CFrameSerializer
local PlotSettings
local TableUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService

--//Controllers

--//Classes
local PlacementClass

--//Locals
local plotStack
local plotContainer


--//Constructor for PlotClass
function PlotClass.new(pseudoPlayer)
	local self = setmetatable({
		Player = pseudoPlayer.Player,

		DebugNetwork = {},
		RoadNetwork = {},
		CachedPlacements = {},
		Level = pseudoPlayer.PlotLevel:Get(1)
	}, PlotClass)

	--Assign physical plot
	self.Object = table.remove(plotStack, #plotStack)

	--Change plot size to loaded level
	self:ChangeSize(PlotSettings.Upgrades[self.Level].Size)

	--Size, CFrame and corner localization
	self.size = self.Object.Main.Size
	self.cframe = self.Object.Main.CFrame
	self.corner = self.cframe - (self.size / 2) + Vector3.new(1, 0, 1)

	--Populate the list
	self.TotalRows = self.Object.Main.Size.Z / 2
	for i=1, self.TotalRows do
		table.insert(self.DebugNetwork, {})
		table.insert(self.RoadNetwork, {})

		for v=1, self.TotalRows do
			local part = Instance.new("Part")
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Size = Vector3.new(1, 1, 1)
			part.CFrame = self.cframe + (Vector3.new(1 * (v - 1), 3, 1 * (i - 1)))
			part.Parent = workspace

			self.DebugNetwork[i][v] = part
		end
	end

	return self
end


--//Converts a worldSpace to a GridSpace
function PlotClass:ToGridSpace(worldSpace)
	local objectSpace = self.corner:ToObjectSpace(worldSpace)

	return Vector3.new(
		math.ceil(math.abs(objectSpace.X / 2) + 1),
		0,
		math.ceil(math.abs(objectSpace.Z / 2) + 1)
	)
end


--//Returns the four adjacent tiles
--//Indecies may be null
function PlotClass:GetAdjacentRoads(gridSpace, isRemoving)
--	if (self.RoadNetwork[gridSpace.Z] and (self.RoadNetwork[gridSpace.Z][gridSpace.X])) then 
		return {
			Top = self.RoadNetwork[math.clamp(gridSpace.Z - 1, 1, self.TotalRows)][gridSpace.X],
			Bottom = self.RoadNetwork[math.clamp(gridSpace.Z + 1, 1, self.TotalRows)][gridSpace.X],
			Left = self.RoadNetwork[gridSpace.Z][math.clamp(gridSpace.X - 1, 1, self.TotalRows)],
			Right = self.RoadNetwork[gridSpace.Z][math.clamp(gridSpace.X + 1, 1, self.TotalRows)]
		}
--	else
--		return {
--			Top = nil,
--			Bottom = nil,
--			Left = nil,
--			Right = nil
--		}
--	end
end


function PlotClass:NetworkRoad(placementObject, adjacentRoads)
	--Four way intersection
	if (adjacentRoads.Top and adjacentRoads.Bottom and adjacentRoads.Left and adjacentRoads.Right) then
		placementObject:Upgrade(4, true)

	--Three way intetsection possibilites
	elseif ((adjacentRoads.Top and adjacentRoads.Bottom and (adjacentRoads.Right or adjacentRoads.Left)) or (adjacentRoads.Right and adjacentRoads.Left and (adjacentRoads.Top or adjacentRoads.Bottom))) then
		placementObject:Upgrade(3, true)

		--Orientation detection
		local worldPosition = placementObject.WorldPosition
		if (adjacentRoads.Right and adjacentRoads.Left) then
			worldPosition = CFrame.new(worldPosition.Position, (adjacentRoads.Top and adjacentRoads.Top.WorldPosition.Position or adjacentRoads.Bottom.WorldPosition.Position))
		elseif (adjacentRoads.Top and adjacentRoads.Bottom) then
			worldPosition = CFrame.new(worldPosition.Position, (adjacentRoads.Right and adjacentRoads.Right.WorldPosition.Position or adjacentRoads.Left.WorldPosition.Position))
		end

		--Update the model
		placementObject:Move(self.cframe:ToObjectSpace(worldPosition))

	--Turn possibilities
	elseif (adjacentRoads.Top and adjacentRoads.Left or adjacentRoads.Top and adjacentRoads.Right or adjacentRoads.Bottom and adjacentRoads.Right or adjacentRoads.Bottom and adjacentRoads.Left) then
		placementObject:Upgrade(2, true)

		--Orientation detection
		local worldPosition = placementObject.WorldPosition
		if (adjacentRoads.Top and adjacentRoads.Left) then
			worldPosition = CFrame.new(worldPosition.Position, adjacentRoads.Left.WorldPosition.Position)
		elseif (adjacentRoads.Top and adjacentRoads.Right) then
			worldPosition = CFrame.new(worldPosition.Position, adjacentRoads.Top.WorldPosition.Position)
		elseif (adjacentRoads.Bottom and adjacentRoads.Right) then
			worldPosition = CFrame.new(worldPosition.Position, adjacentRoads.Right.WorldPosition.Position)
		elseif (adjacentRoads.Bottom and adjacentRoads.Left) then
			worldPosition = CFrame.new(worldPosition.Position, adjacentRoads.Bottom.WorldPosition.Position)
		end

		--Update the model
		placementObject:Move(self.cframe:ToObjectSpace(worldPosition))

	--Straight road possiblities
	elseif (adjacentRoads.Top or adjacentRoads.Bottom or adjacentRoads.Left or adjacentRoads.Right) then
		if (placementObject.Level > 1) then
			placementObject:Upgrade(1, true)
		end

		--Orientation detection
		local worldPosition = CFrame.new(
			placementObject.WorldPosition.Position, 
			(adjacentRoads.Top and adjacentRoads.Top.WorldPosition.Position) or 
			(adjacentRoads.Bottom and adjacentRoads.Bottom.WorldPosition.Position) or
			(adjacentRoads.Left and adjacentRoads.Left.WorldPosition.Position) or
			(adjacentRoads.Right and adjacentRoads.Right.WorldPosition.Position)
		)

		--Update model
		placementObject:Move(self.cframe:ToObjectSpace(worldPosition))
	end	
end


--//Adds the road to the RoadNetwork, solves the surrounding roads' networking
function PlotClass:AddRoadToNetwork(placementObject, isBeingLoaded)
	if (placementObject.MetaData.Type ~= "Road") then return end

	local gridSpace = self:ToGridSpace(placementObject.WorldPosition)
	self.RoadNetwork[gridSpace.Z][gridSpace.X] = placementObject
	self.DebugNetwork[gridSpace.Z][gridSpace.X].Color = Color3.fromRGB(0, 255, 0)

	--Only solve if road is not being loaded
	if (not isBeingLoaded) then
		local adjacentRoads = self:GetAdjacentRoads(gridSpace)
		self:NetworkRoad(placementObject, adjacentRoads)

		--Update surrounding tiles
		for _, adjacentRoad in pairs(adjacentRoads) do
			local adjacentGridSpace = self:ToGridSpace(adjacentRoad.PlacedObject.PrimaryPart.CFrame)
			self:NetworkRoad(adjacentRoad, self:GetAdjacentRoads(adjacentGridSpace))
		end
	end
end


--//Removes the road from the RoadNetwork
function PlotClass:RemoveRoadFromNetwork(placementObject)
	if (placementObject.MetaData.Type ~= "Road") then return end

	local gridSpace = self:ToGridSpace(placementObject.WorldPosition)
	self.RoadNetwork[gridSpace.Z][gridSpace.X] = nil
	self.DebugNetwork[gridSpace.Z][gridSpace.X].Color = Color3.fromRGB(255, 0, 0)

	local adjacentRoads = self:GetAdjacentRoads(gridSpace, true)

	--Update surrounding tiles
	for _, adjacentRoad in pairs(adjacentRoads) do
		print("Updating adjacent road")

		local adjacentGridSpace = self:ToGridSpace(adjacentRoad.PlacedObject.PrimaryPart.CFrame)
		self:NetworkRoad(adjacentRoad, self:GetAdjacentRoads(adjacentGridSpace))
	end
end


--//Returns true if Plot can be upgraded
--//Returns false if plot cannot be upgraded
function PlotClass:CanUpgrade()
	return (math.clamp(self.Level + 1, 1, #PlotSettings.Upgrades) > self.Level)
end


--//Attempts to upgrade the plot if upgrade is avaiable
--/Pre-condition: Player can afford an upgrade
function PlotClass:Upgrade()
	if (self:CanUpgrade()) then
		self.Level = self.Level + 1

		local levelMetaData = PlotSettings.Upgrades[self.Level]
		self:ChangeSize(levelMetaData.Size)
	end
end


--//Changes the size of the VisualPart
function PlotClass:ChangeSize(newSize)
	self.Object.VisualPart.Size = newSize

	PlayerService:FireClientEvent("PlotSizeChanged", self.Player)
end


function PlotClass:LoadPlacements(pseudoPlayer)
    local placementData = pseudoPlayer.PlacementStore:Get({})
    local objectsLoaded = 0

	--Iterate through all the placements asynchronously
	coroutine.wrap(function()
		for objectSpace, encodedData in pairs(placementData) do
			local decodedData = TableUtil.DecodeJSON(encodedData)

			local placementObject = PlacementClass.new(
				pseudoPlayer,
				decodedData.ItemId,
				CFrameSerializer:DecodeCFrame(objectSpace),
				decodedData
			)

			--RoadNetworking
			if (placementObject.MetaData.Type == "Road") then
				self:AddRoadToNetwork(placementObject, true)
			end

			--Create new placementObject and add it to index
			pseudoPlayer:SetPlacementObject(placementObject)
	
			--Load objects in triplets
			objectsLoaded = objectsLoaded + 1;
			if (objectsLoaded % 3 == 0) then
				wait()
			end
		end

		--Tell client that their plot has been loaded
		pseudoPlayer.IsLoaded = true
		PlayerService:FireClientEvent("PlotLoadCompleted", self.Player)
	end)()

	return true
end


--//Recursivly destroy all placed objects
function PlotClass:ClearPlacements(parent)
	parent = (parent or self.Object.Placements)

	for _, container in pairs(parent:GetChildren()) do
		if (container:IsA("Folder")) then
			return self:ClearPlacements(container)
		else
			container:Destroy()
		end
	end
end	


--//Clears all the placements, re-inserts plot object into stack
function PlotClass:Destroy()
	self:ClearPlacements()

	--Push plotObject back into plotStack
	table.insert(plotStack, #plotStack + 1, self.Object)
end


function PlotClass:Start()

	--Push all plot objects into plotStack
	for _, plotObject in pairs(plotContainer:GetChildren()) do
		table.insert(plotStack, #plotStack + 1, plotObject)
	end
end


function PlotClass:Init()
	--//Api
	CFrameSerializer= self.Shared.CFrameSerializer
	PlotSettings = require(ReplicatedStorage.MetaData.Plot)
	TableUtil = self.Shared.TableUtil

	--//Services
	PlayerService = self.Services.PlayerService
	
	--//Controllers
	
	--//Classes
	PlacementClass = self.Modules.Classes.PlacementClass
	
	--//Locals
	plotStack = {}
	plotContainer = workspace.Plots
		
end


return PlotClass