--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    R O L E X  G U I                         ║
    ║              Premium UI Library for Roblox                  ║
    ║                    Version 2.0                              ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Components:
      • Toggle          • Checkbox        • Slider
      • Dropdown        • Progress Bar    • Tab System
      • Modal / Popup   • Notification    • Button
      • Textbox         • Keybind         • Color Picker
    
    Single-file version — paste directly into your executor
--]]

-- ══════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ══════════════════════════════════════════════════════════════
-- LIBRARY TABLE
-- ══════════════════════════════════════════════════════════════
local Rolex = {}
Rolex.__index = Rolex

-- ══════════════════════════════════════════════════════════════
-- THEME / DESIGN TOKENS
-- ══════════════════════════════════════════════════════════════
local Theme = {
    Background       = Color3.fromRGB(12, 12, 18),
    Surface          = Color3.fromRGB(18, 18, 28),
    SurfaceHover     = Color3.fromRGB(24, 24, 38),
    Card             = Color3.fromRGB(22, 22, 34),
    CardBorder       = Color3.fromRGB(40, 40, 65),

    AccentPrimary    = Color3.fromRGB(120, 80, 255),
    AccentSecondary  = Color3.fromRGB(0, 210, 255),
    AccentTertiary   = Color3.fromRGB(255, 60, 170),

    Success          = Color3.fromRGB(0, 230, 130),
    Warning          = Color3.fromRGB(255, 190, 50),
    Error            = Color3.fromRGB(255, 70, 80),
    Info             = Color3.fromRGB(80, 160, 255),

    TextPrimary      = Color3.fromRGB(240, 240, 255),
    TextSecondary    = Color3.fromRGB(160, 160, 190),
    TextMuted        = Color3.fromRGB(100, 100, 130),

    Divider          = Color3.fromRGB(35, 35, 55),
    Shadow           = Color3.fromRGB(0, 0, 0),
    Overlay          = Color3.fromRGB(0, 0, 0),

    FontFamily       = Enum.Font.GothamBold,
    FontBody         = Enum.Font.Gotham,
    FontMono         = Enum.Font.Code,

    TweenSpeed       = 0.28,
    TweenSpeedFast   = 0.15,
    TweenEasing      = Enum.EasingStyle.Quint,
    TweenDirection   = Enum.EasingDirection.Out,

    CornerRadius     = UDim.new(0, 8),
    CornerRadiusLg   = UDim.new(0, 12),
    Padding          = UDim.new(0, 12),
    ElementHeight    = 38,
    WindowWidth      = 580,
    WindowHeight     = 420,
    TabWidth         = 150,
}

-- ══════════════════════════════════════════════════════════════
-- UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════
local Util = {}

function Util.Tween(instance, props, duration, easingStyle, easingDir)
    local info = TweenInfo.new(
        duration or Theme.TweenSpeed,
        easingStyle or Theme.TweenEasing,
        easingDir or Theme.TweenDirection
    )
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

function Util.Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Util.AddCorner(parent, radius)
    return Util.Create("UICorner", {
        CornerRadius = radius or Theme.CornerRadius,
        Parent = parent,
    })
end

function Util.AddStroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or Theme.CardBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent,
    })
end

function Util.AddPadding(parent, top, bottom, left, right)
    local p = top or 12
    return Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or p),
        PaddingBottom = UDim.new(0, bottom or p),
        PaddingLeft = UDim.new(0, left or p),
        PaddingRight = UDim.new(0, right or p),
        Parent = parent,
    })
end

function Util.AddGradient(parent, c1, c2, rotation)
    return Util.Create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 0,
        Parent = parent,
    })
end

function Util.Ripple(parent, posX, posY)
    local ripple = Util.Create("Frame", {
        Name = "_Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, posX, 0, posY),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        ZIndex = parent.ZIndex + 5,
        Parent = parent,
    })
    Util.AddCorner(ripple, UDim.new(1, 0))
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    Util.Tween(ripple, {
        Size = UDim2.fromOffset(maxSize, maxSize),
        BackgroundTransparency = 1,
    }, 0.5, Enum.EasingStyle.Quad)
    task.delay(0.5, function() ripple:Destroy() end)
end

-- ══════════════════════════════════════════════════════════════
-- SCREENGUI ROOT
-- ══════════════════════════════════════════════════════════════
local ScreenGui

local function EnsureScreenGui()
    if ScreenGui and ScreenGui.Parent then return ScreenGui end
    ScreenGui = Util.Create("ScreenGui", {
        Name = "RolexGui_" .. tostring(math.random(1000, 9999)),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    local ok, _ = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = CoreGui
        end
    end)
    if not ok then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    return ScreenGui
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local NotificationContainer

local function EnsureNotificationContainer()
    EnsureScreenGui()
    if NotificationContainer and NotificationContainer.Parent then return NotificationContainer end
    NotificationContainer = Util.Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 320, 1, -40),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 999,
        Parent = ScreenGui,
    })
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = NotificationContainer,
    })
    return NotificationContainer
end

function Rolex:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local nType = config.Type or "Info"

    local accentColor = Theme.Info
    local icon = "ℹ"
    if nType == "Success" then accentColor = Theme.Success; icon = "✓"
    elseif nType == "Warning" then accentColor = Theme.Warning; icon = "⚠"
    elseif nType == "Error" then accentColor = Theme.Error; icon = "✕" end

    EnsureNotificationContainer()

    local card = Util.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
        ZIndex = 1000,
        Parent = NotificationContainer,
    })
    Util.AddCorner(card, Theme.CornerRadiusLg)
    Util.AddStroke(card, accentColor, 1, 0.6)

    Util.Create("Frame", {
        Name = "AccentStripe",
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 1001,
        Parent = card,
    })

    local content = Util.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 1001,
        Parent = card,
    })
    Util.AddPadding(content, 12, 12, 16, 12)
    Util.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = content })

    local header = Util.Create("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1, ZIndex = 1002, Parent = content,
    })

    local iconCircle = Util.Create("Frame", {
        Size = UDim2.fromOffset(22, 22), BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.85, ZIndex = 1003, Parent = header,
    })
    Util.AddCorner(iconCircle, UDim.new(1, 0))
    Util.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = icon, TextColor3 = accentColor, TextSize = 12,
        Font = Theme.FontFamily, ZIndex = 1004, Parent = iconCircle,
    })

    Util.Create("TextLabel", {
        Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1, Text = title, TextColor3 = Theme.TextPrimary,
        TextSize = 14, Font = Theme.FontFamily, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1003, Parent = header,
    })

    local closeBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1,
        Text = "✕", TextColor3 = Theme.TextMuted, TextSize = 14,
        Font = Theme.FontBody, ZIndex = 1003, Parent = header,
    })

    if message ~= "" then
        Util.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Text = message, TextColor3 = Theme.TextSecondary,
            TextSize = 12, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 1002, Parent = content,
        })
    end

    local progressBar = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accentColor, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ZIndex = 1005, Parent = card,
    })

    card.Position = UDim2.new(1, 50, 0, 0)
    card.BackgroundTransparency = 1
    Util.Tween(card, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.05 }, 0.35)
    Util.Tween(progressBar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        Util.Tween(card, { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 }, 0.3)
        task.delay(0.35, function() card:Destroy() end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)
end

-- ══════════════════════════════════════════════════════════════
-- MODAL / POPUP SYSTEM
-- ══════════════════════════════════════════════════════════════
function Rolex:Modal(config)
    config = config or {}
    local title = config.Title or "Confirm"
    local message = config.Message or "Are you sure?"
    local confirmText = config.ConfirmText or "Confirm"
    local cancelText = config.CancelText or "Cancel"
    local onConfirm = config.OnConfirm or function() end
    local onCancel = config.OnCancel or function() end

    EnsureScreenGui()

    local overlay = Util.Create("Frame", {
        Name = "ModalOverlay", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Overlay, BackgroundTransparency = 1,
        ZIndex = 900, Parent = ScreenGui,
    })

    local modal = Util.Create("Frame", {
        Name = "ModalCard", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(380, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Surface,
        ZIndex = 910, Parent = overlay,
    })
    Util.AddCorner(modal, Theme.CornerRadiusLg)
    Util.AddStroke(modal, Theme.AccentPrimary, 1, 0.6)

    local modalContent = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, ZIndex = 911, Parent = modal,
    })
    Util.AddPadding(modalContent, 24, 20, 24, 24)
    Util.Create("UIListLayout", { Padding = UDim.new(0, 16), Parent = modalContent })

    local orb = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -30),
        Size = UDim2.fromOffset(60, 60), BackgroundColor3 = Theme.AccentPrimary,
        BackgroundTransparency = 0.7, ZIndex = 912, Parent = modal,
    })
    Util.AddCorner(orb, UDim.new(1, 0))

    task.spawn(function()
        while orb and orb.Parent do
            Util.Tween(orb, { BackgroundTransparency = 0.5, Size = UDim2.fromOffset(65, 65) }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            Util.Tween(orb, { BackgroundTransparency = 0.8, Size = UDim2.fromOffset(55, 55) }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)

    Util.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "?", TextColor3 = Theme.TextPrimary, TextSize = 26,
        Font = Theme.FontFamily, ZIndex = 913, Parent = orb,
    })

    Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
        Text = title, TextColor3 = Theme.TextPrimary, TextSize = 18,
        Font = Theme.FontFamily, TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 912, Parent = modalContent,
    })

    Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Text = message, TextColor3 = Theme.TextSecondary,
        TextSize = 13, Font = Theme.FontBody, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 912, Parent = modalContent,
    })

    local btnRow = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1,
        ZIndex = 912, Parent = modalContent,
    })
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 12), Parent = btnRow,
    })

    local cancelBtn = Util.Create("TextButton", {
        Size = UDim2.fromOffset(130, 38), BackgroundColor3 = Theme.Card,
        Text = cancelText, TextColor3 = Theme.TextSecondary, TextSize = 13,
        Font = Theme.FontFamily, ZIndex = 913, Parent = btnRow,
    })
    Util.AddCorner(cancelBtn)
    Util.AddStroke(cancelBtn, Theme.CardBorder, 1, 0.5)

    local confirmBtn = Util.Create("TextButton", {
        Size = UDim2.fromOffset(130, 38), BackgroundColor3 = Theme.AccentPrimary,
        Text = confirmText, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontFamily, ZIndex = 913, Parent = btnRow,
    })
    Util.AddCorner(confirmBtn)
    Util.AddGradient(confirmBtn, Theme.AccentPrimary, Theme.AccentSecondary, 45)

    overlay.BackgroundTransparency = 1
    Util.Tween(overlay, { BackgroundTransparency = 0.5 }, 0.3)

    local function closeModal(callback)
        Util.Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
        Util.Tween(modal, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.3, function()
            overlay:Destroy()
            if callback then callback() end
        end)
    end

    confirmBtn.MouseEnter:Connect(function() Util.Tween(confirmBtn, { BackgroundTransparency = 0.15 }, Theme.TweenSpeedFast) end)
    confirmBtn.MouseLeave:Connect(function() Util.Tween(confirmBtn, { BackgroundTransparency = 0 }, Theme.TweenSpeedFast) end)
    cancelBtn.MouseEnter:Connect(function() Util.Tween(cancelBtn, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    cancelBtn.MouseLeave:Connect(function() Util.Tween(cancelBtn, { BackgroundColor3 = Theme.Card }, Theme.TweenSpeedFast) end)

    confirmBtn.MouseButton1Click:Connect(function()
        Util.Ripple(confirmBtn, confirmBtn.AbsoluteSize.X / 2, confirmBtn.AbsoluteSize.Y / 2)
        closeModal(onConfirm)
    end)
    cancelBtn.MouseButton1Click:Connect(function() closeModal(onCancel) end)

    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local mp = modal.AbsolutePosition
            local ms = modal.AbsoluteSize
            if mousePos.X < mp.X or mousePos.X > mp.X + ms.X or mousePos.Y < mp.Y or mousePos.Y > mp.Y + ms.Y then
                closeModal(onCancel)
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ══════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Rolex:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Rolex Hub"
    local subtitle = config.Subtitle or "v2.0"
    local size = config.Size or UDim2.fromOffset(Theme.WindowWidth, Theme.WindowHeight)

    EnsureScreenGui()

    local self = setmetatable({}, Window)
    self._tabs = {}
    self._activeTab = nil
    self._minimized = false
    self._visible = true

    -- Main container
    local mainFrame = Util.Create("Frame", {
        Name = "RolexWindow", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = size,
        BackgroundColor3 = Theme.Background, ClipsDescendants = true,
        ZIndex = 10, Parent = ScreenGui,
    })
    Util.AddCorner(mainFrame, Theme.CornerRadiusLg)
    Util.AddStroke(mainFrame, Theme.CardBorder, 1, 0.4)
    self._frame = mainFrame

    -- Entrance animation
    mainFrame.Size = UDim2.fromOffset(0, 0)
    mainFrame.BackgroundTransparency = 1
    Util.Tween(mainFrame, { Size = size, BackgroundTransparency = 0 }, 0.5, Enum.EasingStyle.Back)

    -- Title bar
    local titleBar = Util.Create("Frame", {
        Name = "TitleBar", Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        ZIndex = 20, Parent = mainFrame,
    })
    Util.AddCorner(titleBar, Theme.CornerRadiusLg)

    Util.Create("Frame", {
        Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        ZIndex = 20, Parent = titleBar,
    })

    -- Accent line with shimmer
    local accentLine = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.AccentPrimary, BorderSizePixel = 0,
        ZIndex = 21, Parent = titleBar,
    })
    Util.AddGradient(accentLine, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    local shimmer = Util.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 255)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.45, 0.6),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(0.55, 0.6),
            NumberSequenceKeypoint.new(1, 0.6),
        }),
        Parent = accentLine,
    })
    task.spawn(function()
        while accentLine and accentLine.Parent do
            shimmer.Offset = Vector2.new(-1, 0)
            Util.Tween(shimmer, { Offset = Vector2.new(1, 0) }, 2.5, Enum.EasingStyle.Linear)
            task.wait(3.5)
        end
    end)

    -- Logo dot with pulse
    local logoDot = Util.Create("Frame", {
        Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Theme.AccentPrimary,
        ZIndex = 22, Parent = titleBar,
    })
    Util.AddCorner(logoDot, UDim.new(1, 0))

    task.spawn(function()
        while logoDot and logoDot.Parent do
            Util.Tween(logoDot, { BackgroundColor3 = Theme.AccentSecondary, Size = UDim2.fromOffset(12, 12) }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            Util.Tween(logoDot, { BackgroundColor3 = Theme.AccentPrimary, Size = UDim2.fromOffset(10, 10) }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end)

    -- Title & subtitle
    Util.Create("TextLabel", {
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(0.5, -32, 1, 0),
        BackgroundTransparency = 1, Text = title, TextColor3 = Theme.TextPrimary,
        TextSize = 15, Font = Theme.FontFamily, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22, Parent = titleBar,
    })
    Util.Create("TextLabel", {
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(0.5, -32, 1, 0),
        BackgroundTransparency = 1, Text = "  " .. subtitle, TextColor3 = Theme.TextMuted,
        TextSize = 11, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22, Parent = titleBar,
    })

    -- Window controls
    local controls = Util.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(70, 24), BackgroundTransparency = 1,
        ZIndex = 22, Parent = titleBar,
    })
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8), Parent = controls,
    })

    local minimizeBtn = Util.Create("TextButton", {
        Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Warning,
        BackgroundTransparency = 0.8, Text = "─", TextColor3 = Theme.Warning,
        TextSize = 14, Font = Theme.FontFamily, ZIndex = 23, Parent = controls,
    })
    Util.AddCorner(minimizeBtn, UDim.new(1, 0))

    local closeBtn = Util.Create("TextButton", {
        Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Error,
        BackgroundTransparency = 0.8, Text = "✕", TextColor3 = Theme.Error,
        TextSize = 12, Font = Theme.FontFamily, ZIndex = 23, Parent = controls,
    })
    Util.AddCorner(closeBtn, UDim.new(1, 0))

    for _, btn in ipairs({minimizeBtn, closeBtn}) do
        btn.MouseEnter:Connect(function() Util.Tween(btn, { BackgroundTransparency = 0.3 }, Theme.TweenSpeedFast) end)
        btn.MouseLeave:Connect(function() Util.Tween(btn, { BackgroundTransparency = 0.8 }, Theme.TweenSpeedFast) end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Util.Tween(mainFrame, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.4, function() mainFrame:Destroy() end)
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        if self._minimized then
            Util.Tween(mainFrame, { Size = UDim2.fromOffset(size.X.Offset, 42) }, 0.3)
        else
            Util.Tween(mainFrame, { Size = size }, 0.3)
        end
    end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local sidebar = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(0, Theme.TabWidth, 1, -42),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        ZIndex = 15, ClipsDescendants = true, Parent = mainFrame,
    })
    Util.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0, ZIndex = 16, Parent = sidebar,
    })

    local tabList = Util.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 16, Parent = sidebar,
    })
    Util.AddPadding(tabList, 6, 6, 8, 8)
    Util.Create("UIListLayout", { Padding = UDim.new(0, 4), Parent = tabList })
    self._tabList = tabList

    -- Content area
    local contentArea = Util.Create("Frame", {
        Position = UDim2.new(0, Theme.TabWidth, 0, 42),
        Size = UDim2.new(1, -Theme.TabWidth, 1, -42),
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 15, Parent = mainFrame,
    })
    self._contentArea = contentArea

    -- Toggle visibility keybind
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            self._visible = not self._visible
            mainFrame.Visible = self._visible
        end
    end)

    return self
end

-- ══════════════════════════════════════════════════════════════
-- TAB CLASS
-- ══════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Window:AddTab(config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or ""

    local self_window = self
    local tab = setmetatable({}, Tab)
    tab._name = name
    tab._elements = {}

    local tabBtn = Util.Create("TextButton", {
        Name = "Tab_" .. name, Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Surface, BackgroundTransparency = 1,
        Text = "", ZIndex = 17, Parent = self._tabList,
    })
    Util.AddCorner(tabBtn)

    local indicator = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 0.15, 0), Size = UDim2.new(0, 3, 0.7, 0),
        BackgroundColor3 = Theme.AccentPrimary, BackgroundTransparency = 1,
        ZIndex = 18, Parent = tabBtn,
    })
    Util.AddCorner(indicator, UDim.new(1, 0))
    Util.AddGradient(indicator, Theme.AccentPrimary, Theme.AccentSecondary, 90)

    if icon ~= "" then
        Util.Create("ImageLabel", {
            Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
            Image = icon, ImageColor3 = Theme.TextSecondary, ZIndex = 18, Parent = tabBtn,
        })
    end

    local labelOffset = icon ~= "" and 38 or 14
    local tabLabel = Util.Create("TextLabel", {
        Position = UDim2.new(0, labelOffset, 0, 0), Size = UDim2.new(1, -labelOffset - 8, 1, 0),
        BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextSecondary,
        TextSize = 12, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 18, Parent = tabBtn,
    })

    local page = Util.Create("ScrollingFrame", {
        Name = "Page_" .. name, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentPrimary, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        ZIndex = 16, Parent = self._contentArea,
    })
    Util.AddPadding(page, 14, 14, 16, 16)
    Util.Create("UIListLayout", { Padding = UDim.new(0, 8), Parent = page })

    tab._page = page
    tab._button = tabBtn
    tab._label = tabLabel
    tab._indicator = indicator
    tab._window = self_window

    local function selectTab()
        for _, t in ipairs(self_window._tabs) do
            t._page.Visible = false
            Util.Tween(t._button, { BackgroundTransparency = 1 }, Theme.TweenSpeedFast)
            Util.Tween(t._label, { TextColor3 = Theme.TextSecondary }, Theme.TweenSpeedFast)
            Util.Tween(t._indicator, { BackgroundTransparency = 1 }, Theme.TweenSpeedFast)
            local ic = t._button:FindFirstChild("Icon")
            if ic then Util.Tween(ic, { ImageColor3 = Theme.TextSecondary }, Theme.TweenSpeedFast) end
        end
        page.Visible = true
        Util.Tween(tabBtn, { BackgroundTransparency = 0.85 }, Theme.TweenSpeedFast)
        Util.Tween(tabLabel, { TextColor3 = Theme.TextPrimary }, Theme.TweenSpeedFast)
        Util.Tween(indicator, { BackgroundTransparency = 0 }, Theme.TweenSpeedFast)
        local ic = tabBtn:FindFirstChild("Icon")
        if ic then Util.Tween(ic, { ImageColor3 = Theme.AccentPrimary }, Theme.TweenSpeedFast) end
        self_window._activeTab = tab
    end

    tabBtn.MouseButton1Click:Connect(selectTab)
    tabBtn.MouseEnter:Connect(function()
        if self_window._activeTab ~= tab then Util.Tween(tabBtn, { BackgroundTransparency = 0.9 }, Theme.TweenSpeedFast) end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self_window._activeTab ~= tab then Util.Tween(tabBtn, { BackgroundTransparency = 1 }, Theme.TweenSpeedFast) end
    end)

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then selectTab() end

    return tab
end

-- ══════════════════════════════════════════════════════════════
-- TAB COMPONENTS
-- ══════════════════════════════════════════════════════════════

-- Section Header
function Tab:AddSection(config)
    config = config or {}
    local name = config.Name or "Section"
    local section = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
        ZIndex = 17, Parent = self._page,
    })
    Util.Create("TextLabel", {
        Position = UDim2.new(0, 2, 0, 8), Size = UDim2.new(1, -4, 0, 16),
        BackgroundTransparency = 1, Text = string.upper(name),
        TextColor3 = Theme.TextMuted, TextSize = 10, Font = Theme.FontFamily,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18, Parent = section,
    })
    Util.Create("Frame", {
        Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Divider, BorderSizePixel = 0,
        ZIndex = 18, Parent = section,
    })
    return section
end

-- Toggle
function Tab:AddToggle(config)
    config = config or {}
    local name = config.Name or "Toggle"
    local description = config.Description
    local default = config.Default or false
    local callback = config.Callback or function() end
    local state = default
    local totalHeight = description and 50 or 38

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, totalHeight), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Position = UDim2.new(0, 0, 0, description and 8 or 0),
        Size = UDim2.new(1, -60, 0, description and 20 or totalHeight),
        BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextPrimary,
        TextSize = 13, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })
    if description then
        Util.Create("TextLabel", {
            Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, -60, 0, 16),
            BackgroundTransparency = 1, Text = description, TextColor3 = Theme.TextMuted,
            TextSize = 11, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 18, Parent = container,
        })
    end

    local track = Util.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = state and Theme.AccentPrimary or Theme.Divider,
        ZIndex = 19, Parent = container,
    })
    Util.AddCorner(track, UDim.new(1, 0))

    local knob = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 20, Parent = track,
    })
    Util.AddCorner(knob, UDim.new(1, 0))

    local glow = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.AccentPrimary,
        BackgroundTransparency = state and 0.7 or 1, ZIndex = 19, Parent = knob,
    })
    Util.AddCorner(glow, UDim.new(1, 0))

    local function updateVisual()
        if state then
            Util.Tween(track, { BackgroundColor3 = Theme.AccentPrimary }, Theme.TweenSpeed)
            Util.Tween(knob, { Position = UDim2.new(1, -19, 0.5, 0) }, Theme.TweenSpeed)
            Util.Tween(glow, { BackgroundTransparency = 0.7 }, Theme.TweenSpeed)
        else
            Util.Tween(track, { BackgroundColor3 = Theme.Divider }, Theme.TweenSpeed)
            Util.Tween(knob, { Position = UDim2.new(0, 3, 0.5, 0) }, Theme.TweenSpeed)
            Util.Tween(glow, { BackgroundTransparency = 1 }, Theme.TweenSpeed)
        end
    end

    local btn = Util.Create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "", ZIndex = 21, Parent = container,
    })
    btn.MouseButton1Click:Connect(function() state = not state; updateVisual(); callback(state) end)
    btn.MouseEnter:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    btn.MouseLeave:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.Card }, Theme.TweenSpeedFast) end)

    local api = {}
    function api:Set(value) state = value; updateVisual(); callback(state) end
    function api:Get() return state end
    return api
end

-- Checkbox
function Tab:AddCheckbox(config)
    config = config or {}
    local name = config.Name or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local state = default

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    local box = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = state and Theme.AccentPrimary or Theme.Surface,
        ZIndex = 19, Parent = container,
    })
    Util.AddCorner(box, UDim.new(0, 5))
    Util.AddStroke(box, state and Theme.AccentPrimary or Theme.CardBorder, 1.5, state and 0 or 0.4)

    local checkmark = Util.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "✓", TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14, TextTransparency = state and 0 or 1,
        Font = Theme.FontFamily, ZIndex = 20, Parent = box,
    })

    Util.Create("TextLabel", {
        Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextPrimary,
        TextSize = 13, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })

    local stroke = box:FindFirstChildOfClass("UIStroke")
    local function updateVisual()
        if state then
            Util.Tween(box, { BackgroundColor3 = Theme.AccentPrimary }, Theme.TweenSpeed)
            Util.Tween(checkmark, { TextTransparency = 0 }, Theme.TweenSpeedFast)
            if stroke then Util.Tween(stroke, { Color = Theme.AccentPrimary, Transparency = 0 }, Theme.TweenSpeed) end
            Util.Tween(box, { Size = UDim2.fromOffset(22, 22) }, 0.1)
            task.delay(0.1, function() Util.Tween(box, { Size = UDim2.fromOffset(20, 20) }, 0.15) end)
        else
            Util.Tween(box, { BackgroundColor3 = Theme.Surface }, Theme.TweenSpeed)
            Util.Tween(checkmark, { TextTransparency = 1 }, Theme.TweenSpeedFast)
            if stroke then Util.Tween(stroke, { Color = Theme.CardBorder, Transparency = 0.4 }, Theme.TweenSpeed) end
        end
    end

    local btn = Util.Create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "", ZIndex = 21, Parent = container,
    })
    btn.MouseButton1Click:Connect(function() state = not state; updateVisual(); callback(state) end)
    btn.MouseEnter:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    btn.MouseLeave:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.Card }, Theme.TweenSpeedFast) end)

    local api = {}
    function api:Set(value) state = value; updateVisual(); callback(state) end
    function api:Get() return state end
    return api
end

-- Slider
function Tab:AddSlider(config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    local value = math.clamp(default, min, max)

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(0.6, 0, 0, 18),
        BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextPrimary,
        TextSize = 13, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })

    local valueLabel = Util.Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 8),
        Size = UDim2.new(0.4, 0, 0, 18), BackgroundTransparency = 1,
        Text = tostring(value) .. suffix, TextColor3 = Theme.AccentSecondary,
        TextSize = 13, Font = Theme.FontMono, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 18, Parent = container,
    })

    local trackBg = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Theme.Divider, ZIndex = 18, Parent = container,
    })
    Util.AddCorner(trackBg, UDim.new(1, 0))

    local fillPercent = (value - min) / (max - min)
    local fill = Util.Create("Frame", {
        Size = UDim2.new(fillPercent, 0, 1, 0), BackgroundColor3 = Theme.AccentPrimary,
        ZIndex = 19, Parent = trackBg,
    })
    Util.AddCorner(fill, UDim.new(1, 0))
    Util.AddGradient(fill, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    local thumb = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(fillPercent, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 21, Parent = trackBg,
    })
    Util.AddCorner(thumb, UDim.new(1, 0))

    local thumbGlow = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.AccentPrimary,
        BackgroundTransparency = 0.8, ZIndex = 20, Parent = thumb,
    })
    Util.AddCorner(thumbGlow, UDim.new(1, 0))

    local sliding = false
    local hitbox = Util.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 26),
        BackgroundTransparency = 1, Text = "", ZIndex = 22, Parent = container,
    })

    local function updateSlider(inputX)
        local trackAbsPos = trackBg.AbsolutePosition.X
        local trackAbsSize = trackBg.AbsoluteSize.X
        local relative = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        local rawValue = min + (max - min) * relative
        value = math.clamp(math.floor((rawValue - min) / increment + 0.5) * increment + min, min, max)
        local percent = (value - min) / (max - min)
        Util.Tween(fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.05, Enum.EasingStyle.Linear)
        Util.Tween(thumb, { Position = UDim2.new(percent, 0, 0.5, 0) }, 0.05, Enum.EasingStyle.Linear)
        valueLabel.Text = tostring(value) .. suffix
        callback(value)
    end

    hitbox.MouseButton1Down:Connect(function()
        sliding = true
        Util.Tween(thumb, { Size = UDim2.fromOffset(18, 18) }, Theme.TweenSpeedFast)
        Util.Tween(thumbGlow, { BackgroundTransparency = 0.5 }, Theme.TweenSpeedFast)
        updateSlider(Mouse.X)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
            sliding = false
            Util.Tween(thumb, { Size = UDim2.fromOffset(16, 16) }, Theme.TweenSpeedFast)
            Util.Tween(thumbGlow, { BackgroundTransparency = 0.8 }, Theme.TweenSpeedFast)
        end
    end)
    RunService.RenderStepped:Connect(function()
        if sliding then updateSlider(Mouse.X) end
    end)

    hitbox.MouseEnter:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    hitbox.MouseLeave:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.Card }, Theme.TweenSpeedFast) end)

    local api = {}
    function api:Set(v)
        value = math.clamp(v, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        thumb.Position = UDim2.new(percent, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. suffix
        callback(value)
    end
    function api:Get() return value end
    return api
end

-- Dropdown
function Tab:AddDropdown(config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local items = config.Items or {}
    local default = config.Default or (items[1] or "")
    local callback = config.Callback or function() end
    local selected = default
    local isOpen = false
    local itemHeight = 30

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        ClipsDescendants = false, ZIndex = 30, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31, Parent = container,
    })

    local selectBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.55, 0, 0, 30), BackgroundColor3 = Theme.Surface,
        Text = "", ZIndex = 32, Parent = container,
    })
    Util.AddCorner(selectBtn, UDim.new(0, 6))
    Util.AddStroke(selectBtn, Theme.CardBorder, 1, 0.6)

    local selectedLabel = Util.Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1, Text = tostring(selected),
        TextColor3 = Theme.TextPrimary, TextSize = 12, Font = Theme.FontBody,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 33, Parent = selectBtn,
    })

    local arrow = Util.Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
        Text = "▼", TextColor3 = Theme.TextMuted, TextSize = 10,
        Font = Theme.FontBody, Rotation = 0, ZIndex = 33, Parent = selectBtn,
    })

    local dropdownList = Util.Create("Frame", {
        Position = UDim2.new(0, -14, 1, 4), Size = UDim2.new(1, 28, 0, 0),
        BackgroundColor3 = Theme.Surface, ClipsDescendants = true,
        Visible = false, ZIndex = 50, Parent = container,
    })
    Util.AddCorner(dropdownList, UDim.new(0, 6))
    Util.AddStroke(dropdownList, Theme.AccentPrimary, 1, 0.7)

    local listContent = Util.Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.AccentPrimary,
        CanvasSize = UDim2.new(0, 0, 0, #items * itemHeight),
        ZIndex = 51, Parent = dropdownList,
    })
    Util.Create("UIListLayout", { Padding = UDim.new(0, 1), Parent = listContent })
    Util.AddPadding(listContent, 4, 4, 4, 4)

    local function populateItems()
        for _, child in ipairs(listContent:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, item in ipairs(items) do
            local itemBtn = Util.Create("TextButton", {
                Size = UDim2.new(1, 0, 0, itemHeight), BackgroundColor3 = Theme.Surface,
                BackgroundTransparency = 0.3, Text = "", ZIndex = 52, Parent = listContent,
            })
            Util.AddCorner(itemBtn, UDim.new(0, 5))
            Util.Create("TextLabel", {
                Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1, Text = tostring(item),
                TextColor3 = (item == selected) and Theme.AccentSecondary or Theme.TextPrimary,
                TextSize = 12, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53, Parent = itemBtn,
            })
            itemBtn.MouseEnter:Connect(function() Util.Tween(itemBtn, { BackgroundColor3 = Theme.SurfaceHover, BackgroundTransparency = 0 }, Theme.TweenSpeedFast) end)
            itemBtn.MouseLeave:Connect(function() Util.Tween(itemBtn, { BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.3 }, Theme.TweenSpeedFast) end)
            itemBtn.MouseButton1Click:Connect(function()
                selected = item; selectedLabel.Text = tostring(item); callback(selected)
                isOpen = false
                Util.Tween(arrow, { Rotation = 0 }, Theme.TweenSpeedFast)
                Util.Tween(dropdownList, { Size = UDim2.new(1, 28, 0, 0) }, Theme.TweenSpeed)
                task.delay(Theme.TweenSpeed, function() dropdownList.Visible = false end)
                populateItems()
            end)
        end
        listContent.CanvasSize = UDim2.new(0, 0, 0, #items * (itemHeight + 1))
    end
    populateItems()

    selectBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            dropdownList.Visible = true
            local maxVisibleItems = math.min(#items, 5)
            local listHeight = maxVisibleItems * (itemHeight + 1) + 8
            Util.Tween(arrow, { Rotation = 180 }, Theme.TweenSpeedFast)
            Util.Tween(dropdownList, { Size = UDim2.new(1, 28, 0, listHeight) }, Theme.TweenSpeed)
        else
            Util.Tween(arrow, { Rotation = 0 }, Theme.TweenSpeedFast)
            Util.Tween(dropdownList, { Size = UDim2.new(1, 28, 0, 0) }, Theme.TweenSpeed)
            task.delay(Theme.TweenSpeed, function() dropdownList.Visible = false end)
        end
    end)
    selectBtn.MouseEnter:Connect(function() Util.Tween(selectBtn, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    selectBtn.MouseLeave:Connect(function() Util.Tween(selectBtn, { BackgroundColor3 = Theme.Surface }, Theme.TweenSpeedFast) end)

    local api = {}
    function api:Set(v) selected = v; selectedLabel.Text = tostring(v); callback(selected); populateItems() end
    function api:Get() return selected end
    function api:Refresh(newItems) items = newItems; populateItems() end
    return api
end

-- Progress Bar
function Tab:AddProgressBar(config)
    config = config or {}
    local name = config.Name or "Progress"
    local default = config.Default or 0
    local animated = config.Animated ~= false
    local progress = math.clamp(default, 0, 100)

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(0.6, 0, 0, 16),
        BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextPrimary,
        TextSize = 13, Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })

    local percentLabel = Util.Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 8),
        Size = UDim2.new(0.4, 0, 0, 16), BackgroundTransparency = 1,
        Text = tostring(math.floor(progress)) .. "%", TextColor3 = Theme.AccentSecondary,
        TextSize = 12, Font = Theme.FontMono, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 18, Parent = container,
    })

    local trackBg = Util.Create("Frame", {
        Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.Divider, ZIndex = 18, Parent = container,
    })
    Util.AddCorner(trackBg, UDim.new(1, 0))

    local fill = Util.Create("Frame", {
        Size = UDim2.new(progress / 100, 0, 1, 0), BackgroundColor3 = Theme.AccentPrimary,
        ZIndex = 19, Parent = trackBg,
    })
    Util.AddCorner(fill, UDim.new(1, 0))
    Util.AddGradient(fill, Theme.AccentPrimary, Theme.AccentSecondary, 0)

    if animated then
        local progressShimmer = Util.Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.4, 0.3),
                NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.6, 0.3),
                NumberSequenceKeypoint.new(1, 0.3),
            }),
            Parent = fill,
        })
        task.spawn(function()
            while fill and fill.Parent do
                progressShimmer.Offset = Vector2.new(-1, 0)
                Util.Tween(progressShimmer, { Offset = Vector2.new(1, 0) }, 1.5, Enum.EasingStyle.Linear)
                task.wait(2)
            end
        end)
    end

    local api = {}
    function api:Set(v)
        progress = math.clamp(v, 0, 100)
        Util.Tween(fill, { Size = UDim2.new(progress / 100, 0, 1, 0) }, 0.4)
        percentLabel.Text = tostring(math.floor(progress)) .. "%"
    end
    function api:Get() return progress end
    function api:Increment(amount) api:Set(progress + (amount or 1)) end
    return api
end

-- Button
function Tab:AddButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end

    local container = Util.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        Text = "", ZIndex = 17, ClipsDescendants = true, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)

    Util.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontBody, ZIndex = 18, Parent = container,
    })

    container.MouseButton1Click:Connect(function()
        Util.Ripple(container, Mouse.X - container.AbsolutePosition.X, Mouse.Y - container.AbsolutePosition.Y)
        callback()
    end)
    container.MouseEnter:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.SurfaceHover }, Theme.TweenSpeedFast) end)
    container.MouseLeave:Connect(function() Util.Tween(container, { BackgroundColor3 = Theme.Card }, Theme.TweenSpeedFast) end)
end

-- Label
function Tab:AddLabel(config)
    config = config or {}
    local text = config.Text or "Label"
    local label = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Text = text, TextColor3 = Theme.TextSecondary, TextSize = 12,
        Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 17, Parent = self._page,
    })
    local api = {}
    function api:Set(v) label.Text = v end
    return api
end

-- Textbox
function Tab:AddTextbox(config)
    config = config or {}
    local name = config.Name or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local callback = config.Callback or function() end

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Size = UDim2.new(0.35, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })

    local inputBox = Util.Create("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.6, 0, 0, 28), BackgroundColor3 = Theme.Surface,
        Text = "", PlaceholderText = placeholder, PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.TextPrimary, TextSize = 12, Font = Theme.FontBody,
        ClearTextOnFocus = false, ZIndex = 19, Parent = container,
    })
    Util.AddCorner(inputBox, UDim.new(0, 6))
    Util.AddStroke(inputBox, Theme.CardBorder, 1, 0.6)
    Util.AddPadding(inputBox, 0, 0, 8, 8)

    local inputStroke = inputBox:FindFirstChildOfClass("UIStroke")
    inputBox.Focused:Connect(function()
        if inputStroke then Util.Tween(inputStroke, { Color = Theme.AccentPrimary, Transparency = 0.2 }, Theme.TweenSpeedFast) end
    end)
    inputBox.FocusLost:Connect(function(enterPressed)
        if inputStroke then Util.Tween(inputStroke, { Color = Theme.CardBorder, Transparency = 0.6 }, Theme.TweenSpeedFast) end
        if enterPressed then callback(inputBox.Text) end
    end)

    local api = {}
    function api:Set(v) inputBox.Text = v end
    function api:Get() return inputBox.Text end
    return api
end

-- Keybind
function Tab:AddKeybind(config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local onChanged = config.OnChanged or function() end
    local currentKey = default
    local listening = false

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        ZIndex = 17, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18, Parent = container,
    })

    local keyBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 26), BackgroundColor3 = Theme.Surface,
        Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
        TextColor3 = Theme.AccentSecondary, TextSize = 12, Font = Theme.FontMono,
        ZIndex = 19, Parent = container,
    })
    Util.AddCorner(keyBtn, UDim.new(0, 6))
    Util.AddStroke(keyBtn, Theme.CardBorder, 1, 0.6)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true; keyBtn.Text = "..."
        Util.Tween(keyBtn, { BackgroundColor3 = Theme.AccentPrimary }, Theme.TweenSpeedFast)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not listening then
            if input.KeyCode == currentKey and not processed then callback() end
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode; keyBtn.Text = currentKey.Name; listening = false
            Util.Tween(keyBtn, { BackgroundColor3 = Theme.Surface }, Theme.TweenSpeedFast)
            onChanged(currentKey)
        end
    end)

    local api = {}
    function api:Set(key) currentKey = key; keyBtn.Text = key.Name; onChanged(currentKey) end
    function api:Get() return currentKey end
    return api
end

-- Color Picker
function Tab:AddColorPicker(config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Color3.fromRGB(120, 80, 255)
    local callback = config.Callback or function() end
    local currentColor = default
    local isOpen = false

    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight), BackgroundColor3 = Theme.Card,
        ClipsDescendants = false, ZIndex = 25, Parent = self._page,
    })
    Util.AddCorner(container); Util.AddStroke(container, Theme.CardBorder, 1, 0.7)
    Util.AddPadding(container, 0, 0, 14, 14)

    Util.Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.TextPrimary, TextSize = 13,
        Font = Theme.FontBody, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 26, Parent = container,
    })

    local swatch = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 22), BackgroundColor3 = currentColor,
        Text = "", ZIndex = 27, Parent = container,
    })
    Util.AddCorner(swatch, UDim.new(0, 5))
    Util.AddStroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.8)

    local pickerPanel = Util.Create("Frame", {
        Position = UDim2.new(0, -14, 1, 4), Size = UDim2.new(1, 28, 0, 0),
        BackgroundColor3 = Theme.Surface, ClipsDescendants = true,
        Visible = false, ZIndex = 60, Parent = container,
    })
    Util.AddCorner(pickerPanel, UDim.new(0, 8))
    Util.AddStroke(pickerPanel, Theme.AccentPrimary, 1, 0.7)

    local presetColors = {
        Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 150, 50),
        Color3.fromRGB(255, 230, 50), Color3.fromRGB(50, 230, 80),
        Color3.fromRGB(50, 200, 255), Color3.fromRGB(120, 80, 255),
        Color3.fromRGB(255, 60, 170), Color3.fromRGB(255, 255, 255),
    }

    local presetGrid = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ZIndex = 61, Parent = pickerPanel,
    })
    Util.AddPadding(presetGrid, 10, 10, 10, 10)
    Util.Create("UIGridLayout", { CellSize = UDim2.fromOffset(28, 28), CellPadding = UDim2.fromOffset(6, 6), Parent = presetGrid })

    for _, color in ipairs(presetColors) do
        local colorBtn = Util.Create("TextButton", {
            Size = UDim2.fromOffset(28, 28), BackgroundColor3 = color,
            Text = "", ZIndex = 62, Parent = presetGrid,
        })
        Util.AddCorner(colorBtn, UDim.new(1, 0))
        Util.AddStroke(colorBtn, Color3.fromRGB(255, 255, 255), 1, 0.85)
        colorBtn.MouseButton1Click:Connect(function()
            currentColor = color; swatch.BackgroundColor3 = color; callback(color)
        end)
        colorBtn.MouseEnter:Connect(function() Util.Tween(colorBtn, { Size = UDim2.fromOffset(30, 30) }, 0.1) end)
        colorBtn.MouseLeave:Connect(function() Util.Tween(colorBtn, { Size = UDim2.fromOffset(28, 28) }, 0.1) end)
    end

    swatch.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            pickerPanel.Visible = true
            Util.Tween(pickerPanel, { Size = UDim2.new(1, 28, 0, 52) }, Theme.TweenSpeed)
        else
            Util.Tween(pickerPanel, { Size = UDim2.new(1, 28, 0, 0) }, Theme.TweenSpeed)
            task.delay(Theme.TweenSpeed, function() pickerPanel.Visible = false end)
        end
    end)

    local api = {}
    function api:Set(c) currentColor = c; swatch.BackgroundColor3 = c; callback(c) end
    function api:Get() return currentColor end
    return api
end

-- Divider
function Tab:AddDivider()
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0, ZIndex = 17, Parent = self._page,
    })
end

-- ══════════════════════════════════════════════════════════════
-- RETURN LIBRARY
-- ══════════════════════════════════════════════════════════════
return Rolex
