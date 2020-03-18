-- Plot Class
-- MrAsync
-- March 16, 2020



local PlotClass = {}
PlotClass.__index = PlotClass


function PlotClass.new()

	local self = setmetatable({

	}, PlotClass)

	return self

end


return PlotClass