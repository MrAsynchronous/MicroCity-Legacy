-- Plate Purchase Mode Api
-- MrAsync
-- July 6, 2020



local PlatePurchaseModeApi = {}

--//Api

--//Services
local Workspace = game:GetService("Workspace")

local PlayerService

--//Classes
local EventClass

--//Controllers

--//Locals
local Camera


function PlatePurchaseModeApi:EnterPurchaseMode()

end


function PlatePurchaseModeApi:ExitPurchaseMode()

end


function PlatePurchaseModeApi:Init()
    --//Api
    
    --//Services
    PlayerService = self.Services.PlayerService
    
    --//Classes
    EventClass = self.Shared.Event
    
    --//Controllers
    
    --//Locals
    Camera = Workspace.CurrentCamera
    
end


return PlatePurchaseModeApi