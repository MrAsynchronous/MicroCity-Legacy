-- Save Selector
-- MrAsync
-- July 2, 2020



local SaveSelector = {}

--//Api
local Roact

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local PlayerGui

--//Classes

--//Controllers

--//Locals
local CoreGui
local Element


local function OnSaveSelected(id)
    print("Player selected", id)
end


function SaveSelector:Start()
    local saveSelectorApp = Roact.mount(Element:render(OnSaveSelected), CoreGui)
    Roact.unmount(saveSelectorApp)

end


function SaveSelector:Init()
    --//Api
    Roact = require(ReplicatedStorage.Roact)

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    
    --//Classes
    
    --//Controllers
    
    --//Locals
    CoreGui = PlayerGui:WaitForChild("CoreGui")
    Element = require(script.Element)
    Element:init()

end


return SaveSelector