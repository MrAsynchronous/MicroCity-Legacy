-- Placement Api
-- MrAsync
-- March 24, 2020


--[[

    Interface for controlling the players ability to place objects, edit objects

]]



local PlacementApi = {}

--//Api

--//Services
local RunService = game:GetService("RunService")

--//Controllers

--//Classes

--//Locals
local mouse   


--//Starts the placing process
--//Clones the model
--//Binds function to renderStepped
function PlacementApi:StartPlacement()

    RunService:BindToRenderStep("UpdatePlacement", 1, self:UpdatePlacement())
end

--//Stops placing object
function PlacementApi:StopPlacement()

    RunService:UnbindFromRenderStep("UpdatePlacement")
end

--//Bound to RenderStep
--//Checks if player is hovering over a placed object
function PlacementApi:CheckSelection()

end

--//Bound to RenderStep
--//Moves model to position of mouse
function PlacementApi:UpdatePlacement()

end



function PlacementApi:Start()

    RunService:BindToRenderStep("SelectionChecking", 0, self:CheckSelection())
end


function PlacementApi:Init()
    --//Api
    
    --//Services
    
    --//Controllers
    
    --//Classes
    
    --//Locals
    mouse = self.Player

end

return PlacementApi