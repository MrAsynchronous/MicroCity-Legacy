-- Building Effect Controller
-- MrAsync
-- June 5, 2020


--[[

    Listens for changes when buildings are added to give them a better tweening effect

]]


local BuildingEffectController = {}


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerService

--//Classes

--//Controllers

--//Locals
local Plot
local Particles

local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)


function BuildingEffectController:Start()
    Plot = (PlayerService:RequestPlot() or PlayerService.PlotRequest:Wait())
    
    --Listen to Children being Added
    Plot.Placements.ChildAdded:Connect(function(newBuilding)
        while (newBuilding.PrimaryPart == nil) do wait() end

        --Localize
        local normalCFrame = newBuilding.PrimaryPart.CFrame
        local hiddenCFrame = normalCFrame - Vector3.new(0, newBuilding.PrimaryPart.Size.Y, 0)

        --Move the building and clone the particle
        newBuilding:SetPrimaryPartCFrame(hiddenCFrame)
        local newParticle = Particles.PlacementEffect:Clone()
        newParticle.Parent = newBuilding.PrimaryPart
        newParticle.Enabled = true

        --Create and play the tween, cleaning up when finished
        local effectTween = TweenService:Create(newBuilding.PrimaryPart, tweenInfo, {CFrame = normalCFrame})
        effectTween.Completed:Connect(function(playbackState)
            if (playbackState == Enum.PlaybackState.Completed) then
                effectTween:Destroy()
                newParticle:Destroy()
            end
        end)

        effectTween:Play()
    end)
end


function BuildingEffectController:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes

    --//Controllers

    --//Locals
    Particles = ReplicatedStorage.Particles

end


return BuildingEffectController