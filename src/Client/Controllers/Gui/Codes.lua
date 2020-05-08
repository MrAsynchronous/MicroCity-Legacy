-- Codes
-- Username
-- May 7, 2020



local Codes = {}

--//Api

--//Services
local PlayerGui

--//Controllers

--//Classes

--//Locals
local CodesGui


function Codes:Start()
    CodesGui.Enabled = false
end


function Codes:Init()
    --//Api

    --//Services
     PlayerGui = self.Player.PlayerGui

    --//Controllers

    --//Classes

    --//Locals
    CodesGui = PlayerGui.Codes

end


return Codes