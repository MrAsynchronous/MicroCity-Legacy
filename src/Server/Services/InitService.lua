-- Init Service
-- MrAsync
-- March 23, 2020


--[[

    Handles tasks at RunTime such as Parenting and Cloning the Items repository

]]


local InitService = {Client = {}}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Controllers

--//Classes

--//Locals
local itemsRepository


function InitService:Start()
    print("Game initializing: ")
    local startTime = os.time()

    print("Game initialized! Took: " .. (os.time() - startTime) .. " seconds.")
end


function InitService:Init()
    --//Api

    --//Services

    --//Controllers

    --//Classes

    --//Locals
    itemsRepository = workspace:WaitForChild("Items")
    itemsRepository.Parent = ReplicatedStorage

end


return InitService