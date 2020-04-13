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


function NotificationDispatcher:Dispatch(identifier)
    print(NoticeLibrary[identifier].Text)
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
        
end


return NotificationDispatcher