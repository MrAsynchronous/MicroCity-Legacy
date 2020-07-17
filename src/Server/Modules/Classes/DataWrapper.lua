-- Data Wrapper
-- MrAsync
-- July 14, 2020



local DataWrapper = {}
DataWrapper.__index = DataWrapper


--//Api

--//Services
local DataService

--//Classes
local PromiseClass
local MaidClass

--//Controllers

--//Locals


function DataWrapper.new(player, scope)
    local self = setmetatable({
        Player = player,
        Scope  scope,

        _Maid = MaidClass.new()
    }, DataWrapper)


    return self
end


function DataWrapper:Init()
    --//Api

    --//Services
    
    --//Classes
    PromiseClass = self.Shared.Promise
    MaidClass = self.Shared.Maid

    --//Controllers

    --//Locals

end


return DataWrapper