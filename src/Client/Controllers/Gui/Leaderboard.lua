-- Leaderboard
-- MrAsync
-- May 4, 2020


--[[

    Handles the mutation of the game's custom leaderboard

]]


local Leaderboard = {}

--//Api
local UserInput
local MoneyLib

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerGui

--//Controllers

--//Classes
local MaidClass

--//Locals
local LeaderboardGui
local TemplateGui

local Maids = {}


--//Creates a frame belonging to player joining
local function CreateFrame(player)
    local newFrame = TemplateGui:Clone()
    newFrame.Parent = LeaderboardGui.Container.ScrollingFrame

    --Localize replicatedData
    local replicatedData = ReplicatedStorage.ReplicatedData:WaitForChild(player.UserId)
    local cashValue = replicatedData:WaitForChild("Cash")

    --Update leaderboard
    if (cashValue) then
        newFrame.CashValue.Text = MoneyLib:ToShort(cashValue.Value)

        Maids[player]:GiveTask(cashValue.Changed:Connect(function(newValue)
            newFrame.CashValue.Text = MoneyLib:ToShort(cashValue.Value)
        end))
    end

    --Setup labels
    newFrame.Name = player.UserId
    newFrame.Username.Text = player.Name

    --Setup icon
    newFrame.PlayerImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    newFrame.Visible = true
end


--//Elegantly removes frame belonging to player leaving
local function RemoveFrame(player)
    local oldFrame = LeaderboardGui.Container.ScrollingFrame:FindFirstChild( tostring(player.UserId) )
    if (oldFrame) then
        oldFrame:Destroy()
    end
end


function Leaderboard:Start()
    LeaderboardGui.Container.Position = UDim2.new(1, 0, 0, -36)

    --Hide UI on mobile devices
    if (UserInput:GetPreferred() == UserInput.Preferred.Touch) then
        LeaderboardGui.Enabled = false

        return
    end

    --Update UI to reflect current player base
    for _, player in pairs(Players:GetChildren()) do
        Maids[player] = MaidClass.new()

        CreateFrame(player)
    end

    --Update UI when new players join the game
    Players.PlayerAdded:Connect(function(newPlayer)
        if (newPlayer.Name ~= self.Player.Name and (not LeaderboardGui.Container:FindFirstChild(newPlayer.UserId))) then
            Maids[newPlayer] = MaidClass.new()

            CreateFrame(newPlayer)
        end
    end)

    --Update the UI when old players leave
    Players.PlayerRemoving:Connect(function(oldPlayer)
        if (oldPlayer.Name ~= self.Player.Name) then
            RemoveFrame(oldPlayer)

            if (Maids[oldPlayer]) then
                Maids[oldPlayer]:Destroy()
            end
        end
    end)
end


function Leaderboard:Init()
    --//Api
    UserInput = self.Controllers.UserInput
    MoneyLib = self.Shared.MoneyLib

    --//Services
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    --//Controllers

    --//Classes
    MaidClass = self.Shared.Maid

    --//Locals
    LeaderboardGui = PlayerGui:WaitForChild("Leaderboard")
    TemplateGui = LeaderboardGui.Container:WaitForChild("Template")

end

return Leaderboard