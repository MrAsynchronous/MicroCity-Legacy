-- Code Service
-- MrAsync
-- April 27, 2020


--[[

    Has various methods to allow for easy code manipulation

]]


local CodeService = {Client = {}}

--//Api
local GameSettings
local Notices

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PlayerService

--//Controllers

--//Classes

--//Locals
local CodesDataStore
local CodesCache

local timeSinceLastUpdate

--//Retrives the table from the DataStore
local function GetCodes()
    local wasSuccess, retrievedData = pcall(function()
        return CodesDataStore:GetAsync(GameSettings.CodesToken)
    end)

    return wasSuccess, retrievedData
end


--//Attempts to redeem a code!
function CodeService:TryCode(player, input)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)
    if (not pseudoPlayer) then
        return {
            wasSuccess = false
         }
    end

    input = string.upper(input)

    --Validate that the entered code exists
    if (CodesCache[input]) then
        local codesUsed = pseudoPlayer.CodesUsed:Get({})

        --Validate that player has not already used the code
        if (codesUsed[input] == nil) then
            --Inject input into CodesUsed
            coroutine.wrap(function()
                pseudoPlayer.CodesUsed:Update(function(currentValue)
                    currentValue[input] = true
                    return currentValue
                end)
            end)()

            --IMPLEMENT REWARD MECHANICS

            return {
                wasSuccess = true,
                noticeObject = Notices.codeSuccess
            }
        else
            return {
                wasSuccess = false,
                noticeObject = Notices.codeUsed
            }
        end
    else
        return {
            wasSucess = false,
            noticeObject = Notices.codeInvalid
        }
    end
end


--//Calls server-sided TryCode method
function CodeService.Client:RedeemCode(player, input)
    return self.Server:TryCode(player, input)
end


function CodeService:Start()
    CodesDataStore = DataStoreService:GetDataStore(GameSettings.CodesToken)

    --Initially retrieve data
    local success, data = GetCodes()
    if (success) then 
        CodesCache = data 
    end

    --Update CodesCache on a set interval
    RunService.Stepped:Connect(function()
        if (timeSinceLastUpdate - os.time() >= GameSettings.CodeUpdateInterval) then
            timeSinceLastUpdate = os.time()

            --Retrieve and update CodesCache
            local success, data = GetCodes()
            if (success) then
                CodesCache = data
            end     
        end
    end)
end


function CodeService:Init()
    --//Api
    GameSettings = require(ReplicatedStorage:WaitForChild("MetaData").Settings)
    Notices = require(ReplicatedStorage:WaitForChild("MetaData").Notices)
    
    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers
    
    --//Classes
    
    --//Locals
    timeSinceLastUpdate = os.time()
    
end


return CodeService