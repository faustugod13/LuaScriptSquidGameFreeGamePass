-- Wait for game to load
repeat wait() until game:IsLoaded()

-- Synapse Compatibilities
if syn then
    queue_on_teleport = syn.queue_on_teleport
    request = syn.request
end


-- Variables
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CameraSubject = Workspace.Camera.CameraSubject

-- Global Variables
getgenv().DiscordJoined = true -- Avoiding Discord Join Multiple Times
getgenv().InfiniteJump = false
getgenv().CurrentCookie = nil
getgenv().RopeGame = false
getgenv().MarbleGame = false
getgenv().GlassESP = false
getgenv().GlassESPColor = Color3.fromRGB(0, 255, 0)
getgenv().AutoPunch = false

-- Metamethod Hook for WalkSpeed and JumpHeight
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and tostring(Self) == "Humanoid" and Key == "WalkSpeed" then
        return 16
    elseif not checkcaller() and tostring(Self) == "Humanoid" and Key == "JumpHeight" then
       return 7.2 
    end

    return OldIndex(Self, Key)
end)    

-- Infinite Jump
UIS.InputBegan:Connect(function(UserInput)
    if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
        if getgenv().InfiniteJump then
            LocalPlayer.Character.Humanoid:ChangeState(3)
        end
    end
end)

-- Hook OnClientEvent to get the current cookie
pcall(function()
    ReplicatedStorage.Remotes.StartHoneycomb.OnClientEvent:Connect(function(Cookie)
        getgenv().CurrentCookie = Cookie
    end)
end)

local function AutoPunch()
    local Distance = math.huge
    local Closest

    for next, Target in pairs(Players:GetPlayers()) do
        if Target ~= LocalPlayer and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character.Humanoid.Health > 0 and not Target:GetAttribute("Guard") then
            local Magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - Target.Character.HumanoidRootPart.Position).magnitude
            if Magnitude < Distance then
                Distance = Magnitude
                Closest = Target
            end
        end
    end

    if Closest ~= nil then ReplicatedStorage.Remotes.PunchEvent:FireServer(Workspace[Closest.Name]) end
end

-- ImGui Settings
local ImGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/kubuntuclaps/Roblox-Scripts/main/UI/ImGui.lua"))()
local Settings = {
    main_color = Color3.fromRGB(0, 0, 0),
    min_size = Vector2.new(400, 400),
    toggle_key = Enum.KeyCode.RightShift,
    can_resize = true,
}
local Window = ImGui:AddWindow("Squid Game - Free Game Passes + AutoWin", Settings)
local AutoWinTab = Window:AddTab("Auto Win")
local GamepassTab = Window:AddTab("Gamepass")
local CreditsTab = Window:AddTab("Credits")


-- Auto Win Tab
AutoWinTab:AddLabel("Auto Win")

local tweenInfo = TweenInfo.new(13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(-341, 3, 435)})

local WinDoll = AutoWinTab:AddSwitch("Win Doll Game", function(toggle)
    ReplicatedStorage.Remotes.ReachedGoal:FireServer(Workspace.Mechanics.GoalPart1)
    if toggle and tween.PlaybackState ~= Enum.PlaybackState.Playing then
        tween:Play()
    elseif not toggle and tween.PlaybackState == Enum.PlaybackState.Playing then
        tween:Cancel()
    end
end)

local WinCookie = AutoWinTab:AddButton("Win Honey Comb Game", function()
    if getgenv().CurrentCookie ~= nil then
        getgenv().CurrentCookie:SetAttribute("Percent", 100)
        getgenv().CurrentCookie[getgenv().CurrentCookie.Name .. "Hitboxes"]:ClearAllChildren()
        wait(5)
        ReplicatedStorage.Remotes.HoneyCombResult:FireServer(true)
    end
end)

local WinRope = AutoWinTab:AddSwitch("Win Rope Game", function(toggle)
    getgenv().RopeGame = toggle
end)
WinRope:Set(false)

local MarbleGame = AutoWinTab:AddSwitch("Win Marble Game", function(toggle)
    getgenv().MarbleGame = toggle
end)

local WinGlass = AutoWinTab:AddButton("Win Glass Game", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-501, 78, -480)
end)

local WinSquid = AutoWinTab:AddSwitch("Win Squid Game", function(toggle)
    if toggle then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-314, 3, 326)
    end
    getgenv().AutoPunch = toggle
end)
WinSquid:Set(false)

-- Gamepass Tab
GamepassTab:AddLabel("Guard Options")

local BecomeGuard = GamepassTab:AddButton("Become Guard", function()
    ReplicatedStorage.GuardRemotes.BecomeGuard:InvokeServer(true)
end)

local CollectAllBodies = GamepassTab:AddButton("Collect All Bodies", function()
    for next, Body in pairs(Workspace.Bodies:GetChildren()) do
        ReplicatedStorage.GuardRemotes.CollectBody:FireServer(LocalPlayer, Body.Torso.CFrame, Body.Name)
    end
end)

GamepassTab:AddLabel("Frontman Options")

local BecomeFrontman = GamepassTab:AddButton("Become Frontman", function()
    ReplicatedStorage.FrontmanRemotes.BecomeFrontman:InvokeServer(true)
end)


local GlassESP = AutoWinTab:AddSwitch("Glass ESP", function(toggle)
    getgenv().GlassESP = toggle

    if not toggle then
        for next, Glass in pairs(Workspace.Glass:GetChildren()) do
            if Glass:FindFirstChild("SelectionBox") then
                Glass.SelectionBox.Transparency = 1
            end
        end
    end
end)

local GlassESPColor = AutoWinTab:AddColorPicker("Glass ESP Color", function(color)
    getgenv().GlassESPColor = color
end)


-- Credits Tab
CreditsTab:AddLabel("Made by faustino#8488")
CreditsTab:AddLabel("Thanks to fifi#8250 for emotional support <3")

ImGui:FormatWindows()
CreditsTab:Show()

-- RenderStepped Loop
RunService.RenderStepped:Connect(function()
    if getgenv().AutoPunch then
        AutoPunch()
    elseif getgenv().RopeGame then
        ReplicatedStorage.Pull:FireServer(1)
    elseif getgenv().GlassESP then
        for next, Glass in pairs(Workspace.Glass:GetChildren()) do
            if Glass:FindFirstChild("SelectionBox") then
                Glass.SelectionBox.Transparency = 0
                Glass.SelectionBox.SurfaceColor3 = getgenv().GlassESPColor
            end
        end
    end
end)