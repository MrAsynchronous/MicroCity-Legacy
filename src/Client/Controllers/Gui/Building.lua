-- Building
-- MrAsync
-- June 28, 2020



local Building = {}

--//Api
local PlacementApi
local BuildModeApi

--//Services
local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local BuildingGui


function Building:Start()
    if (not BuildModeApi.IsLoaded) then BuildModeApi.Loaded:Wait() end

    BuildingGui.Button.MouseButton1Click:Connect(function()
        local character = self.Player.Character or self.Player.CharacterAdded:Wait()
        
        local id = tonumber(BuildingGui.Id.Text)
        if (not id) then return end

        PlacementApi:StartPlacing(id)
    end)
end


function Building:Init()
    --//Api
    PlacementApi = self.Modules.Api.PlacementApi
    
    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    
    --//Controllers
    BuildModeApi = self.Modules.Api.BuildModeApi
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    BuildingGui = CoreGui:WaitForChild("Building")

end


return Building