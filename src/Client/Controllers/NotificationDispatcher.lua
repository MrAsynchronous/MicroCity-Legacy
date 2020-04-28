-- Notification Dispatch
-- MrAsync
-- April 10, 2020


--[[

    Methods:
        public void Dispatch(Table notificationTable)
        public void ClearNotifications()

]]


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
    if (not notificationInfo) then return end
    local notificationObject = NotificationClass.new(notificationInfo)

    --Iterate through and hide all old notifications
    for _, oldNotificationObject in pairs(activeNotifications) do
        oldNotificationObject:Push()
    end

    --Cache new notification object to be removed later
    table.insert(activeNotifications, notificationObject)
end


--//Clears all active notifications
function NotificationDispatcher:ClearNotifications()
    for _, oldNotificationObject in pairs(activeNotifications) do
        oldNotificationObject:Hide()
    end
end


--//Removes the objectToRemove from activeNotifications
function NotificationDispatcher:RemoveNotification(objectToRemove)
    for index, notificationObject in pairs(activeNotifications) do
        if (notificationObject == objectToRemove) then
            table.remove(activeNotifications, index)
        end
    end
end

function NotificationDispatcher:Init()
    --//Api

    --//Services

    --//Controllers

    --//Classes
    NotificationClass = self.Modules.Classes.NotificationClass

    --//Locals
    activeNotifications = {}
end


return NotificationDispatcher