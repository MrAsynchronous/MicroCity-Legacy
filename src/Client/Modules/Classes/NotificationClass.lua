-- Notification Class
-- Username
-- April 14, 2020



local NotificationClass = {}
NotificationClass.__index = NotificationClass

--//Api

--//Services
local PlayerGui

--//Controllers

--//Classes

--//Locals
local NotificationRegion
local NotificationTemplate

local ACTIVE_TIME = 3
local ACTIVE_POSITION = UDim2.new(0.5, 0, 1, 0)
local INACTIVE_POSITION = UDim2.new(0.5, 0, 0, 0)


--//Constructor for NotificationClass
function NotificationClass.new(notificationInfo)
    local self = setmetatable({
        Text = notificationInfo.Text,
        Color = notificationInfo.Color

    }, NotificationClass)

    --Clone and setup new notification text label
    self.Notification = NotificationTemplate:Clone()
    self.Notification.Text = self.Text
    self.Notification.TextColor3 = self.Color
    self.Notification.Parent = NotificationRegion

    --Call meta-method to show new notification
    self:Show()

    return self
end


--//Shows the notification
function NotificationClass:Show()
    self.Notification.Visible = true
    self.Notification:TweenPosition(ACTIVE_POSITION, "In", "Quint", 0.25, true, function()
        wait(ACTIVE_TIME)

        self:Hide()
    end)
end


--//Hides then removes notification object from existence
function NotificationClass:Hide()
    self.NotificationClass:TweenPosition(INACTIVE_POSITION, "Out", "Quint", 0.25, true, function()
        self.Notification.Visible = false
        self.Notification:Destroy()
        self = nil
    end)
end


function NotificationClass:Start()

end


function NotificationClass:Init()
    --//Api

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers

    --//Classes

    --//Locals
    NotificationRegion = PlayerGui:WaitForChild("NotificationRegion")
    NotificationTemplate = NotificationTemplate.Template

end


return NotificationClass