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
local Workspace = game:GetService("Workspace")

--//Locals
local GRID_SIZE = 1
local ROTATION_INCREMENT = math.pi / 2


--//Changes a rotation by the constant Rotation Increment
function SnapApi:Rotate(currentRotation)
    currentRotation -= ROTATION_INCREMENT
    
    return currentRotation
end


function SnapApi:CheckForValidity(Plot, worldPosition, dummyPart)
    local modelSize = dummyPart.Size

    -- Create rayCast params object
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.FilterDescendantsInstances = {Plot.Islands}

    -- Localize half sizes
    local halfX, halfY, halfZ = modelSize.X / 2, modelSize.Y / 2, modelSize.Z / 2

    -- Calculate corners
    local corners = {
        topRight = worldPosition * Vector3.new(halfX, halfY, halfZ),
        bottomRight = worldPosition * Vector3.new(halfX, halfY, -halfZ),
        bottomLeft = worldPosition * Vector3.new(-halfX, halfY, halfZ),
        topLeft = worldPosition * Vector3.new(-halfX, halfY, -halfZ)
    }

    -- Raycast
    for _, origin in pairs(corners) do
        local result = Workspace:Raycast(origin, Vector3.new(0, -(halfY * 4), 0), raycastParams)

        if (not result or (result and result.Normal:Dot(Vector3.new(0, 1, 0)) < 0.999)) then
            return false
        end
    end

    return true
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