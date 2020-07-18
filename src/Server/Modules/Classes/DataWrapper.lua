-- Data Wrapper
-- MrAsync
-- July 14, 2020



local DataWrapper = {}
DataWrapper.__index = DataWrapper

--//Api

--//Services
local MetaDataService
local DataService

--//Classes
local PromiseClass
local MaidClass

--//Controllers

--//Locals
local DefaultData


function DataWrapper.new(player, scope)
    local self = setmetatable({
        Player = player,
        Scope = scope,

        _UpdateCallbacks = {},
        _Data = DataService.new(tostring(player.UserId), scope),
        _Maid = MaidClass.new()
    }, DataWrapper)


    return self
end


--Override method for Getting data
function DataWrapper:Get(key)
    return self._Data:Get(key, DefaultData[key])
end


--Override method for Setting data
function DataWrapper:Set(key, value)
    for _, callback in pairs(self._UpdateCallbacks[key] or {}) do
        coroutine.wrap(callback)(value)
    end

    return self._Data:Set(key, value)
end


--Method for updating data using function
function DataWrapper:Update(key, method)
    self:Set(key, method(self:Get(key)))
end


--Adds callback function to array of callbacks, called when set method is used
function DataWrapper:OnUpdate(key, callback)
    local callbackList = {self._UpdateCallbacks[key] or {}}
    table.insert(callbackList, callback)
    
    self._UpdateCallbacks[key] = callbackList
end 


function DataWrapper:Start()
    DefaultData = MetaDataService:GetMetaData("DefaultPlayerData")
end


function DataWrapper:Init()
    --//Api

    --//Services
    MetaDataService = self.Services.MetaDataService
    DataService = self.Modules.Data
    
    --//Classes
    PromiseClass = self.Shared.Promise
    MaidClass = self.Shared.Maid

    --//Controllers

    --//Locals

end


return DataWrapper