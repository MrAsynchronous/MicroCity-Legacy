-- Placement Api
-- MrAsync
-- June 3, 2020


--[[

    Handles the static management of placing an item

]]


local PlacementApi = {}

--//Api
local EventApi

--//Services
local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot


function PlacementApi:StartPlacing(itemId)
    self.PlacementBegan:Fire()
end


function PlacementApi:StopPlacing()
    self.PlacementEnded:Fire()
end


function PlacementApi:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.RequestPlot:Wait())

    --Register events
    self.PlacementBegan = EventApi.new()
    self.PlacementEnded = EventApi.new()
    self.ObjectPlaced = EventApi.new()
    self.ObjectMoved = EventApi.new()

end


function PlacementApi:Init()
    --//Api
    EventApi = self.Shared.Event

    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes

    --//Controllers

    --//Locals

end


return PlacementApi