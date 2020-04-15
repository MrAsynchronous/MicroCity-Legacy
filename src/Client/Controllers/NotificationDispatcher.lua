-- Notification Dispatch
-- MrAsync
-- April 10, 2020



local NotificationDispatcher = {}


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes
local NotificationClass

--//Locals
local activeNotifications


--//Creates a new notification object
function NotificationDispatcher:Dispatch(notificationInfo)
    local notificationObject = NotificationClass.new(notificationInfo)

    --Iterate through and hide all old notifications
    for _, oldNotificationObject in pairs(activeNotifications) do
        oldNotificationObject:Hide()
    end

    --Cache new notification object to be removed later
    table.insert(activeNotifications, notificationObject)
end


function NotificationDispatcher:Init()
    --//Api

    --//Services

    --//Controllers

    --//Classes

    --//Locals
    activeNotifications = {}
end


return NotificationDispatcher