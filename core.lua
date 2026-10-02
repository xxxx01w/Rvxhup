--[[
    RVX HUB - CORE V3 (slim)
    ตั้งค่าทั้งหมดรวมอยู่ในแท็บเดียว

    Game modules ใช้แค่:
        local Window, WindUI = Core.Init(mapName)
        Window.RVXGameSection  -- ใช้เพิ่มแท็บของแมพ
]]

local Core = {}

-- ============================================================
-- SERVICES
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- WINDUI
-- ============================================================

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ============================================================
-- BRAND / DEFAULTS
-- ============================================================

local RVX = {
    Purple       = "#8B5CF6",
    Pink         = "#FF3D9A",
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
local DISCORD_URL = "https://discord.gg/WQePykh3yJ"

local DEFAULTS = {
    Theme = "Crimson",
    Transparency = 0.08,
    ToggleKey = "RightShift",
    OpenButton = true,
    OpenButtonScale = 0.50,
    Notifications = true,
}

-- ============================================================
-- STATE
-- ============================================================

local State = {
    MapName = "RVX Hub",
    Window = nil,
    NotificationsEnabled = DEFAULTS.Notifications,
    AntiAFKConnection = nil,
    Config = nil,
}

-- ============================================================
-- HELPERS
-- ============================================================

local function safeCall(callback, ...)
    local ok, result = xpcall(callback, function(err)
        return tostring(err) .. "\n" .. debug.traceback()
    end, ...)

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
            Duration = duration or 3,
            Icon = icon or "sparkles",
        })
    end)
end

local function normalizeKey(value)
    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
        return value.Name
    end

    local name = tostring(value or DEFAULTS.ToggleKey)

    if Enum.KeyCode[name] then
        return name
    end

    return DEFAULTS.ToggleKey
end

local function getPlayerDisplay()
    return LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "Player"
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

local function copyToClipboard(text)
    local ok = pcall(function()
        local copy = setclipboard or toclipboard or set_clipboard
        if not copy then
            error("Clipboard API unavailable")
        end
        copy(text)
    end)

    return ok
end

local function asColor3(value, fallback)
    if typeof(value) == "Color3" then
        return value
    end

    if type(value) == "string" then
        local ok, color = pcall(Color3.fromHex, value)
        if ok and color then
            return color
        end
    end

    return fallback
end

local function updateOpenButtonTheme(Window, themeName)
    local fallbackA = Color3.fromHex("#DC143C")
    local fallbackB = Color3.fromHex("#FF4D6D")
    local accent, button = fallbackA, fallbackB

    local ok, themes = pcall(function()
        return WindUI:GetThemes()
    end)

    if ok and type(themes) == "table" and type(themes[themeName]) == "table" then
        local theme = themes[themeName]
        accent = asColor3(theme.Accent, fallbackA)
        button = asColor3(theme.Button, accent)
    end

    safeCall(function()
        Window:EditOpenButton({
            CornerRadius = UDim.new(0, 14),
            Color = ColorSequence.new(accent, button),
        })
    end)
end

-- ============================================================
-- ANTI-AFK
-- ============================================================

local function setAntiAFK(enabled)
    if State.AntiAFKConnection then
        pcall(function()
            State.AntiAFKConnection:Disconnect()
        end)
        State.AntiAFKConnection = nil
    end

    if enabled ~= true or not LocalPlayer then
        return
    end

    State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
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
    if not WindUI:GetThemes()["RVX Purple Pink"] then
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
-- INIT
-- ============================================================

function Core.Init(mapName)
    State.MapName = tostring(mapName or "RVX Hub")

    if State.Window then
        return State.Window, WindUI
    end

    -- --------------------------------------------------------
    -- WINDOW
    -- --------------------------------------------------------

    local Window = WindUI:CreateWindow({
        Title = "RVX Hub",
        Icon = "rbxassetid://95844711546407",
        IconSize = 38,
        Author = State.MapName,
        Folder = "RVXHub",
        Size = UDim2.fromOffset(700, 520),
        Transparent = true,
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

        User = {
            Enabled = true,
            Anonymous = false,
        },
    })

    if not Window then
        error("[RVX Hub Core] Failed to create WindUI window")
    end

    State.Window = Window

    safeCall(function() WindUI:SetTheme(DEFAULTS.Theme) end)
    safeCall(function() Window:SetBackgroundTransparency(DEFAULTS.Transparency) end)
    safeCall(function() Window:SetToggleKey(Enum.KeyCode[DEFAULTS.ToggleKey]) end)
    updateOpenButtonTheme(Window, DEFAULTS.Theme)

    -- --------------------------------------------------------
    -- TAGS + DISCORD
    -- --------------------------------------------------------

    safeCall(function()
        Window:Tag({ Title = "RVX", Radius = 8, Color = Color3.fromHex(RVX.Magenta) })
    end)

    safeCall(function()
        Window:Tag({ Title = VERSION, Radius = 8, Color = Color3.fromHex(RVX.Purple) })
    end)

    safeCall(function()
        Window:CreateTopbarButton("rvx-discord", "message-circle", function()
            if copyToClipboard(DISCORD_URL) then
                safeNotify("Discord", "คัดลอกลิงก์ Discord แล้ว", 2, "copy")
            else
                safeNotify("Discord", "Executor นี้ไม่รองรับการคัดลอก", 3, "circle-alert")
            end
        end, 995)
    end)

    -- --------------------------------------------------------
    -- SECTIONS (หน้าหลัก / แมพ / การตั้งค่า)
    -- --------------------------------------------------------

    local HomeSection = Window:Section({ Title = "RVX HUB", Opened = true })
    local GameSection = Window:Section({ Title = "แมพ", Opened = true })
    local SettingsSection = Window:Section({ Title = "การตั้งค่า", Opened = true })

    -- Game modules ใช้ Window.RVXGameSection เพื่อเพิ่มแท็บของตัวเอง
    Window.RVXGameSection = GameSection

    -- --------------------------------------------------------
    -- HOME
    -- --------------------------------------------------------

    local HomeTab = HomeSection:Tab({
        Title = "หน้าหลัก",
        Icon = "house",
    })

    HomeTab:Paragraph({
        Title = "ยินดีต้อนรับสู่ RVX Hub",
        Desc =
            "สวัสดี, " .. getPlayerDisplay() ..
            "\nแมพ: " .. State.MapName ..
            "\nอุปกรณ์: " .. getDeviceName(),
        Image = "sparkles",
        ImageSize = 24,
        Color = Color3.fromHex(RVX.Pink),
    })

    -- --------------------------------------------------------
    -- SETTINGS (แท็บเดียว)
    -- --------------------------------------------------------

    local SettingsTab = SettingsSection:Tab({
        Title = "ตั้งค่า",
        Icon = "settings",
    })

    -- ===== หน้าตา =====
    SettingsTab:Section({ Title = "หน้าตา", TextSize = 18 })

    local themeNames = {}

    safeCall(function()
        for themeName in pairs(WindUI:GetThemes()) do
            table.insert(themeNames, themeName)
        end
    end)

    table.sort(themeNames)

    local ThemeDropdown = SettingsTab:Dropdown({
        Title = "ธีม",
        Values = themeNames,
        Value = DEFAULTS.Theme,
        SearchBarEnabled = true,
        Flag = "RVX_THEME",

        Callback = function(theme)
            if type(theme) ~= "string" then
                return
            end

            safeCall(function() WindUI:SetTheme(theme) end)
            updateOpenButtonTheme(Window, theme)
        end,
    })

    local TransparencySlider = SettingsTab:Slider({
        Title = "ความโปร่งใสของ UI",
        Step = 0.05,
        Value = { Min = 0, Max = 0.50, Default = DEFAULTS.Transparency },
        Flag = "RVX_TRANSPARENCY",

        Callback = function(value)
            local transparency = tonumber(value)
            if not transparency then
                return
            end

            safeCall(function() Window:SetBackgroundTransparency(transparency) end)
        end,
    })

    -- ===== ปุ่มและการควบคุม =====
    SettingsTab:Section({ Title = "ปุ่มและการควบคุม", TextSize = 18 })

    local ToggleKeyElement = SettingsTab:Keybind({
        Title = "ปุ่มเปิด / ปิด UI",
        Value = DEFAULTS.ToggleKey,
        Flag = "RVX_TOGGLE_KEY",

        Callback = function(value)
            local keyName = normalizeKey(value)

            safeCall(function()
                Window:SetToggleKey(Enum.KeyCode[keyName])
            end)
        end,
    })

    local OpenButtonToggle = SettingsTab:Toggle({
        Title = "ปุ่มเปิดแบบลอย",
        Value = DEFAULTS.OpenButton,
        Flag = "RVX_OPEN_BUTTON",

        Callback = function(state)
            safeCall(function() Window:EditOpenButton({ Enabled = state }) end)
        end,
    })

    local OpenButtonScaleSlider = SettingsTab:Slider({
        Title = "ขนาดปุ่มเปิด",
        Step = 0.05,
        Value = { Min = 0.35, Max = 0.80, Default = DEFAULTS.OpenButtonScale },
        Flag = "RVX_OPEN_BUTTON_SCALE",

        Callback = function(value)
            local scale = tonumber(value)
            if not scale then
                return
            end

            safeCall(function() Window:EditOpenButton({ Scale = scale }) end)
        end,
    })

    -- ===== ระบบ =====
    SettingsTab:Section({ Title = "ระบบ", TextSize = 18 })

    local NotificationToggle = SettingsTab:Toggle({
        Title = "การแจ้งเตือน",
        Desc = "เปิด / ปิดข้อความแจ้งเตือนจาก RVX Core",
        Value = DEFAULTS.Notifications,
        Flag = "RVX_NOTIFICATIONS",

        Callback = function(state)
            State.NotificationsEnabled = state == true
        end,
    })

    SettingsTab:Toggle({
        Title = "Anti-AFK",
        Desc = "ป้องกัน Roblox ตัดการเชื่อมต่อเมื่อไม่ได้ใช้งานนาน",
        Value = false,
        Flag = "RVX_ANTI_AFK",

        Callback = function(state)
            setAntiAFK(state)
        end,
    })

    -- ===== Config =====
    SettingsTab:Section({ Title = "Config", TextSize = 18 })

    local ConfigManager = Window.ConfigManager

    if ConfigManager then
        safeCall(function()
            ConfigManager:Init(Window)
        end)

        local configName = "RVX_UI"

        local ConfigNameInput = SettingsTab:Input({
            Title = "ชื่อ Config",
            Value = configName,
            Placeholder = "RVX_UI",

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

        local ConfigDropdown = SettingsTab:Dropdown({
            Title = "Config ที่บันทึกไว้",
            Values = getConfigs(),
            SearchBarEnabled = true,

            Callback = function(value)
                if value then
                    configName = tostring(value)
                    safeCall(function() ConfigNameInput:Set(configName) end)
                end
            end,
        })

        SettingsTab:Button({
            Title = "บันทึก Config",
            Icon = "save",

            Callback = function()
                local config
                pcall(function()
                    config = ConfigManager:CreateConfig(configName)
                end)

                local saved = false
                if config then
                    pcall(function()
                        saved = config:Save() == true
                    end)
                end

                if saved then
                    safeNotify("Config", "บันทึก: " .. configName, 3, "check")
                    safeCall(function() ConfigDropdown:Refresh(ConfigManager:AllConfigs()) end)
                else
                    safeNotify("Config", "บันทึกไม่สำเร็จ", 3, "circle-alert")
                end
            end,
        })

        SettingsTab:Button({
            Title = "โหลด Config",
            Icon = "folder-open",

            Callback = function()
                local config
                pcall(function()
                    config = ConfigManager:CreateConfig(configName)
                end)

                local loaded = false
                if config then
                    pcall(function()
                        loaded = config:Load() == true
                    end)
                end

                if loaded then
                    State.Config = config
                    safeNotify("Config", "โหลด: " .. configName, 3, "refresh-cw")
                else
                    safeNotify("Config", "ไม่พบหรือโหลดไม่สำเร็จ", 3, "circle-alert")
                end
            end,
        })

        -- Config หลักสำหรับ autosave ตอนปิด UI
        safeCall(function()
            State.Config = ConfigManager:CreateConfig("RVX_UI", true)
        end)
    else
        SettingsTab:Paragraph({
            Title = "Config ใช้งานไม่ได้",
            Desc = "Executor นี้ไม่รองรับ Config Manager (ส่วนอื่นทำงานปกติ)",
            Image = "circle-alert",
            ImageSize = 22,
            Color = Color3.fromHex("#FFB4B4"),
        })
    end

    -- ===== รีเซ็ต =====
    SettingsTab:Button({
        Title = "รีเซ็ตการตั้งค่า UI",
        Desc = "คืนค่าหน้าตา ปุ่มลัด และปุ่มลอยเป็นค่าเริ่มต้น",
        Icon = "rotate-ccw",

        Callback = function()
            safeCall(function() ThemeDropdown:Select(DEFAULTS.Theme) end)
            safeCall(function() TransparencySlider:Set(DEFAULTS.Transparency) end)
            safeCall(function() ToggleKeyElement:Set(DEFAULTS.ToggleKey) end)
            safeCall(function() OpenButtonToggle:Set(DEFAULTS.OpenButton) end)
            safeCall(function() OpenButtonScaleSlider:Set(DEFAULTS.OpenButtonScale) end)
            safeCall(function() NotificationToggle:Set(DEFAULTS.Notifications) end)

            setAntiAFK(false)

            safeNotify("RVX Hub", "คืนค่าการตั้งค่า UI แล้ว", 3, "rotate-ccw")
        end,
    })

    -- --------------------------------------------------------
    -- AUTOSAVE ON CLOSE
    -- --------------------------------------------------------

    safeCall(function()
        Window:OnClose(function()
            if State.Config and State.Config.Save then
                pcall(function()
                    State.Config:Save()
                end)
            end
        end)
    end)

    safeNotify("RVX Hub", "Loaded • " .. State.MapName, 3, "sparkles")

    return Window, WindUI
end

return Core
