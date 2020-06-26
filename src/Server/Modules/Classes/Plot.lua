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