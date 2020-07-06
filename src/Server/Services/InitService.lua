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


local function WeldParts(parent, primaryPart)
    for _, part in pairs(parent:GetChildren()) do
        if (part:IsA("Model") or part:IsA("Folder")) then
            WeldParts(part, primaryPart)
        else
            if (part.Name == "PrimaryPart") then continue end

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = primaryPart
            weld.Part1 = part
            weld.Parent = part
    
            part.Anchored = false
        end
    end
end


function InitService:Start()
    for _, model in pairs(Workspace.Items:GetChildren()) do
        if (not model:IsA("Model")) then continue end

        model.PrimaryPart.CanCollide = false
        model.PrimaryPart.Transparency = 1
        
        WeldParts(model, model.PrimaryPart)
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