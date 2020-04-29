-- Payment Service
-- MrAsync
-- April 23, 2020


--[[

    Handles the deposit of money to each player

    Methods:
        private void PayPlayer(Player player)

]]


local PaymentService = {Client = {}}

--//Api
local GameSettings

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PlayerService

--//Controllers

--//Classes

--//Locals
local timeUntilNextPaycheck
local lastPayment


--TODO
--Verification of loaded data, unloading data etc
local function PayPlayer(player)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)

    --Validate pseudoPlayer and the state of pseudoPlayer
    if (pseudoPlayer and pseudoPlayer.IsLoaded) then
        local paycheck = (pseudoPlayer.Population:Get(0) * GameSettings.AmountPerCitizen)
        
        pseudoPlayer.Cash:Increment(paycheck)
    end

    return
end

function PaymentService:Start()   
    RunService.Stepped:Connect(function()
        timeUntilNextPaycheck.Value = GameSettings.GlobalPaymentInterval - (os.time() - lastPayment)

        if (timeUntilNextPaycheck.Value <= 0) then
            lastPayment = os.time()

            --Asynchronously pay each player
            for _, player in pairs(Players:GetChildren()) do
                coroutine.wrap(PayPlayer)(player)
            end
        end
    end)
end


function PaymentService:Init()
    --//Api
    GameSettings = require(ReplicatedStorage:WaitForChild("MetaData").Settings)

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals
    lastPayment = os.time()
    timeUntilNextPaycheck = ReplicatedStorage:WaitForChild("TimeUntilNextPaycheck")
        
end


return PaymentService