-- Init Service
-- MrAsync
-- June 26, 2020



local InitService = {Client = {}}
InitService.__aeroOrder = 1

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--//Classes

--//Controllers

--//Locals



function InitService:Start()
    for _, model in pairs(Workspace.Items:GetChildren()) do
        local orientation, size = model:GetBoundingBox()
        local decor = Instance.new("Folder")
        decor.Name = "Decor"
        decor.Parent = model

        local primaryPart = Instance.new("Part")
        primaryPart.Parent = model
        primaryPart.Size = size + Vector3.new(0.01, 0.01, 0.01)
        primaryPart.CFrame = orientation
        primaryPart.Transparency = 1
        primaryPart.Anchored = true
        primaryPart.CanCollide = false
        primaryPart.Name = "PrimaryPart"

        for _, part in pairs(model:GetChildren()) do
            if (part:IsA("Folder") or part.Name == "PrimaryPart") then continue end
            part.Parent = decor

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = primaryPart
            weld.Part1 = part
            weld.Parent = part

            part.CanCollide = false
            part.Anchored = false
        end

        model.PrimaryPart = primaryPart
    end

    Workspace.Items.Parent = ReplicatedStorage
    Workspace.Particles.Parent = ReplicatedStorage
end


function InitService:Init()
	
end


return InitService