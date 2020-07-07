local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Roact)
local SaveSelector = Roact.PureComponent:extend("SaveSelector")

function SaveSelector:init()
	
end

function SaveSelector:render(buttonCallback)
	return Roact.createElement("Frame", {
		Name = "SaveSelector",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(92, 94, 94),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.200000003, 0, 0.5, 0),
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 24),
		}),
		Roact.createElement("Frame", {
			Name = "Inlet",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(130, 132, 134),
			BorderSizePixel = 0,
			Position = UDim2.new(0.499080777, 0, 0.115440525, 0),
			Size = UDim2.new(0.939387262, 0, 0.181706294, 0),
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 24),
			}),
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.831009924, 0, 0.820102334, 0),
				Font = Enum.Font.SourceSansBold,
				Text = "Select Save",
				TextColor3 = Color3.fromRGB(252, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = 0,
				TextWrapped = true,
			})
		}),
		Roact.createElement("ScrollingFrame", {
			Name = "Container",
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.600000024, 0),
			Size = UDim2.new(0.939387262, 0, 0.720279694, 0),
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		}, {
			Roact.createElement("Frame", {
				Name = "1",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(130, 132, 134),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0.93900001, 0, 0.0900000036, 0),
			}, {
				Roact.createElement("Frame", {
					Name = "Inlet",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.50000006, 0),
					Size = UDim2.new(0.745575011, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					Roact.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(130, 132, 134),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.831009924, 0, 0.820102334, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "Save 1",
						TextColor3 = Color3.fromRGB(252, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextStrokeTransparency = 0,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				}),
				Roact.createElement("ImageButton", {
					Name = "Button",
					Active = false,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0.5, 0),
					Selectable = false,
					Size = UDim2.new(0.25, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
					Roact.createElement("UIAspectRatioConstraint", {
					}),
					Roact.createElement("TextButton", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "+",
						TextColor3 = Color3.fromRGB(29, 224, 4),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						[Roact.Event.Activated] = buttonCallback()
					})
				})
			}),
			Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.0199999996, 0),
			}),
			Roact.createElement("Frame", {
				Name = "2",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(130, 132, 134),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0.93900001, 0, 0.0900000036, 0),
			}, {
				Roact.createElement("Frame", {
					Name = "Inlet",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.50000006, 0),
					Size = UDim2.new(0.745575011, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					Roact.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(130, 132, 134),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.831009924, 0, 0.820102334, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "Save 2",
						TextColor3 = Color3.fromRGB(252, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextStrokeTransparency = 0,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				}),
				Roact.createElement("ImageButton", {
					Name = "Button",
					Active = false,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0.5, 0),
					Selectable = false,
					Size = UDim2.new(0.25, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
					Roact.createElement("UIAspectRatioConstraint", {
					}),
					Roact.createElement("TextButton", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "+",
						TextColor3 = Color3.fromRGB(29, 224, 4),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						[Roact.Event.Activated] = function()
							print("Clicked!")
						end
					})
				})
			}),
			Roact.createElement("Frame", {
				Name = "3",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(130, 132, 134),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0.93900001, 0, 0.0900000036, 0),
			}, {
				Roact.createElement("Frame", {
					Name = "Inlet",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.50000006, 0),
					Size = UDim2.new(0.745575011, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					Roact.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(130, 132, 134),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.831009924, 0, 0.820102334, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "Save 3",
						TextColor3 = Color3.fromRGB(252, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextStrokeTransparency = 0,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				}),
				Roact.createElement("ImageButton", {
					Name = "Button",
					Active = false,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(188, 189, 195),
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0.5, 0),
					Selectable = false,
					Size = UDim2.new(0.25, 0, 1, 0),
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
					Roact.createElement("UIAspectRatioConstraint", {
					}),
					Roact.createElement("TextButton", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.SourceSansBold,
						Text = "+",
						TextColor3 = Color3.fromRGB(29, 224, 4),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						[Roact.Event.Activated] = function()
							print("Clicked!")
						end
					})
				})
			})
		})
	})
end

return SaveSelector