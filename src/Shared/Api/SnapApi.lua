-- Snap Api
-- MrAsync
-- June 12, 2020


--[[

    Snaps positions to proper plot positions.  Used by the server and the client

    Methods
        Integer Rotate(Interger currentRotation)
        WorldSpace CFrame SnapVector(Instance Plot, Instance model, Vector3 vector, Integer rotation)
        CFrame, Vector2 GetPlotData(Instance plotObject)

]]


local SnapApi = {}


--//Api
local NumberUtil
local AABB

--//Services
local RunService = game:GetService("RunService")

--//Locals
local GRID_SIZE = 1
local ROTATION_INCREMENT = math.pi / 2


--//Changes a rotation by the constant Rotation Increment
function SnapApi:Rotate(currentRotation)
    currentRotation -= ROTATION_INCREMENT
    
    return currentRotation
end


--//Snaps a vector to the proper plot size
function SnapApi:SnapVector(Plot, model, vector, rotation)
    local x, y, z = vector.X, Plot.FocalMin.Position.Y + (model.PrimaryPart.Size.Y / 2), vector.Z

    -- Sterilize rotation
    local int, rest = math.modf(rotation / ROTATION_INCREMENT)
    rotation = int * ROTATION_INCREMENT

    -- Snap x and z to grid
    x = math.floor(x / 1 + 0.5) * 1
    z = math.floor(z / 1 + 0.5) * 1

    -- Clamp to Plot
    local plotCFrame, plotSize = Plot.Islands:GetBoundingBox()
    local plotMin, plotMax = plotCFrame - (plotSize / 2), plotCFrame + (plotSize / 2)
    x = math.clamp(x, plotMin.X, plotMax.X)
    z = math.clamp(z, plotMin.Z, plotMax.Z)

    -- Return CFrame to caller
    return CFrame.new(Vector3.new(x, y, z)) * CFrame.Angles(0, rotation, 0)
end


function SnapApi:Init()
    --//Api
    NumberUtil = self.Shared.NumberUtil
    AABB = self.Shared.Api.AABB
end


return SnapApi