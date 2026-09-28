--[[
    RVX HUB - CORE V3
    Centralized UI / Appearance / Controls / Config system

    Main responsibilities:
      • One WindUI instance for every RVX game module
      • RVX Purple -> Pink visual identity
      • Real LocalPlayer profile
      • Home / Dashboard
      • Appearance controls
      • Keybind controls
      • Notification controls
      • Performance controls
      • Config manager
      • Module / game information
      • Safe API wrappers so optional WindUI features do not hard-crash the hub

    Game modules should ONLY receive:
        local Window, WindUI = Core.Init(mapName)

    Then create their own game-specific tabs on Window.
]]

local Core = {}

-- ============================================================
-- SERVICES
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- WINDUI
-- ============================================================

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ============================================================
-- RVX BRAND
-- ============================================================

local RVX = {
    Purple       = "#8B5CF6",
    PurpleDark   = "#24103D",
    PurpleDeep   = "#100914",
    Pink         = "#FF3D9A",
    PinkLight    = "#FF77BE",
    Magenta      = "#D946EF",

    ThemeAccent  = "#7C3AED",
    ThemeDialog  = "#21132F",
    ThemeOutline = "#F0B7FF",
    ThemeText    = "#FFFFFF",
    ThemeMuted   = "#BDA9CA",
    ThemeBG      = "#100914",
    ThemeButton  = "#9D3DDB",
    ThemeIcon    = "#F09CFF",
}

local VERSION = "Version 1"

-- ============================================================
-- DEFAULTS
-- ============================================================

local DEFAULTS = {
    Theme = "Crimson",

    Transparency = 0.08,
    BackgroundImageTransparency = 1,
    PanelBackground = Color3.fromRGB(18, 12, 24),
    PanelBackgroundEnabled = true,

    ToggleKey = "RightShift",

    OpenButton = true,
    OpenButtonScale = 0.50,

    Notifications = true,
    NotificationDuration = 3,

    ReducedAnimation = false,
    LowPerformanceMode = false,

    CompactMode = false,
}

-- ============================================================
-- STATE
-- ============================================================

local State = {
    MapName = "RVX Hub",
    Window = nil,

    AntiAFKEnabled = false,
    AntiAFKConnection = nil,

    ConfigManager = nil,
    Config = nil,

    NotificationsEnabled = DEFAULTS.Notifications,
    NotificationDuration = DEFAULTS.NotificationDuration,

    ReducedAnimation = DEFAULTS.ReducedAnimation,
    LowPerformanceMode = DEFAULTS.LowPerformanceMode,
}

-- ============================================================
-- SAFE HELPERS
-- ============================================================

local function safeCall(callback, ...)
    local ok, result = pcall(callback, ...)
    if ok then
        return true, result
    end

    warn("[RVX Hub Core] " .. tostring(result))
    return false, nil
end

local function safeNotify(title, content, duration, icon)
    if not State.NotificationsEnabled then
        return
    end

    safeCall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or State.NotificationDuration or 3,
            Icon = icon or "sparkles",
        })
    end)
end

local function isEnumKey(value)
    return typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode
end

local function normalizeKey(value)
    if isEnumKey(value) then
        return value.Name
    end

    local name = tostring(value or DEFAULTS.ToggleKey)

    if Enum.KeyCode[name] then
        return name
    end

    return DEFAULTS.ToggleKey
end

local function getPlayerDisplay()
    if not LocalPlayer then
        return "Player"
    end

    return LocalPlayer.DisplayName or LocalPlayer.Name
end

local function getPlayerUsername()
    if not LocalPlayer then
        return "Unknown"
    end

    return "@" .. tostring(LocalPlayer.Name)
end

local function getDeviceName()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    end

    if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "Console"
    end

    return "PC"
end

local function getExecutorName()
    local ok, executor = pcall(function()
        if identifyexecutor then
            return identifyexecutor()
        end

        return "Unknown"
    end)

    if ok and executor then
        return tostring(executor)
    end

    return "Unknown"
end

-- ============================================================
-- ANTI-AFK
-- ============================================================

local function setAntiAFK(enabled)
    State.AntiAFKEnabled = enabled == true

    if State.AntiAFKConnection then
        pcall(function()
            State.AntiAFKConnection:Disconnect()
        end)
        State.AntiAFKConnection = nil
    end

    if not State.AntiAFKEnabled or not LocalPlayer then
        return
    end

    State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        if not State.AntiAFKEnabled then
            return
        end

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ============================================================
-- CUSTOM THEME
-- ============================================================

safeCall(function()
    local themes = WindUI:GetThemes()

    if not themes["RVX Purple Pink"] then
        WindUI:AddTheme({
            Name = "RVX Purple Pink",

            Accent = RVX.ThemeAccent,
            Dialog = RVX.ThemeDialog,
            Outline = RVX.ThemeOutline,
            Text = RVX.ThemeText,
            Placeholder = RVX.ThemeMuted,
            Background = RVX.ThemeBG,
            Button = RVX.ThemeButton,
            Icon = RVX.ThemeIcon,
            PanelBackground = Color3.fromRGB(18, 12, 24),
        })
    end
end)

-- ============================================================
-- THEME / OPEN BUTTON HELPERS
-- ============================================================

local function asColor3(value, fallback)
    if typeof(value) == "Color3" then
        return value
    end

    if type(value) == "string" then
        local ok, color = pcall(function()
            return Color3.fromHex(value)
        end)

        if ok and color then
            return color
        end
    end

    return fallback
end

local function getThemeButtonColors(themeName)
    local fallbackA = Color3.fromHex("#DC143C")
    local fallbackB = Color3.fromHex("#FF4D6D")

    local ok, themes = pcall(function()
        return WindUI:GetThemes()
    end)

    if not ok or type(themes) ~= "table" then
        return fallbackA, fallbackB
    end

    local theme = themes[themeName]
    if type(theme) ~= "table" then
        return fallbackA, fallbackB
    end

    local accent = asColor3(theme.Accent, fallbackA)
    local button = asColor3(theme.Button, accent)

    return accent, button
end

local function updateOpenButtonTheme(Window, themeName)
    local accent, button = getThemeButtonColors(themeName)

    safeCall(function()
        Window:EditOpenButton({
            CornerRadius = UDim.new(0, 14),
            Color = ColorSequence.new(accent, button),
        })
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================

function Core.Init(mapName)
    mapName = mapName or "RVX Hub"

    State.MapName = tostring(mapName)

    -- Prevent accidental duplicate Core windows if Init is called twice.
    if State.Window then
        return State.Window, WindUI
    end

    -- --------------------------------------------------------
    -- WINDOW
    -- --------------------------------------------------------

    local Window = WindUI:CreateWindow({
        Title = "RVX Hub",

        -- RVX HUB cover/logo shown at the top-left of the window.
        Icon = "rbxassetid://95844711546407",
        IconSize = 38,

        Author = State.MapName,

        Folder = "RVXHub",

        Size = UDim2.fromOffset(700, 520),

        Transparent = true,

        -- ปิดภาพพื้นหลังใหญ่ของ RVX Hub
        Background = "",
        BackgroundImageTransparency = 1,

        Theme = DEFAULTS.Theme,

        NewElements = true,

        HideSearchBar = false,

        OpenButton = {
            Title = "เปิด RVX Hub",

            CornerRadius = UDim.new(0, 14),

            StrokeThickness = 2,

            Enabled = DEFAULTS.OpenButton,

            Draggable = true,

            OnlyMobile = false,

            Scale = DEFAULTS.OpenButtonScale,

            Color = ColorSequence.new(
                Color3.fromHex("#DC143C"),
                Color3.fromHex("#FF4D6D")
            ),
        },

        -- WindUI uses the LocalPlayer for this profile.
        -- Anonymous=false tells it to show the actual account.
        User = {
            Enabled = true,
            Anonymous = false,
        },
    })

    if not Window then
        error("[RVX Hub Core] Failed to create WindUI window")
    end

    State.Window = Window

    -- --------------------------------------------------------
    -- INITIAL WINDOW STATE
    -- --------------------------------------------------------

    -- Theme is already applied by CreateWindow({ Theme = DEFAULTS.Theme }).
    -- Do not call SetTheme() a second time here; newer WindUI builds can
    -- re-apply theme properties during startup and emit a TextColor3 type warning.

    updateOpenButtonTheme(Window, DEFAULTS.Theme)

    safeCall(function()
        Window:SetBackgroundTransparency(DEFAULTS.Transparency)
    end)

    safeCall(function()
        Window:SetBackgroundImageTransparency(DEFAULTS.BackgroundImageTransparency)
    end)

    -- Panel background is controlled by the selected WindUI theme.
    -- Do not pass a boolean to SetPanelBackground; some WindUI builds
    -- expect a Color3 and will throw a TextColor3 type warning.

    safeCall(function()
        Window:SetToggleKey(Enum.KeyCode[DEFAULTS.ToggleKey])
    end)

    safeCall(function()
        Window:EditOpenButton({
            Enabled = DEFAULTS.OpenButton,
        })
    end)

    -- --------------------------------------------------------
    -- BRAND TAGS
    -- --------------------------------------------------------

    safeCall(function()
        Window:Tag({
            Title = "RVX",
            Radius = 8,

            Color = WindUI:Gradient({
                ["0"] = {
                    Color = Color3.fromHex(RVX.Purple),
                    Transparency = 0,
                },

                ["100"] = {
                    Color = Color3.fromHex(RVX.Pink),
                    Transparency = 0,
                },
            }, {
                Rotation = 45,
            }),
        })
    end)

    safeCall(function()
        Window:Tag({
            Title = VERSION,
            Radius = 8,
            Color = Color3.fromHex(RVX.Magenta),
        })
    end)

    -- Discord shortcut: click the topbar Discord button to copy the invite link.
    safeCall(function()
        Window:CreateTopbarButton("rvx-discord", "message-circle", function()
            local copied = pcall(function()
                if setclipboard then
                    setclipboard("https://discord.gg/WQePykh3yJ")
                elseif toclipboard then
                    toclipboard("https://discord.gg/WQePykh3yJ")
                elseif set_clipboard then
                    set_clipboard("https://discord.gg/WQePykh3yJ")
                else
                    error("Clipboard API unavailable")
                end
            end)

            if copied then
                safeNotify(
                    "Discord",
                    "คัดลอกลิงก์ Discord แล้ว",
                    2,
                    "copy"
                )
            else
                safeNotify(
                    "Discord",
                    "ไม่สามารถคัดลอกลิงก์ได้ใน Executor นี้",
                    3,
                    "circle-alert"
                )
            end
        end, 995)
    end)

    -- ========================================================
    -- SECTIONS
    -- ========================================================

    local HomeSection = Window:Section({
        Title = "RVX HUB",
        Opened = true,
    })

    -- กลุ่มแมพ/ฟังก์ชันเกมจะอยู่ตรงกลางระหว่างหน้าหลักกับการตั้งค่า
    -- Game modules สามารถใช้ Window.RVXGameSection เพื่อเพิ่มแท็บของตัวเองได้
    local GameSection = Window:Section({
        -- ฟังก์ชันของแมพทั้งหมดจะรวมอยู่ตรงกลางของ Sidebar
        -- Game modules ควรใช้ Window.RVXGameSection แทนการสร้าง Section ใหม่
        Title = "แมพ",
        Opened = true,
    })

    local SettingsSection = Window:Section({
        Title = "การตั้งค่า",
        Opened = true,
    })

    local UtilitiesSection = Window:Section({
        Title = "เครื่องมือ",
        Opened = true,
    })

    -- เปิดให้ Game Modules ใช้กลุ่มแมพเดียวกัน
    Window.RVXGameSection = GameSection

    -- ========================================================
    -- HOME
    -- ========================================================

    local HomeTab = HomeSection:Tab({
        Title = "หน้าหลัก",
        Icon = "house",
        Desc = "หน้าหลักของ RVX Hub",
    })

    HomeTab:Paragraph({
        Title = "ยินดีต้อนรับสู่ RVX Hub",
        Desc =
            "Welcome back, " ..
            getPlayerDisplay() ..
            "\\n" ..
            getPlayerUsername() ..
            "\\n\\n" ..
            "แมพปัจจุบัน: " ..
            State.MapName,

        Image = "sparkles",
        ImageSize = 24,
        Color = Color3.fromHex(RVX.Pink),
    })

    HomeTab:Section({
        Title = "เซสชัน",
        TextSize = 18,
    })

    HomeTab:Paragraph({
        Title = "พร้อมใช้งาน",
        Desc = "RVX Hub Core ทำงานอยู่ • เมนูของแมพจะอยู่ในหมวด \"แมพ\" ตรงกลาง",
        Image = "circle-check",
        ImageSize = 20,
        Color = Color3.fromHex("#8AFFC1"),
    })

    HomeTab:Paragraph({
        Title = "แมพ",
        Desc = State.MapName,
        Image = "gamepad-2",
        ImageSize = 20,
        Color = Color3.fromHex(RVX.Purple),
    })

    HomeTab:Paragraph({
        Title = "ผู้เล่น",
        Desc =
            getPlayerDisplay() ..
            "\\n" ..
            getPlayerUsername(),
        Image = "user-round",
        ImageSize = 20,
        Color = Color3.fromHex(RVX.Pink),
    })

    HomeTab:Paragraph({
        Title = "อุปกรณ์",
        Desc = getDeviceName(),
        Image = "monitor",
        ImageSize = 20,
        Color = Color3.fromHex(RVX.Magenta),
    })

    HomeTab:Paragraph({
        Title = "เอ็กซีคิวเตอร์",
        Desc = getExecutorName(),
        Image = "cpu",
        ImageSize = 20,
        Color = Color3.fromHex(RVX.Purple),
    })

    HomeTab:Section({
        Title = "สถานะ RVX",
        TextSize = 18,
    })

    HomeTab:Paragraph({
        Title = "สถานะ Core",
        Desc =
            "● Core โหลดแล้ว\\n" ..
            "● WindUI พร้อมใช้งาน\\n" ..
            "● โมดูลแมพ: " .. State.MapName,

        Image = "activity",
        ImageSize = 20,
        Color = Color3.fromHex("#8AFFC1"),
    })

    HomeTab:Button({
        Title = "รีเฟรชข้อมูลผู้เล่น",
        Desc = "อัปเดตข้อมูลโปรไฟล์บนหน้าหลัก",
        Icon = "refresh-cw",

        Callback = function()
            safeNotify(
                "RVX Hub",
                getPlayerDisplay() .. " • " .. getPlayerUsername(),
                3,
                "user-round"
            )
        end,
    })

    -- ========================================================
    -- APPEARANCE
    -- ========================================================

    local AppearanceTab = SettingsSection:Tab({
        Title = "หน้าตา",
        Icon = "palette",
        Desc = "ปรับหน้าตา RVX Hub",
    })

    AppearanceTab:Paragraph({
        Title = "RVX Purple Pink",
        Desc = "เอกลักษณ์หลักของ RVX Hub • Purple → Pink",
        Image = "palette",
        ImageSize = 22,
        Color = Color3.fromHex(RVX.Pink),
    })

    AppearanceTab:Section({
        Title = "ธีม",
        TextSize = 18,
    })

    local themeNames = {}

    safeCall(function()
        for themeName in pairs(WindUI:GetThemes()) do
            table.insert(themeNames, themeName)
        end
    end)

    table.sort(themeNames)

    local ThemeDropdown = AppearanceTab:Dropdown({
        Title = "ธีม",
        Desc = "เลือกธีมของ WindUI",
        Values = themeNames,
        Value = DEFAULTS.Theme,
        SearchBarEnabled = true,
        Flag = "RVX_THEME",

        Callback = function(theme)
            if type(theme) ~= "string" then
                return
            end

            safeCall(function()
                WindUI:SetTheme(theme)
            end)

            updateOpenButtonTheme(Window, theme)

            safeNotify(
                "Theme Changed",
                "ใช้ธีม: " .. theme,
                2,
                "palette"
            )
        end,
    })

    AppearanceTab:Slider({
        Title = "ความโปร่งใสของ UI",
        Desc = "ปรับความโปร่งใสของหน้าต่าง",
        Step = 0.05,

        Value = {
            Min = 0,
            Max = 0.50,
            Default = DEFAULTS.Transparency,
        },

        Flag = "RVX_TRANSPARENCY",

        Callback = function(value)
            local transparency = tonumber(value)

            if not transparency then
                return
            end

            safeCall(function()
                Window:SetBackgroundTransparency(transparency)
            end)

            safeCall(function()
                Window:SetBackgroundImageTransparency(transparency)
            end)
        end,
    })

    AppearanceTab:Toggle({
        Title = "พื้นหลัง Panel",
        Desc = "เปิด / ปิดพื้นหลังของ Panel",
        Value = DEFAULTS.PanelBackgroundEnabled,
        Flag = "RVX_PANEL_BACKGROUND",

        Callback = function(state)
            -- Some WindUI releases expose SetPanelBackground as a Color3 API.
            -- Use the theme's PanelBackground color instead of passing a boolean.
            local themes = WindUI:GetThemes()
            local theme = themes[DEFAULTS.Theme]
            local panelColor = theme and theme.PanelBackground

            if typeof(panelColor) ~= "Color3" then
                panelColor = DEFAULTS.PanelBackground
            end

            safeCall(function()
                Window:SetPanelBackground(state)
            end)
        end,
    })

    AppearanceTab:Toggle({
        Title = "โหมดกระชับ",
        Desc = "ลดขนาด UI สำหรับหน้าจอเล็ก",
        Value = DEFAULTS.CompactMode,
        Flag = "RVX_COMPACT",

        Callback = function(state)
            -- Kept as a preference flag for future centralized layout work.
            -- Game modules do not need to know about this setting.
            safeNotify(
                "Compact Mode",
                state and "เปิดโหมดกระชับ" or "ปิดโหมดกระชับ",
                2,
                "layout-dashboard"
            )
        end,
    })

    -- ========================================================
    -- CONTROLS
    -- ========================================================

    local ControlsTab = SettingsSection:Tab({
        Title = "การควบคุม",
        Icon = "keyboard",
        Desc = "ปุ่มลัดและการควบคุม UI",
    })

    ControlsTab:Paragraph({
        Title = "เปิด / ปิด UI",
        Desc = "ตั้งปุ่มสำหรับเปิด / ปิด RVX Hub",
        Image = "keyboard",
        ImageSize = 22,
        Color = Color3.fromHex(RVX.Purple),
    })

    local ToggleKeyElement = ControlsTab:Keybind({
        Title = "ปุ่มเปิด / ปิด UI",
        Desc = "กดปุ่มที่ต้องการเพื่อตั้งปุ่มลัด",
        Value = DEFAULTS.ToggleKey,
        Flag = "RVX_TOGGLE_KEY",

        Callback = function(value)
            local keyName = normalizeKey(value)
            local keyCode = Enum.KeyCode[keyName]

            if not keyCode then
                keyName = DEFAULTS.ToggleKey
                keyCode = Enum.KeyCode[keyName]
            end

            safeCall(function()
                Window:SetToggleKey(keyCode)
            end)

            safeNotify(
                "Shortcut Updated",
                "ปุ่มเปิด/ปิด UI: " .. keyName,
                2,
                "keyboard"
            )
        end,
    })

    ControlsTab:Toggle({
        Title = "ปุ่มเปิดแบบลอย",
        Desc = "แสดงปุ่มลอยสำหรับเปิด UI",
        Value = DEFAULTS.OpenButton,
        Flag = "RVX_OPEN_BUTTON",

        Callback = function(state)
            safeCall(function()
                Window:EditOpenButton({
                    Enabled = state,
                })
            end)
        end,
    })

    ControlsTab:Slider({
        Title = "ขนาดปุ่มเปิด",
        Desc = "ปรับขนาดปุ่มลอย",
        Step = 0.05,

        Value = {
            Min = 0.35,
            Max = 0.80,
            Default = DEFAULTS.OpenButtonScale,
        },

        Flag = "RVX_OPEN_BUTTON_SCALE",

        Callback = function(value)
            local scale = tonumber(value)

            if not scale then
                return
            end

            safeCall(function()
                Window:EditOpenButton({
                    Scale = scale,
                })
            end)
        end,
    })

    ControlsTab:Button({
        Title = "รีเซ็ตปุ่มลัด",
        Desc = "กลับไปใช้ RightShift",
        Icon = "rotate-ccw",

        Callback = function()
            safeCall(function()
                Window:SetToggleKey(Enum.KeyCode.RightShift)
            end)

            safeCall(function()
                ToggleKeyElement:Set("RightShift")
            end)

            safeNotify(
                "Shortcut Reset",
                "กลับไปใช้ RightShift แล้ว",
                2,
                "keyboard"
            )
        end,
    })

    -- ========================================================
    -- NOTIFICATIONS
    -- ========================================================

    local NotificationTab = SettingsSection:Tab({
        Title = "การแจ้งเตือน",
        Icon = "bell",
        Desc = "ตั้งค่าการแจ้งเตือน",
    })

    NotificationTab:Toggle({
        Title = "เปิดการแจ้งเตือน",
        Desc = "เปิด / ปิดข้อความแจ้งเตือนจาก RVX Core",
        Value = DEFAULTS.Notifications,
        Flag = "RVX_NOTIFICATIONS",

        Callback = function(state)
            State.NotificationsEnabled = state

            if state then
                safeNotify(
                    "Notifications",
                    "เปิดการแจ้งเตือนแล้ว",
                    2,
                    "bell"
                )
            end
        end,
    })

    NotificationTab:Slider({
        Title = "ระยะเวลาการแจ้งเตือน",
        Desc = "กำหนดระยะเวลาแสดงการแจ้งเตือน",
        Step = 0.5,

        Value = {
            Min = 1,
            Max = 8,
            Default = DEFAULTS.NotificationDuration,
        },

        Flag = "RVX_NOTIFICATION_DURATION",

        Callback = function(value)
            State.NotificationDuration = tonumber(value) or 3
        end,
    })

    NotificationTab:Button({
        Title = "ทดสอบการแจ้งเตือน",
        Desc = "ทดสอบรูปแบบ Notification",
        Icon = "bell-ring",

        Callback = function()
            safeNotify(
                "RVX Hub",
                "ระบบแจ้งเตือนทำงานปกติ",
                State.NotificationDuration,
                "sparkles"
            )
        end,
    })

    -- ========================================================
    -- PERFORMANCE
    -- ========================================================

    local PerformanceTab = SettingsSection:Tab({
        Title = "ประสิทธิภาพ",
        Icon = "gauge",
        Desc = "ตั้งค่าการใช้ทรัพยากรของ UI",
    })

    PerformanceTab:Paragraph({
        Title = "โหมดประสิทธิภาพ",
        Desc =
            "การตั้งค่านี้ควบคุมเฉพาะ UI Core\\n" ..
            "ไม่แก้ระบบฟีเจอร์ของแต่ละเกม",

        Image = "gauge",
        ImageSize = 22,
        Color = Color3.fromHex(RVX.Purple),
    })

    PerformanceTab:Toggle({
        Title = "ลดแอนิเมชัน",
        Desc = "ลดเอฟเฟกต์เคลื่อนไหวของ UI",
        Value = DEFAULTS.ReducedAnimation,
        Flag = "RVX_REDUCED_ANIMATION",

        Callback = function(state)
            State.ReducedAnimation = state

            safeNotify(
                "Performance",
                state and "ลด Animation แล้ว" or "เปิด Animation ตามปกติ",
                2,
                "gauge"
            )
        end,
    })

    PerformanceTab:Toggle({
        Title = "โหมดประหยัดทรัพยากร",
        Desc = "ลดภาระการทำงานของ UI สำหรับเครื่องที่ต้องการ",
        Value = DEFAULTS.LowPerformanceMode,
        Flag = "RVX_LOW_PERFORMANCE",

        Callback = function(state)
            State.LowPerformanceMode = state

            if state then
                State.ReducedAnimation = true
            end

            safeNotify(
                "Performance Mode",
                state and "เปิด Low Performance Mode" or "ปิด Low Performance Mode",
                2,
                "cpu"
            )
        end,
    })

    PerformanceTab:Toggle({
        Title = "Anti-AFK",
        Desc = "ป้องกัน Roblox ตัดการเชื่อมต่อเมื่อไม่ได้ใช้งานนาน",
        Value = false,
        Flag = "RVX_ANTI_AFK",

        Callback = function(state)
            setAntiAFK(state)

            safeNotify(
                "Anti-AFK",
                state and "เปิด Anti-AFK แล้ว" or "ปิด Anti-AFK แล้ว",
                2,
                state and "shield-check" or "shield-off"
            )
        end,
    })

    PerformanceTab:Button({
        Title = "สถานะประสิทธิภาพ",
        Desc = "ดูสถานะการทำงานของ Core",
        Icon = "activity",

        Callback = function()
            safeNotify(
                "RVX Performance",
                "Device: " .. getDeviceName() ..
                "\\nExecutor: " .. getExecutorName() ..
                "\\nReduced Animation: " .. tostring(State.ReducedAnimation) ..
                "\\nLow Performance: " .. tostring(State.LowPerformanceMode),
                4,
                "activity"
            )
        end,
    })

    -- ========================================================
    -- CONFIGURATION
    -- ========================================================

    local ConfigTab = UtilitiesSection:Tab({
        Title = "การตั้งค่า Config",
        Icon = "save",
        Desc = "บันทึกและโหลดการตั้งค่า",
    })

    ConfigTab:Paragraph({
        Title = "การตั้งค่า RVX",
        Desc =
            "WindUI Config Manager จะเก็บค่าของ Elements ที่มี Flag\\n" ..
            "เช่น Theme, Transparency, Keybind และ Toggle",

        Image = "save",
        ImageSize = 22,
        Color = Color3.fromHex(RVX.Pink),
    })

    local ConfigManager = Window.ConfigManager

    if ConfigManager then
        State.ConfigManager = ConfigManager

        safeCall(function()
            ConfigManager:Init(Window)
        end)

        local configName = "RVX_UI"

        local ConfigNameInput = ConfigTab:Input({
            Title = "ชื่อ Config",
            Desc = "ชื่อไฟล์ Config",
            Value = configName,
            Placeholder = "RVX_UI",
            Flag = "RVX_CONFIG_NAME",

            Callback = function(value)
                if value and tostring(value) ~= "" then
                    configName = tostring(value)
                end
            end,
        })

        local function getConfigs()
            local result = {}

            safeCall(function()
                result = ConfigManager:AllConfigs()
            end)

            return result or {}
        end

        local ConfigDropdown = ConfigTab:Dropdown({
            Title = "Config ที่บันทึกไว้",
            Desc = "เลือก Config ที่มีอยู่",
            Values = getConfigs(),
            SearchBarEnabled = true,

            Callback = function(value)
                if value then
                    configName = tostring(value)

                    safeCall(function()
                        ConfigNameInput:Set(configName)
                    end)
                end
            end,
        })

        ConfigTab:Button({
            Title = "บันทึก Config",
            Desc = "บันทึกค่าการตั้งค่า UI ปัจจุบัน",
            Icon = "save",

            Callback = function()
                if configName == "" then
                    configName = "RVX_UI"
                end

                local config

                local ok = pcall(function()
                    config = ConfigManager:CreateConfig(configName)
                end)

                if not ok or not config then
                    safeNotify(
                        "Config Error",
                        "ไม่สามารถสร้าง Config ได้",
                        3,
                        "circle-alert"
                    )
                    return
                end

                local saved = false

                pcall(function()
                    saved = config:Save() == true
                end)

                if saved then
                    safeNotify(
                        "Config Saved",
                        "บันทึก: " .. configName,
                        3,
                        "check"
                    )

                    safeCall(function()
                        ConfigDropdown:Refresh(ConfigManager:AllConfigs())
                    end)
                else
                    safeNotify(
                        "Config Error",
                        "บันทึก Config ไม่สำเร็จ",
                        3,
                        "circle-alert"
                    )
                end
            end,
        })

        ConfigTab:Button({
            Title = "โหลด Config",
            Desc = "โหลดค่าการตั้งค่าที่บันทึกไว้",
            Icon = "folder-open",

            Callback = function()
                if configName == "" then
                    configName = "RVX_UI"
                end

                local config

                local ok = pcall(function()
                    config = ConfigManager:CreateConfig(configName)
                end)

                if not ok or not config then
                    safeNotify(
                        "Config Error",
                        "ไม่สามารถเปิด Config ได้",
                        3,
                        "circle-alert"
                    )
                    return
                end

                local loaded = false

                pcall(function()
                    loaded = config:Load() == true
                end)

                if loaded then
                    State.Config = config

                    safeNotify(
                        "Config Loaded",
                        "โหลด: " .. configName,
                        3,
                        "refresh-cw"
                    )
                else
                    safeNotify(
                        "Config Error",
                        "ไม่พบหรือโหลด Config ไม่สำเร็จ",
                        3,
                        "circle-alert"
                    )
                end
            end,
        })

        ConfigTab:Button({
            Title = "รีเฟรชรายการ Config",
            Desc = "อัปเดตรายการ Config",
            Icon = "refresh-cw",

            Callback = function()
                safeCall(function()
                    ConfigDropdown:Refresh(ConfigManager:AllConfigs())
                end)

                safeNotify(
                    "Config",
                    "อัปเดตรายการแล้ว",
                    2,
                    "refresh-cw"
                )
            end,
        })

        State.Config = ConfigManager:CreateConfig("RVX_UI", true)
    else
        ConfigTab:Paragraph({
            Title = "Config Manager ไม่พร้อมใช้งาน",
            Desc =
                "WindUI Config Manager ใช้งานไม่ได้ในสภาพแวดล้อมนี้\\n" ..
                "ส่วน UI อื่นยังทำงานตามปกติ",

            Image = "circle-alert",
            ImageSize = 22,
            Color = Color3.fromHex("#FFB4B4"),
        })
    end

    -- ========================================================
    -- MODULE / SYSTEM INFO
    -- ========================================================

    local InfoTab = UtilitiesSection:Tab({
        Title = "ระบบ",
        Icon = "info",
        Desc = "ข้อมูล RVX Hub",
    })

    InfoTab:Paragraph({
        Title = "ระบบหลัก RVX Hub",
        Desc =
            VERSION ..
            "\\nGame: " .. State.MapName ..
            "\\nPlayer: " .. getPlayerDisplay() ..
            "\\nDevice: " .. getDeviceName() ..
            "\\nExecutor: " .. getExecutorName(),

        Image = "info",
        ImageSize = 22,
        Color = Color3.fromHex(RVX.Pink),
    })

    InfoTab:Button({
        Title = "คัดลอก Game Job ID",
        Desc = "คัดลอก JobId ของ Server",
        Icon = "copy",

        Callback = function()
            local copied = false

            pcall(function()
                if setclipboard then
                    setclipboard(game.JobId)
                    copied = true
                end
            end)

            if copied then
                safeNotify(
                    "Copied",
                    "คัดลอก Job ID แล้ว",
                    2,
                    "copy"
                )
            else
                safeNotify(
                    "Clipboard",
                    "Executor นี้ไม่รองรับ setclipboard",
                    3,
                    "circle-alert"
                )
            end
        end,
    })

    InfoTab:Button({
        Title = "คัดลอก Place ID",
        Desc = "คัดลอก PlaceId ของเกม",
        Icon = "copy",

        Callback = function()
            local copied = false

            pcall(function()
                if setclipboard then
                    setclipboard(tostring(game.PlaceId))
                    copied = true
                end
            end)

            if copied then
                safeNotify(
                    "Copied",
                    "Place ID: " .. tostring(game.PlaceId),
                    2,
                    "copy"
                )
            else
                safeNotify(
                    "Clipboard",
                    "Executor นี้ไม่รองรับ setclipboard",
                    3,
                    "circle-alert"
                )
            end
        end,
    })

    InfoTab:Button({
        Title = "รีเซ็ต UI",
        Desc = "คืนค่าหน้าตาและปุ่มลัดเป็นค่าเริ่มต้น",
        Icon = "rotate-ccw",

        Callback = function()
            safeCall(function()
                WindUI:SetTheme(DEFAULTS.Theme)
            end)

            safeCall(function()
                Window:SetBackgroundTransparency(DEFAULTS.Transparency)
            end)

            safeCall(function()
                Window:SetBackgroundImageTransparency(DEFAULTS.BackgroundImageTransparency)
            end)

            updateOpenButtonTheme(Window, DEFAULTS.Theme)

            safeCall(function()
                Window:SetToggleKey(Enum.KeyCode.RightShift)
            end)

            safeCall(function()
                Window:EditOpenButton({
                    Enabled = DEFAULTS.OpenButton,
                    Scale = DEFAULTS.OpenButtonScale,
                })
            end)

            safeCall(function()
                ThemeDropdown:Select(DEFAULTS.Theme)
            end)

            safeCall(function()
                ToggleKeyElement:Set(DEFAULTS.ToggleKey)
            end)

            setAntiAFK(false)

            safeNotify(
                "RVX Hub",
                "คืนค่าการตั้งค่า UI แล้ว",
                3,
                "rotate-ccw"
            )
        end,
    })

    -- ========================================================
    -- AUTOSAVE ON CLOSE
    -- ========================================================

    safeCall(function()
        Window:OnClose(function()
            if State.Config and State.Config.Save then
                pcall(function()
                    State.Config:Save()
                end)
            end
        end)
    end)

    -- ========================================================
    -- FINAL
    -- ========================================================

    safeNotify(
        "RVX Hub",
        "Loaded • " .. State.MapName,
        3,
        "sparkles"
    )

    return Window, WindUI
end

return Core
