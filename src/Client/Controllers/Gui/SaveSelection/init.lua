-- Save Selection Gui Handler
-- MrAsync
-- 7/8/20

local SaveSelection = {}

--//Api
local FreeCamApi

--//Services
local Workspace = game:GetService("Workspace")

local PlayerService
local PlayerGui

--//Classes
local ConfirmationDialogClass
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

    -- Update savelist when server sends info
    local saveIndex = PlayerService:RequestSaveIndex()
    for _, saveId in pairs(saveIndex) do
        local ui = SaveLoad.Object.Template:Clone()
        ui.Parent = SaveLoad.Object.SaveContainer
        ui.Visible = true
        ui.Text = saveId
        ui.Name = saveId

        SaveLoad:BindButton(ui, function()
            SaveLoad:Hide()

            local Confirmation = ConfirmationDialogClass.new(string.format('Load "%s"?', saveId),true)
            Confirmation:BindButton(Confirmation.ButtonContainer.Yes, function()
                Confirmation:Destroy()
                local reponse = PlayerService:RequestSave(saveId)
            end)
            Confirmation:BindButton(Confirmation.ButtonContainer.No, function()
                Confirmation:Destroy()
                SaveLoad:Show()
            end)
        end)
    end

    MainMenu:Show()
    MainMenu:BindButton(MainMenu.ButtonContainer.Play, function()
        MainMenu:Hide()
        SaveLoad:Show()
    end)

    MainMenu:BindButton(MainMenu.ButtonContainer.Shop, function()
        MainMenu:Hide()
        RobuxShop:Show()
    end)

    RobuxShop:BindButton(RobuxShop.ButtonContainer.Back, function()
        RobuxShop:Hide()
        MainMenu:Show()
    end)

    SaveLoad:BindButton(SaveLoad.ButtonContainer.Back, function()
        SaveLoad:Hide()
        MainMenu:Show()
    end)

    SaveLoad:BindButton(SaveLoad.ButtonContainer.CreateSave, function()
        SaveLoad:Hide()
        NewSave:Show()
    end)

    NewSave:BindButton(NewSave.ButtonContainer.Back, function()
        NewSave:Hide()
        SaveLoad:Show()
    end)

    NewSave:BindButton(NewSave.ButtonContainer.Create, function()
        NewSave:Hide()

        local Confirmation = ConfirmationDialogClass.new(string.format('Create "%s"?', NewSave.Object.NameInput.Text), true)
        Confirmation:BindButton(Confirmation.ButtonContainer.Yes, function()
            local reponse = PlayerService:RequestSave(NewSave.Object.NameInput.Text)
        end)
        Confirmation:BindButton(Confirmation.ButtonContainer.No, function()
            Confirmation:Destroy()
            NewSave:Show()
        end)
    end)

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Parent = Camera
    blurEffect.Size = 12

    FreeCamApi:EnterAsMenu()
end


function SaveSelection:Init()
    --//Api
    FreeCamApi = self.Modules.Api.FreeCamApi

    --//Services
    PlayerService = self.Services.PlayerService
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Classes
    ConfirmationDialogClass = self.Modules.Classes.ConfirmationDialog
    MaidClass = self.Shared.Maid
    GuiClass = self.Modules.Classes.Gui

    --//Controllers

    --//Locals
    Camera = Workspace.CurrentCamera

    CoreGui = PlayerGui:WaitForChild("CoreGui")

end


return SaveSelection