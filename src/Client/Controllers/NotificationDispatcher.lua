-- Notification Dispatch
-- MrAsync
-- April 10, 2020



local NotificationDispatcher = {}


--//Api
local NoticeLibrary

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes

--//Locals
local PlayerGui
local NotificationRegion
local NotificationTemplate

local isActive
local activeNotifications

local ACTIVE_POSITION = UDim2.new(0.5, 0, 1, 0)
local INACTIVE_POSITION = UDim2.new(0.5, 0, 0, 0)

function NotificationDispatcher:Dispatch(identifier)
end


function NotificationDispatcher:Start()
	
end


function NotificationDispatcher:Init()
    --//Api
    NoticeLibrary = require(ReplicatedStorage.MetaData.Notices)

    --//Services

    --//Controllers

    --//Classes

    --//Locals
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    NotificationRegion = PlayerGui:WaitForChild("NotificationRegion")
    NotificationTemplate = NotificationRegion.Template
        
    isActive = false
    activeNotifications = {}
end


return NotificationDispatcher