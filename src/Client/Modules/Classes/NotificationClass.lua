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

local SHOWING_TIME = 4
local ACTIVE_POSITION = UDim2.new(0, 0, 1, 0)
local PRE_ACTIVE_POSITION = UDim2.new(1, 0, 1, 0)


--//Constructor for NotificationClass
function NotificationClass.new(notificationInfo)
    local self = setmetatable({
        Text = notificationInfo.Text,
        Color = notificationInfo.Color,
        Position = ACTIVE_POSITION

    }, NotificationClass)

    --Clone and setup new notification text label
    self.Notification = NotificationTemplate:Clone()
    self.Notification.Text = self.Text
    self.Notification.TextColor3 = self.Color
    self.Notification.Position = PRE_ACTIVE_POSITION
    self.Notification.Parent = NotificationRegion.Container

    --Call meta-method to show new notification
    self:Show()

    return self
end


--//Shows the notification
function NotificationClass:Show()
    self.removalTime = os.time() + SHOWING_TIME

    --Make notification visible, tween, on callback, wait until time to delete, make call
    self.Notification.Visible = true
    self.Notification:TweenPosition(ACTIVE_POSITION, "Out", "Quint", 0.25, true, function()
        while (os.time() < self.removalTime) do wait() end

        if (self and self.Notification and self.Notification.Parent) then
            self:Hide()
        end
    end)
end


--//Physically pushes notification object vertically
function NotificationClass:Push()
    self.Position = self.Position - UDim2.new(0, 0, self.Notification.Size.Y.Scale, 0)

    if (self and self.Notification and self.Notification.Parent) then
        --Tween notification up, if notification is above the bounds, hide
        self.Notification:TweenPosition(self.Position, "InOut", "Quint", 0.25, true, function()
            if (self.Position.X.Scale < 0) then
                self:Hide()
            end
        end)
    end
end


--//Hides then removes notification object from existence
function NotificationClass:Hide()

    --Tween notification out, on callback, destroy 
    self.Notification:TweenPosition(self.Position + UDim2.new(1, 0, 0, 0), "In", "Quint", 0.25, true, function()
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
    NotificationTemplate = NotificationRegion.Template

end


return NotificationClass