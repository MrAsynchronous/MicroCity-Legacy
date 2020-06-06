-- Init Service
-- MrAsync
-- June 2, 2020



local InitService = {Client = {}}

--//Api
local LogApi

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//Classes

--//Controllers

--//Locals

function InitService:Start()
    LogApi:Log("Server | InitService | Start: Initiating cmdr")
    
    local cmdr = require(ServerScriptService:WaitForChild("Cmdr"))
    cmdr:RegisterDefaultCommands()

    LogApi:Log("Server | InitService | Start: Moving Items")

    Workspace.Items.Parent = ReplicatedStorage

    LogApi:Log("Server | InitService | Start: Completed")
end


function InitService:Init()
    --//Api
    LogApi = self.Shared.Api.LogApi

    --//Services

    --//Classes

    --//Controllers

    --//Locals
	
end


return InitService