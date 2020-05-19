-- Upgrades
-- MrAsync
-- May 15, 2020



local Upgrades = {}

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui

local NotificationDispatch
local MetaDataService
local PlayerService

--//Controllers

--//Classes
local GuiClass

--//Locals
local UpgradesGui
local GuiObject

local ViewportFrame
local Camera

local itemMetaData
local upgradeModels
local selectedModel
local objectSpinConnection


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

    --Reset array
    upgradeModels = {}
end


--//Public facing Show
function Upgrades:Show(guid)
    --Viewport!
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
    end)

    --Clear models when GUI closes
    GuiObject:AddCallbackToClose(function()
        while (UpgradesGui.Container.Visible) do wait() end

        CleanupViewport()
    end)

    GuiObject:BindButton(UpgradesGui.Container.Purchase)
end


function Upgrades:Init()
    --//Api
    
    --//Services
    PlayerGui = self.Player.PlayerGui

    NotificationDispatch = self.Controllers.NotificationDispatcher
    MetaDataService = self.Services.MetaDataService
    PlayerService = self.Services.PlayerService

    --//Controllers

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass
    
    --//Locals
    upgradeModels = {}

end

return Upgrades