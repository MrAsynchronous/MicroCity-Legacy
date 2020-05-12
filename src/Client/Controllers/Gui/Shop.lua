-- Codes
-- MrAsync
-- May 7, 2020



local Codes = {}

--//Api

--//Services
local PlayerGui

local NotificationDispatch

--//Controllers
local NavigationController

--//Classes
local GuiClass

--//Locals
local PRODUCT_FRAME_SIZE = UDim2.new(0.925, 0, 0.726, 0)

function Codes:Start()
    if (not NavigationController:HasLoaded()) then
        NavigationController.IsLoaded:Wait()
    end

    local ShopGui = PlayerGui.Shop
    local GuiObject = GuiClass.new(ShopGui)
    local ProductFrame = ShopGui.Container.ProductFrame
    local GamepassFrame = ShopGui.Container.GamepassFrame

    GamepassFrame.Visible = false

    GuiObject:BindButton(ShopGui.Container.ProductButton, function()
        if (ProductFrame.Visible) then return end

        GamepassFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true, function()
            GamepassFrame.Visible = false

            ProductFrame.Size = UDim2.new(0, 0, 0, 0)
            ProductFrame.Visible = true
            
            ProductFrame:TweenSize(PRODUCT_FRAME_SIZE, "Out", "Quint", 0.25, true)
        end)
    end)

    GuiObject:BindButton(ShopGui.Container.GamepassButton, function()
        if (GamepassFrame.Visible) then return end

        ProductFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true, function()
            ProductFrame.Visible = false

            GamepassFrame.Size = UDim2.new(0, 0, 0, 0)
            GamepassFrame.Visible = true

            GamepassFrame:TweenSize(PRODUCT_FRAME_SIZE, "Out", "Quint", 0.25, true)
        end)
    end)

    --Navigation Button Bind
    NavigationController.ShopButtonClicked:Connect(function()
        GuiObject:ChangeVisibility()
    end)
end


function Codes:Init()
    --//Api

    --//Services
    PlayerGui = self.Player.PlayerGui

    NotificationDispatch = self.Controllers.NotificationDispatcher

    --//Controllers
    NavigationController = self.Controllers.Gui.Navigation

    --//Classes
    GuiClass = self.Modules.Classes.GuiClass

    --//Locals

end


return Codes