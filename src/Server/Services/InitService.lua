-- Init Service
-- MrAsync
-- June 26, 2020



local InitService = {Client = {}}
InitService.__aeroOrder = 1

--//Api
local NumberUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//Classes

--//Controllers

--//Locals

function InitService:Start()
    for _, model in pairs(Workspace.Items:GetChildren()) do
        if (not model:IsA("Model")) then continue end

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = model.PrimaryPart
        weld.Part1 = model.Plate
        weld.Parent = model.Plate

        model.Plate.CanCollide = false
        model.Plate.Anchored = false       

        for _, part in pairs(model.Decor:GetChildren()) do
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = model.PrimaryPart
            weld.Part1 = part
            weld.Parent = part

            part.CanCollide = false
            part.Anchored = false
        end
    end

    Workspace.Items.Parent = ReplicatedStorage
    Workspace.Particles.Parent = ReplicatedStorage
end


function InitService:Init()
	--//Api
    NumberUtil = self.Shared.NumberUtil

    --//Services
    
    --//Classes
    
    --//Controllers
    
    --//Locals

end


return InitService