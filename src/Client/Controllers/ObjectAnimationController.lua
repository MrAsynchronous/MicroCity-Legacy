-- Object Animation Controller
-- MrAsync
-- June 1, 2020



local ObjectAnimationController = {}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PlayerService

--//Classes

--//Controllers

--//Locals
local PlotObject
local Particles


function ObjectAnimationController:Start()
    --Begin listening for changes when PlotLoadCompleted is fired
--    PlayerService.PlotLoadCompleted:Connect(function()

        --Listen to ChildAdded
        PlotObject.Placements.Building.ChildAdded:Connect(function(newObject)
            while (newObject.PrimaryPart == nil) do wait() end

            local objectCFrame = newObject.PrimaryPart.CFrame
            local objectSize = newObject.PrimaryPart.Size

            --Hide object under map
            newObject:SetPrimaryPartCFrame(objectCFrame - Vector3.new(0, objectSize.Y, 0))

            --Clone particle
            local newParticle = Particles.PlacementEffect:Clone()
            newParticle.Parent = newObject.PrimaryPart
            newParticle.Enabled = true

            --Construct and play tween
            local effectTween = TweenService:Create(newObject.PrimaryPart, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = objectCFrame})
            effectTween.Completed:Connect(function(playbackState)
                if (playbackState == Enum.PlaybackState.Completed) then
                    effectTween:Destroy()
                    newParticle:Destroy()
                end
            end)

            effectTween:Play()
        end)
--    end)
end


function ObjectAnimationController:Init()
    --//Api

    --//Services
    PlayerService = self.Services.PlayerService

    --//Classes

    --//Controllers

    --//Locals
    PlotObject = self.Player:WaitForChild("PlotObject").Value
    Particles = ReplicatedStorage.Items.Particles

end


return ObjectAnimationController