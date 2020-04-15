-- Shopping Service
-- MrAsync
-- April 1, 2020


--[[

    Handles requests for item purchases
    Does not handle monetized purchases

]]


local ShoppingService = {Client = {}}

--//Api

--//Services
local MetaDataService
local PlayerService

--//Controllers

--//Classes

--//Locals


--//Returns true if player can afford a cost
--//Subtracts cost from player's cash balance
function ShoppingService:CanAffordCost(pseudoPlayer, cost)
    local cashValue = pseudoPlayer:GetData("Cash")

    --If player can afford cost, subtract and return true
    if (cashValue >= cost) then
        pseudoPlayer:SetData("Cash", pseudoPlayer:GetData("Cash") - cost)

        return true
    else
        return false
    end
end


function ShoppingService:PurchaseItem(pseudoPlayer, itemId, itemMetaData)
    local itemMetaData = MetaDataService:GetMetaData(itemId)

--    if (playerObject:GetData("Cash") >= itemMetaData.Cost) then
        pseudoPlayer:SetData("Cash", pseudoPlayer:GetData("Cash") - itemMetaData.Cost)

        return true
--    else
--        print("Not enough funds!")

--        return false
--   end
end


function ShoppingService:SellItem(pseudoPlayer, profit)
    pseudoPlayer:SetData("Cash", pseudoPlayer:GetData("Cash") + profit)

    return true
end


function ShoppingService:Start()
	
end


function ShoppingService:Init()
    --//Api

    --//Services
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals
        
end


return ShoppingService