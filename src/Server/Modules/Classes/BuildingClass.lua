-- Building Class
-- MrAsync
-- March 16, 2020



local BuildingClass = {}
BuildingClass.__index = BuildingClass


function BuildingClass.new()

	local self = setmetatable({

	}, BuildingClass)

	return self

end


return BuildingClass