-- Init Service
-- MrAsync
-- March 23, 2020


--[[

    Handles tasks at RunTime such as Parenting and Cloning the Items repository

]]


local InitService = {Client = {}}
InitService.__aeroOrder = 1

--//Api

--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local PlayerService

--//Controllers
local Cmdr

--//Classes

--//Locals
local itemsRepository
local cmdrCommand

function InitService:Start()
    print("Game initializing: ")
    local startTime = os.time()

    --Re-parent Items
    itemsRepository.Parent = ReplicatedStorage

    --Init cmdr
    Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(ServerScriptService.CustomCommands)

    cmdrCommand.Event:Connect(function(player, amount, costType)
        local pseudoPlayer = PlayerService:GetPseudoPlayer(player)

        if (pseudoPlayer and pseudoPlayer[costType]) then
            pseudoPlayer[costType]:Update(function(currentValue)
                return currentValue + amount
            end)
        end
    end)

    print("Game initialized! Took: " .. (os.time() - startTime) .. " seconds.")
end


function InitService:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers
    Cmdr = require(ServerScriptService:WaitForChild("Cmdr"))

    --//Classes

    --//Locals
    itemsRepository = workspace:WaitForChild("Items")
    cmdrCommand = ServerScriptService:WaitForChild("cmdrCommand")

end


return InitService