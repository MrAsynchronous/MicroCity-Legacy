-- Clock
-- MrAsync
-- July 2, 2020



local Clock = {}

--//Api
local Roact

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui

function Clock:Start()
    local clockApp = Roact.mount(self:Render(0, 0), CoreGui)

    RunService.RenderStepped:Connect(function()
        local hour, minutes = math.modf(Lighting.ClockTime)
        hour = Lighting.ClockTime
        minutes = (minutes * 60)

        --Hour modifiers
        hour = (hour == 0 and 12 or hour)
        hour = (hour > 12 and hour - 12 or hour)
        
        Roact.update(clockApp, self:Render(
            (hour / 12) * 360,
            (minutes / 60) * 360
        ))
    end)
end


function Clock:Render(hourRot, minuteRot)
	return Roact.createElement("Frame", {
		Name = "Clock",
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Color3.fromRGB(92, 94, 94),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -5, 1, -5),
		Size = UDim2.new(0.0753067806, 0, 0.168650225, 0),
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Roact.createElement("Frame", {
            Name = "Hour",
            Rotation = hourRot,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.899999976, 0, 0.899999976, 0),
			ZIndex = 2,
		}, {
			Roact.createElement("ImageLabel", {
				Name = "Arrow",
                AnchorPoint = Vector2.new(0.5, 1), 
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Selectable = true,
				Size = UDim2.new(0.0329999998, 0, 0.338888884, 0),
				Image = "rbxassetid://5274132094",
				ScaleType = Enum.ScaleType.Fit,
			})
		}),
		Roact.createElement("Frame", {
            Name = "Minute",
            Rotation = minuteRot,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.899999976, 0, 0.899999976, 0),
			ZIndex = 2,
		}, {
			Roact.createElement("ImageLabel", {
				Name = "Arrow",
                AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.0329999998, 0, 0.449999988, 0),
				Image = "rbxassetid://5274132094",
			})
		}),
		Roact.createElement("UIAspectRatioConstraint", {
		})
	})    
end

function Clock:Init()
    --//Api
    Roact = require(ReplicatedStorage.Roact)

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui") 

end


return Clock