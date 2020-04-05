-- Vehicle Class
-- MrAsync
-- April 3, 2020



local VehicleClass = {}
VehicleClass.__index = VehicleClass


--//Api

--//Services

--//Controllers

--//Classes

--//Locals


function VehicleClass.new(start, vehicleIndex, plotObject)
    local self = setmetatable({
        StartingPoint = start,
        CurrentPoint = start
    }, VehicleClass)


    local Random = Random.new(os.time())
    self.Vehicle = vehicleIndex[math.random(#vehicleIndex)]:Clone()
    self.Vehicle.Parent = plotObject.Vehicles
    self.Vehicle:SetPrimaryPartCFrame(start.PrimaryPart.CFrame)

    return self
end


function VehicleClass:Start()

end


function VehicleClass:Init()
    --//Api

    --//Services

    --//Controllers

    --//Classes

    --//Locals

end


return VehicleClass