-- Platform
-- MrAsync
-- March 29, 2020


--[[

    Easily get the Platform of the player.
    Ripped from developer.roblox.com

]]


local Platform = {}


local UserInputService = game:GetService("UserInputService")


function Platform:GetInputType()
    local lastInputEnum = UserInputService:GetLastInputType()
    local inputTypeString = "PC"

	if lastInputEnum == Enum.UserInputType.Keyboard or string.find(tostring(lastInputEnum.Name), "MouseButton") or lastInputEnum == Enum.UserInputType.MouseWheel then
		inputTypeString = "PC"
	elseif lastInputEnum == Enum.UserInputType.Touch then
		inputTypeString = "Mobile"
	elseif string.find(tostring(lastInputEnum.Name), "Gamepad") then
		inputTypeString = "Console"
    end
    
	return inputTypeString, lastInputEnum
end


return Platform