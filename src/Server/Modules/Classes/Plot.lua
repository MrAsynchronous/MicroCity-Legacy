-- Plot
-- MrAsync
-- June 26, 2020



local Plot = {}
Plot.__index = Plot

--//Api
local CompressionApi
local DataStore2

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local PlayerService

--//Classes
local BuildingClass
local StackClass
local MaidClass

--//Controllers

--//Locals
local LandStack


function Plot.new(pseudoPlayer)
    local self = setmetatable({
        Player = pseudoPlayer.Player,
        Object = LandStack:Pop(),

        BuildingList = {},
        BuildingStore = DataStore2("Placements", pseudoPlayer.Player),

        Loaded = false,
        _Maid = MaidClass.new()
    }, Plot)

    --Sterilization
    if (not self.Object) then
        warn(self.Player.Name, "was not given a plot!")

        self.Object = LandStack:Pop()
        if (not self.Object) then
            self.Player:Kick("We're sorry, something went wrong.  Please rejoin!")
        end
    end

    self.BuildingStore:BeforeInitialGet(function(serialized)
        local decompressedData = CompressionApi:decompress(serialized)
        local buildingData = string.split(decompressedData, "|")
        serialized = {}

        --Iterate through all split strings, insert them into table
        for _, JSONData in pairs(buildingData) do
            serialized[HttpService:GenerateGUID(false)] = JSONData
        end

        return serialized
    end)

    self.BuildingStore:BeforeSave(function(deserialized)
        local str = ""

        --Iterate through all placements, combine JSONData
        for guid, jsonArray in pairs(deserialized) do
            if (str == "") then
                str = jsonArray
            else
                str = str .. "|" .. jsonArray
            end
        end

        return CompressionApi:compress(str)
    end)

    --Plate loading
    for _, ownedPlate in pairs(pseudoPlayer.OwnedPlates:Get({1, 2, 3, 4, 5, 6, 7})) do
        local decor = self.Object.Locked.Decor:FindFirstChild(tostring(ownedPlate))
        local plate = self.Object.Locked.Plates:FindFirstChild(tostring(ownedPlate))

        decor.Parent = self.Object.Decor
        plate.Parent = self.Object.Plates

        decor.Transparency = 0
        plate.Grid.Transparency = 1
        plate.GridDash.Transparency = 1
    end

    return self
end


--//Returns data at index guid
function Plot:GetBuildingObjcet(guid)
    return self.BuildingList[guid]
end


--//Adds buildingObject to buildingList and to BuildingStore
function Plot:AddBuildingObject(buildingObject)
    self.BuildingList[buildingObject.Guid] = buildingObject

    self.BuildingStore:Update(function(currentIndex)
        currentIndex[buildingObject.Guid] = buildingObject:Encode()

        return currentIndex
    end)
end


--//Removes traces of buildingObject from buildingList and building store
function Plot:RemoveBuildingObject(buildingObject)
    self.BuildingList[buildingObject.Guid] = nil
    
    self.BuildingStore:Update(function(currentIndex)
        currentIndex[buildingObject.Guid] = nil

        return currentIndex
    end)
end


--//Pseudo-code for AddBuildingObject
function Plot:RefreshBuildingObject(...)
    return self:AddBuildingObject(...)
end


--//Loads data for player
function Plot:LoadBuildings(pseudoPlayer)
    self.Loading = true

    local steppedConnection
    local numericalTable = {}
    local currentIndex = 1

    --Temporarily store all items in a sub-table in numericalTable
    for guid, JSONData in pairs(self.BuildingStore:Get({})) do
        table.insert(numericalTable, {guid, JSONData})
    end

    --Failsafe to prevent error spam if player leaves while loading
    local failSafe = Players.PlayerRemoving:Connect(function(player)
        if (player.Name == pseudoPlayer.Player.Name) then
            if (steppedConnection) then
                steppedConnection:Disconnect()
            end
        end
    end)

    --Load items when stepped
    steppedConnection = RunService.Stepped:Connect(function()
        local buildInfo = numericalTable[currentIndex]

        --Run once all buildings are loaded
        if (not buildInfo) then
            steppedConnection:Disconnect()

            --Tell client that their plot has finished loading
            PlayerService:FireClient("PlotRequest", self.Player, self.Object)

            --Disconnect failsafe
            failSafe:Disconnect()
            self.Loading = false

            return
        end

        local guid = buildInfo[1]
        local jsonData = buildInfo[2]

        --Construct a new BuildingObject
        local buildingObject = BuildingClass.newFromSave(pseudoPlayer, guid, jsonData)
        if (not buildingObject) then return end

        self:AddBuildingObject(buildingObject)

        currentIndex += 1
    end)
end


--//Unloads and cleans up PlotOnject
function Plot:Unload()
    self._Maid:DoCleaning()

    LandStack:Push(self.Object)
end


function Plot:Start()
    LandStack = StackClass.new(Workspace.Land:GetChildren())

    -- Initiate land
    for _, landObject in pairs(Workspace.Land:GetChildren()) do
        for i = 1, #landObject.Plates:GetChildren() - 1 do
            local plate = landObject.Plates:FindFirstChild(tostring(i))
            local decor = landObject.Decor:FindFirstChild(tostring(i))

            plate.Grid.Transparency = 1
            plate.GridDash.Transparency = 1
            decor.Transparency = 1

            local adjacentPlatePosition = landObject.PrimaryPart.CFrame:ToObjectSpace(plate.CFrame)
            local adjacentDecorPosition = landObject.PrimaryPart.CFrame:ToObjectSpace(decor.CFrame)

            local plateCFrame = Instance.new("CFrameValue")
            plateCFrame.Name = "Origin"
            plateCFrame.Value = adjacentPlatePosition
            plateCFrame.Parent = plate

            local decorCFrame = Instance.new("CFrameValue")
            decorCFrame.Name = "Origin"
            decorCFrame.Value = adjacentDecorPosition
            decorCFrame.Parent = decor

            plate.Parent = landObject.Locked.Plates
            decor.Parent = landObject.Locked.Decor
        end
    end
end


function Plot:Init()
    --//Api
    CompressionApi = self.Shared.Api.CompressionApi
    DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    BuildingClass = self.Modules.Classes.Building
    StackClass = self.Shared.Stack
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Plot