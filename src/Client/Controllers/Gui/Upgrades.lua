-- Upgrades
-- MrAsync
-- May 15, 2020



local Upgrades = {}

--//Api
local TableUtil

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui

local PlacementService
local MetaDataService
local PlayerService

--//Controllers
local NotificationDispatch

--//Classes
local GuiClass

--//Locals
local ReplicatedData
local UnlockedItems
local UpgradesGui
local PlotObject
local GuiObject
local Particles

local ViewportFrame
local Camera

local selectedGuid
local itemMetaData
local upgradeModels
local selectedModel
local objectSpinConnection

local CAN_AFFORD_BUTTON = "rbxassetid://5124300858"
local CANNOT_AFFORD_BUTTON = "rbxassetid://5124300940"
local OWNED_BUTTON = "rbxassetid://4981264069"


--//Returns index of item if found
local function HasItem(itemId, level)
    return table.find(UnlockedItems, itemId .. ":" .. level)
end


--//Changes the viewports color to the given color
local function ChangeViewportColors(color)
    ViewportFrame.Ambient = color
    ViewportFrame.LightColor = color
end


--//Changes the viewports view to black
local function Blackout()
    return ChangeViewportColors(Color3.fromRGB(0, 0, 0))
end


--//Changes the viewports view to white
local function Whiteout()
    return ChangeViewportColors(Color3.fromRGB(255, 255, 255))
end


--//Used for moving camera to and from models
local function TweenCamera(toCFrame)
    local cameraTween = TweenService:Create(Camera, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = toCFrame})
    cameraTween.Completed:Connect(function(playbackState)
        if (playbackState == Enum.PlaybackState.Completed) then
            cameraTween:Destroy()
        end
    end)

    return cameraTween:Play()
end


--//Calculate and return position for model to center it perfectly in the viewport frame
local function AttachCameraToModel(model)
    local cf, size = model:GetBoundingBox()
    local rot = CFrame.Angles(math.rad(22.5), math.rad(180), 0)

    --Create sizes based on radians and stuff
    size = rot:VectorToObjectSpace(size)
    local sizeY, sizeZ = math.abs(size.Y), math.abs(size.Z)

    --Calulate proper distance from model to camera
    local h = (sizeY / (math.tan(math.rad(Camera.FieldOfView / 2)) * 2)) + (sizeZ / 2)

    --Reset other models for smooth transitions
    for index, otherModel in ipairs(upgradeModels) do
        if (otherModel == model) then continue end

        local partSize = otherModel.PrimaryPart.Size
         --Socially distance models #covid-19
         otherModel:SetPrimaryPartCFrame(CFrame.new(
            Vector3.new((partSize.X * 3) * (index - 1), 0, -partSize.Z),
            Vector3.new((partSize.X * 3) * (index - 1), 0, (partSize.Z * 2))
        ))
    end

    return cf * rot * CFrame.new(0, 0, h + 1)
end


--//Clones all upgradable models
local function SetupViewport(itemId, level)
    itemMetaData = MetaDataService:GetMetaData(itemId)
    selectedModel = level

    Whiteout()
    UpgradesGui.Container.Purchase.Button.Image = OWNED_BUTTON

    --Clone all models
    for index, data in ipairs(itemMetaData.Upgrades) do
        local modelClone = ReplicatedStorage.Items.Buildings:FindFirstChild(itemId .. ":" .. index):Clone()
        modelClone.Parent = ViewportFrame

        local partSize = modelClone.PrimaryPart.Size

        --Socially distance models #covid-19
        modelClone:SetPrimaryPartCFrame(CFrame.new(
            Vector3.new((partSize.X * 3) * (index - 1), 0, -partSize.Z),
            Vector3.new((partSize.X * 3) * (index - 1), 0, (partSize.Z * 2))
        ))

        table.insert(upgradeModels, modelClone)

        if (index == level) then
            Camera.CFrame = AttachCameraToModel(modelClone)
        end
    end

    --Render selected model
    objectSpinConnection = RunService.RenderStepped:Connect(function()
        for index, model in ipairs(upgradeModels) do
            if (index ~= selectedModel) then continue end

            model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(1), 0))
        end
    end)
end


--//Removes all models from viewport
--//Disconnect RunService connection
local function CleanupViewport()
    if (objectSpinConnection) then
        objectSpinConnection:Disconnect()
    end

    --Destroy all models
    for i, model in ipairs(upgradeModels) do
        model:Destroy()
    end

    --Reset variables
    upgradeModels = {}
    selectedGuid = nil
    itemMetaData = nil
    selectedModel = nil
end


--//Public facing Show
function Upgrades:Show(guid)
    selectedGuid = guid

    local itemId = PlayerService:GetItemIdFromGuid(guid)
    local level = PlayerService:GetLevelFromGuid(guid)
    SetupViewport(itemId, level)

    return GuiObject:Show()
end


function Upgrades:Start()
    UpgradesGui = PlayerGui:WaitForChild("Upgrades")
    GuiObject = GuiClass.new(UpgradesGui)

    ViewportFrame = UpgradesGui.Container.ViewportFrame
    Camera = Instance.new("Camera")
    ViewportFrame.CurrentCamera = Camera
    Camera.Parent = ViewportFrame

    --Forward button bind
    GuiObject:BindButton(UpgradesGui.Container.Forward, function()
        --Increment selectedModel, account for infinite scroll
        selectedModel = selectedModel + 1
        if (selectedModel > #upgradeModels) then
            selectedModel = 1
        end

        --Get model, tween camera
        local model = upgradeModels[selectedModel]
        TweenCamera(AttachCameraToModel(model))

        --Either black or whiteout the viewport frame depending on if the item is owned
        if (not HasItem(itemMetaData.ItemId, selectedModel)) then
            Blackout()
        else
            Whiteout()
        end
    end)

    --Back button binds
    GuiObject:BindButton(UpgradesGui.Container.Back, function()
        --Decrement selectedModel, account for infinite scroll
        selectedModel = selectedModel - 1
        if (selectedModel < 1) then
            selectedModel = #upgradeModels
        end

        --Get model and tween camera
        local model = upgradeModels[selectedModel]
        TweenCamera(AttachCameraToModel(model))

        --Either black or whiteout the viewport frame depending on if the item is owned
        if (not HasItem(itemMetaData.ItemId, selectedModel)) then
            Blackout()
        else
            Whiteout()
        end
    end)

    --Clear models when GUI closes
    GuiObject:AddCallbackToClose(function()
        while (UpgradesGui.Container.Visible) do wait() end

        CleanupViewport()
    end)

    GuiObject:BindButton(UpgradesGui.Container.Purchase, function()
        local actionData = PlacementService:RequestUpgrade(selectedGuid)
        NotificationDispatch:Dispatch(actionData.noticeObject)
    end)
end


function Upgrades:Init()
    --//Api
    TableUtil = self.Shared.TableUtil
    
    --//Services
    PlayerGui = self.Player.PlayerGui

    PlacementService = self.Services.PlacementService
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Controllers
    NotificationDispatch = self.Controllers.NotificationDispatcher

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass
    
    --//Locals
    ReplicatedData = ReplicatedStorage.ReplicatedData:WaitForChild(self.Player.UserId)
    UnlockedItems = TableUtil.DecodeJSON(ReplicatedData:WaitForChild("UnlockedItems").Value)
    PlotObject = self.Player:WaitForChild("PlotObject").Value
    Particles = ReplicatedStorage:WaitForChild("Items").Particles

    upgradeModels = {}

end

return Upgrades