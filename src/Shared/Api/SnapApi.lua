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


--//Returns true if model is colliding with other models
function SnapApi:IsColliding(Plot, vector, rotation, modelSize)
    local rotatedModelSize = AABB.worldBoundingBox(CFrame.Angles(0, rotation, 0), modelSize)
    rotatedModelSize = Vector3.new(math.abs(NumberUtil.Round(rotatedModelSize.X)), math.abs(rotatedModelSize.Y), math.abs(NumberUtil.Round(rotatedModelSize.Z)))

    local region3 = Region3.new((vector - (rotatedModelSize / 2)) + Vector3.new(0.5, 0.5, 0.5), (vector + (rotatedModelSize / 2)) - Vector3.new(0.5, 0.5, 0.5))

    return #Workspace:FindPartsInRegion3WithWhiteList(region3, Plot.Placements:GetChildren(), -1) > 0
end


--//Snaps a vector to the proper plot size
function SnapApi:SnapVector(Plot, plate, model, vector, rotation)
    local PlotCFrame, PlotSize = self:GetPlateData(plate)

    --Sterilize rotation (thanks crut)
    local int, rest = math.modf(rotation / ROTATION_INCREMENT)
    rotation = int * ROTATION_INCREMENT

    if (not RunService:IsServer()) then
        model = model.PrimaryPart.Size
    end

    --Calculate model size
    local modelSize = AABB.worldBoundingBox(CFrame.Angles(0, rotation, 0), model)
    modelSize = Vector3.new(math.abs(NumberUtil.Round(modelSize.X)), math.abs(modelSize.Y), math.abs(NumberUtil.Round(modelSize.Z)))

    --Use AABB to validate that model has no area on other plates
    local sum = 0
    for _, plate in pairs(Plot.Plates:GetChildren()) do
        local cf, size = self:GetPlateData(plate)

        local volume = AABB.overlap(
            CFrame.new(vector) * (cf - cf.Position), Vector3.new(modelSize.X, modelSize.Z, 1),
            cf, Vector3.new(size.X, size.Y, 1)
        )

        sum = sum + volume
    end

    --Boolean to determine if Vector should be clamped
    local area = modelSize.X * modelSize.Z
    local clamp = (sum < area - 0.1)

    --Get size and position relative to plot
    local lpos = PlotCFrame:PointToObjectSpace(vector)
    local size2 = (PlotSize - Vector2.new(modelSize.X, modelSize.Z)) / 2

    --Constrain model within the bounds of the plot
    local x = clamp and math.clamp(lpos.X, -size2.X, size2.X)or lpos.X
    local y = clamp and math.clamp(lpos.Y, -size2.Y, size2.Y) or lpos.Y

    --Snap model to grid
    x = math.sign(x) * ((math.abs(x) - math.abs(x) % GRID_SIZE) + (size2.X % GRID_SIZE))
    y = math.sign(y) * ((math.abs(y) - math.abs(y) % GRID_SIZE) + (size2.Y % GRID_SIZE))

    --Construct CFrame
    local worldSpace = PlotCFrame * CFrame.new(x, y, -modelSize.Y / 2) * CFrame.Angles(-math.pi / 2, rotation, 0)

    --Destroy temp model, return a localSpcae cframe
    if (RunService:IsServer()) then
        return worldSpace, Plot.PrimaryPart.CFrame:ToObjectSpace(worldSpace)
    end

    return worldSpace
end


--//Called on RunTime and when the VisualPart changes
--//Calculates the proper Size and CFrame of the plot
function SnapApi:GetPlateData(plate)
    local plotSize = plate.Size

    local up = Vector3.new(0, 1, 0)
    local back = -Vector3.FromNormalId(Enum.NormalId.Top)

    local dot = back:Dot(Vector3.new(0, 1, 0))
    local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up

    local right = CFrame.fromAxisAngle(axis, math.pi / 2) * back
    local top = back:Cross(right).Unit

    local plateCFrame = plate.CFrame * CFrame.fromMatrix(-back * plotSize / 2, right, top, back)
    local plateSize = Vector2.new((plotSize * right).Magnitude, (plotSize * top).Magnitude)

    return plateCFrame, plateSize
end


function SnapApi:Init()
    --//Api
    NumberUtil = self.Shared.NumberUtil
    AABB = self.Shared.Api.AABB
end


return SnapApi