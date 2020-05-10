-- Settings Service
-- MrAsync
-- May 9, 2020

--[[

    Handles the interaction between the client and server when it comes to changing settings

]]


local SettingsService = {Client = {}}

--//Api
local PlayerDataApi

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerService

--//Controllers

--//Classes

--//Locals


--//Client patch for sever side ChangePlayerSetting
function SettingsService.Client:ChangeSetting(...)
    return self.Server:ChangePlayerSetting(...)
end


--//Appends player's settings array to the given values
function SettingsService:ChangePlayerSetting(player, settingName, settingState)
    local pseudoPlayer = PlayerService:GetPseudoPlayer(player)

    --Sanity check inputs
    if (PlayerDataApi.Settings[settingName] == nil) and (settingState == true or settingState == false) then 
        return {
            wasSuccess = false
        }
     end

    --Update playerData
    pseudoPlayer.Settings:Update(function(currentArray)
        currentArray[settingName] = settingState

        return currentArray
    end)

    return {
        wasSuccess = true,
        settingsArray = pseudoPlayer.Settings:Get(PlayerDataApi.Settings)
    }
end


function SettingsService:Init()
    --//Api
    PlayerDataApi = require(ReplicatedStorage.MetaData.Player)

    --//Services
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes

    --//Locals	

end


return SettingsService