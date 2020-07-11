local cam = workspace.Camera
local frame = game.StarterGui.Gui.ViewportFrame
local car = frame.Car

local cf, size = car:GetBoundingBox()

frame.Part.Size = size * 1.001
frame.Part.CFrame = cf

local rot = CFrame.Angles(math.rad(0), math.rad(90), 0)

size = rot:VectorToObjectSpace(size)
local sizeX, sizeY, sizeZ = math.abs(size.X), math.abs(size.Y), math.abs(size.Z)

local frameSize = 500

local h = (sizeY / (math.tan(math.rad(cam.FieldOfView / 2)) * 2)) + (sizeZ / 2)

local frameX = (sizeX > sizeY and frameSize or (frameSize * (sizeX / sizeY)))
local frameY = (sizeY > sizeX and frameSize or (frameSize * (sizeY / sizeX)))

frame.Size = UDim2.new(0, frameX, 0, frameY)

cam.CFrame = cf * rot * CFrame.new(0, 0, h)