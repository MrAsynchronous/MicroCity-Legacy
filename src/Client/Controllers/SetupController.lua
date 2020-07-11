-- Setup Controller
-- MrAsync
-- 7/11/2020

local SetupController = {}

--//Api
local FreeCamApi

--//Services
local Workspace = game:GetService("Workspace")

local PlayerService
local PlayerGui

--//Classes
local ConfirmationDialogClass
local GuiClass

--//Controllers

--//Locals
local CoreGui
local Camera
local Plot


function SetupController:Start()
	FreeCamApi:EnterAsMenu()

	local blurEffect = Instance.new("BlurEffect")
    blurEffect.Parent = Camera
    blurEffect.Size = 12

    --Setup GUI's
    local MainMenu = GuiClass.new(CoreGui.MainMenu)
    local SaveLoad = GuiClass.new(CoreGui.SaveLoadDialog)
    local ShopMenu = GuiClass.new(CoreGui.ShopMenu)
    local NewSave = GuiClass.new(CoreGui.NewSaveDialog)

    --Main Menu
    MainMenu:BindButton(MainMenu.ButtonContainer.Play, function()
    	MainMenu:Hide()
    	SaveLoad:Show()
    end)

    MainMenu:BindButton(MainMenu.ButtonContainer.Shop, function()
    	MainMenu:Hide()
    	ShopMenu:Show()
    end)

    --Shop Menu
    ShopMenu:BindButton(ShopMenu.ButtonContainer.Back, function()
    	ShopMenu:Hide()
    	MainMenu:Show()
    end)

    --SaveLoad Dialog
    SaveLoad:BindButton(SaveLoad.ButtonContainer.Back, function()
    	SaveLoad:Hide()
    	MainMenu:Show()
    end)

    SaveLoad:BindButton(SaveLoad.ButtonContainer.CreateSave, function()
    	SaveLoad:Hide()
    	NewSave:Show()
    end)

    --NewSave Dialog
    NewSave:BindButton(NewSave.ButtonContainer.Back, function()
    	NewSave:Hide()
    	SaveLoad:Show()
    end)

    NewSave:BindButton(NewSave.ButtonContainer.Create, function()
    	NewSave:Hide()

    	--Create new confirmationDialog for creating slot
    	local saveId = NewSave.Object.NameInput.Text
    	local confirmationDialog = ConfirmationDialogClass.new(string.format('Create "%s"?', saveId))
    	confirmationDialog:AddAcceptCallback(function()
    		local response = PlayerService:RequestSave(saveId)
    	end)
    	confirmationDialog:AddDenyCallback(function()
    		confirmationDialog:Destroy()
    		NewSave:Show()
    	end)
    end)


    --Populate SaveLoad with saves
    local saveIndex = PlayerService:RequestSaveIndex()
    for _, saveId in pairs(saveIndex) do
    	local saveButton = SaveLoad.Object.Template:Clone()
    	saveButton.Text = saveId
    	saveButton.Name = saveId

    	saveButton.Visible = true
    	saveButton.Parent = SaveLoad.Object.SaveContainer

    	SaveLoad:BindButton(saveButton, function()
    		SaveLoad:Hide()

    		--Create confirmationDialog for loading slot
    		local confirmationDialog = ConfirmationDialogClass.new(string.format('Load "%s"?', saveId))
    		confirmationDialog:AddAcceptCallback(function()
    			local response = PlayerService:RequestSave(saveId)
    		end)
    		confirmationDialog:AddDenyCallback(function()
    			confirmationDialog:Destroy()
    			SaveLoad:Show()
    		end)
    	end)
    end

    MainMenu:Show()
end


function SetupController:Init()
	--//Api
	FreeCamApi = self.Modules.Api.FreeCamApi

	--//Services
	PlayerService = self.Services.PlayerService
	PlayerGui = self.Player:WaitForChild("PlayerGui")

	--//Classes
	ConfirmationDialogClass = self.Modules.Classes.ConfirmationDialog
	GuiClass = self.Modules.Classes.Gui

	--//Controllers

	--//Locals
	CoreGui = PlayerGui:WaitForChild("CoreGui")
	Camera = Workspace.CurrentCamera

end


return SetupController