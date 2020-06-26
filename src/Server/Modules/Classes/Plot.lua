-- Plot
-- MrAsync
-- June 26, 2020



local Plot = {}
Plot.__index = Plot

--//Api

--//Services
local Workspace = game:GetService("Workspace")

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


    return self
end


function Plot:LoadData()

end


function Plot:Start()
    LandStack = StackClass.new(Workspace.Land:GetChildren())
end


function Plot:Init()
    --//Api
    
    --//Services
    
    --//Classes
    StackClass = self.Shared.Stack
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Plot