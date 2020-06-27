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

--//Services
local RunService = game:GetService("RunService")

--//Locals
local GRID_SIZE = 2
local ROTATION_INCREMENT = math.pi / 2


--//Changes a rotation by the constant Rotation Increment
function SnapApi:Rotate(currentRotation)
    currentRotation -= ROTATION_INCREMENT
    
    return currentRotation
end


--//Snaps a vector to the proper plot size
function SnapApi:SnapVector(Plot, model, vector, rotation)
    local PlotCFrame, PlotSize = self:GetPlotData(Plot)

    --Sterilize rotation (thanks crut)
    local int, rest = math.modf(rotation / ROTATION_INCREMENT)
    rotation = int * ROTATION_INCREMENT

    --Calculate model size
    local modelSize = CFrame.fromEulerAnglesYXZ(0, rotation, 0) * model.PrimaryPart.Size
    modelSize = Vector3.new(math.abs(NumberUtil.Round(modelSize.X)), math.abs(NumberUtil.Round(modelSize.Y)), math.abs(NumberUtil.Round(modelSize.Z)))

    --Get size and position relative to plot
    local lpos = PlotCFrame:PointToObjectSpace(vector)
    local size2 = (PlotSize - Vector2.new(modelSize.X, modelSize.Z)) / 2

    --Constrain model within the bounds of the plot
    local x = math.clamp(lpos.X, -size2.X, size2.X)
    local y = math.clamp(lpos.Y, -size2.Y, size2.Y)

    --Snap model to grid
    x = math.sign(x) * ((math.abs(x) - math.abs(x) % GRID_SIZE) + (size2.X % GRID_SIZE))
    y = math.sign(y) * ((math.abs(y) - math.abs(y) % GRID_SIZE) + (size2.Y % GRID_SIZE))

    --Construct CFrame
    local worldSpace = PlotCFrame * CFrame.new(x, y, -modelSize.Y / 2) * CFrame.Angles(-math.pi / 2, rotation, 0)

    --Destroy temp model, return a localSpcae cframe
    if (RunService:IsServer()) then
        model:Destroy()

        return Plot.PrimaryPart.CFrame:ToObjectSpace(worldSpace)
    end

    return worldSpace
end


--//Called on RunTime and when the VisualPart changes
--//Calculates the proper Size and CFrame of the plot
function SnapApi:GetPlotData(plotObject)
    local plotSize = plotObject.PrimaryPart.Size

    local back = Vector3.new(0, -1, 0)
    local top = Vector3.new(0, 0, -1)
    local right = Vector3.new(-1, 0, 0)

    local plotCFrame = plotObject.PrimaryPart.CFrame * CFrame.fromMatrix(-back * plotSize / 2, right, top, back)
    local plotSize = Vector2.new((plotSize * right).magnitude, (plotSize * top).magnitude)

    return plotCFrame, plotSize
end


function SnapApi:Init()
    --//Api
    NumberUtil = self.Shared.NumberUtil
end


return SnapApi