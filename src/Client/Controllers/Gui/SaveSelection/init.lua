-- Save Selection Gui Handler
-- MrAsync
-- 7/8/20

local SaveSelection = {}

--//Api
local FreeCamApi

--//Services
local Workspace = game:GetService("Workspace")

local PlayerGui

--//Classes
local MaidClass
local GuiClass

--//Controllers

--//Locals
local _Maid
local Camera
local CoreGui

function SaveSelection:Start()
    _Maid = MaidClass.new()
    local MainMenu = GuiClass.new(CoreGui.MainMenu)
    local RobuxShop = GuiClass.new(CoreGui.RobuxShop)
    local SaveLoad = GuiClass.new(CoreGui.SaveLoadDialog)
    local NewSave = GuiClass.new(CoreGui.NewSaveDialog)
    local Confirmation = GuiClass.new(CoreGui.ConfirmationDialog)

    MainMenu:Show()

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Parent = Camera
    blurEffect.Size = 12

    repeat wait() until FreeCamApi.IsLoaded
FreeCamApi:EnterAsMenu()
end


function SaveSelection:Init()
    --//Api
    FreeCamApi = self.Modules.Api.FreeCamApi
    
    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    MaidClass = self.Shared.Maid
    GuiClass = self.Modules.Classes.Gui

    --//Controllers
    
    --//Locals
    Camera = Workspace.CurrentCamera

    CoreGui = PlayerGui:WaitForChild("CoreGui")
    MainMenu = CoreGui.MainMenu
    RobuxShop = CoreGui.RobuxShop
    SaveLoad = CoreGui.SaveLoadDialog
    NewSave = CoreGui.NewSaveDialog
    ConfirmationBox = CoreGui.ConfirmationDialog
    
end


return SaveSelection