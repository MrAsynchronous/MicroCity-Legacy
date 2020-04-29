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

		Level = pseudoPlayer.PlotLevel:Get(1)
	}, PlotClass)

	--Assign physical plot
	self.Object = table.remove(plotStack, #plotStack)

	--Change plot size to loaded level
	self:ChangeSize(PlotSettings.Upgrades[self.Level].Size)

	return self
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

    --Load plot size
    local plotSizeData = PlotSettings.Upgrades[pseudoPlayer.PlotLevel:Get(1)]
    self.Object.VisualPart.Size = Vector3.new(
        plotSizeData.Size.X,
        self.Object.VisualPart.Size.Y,
        plotSizeData.Size.Z
    )

	--Iterate through all the placements asynchronously
	coroutine.wrap(function()
		for objectSpace, encodedData in pairs(placementData) do
			local decodedData = TableUtil.DecodeJSON(encodedData)

			--Create new placementObject and add it to index
			pseudoPlayer:SetPlacementObject(PlacementClass.new(
				pseudoPlayer,
				decodedData.ItemId,
				CFrameSerializer:DecodeCFrame(objectSpace),
				decodedData
			))
	
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