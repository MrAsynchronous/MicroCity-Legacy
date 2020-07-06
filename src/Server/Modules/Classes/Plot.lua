-- Plot
-- MrAsync
-- June 26, 2020



local Plot = {}
Plot.__index = Plot

--//Api

--//Services
local Workspace = game:GetService("Workspace")

local PlayerService

--//Classes
local StackClass
local MaidClass

--//Controllers

--//Locals
local LandStack


function Plot.new(pseudoPlayer)
    local self = setmetatable({
        Player = pseudoPlayer.Player,

        Object = LandStack:Pop(),
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


--//Loads data for player
function Plot:Load()
    PlayerService:FireClient("PlotRequest", self.Player, self.Object)
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
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    StackClass = self.Shared.Stack
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Plot