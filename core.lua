--[[
    RVX HUB - CORE V3 (slim)
    ตั้งค่าทั้งหมดรวมอยู่ในแท็บเดียว

    Game modules ใช้แค่:
        local Window, WindUI = Core.Init(mapName)
        Window.RVXGameSection  -- ใช้เพิ่มแท็บของแมพ

    เพิ่มเมนูโปรด (แสดงที่หน้าหลัก เลือกแล้วรัน callback ทันที):
        Window.RVXAddFavorite("Auto Egg", function() ... end)
        Window.RVXRemoveFavorite("Auto Egg")
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
    UIScale = 1.00,
    Background = "",
    BackgroundHidden = 1,    -- ไม่มีรูปพื้นหลัง
    BackgroundShown = 0.60,  -- มีรูปพื้นหลัง
}

-- ============================================================
-- STATE
-- ============================================================

local State = {
    MapName = "RVX Hub",
    Window = nil,
    NotificationsEnabled = DEFAULTS.Notifications,
    Theme = DEFAULTS.Theme,
    OpenButtonEnabled = DEFAULTS.OpenButton,
    OpenButtonScale = DEFAULTS.OpenButtonScale,
    AntiAFKConnection = nil,
    Config = nil,
    UIScale = DEFAULTS.UIScale,
    Background = DEFAULTS.Background,
    Favorites = {},
    FavoriteCallbacks = {},
    FavoriteDropdown = nil,
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

-- ลบอีโมจิออกจากข้อความ (เช่น ชื่อแมพที่โมดูลส่งเข้ามา)
local function stripEmoji(text)
    text = tostring(text or "")
    text = text:gsub("[\240-\247][\128-\191][\128-\191][\128-\191]", "") -- อีโมจิ 4 ไบต์
    text = text:gsub("\226[\134-\175][\128-\191]", "")                   -- สัญลักษณ์ เช่น นาฬิกาทราย ดาว หัวใจ
    text = text:gsub("\239\184[\142\143]", "")                           -- variation selector
    text = text:gsub("\226\128\141", "")                                 -- zero width joiner
    text = text:gsub("%[%s*%]", "")                                      -- วงเล็บว่างที่เหลือ
    text = text:gsub("%(%s*%)", "")
    text = text:gsub("%s+", " ")

    return text:match("^%s*(.-)%s*$") or text
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

-- WindUI: EditOpenButton รีเซ็ตค่าที่ไม่ได้ส่งมาเป็นค่าเริ่มต้นทุกครั้ง
-- (สี, มุมโค้ง, ขนาด) จึงต้องส่งครบทุกค่าเสมอ ห้ามเรียกแบบส่งบางค่า
local function applyOpenButton(Window)
    local fallbackA = Color3.fromHex("#DC143C")
    local fallbackB = Color3.fromHex("#FF4D6D")
    local accent, button = fallbackA, fallbackB

    local ok, themes = pcall(function()
        return WindUI:GetThemes()
    end)

    if ok and type(themes) == "table" and type(themes[State.Theme]) == "table" then
        local theme = themes[State.Theme]
        accent = asColor3(theme.Accent, fallbackA)
        button = asColor3(theme.Button, accent)
    end

    -- WindUI ตั้ง IsOpenButtonEnabled เป็น false ได้อย่างเดียว ต้องตั้งกลับเอง
    Window.IsOpenButtonEnabled = State.OpenButtonEnabled

    safeCall(function()
        Window:EditOpenButton({
            Enabled = State.OpenButtonEnabled,
            OnlyMobile = false,
            CornerRadius = UDim.new(0, 14),
            StrokeThickness = 2,
            Scale = State.OpenButtonScale,
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
-- UI SCALE / BACKGROUND
-- ============================================================

local function applyUIScale(Window, scale)
    local s = math.clamp(tonumber(scale) or DEFAULTS.UIScale, 0.75, 1.25)
    State.UIScale = s

    safeCall(function()
        Window:SetSize(UDim2.fromOffset(
            math.floor(700 * s),
            math.floor(520 * s)
        ))
    end)
end

-- รับ: เลขรหัสรูป, rbxassetid://..., หรือ URL (ดาวน์โหลดแล้วใช้ getcustomasset)
local function resolveImage(value)
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end

    if value:match("^https?://") then
        local ok, asset = pcall(function()
            local data = game:HttpGet(value)

            if not isfolder("RVXHub") then
                makefolder("RVXHub")
            end

            writefile("RVXHub/background.png", data)
            return getcustomasset("RVXHub/background.png")
        end)

        if ok and asset then
            return asset
        end

        return nil
    end

    return value
end

-- WindUI ไม่มี Window:SetBackground ต้องใช้ SetBackgroundImage + ปรับความโปร่งใสของรูป
local function applyBackground(Window, background)
    local value = tostring(background or ""):match("^%s*(.-)%s*$") or ""
    State.Background = value

    if value == "" then
        safeCall(function()
            Window:SetBackgroundImage("")
            Window:SetBackgroundImageTransparency(DEFAULTS.BackgroundHidden)
        end)
        return
    end

    local image = resolveImage(value)

    if not image then
        safeNotify("พื้นหลัง", "โหลดรูปจาก URL ไม่สำเร็จ หรือ Executor ไม่รองรับ", 3, "image")
        return
    end

    safeCall(function()
        Window:SetBackgroundImage(image)
        Window:SetBackgroundImageTransparency(DEFAULTS.BackgroundShown)
    end)
end

-- ============================================================
-- FAVORITES
-- ============================================================

local function refreshFavorites()
    if not State.FavoriteDropdown then
        return
    end

    local values = Core.GetFavorites()
    safeCall(function() State.FavoriteDropdown:Refresh(values) end)
end

function Core.RegisterFavorite(name, callback)
    name = tostring(name or ""):match("^%s*(.-)%s*$") or ""

    if name == "" then
        return false
    end

    State.Favorites[name] = true

    if type(callback) == "function" then
        State.FavoriteCallbacks[name] = callback
    end

    refreshFavorites()
    return true
end

function Core.RemoveFavorite(name)
    name = tostring(name or "")

    State.Favorites[name] = nil
    State.FavoriteCallbacks[name] = nil

    refreshFavorites()
    return true
end

function Core.GetFavorites()
    local result = {}

    for name in pairs(State.Favorites) do
        table.insert(result, name)
    end

    table.sort(result)
    return result
end

-- ============================================================
-- INIT
-- ============================================================

function Core.Init(mapName)
    State.MapName = stripEmoji(mapName or "RVX Hub")

    if State.MapName == "" then
        State.MapName = "RVX Hub"
    end

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
        Background = State.Background,
        BackgroundImageTransparency = DEFAULTS.BackgroundHidden,
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
    applyOpenButton(Window)

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

    -- Game modules ใช้สองตัวนี้เพื่อเพิ่ม/ลบเมนูโปรดโดยไม่ต้องเข้าถึง Core
    Window.RVXAddFavorite = Core.RegisterFavorite
    Window.RVXRemoveFavorite = Core.RemoveFavorite

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

    HomeTab:Section({ Title = "Favorites", TextSize = 18 })

    State.FavoriteDropdown = HomeTab:Dropdown({
        Title = "เมนูโปรด",
        Desc = "ทางลัดที่แมพเพิ่มไว้ เลือกเพื่อรันทันที",
        Values = Core.GetFavorites(),
        SearchBarEnabled = true,

        Callback = function(value)
            local callback = State.FavoriteCallbacks[value]

            if type(callback) == "function" then
                safeCall(callback)
            end
        end,
    })

    HomeTab:Paragraph({
        Title = "Hub Profile",
        Desc =
            "RVX Hub\n" ..
            VERSION ..
            "\nแมพปัจจุบัน: " .. State.MapName,
        Image = "crown",
        ImageSize = 24,
        Color = Color3.fromHex(RVX.Purple),
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

            State.Theme = theme
            safeCall(function() WindUI:SetTheme(theme) end)
            applyOpenButton(Window)
        end,
    })

    local UIPresetDropdown = SettingsTab:Dropdown({
        Title = "UI Preset",
        Values = { "RVX Classic", "Purple Neon", "Compact", "Large" },
        Value = "RVX Classic",
        Flag = "RVX_UI_PRESET",

        Callback = function(preset)
            local purpleTheme = DEFAULTS.Theme

            for themeName in pairs(WindUI:GetThemes()) do
                if string.find(string.lower(themeName), "purple", 1, true) then
                    purpleTheme = themeName
                    break
                end
            end

            local presets = {
                ["RVX Classic"] = { Theme = DEFAULTS.Theme, Transparency = DEFAULTS.Transparency, Scale = 1.00 },
                ["Purple Neon"] = { Theme = purpleTheme, Transparency = 0.12, Scale = 1.00 },
                ["Compact"] = { Theme = DEFAULTS.Theme, Transparency = 0.16, Scale = 0.85 },
                ["Large"] = { Theme = DEFAULTS.Theme, Transparency = 0.05, Scale = 1.15 },
            }

            local cfg = presets[preset]
            if not cfg then
                return
            end

            safeCall(function()
                if WindUI:GetThemes()[cfg.Theme] then
                    State.Theme = cfg.Theme
                    WindUI:SetTheme(cfg.Theme)
                    ThemeDropdown:Select(cfg.Theme)
                    applyOpenButton(Window)
                end
            end)

            safeCall(function() Window:SetBackgroundTransparency(cfg.Transparency) end)
            applyUIScale(Window, cfg.Scale)
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

    local UIScaleSlider = SettingsTab:Slider({
        Title = "ขนาด UI",
        Desc = "ปรับขนาดหน้าต่าง",
        Step = 0.05,
        Value = { Min = 0.75, Max = 1.25, Default = DEFAULTS.UIScale },
        Flag = "RVX_UI_SCALE",

        Callback = function(value)
            applyUIScale(Window, value)
        end,
    })

    local BackgroundInput = SettingsTab:Input({
        Title = "Custom Background",
        Desc = "รหัสรูป, rbxassetid:// หรือ URL รูปภาพ (เว้นว่างเพื่อลบ)",
        Placeholder = "https://... หรือ rbxassetid://...",
        Value = DEFAULTS.Background,
        Flag = "RVX_BACKGROUND",

        Callback = function(value)
            applyBackground(Window, value)
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
            State.OpenButtonEnabled = state == true
            applyOpenButton(Window)
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

            State.OpenButtonScale = scale
            applyOpenButton(Window)
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

        local DEFAULT_CONFIG = "RVX_UI"
        local configName = DEFAULT_CONFIG
        local configCache = {}

        -- ตัดอักขระที่ใช้ตั้งชื่อไฟล์ไม่ได้ และช่องว่างหัวท้าย
        local function cleanConfigName(value)
            local name = tostring(value or "")
            name = name:gsub('[\\/:*?"<>|]', "")
            name = name:match("^%s*(.-)%s*$") or ""

            if name == "" then
                return DEFAULT_CONFIG
            end

            return name
        end

        -- เก็บ object ไว้ใช้ซ้ำ เพราะ CreateConfig ทุกครั้งจะสั่ง AutoLoad ซ้ำถ้าไฟล์ตั้งไว้
        local function getConfig(name)
            if configCache[name] then
                return configCache[name]
            end

            local ok, config = pcall(function()
                return ConfigManager:CreateConfig(name, name == DEFAULT_CONFIG)
            end)

            if ok and type(config) == "table" then
                configCache[name] = config
                return config
            end

            return nil
        end

        local function getConfigs()
            local ok, result = pcall(function()
                return ConfigManager:AllConfigs()
            end)

            if ok and type(result) == "table" then
                return result
            end

            return {}
        end

        local function contains(list, value)
            for _, item in ipairs(list) do
                if item == value then
                    return true
                end
            end

            return false
        end

        local initialConfigs = getConfigs()

        local ConfigNameInput = SettingsTab:Input({
            Title = "ชื่อ Config",
            Value = configName,
            Placeholder = DEFAULT_CONFIG,

            Callback = function(value)
                configName = cleanConfigName(value)
            end,
        })

        local ConfigDropdown = SettingsTab:Dropdown({
            Title = "Config ที่บันทึกไว้",
            Values = initialConfigs,
            Value = contains(initialConfigs, configName) and configName or nil,
            SearchBarEnabled = true,

            Callback = function(value)
                if value then
                    configName = cleanConfigName(value)
                    safeCall(function() ConfigNameInput:Set(configName) end)
                end
            end,
        })

        local function refreshConfigList(selectName)
            local list = getConfigs()

            safeCall(function() ConfigDropdown:Refresh(list) end)
            safeCall(function() ConfigDropdown:Select(selectName) end)

            return list
        end

        SettingsTab:Button({
            Title = "บันทึก Config",
            Icon = "save",

            Callback = function()
                local name = configName
                local config = getConfig(name)

                -- Save() คืนค่าเป็น table ของข้อมูลที่บันทึก (ไม่ใช่ true)
                local ok, data = false, nil
                if config then
                    ok, data = pcall(config.Save, config)
                end

                if ok and type(data) == "table" then
                    safeNotify("Config", "บันทึก: " .. name, 3, "check")
                    refreshConfigList(name)
                else
                    safeNotify("Config", "บันทึกไม่สำเร็จ", 3, "circle-alert")
                end
            end,
        })

        SettingsTab:Button({
            Title = "โหลด Config",
            Icon = "folder-open",

            Callback = function()
                local name = configName
                local config = getConfig(name)

                -- Load() สำเร็จ = คืน table (CustomData) / ล้มเหลว = คืน false, ข้อความ
                local ok, result, message = false, nil, nil
                if config then
                    ok, result, message = pcall(config.Load, config)
                end

                if ok and type(result) == "table" then
                    State.Config = config
                    safeNotify("Config", "โหลด: " .. name, 3, "refresh-cw")
                elseif ok and tostring(message):find("does not exist") then
                    safeNotify("Config", "ไม่พบ Config \"" .. name .. "\" (ยังไม่เคยบันทึก)", 3, "circle-alert")
                else
                    safeNotify("Config", "โหลดไม่สำเร็จ: " .. tostring(message or result), 3, "circle-alert")
                end
            end,
        })

        local function deleteConfig(name)
            local ok, success, message = pcall(function()
                return ConfigManager:DeleteConfig(name)
            end)

            if not (ok and success == true) then
                local reason = tostring(success == false and message or success)

                if reason:find("delfile") then
                    reason = "Executor นี้ไม่รองรับการลบไฟล์"
                elseif reason:find("does not exist") then
                    reason = "ไม่พบไฟล์ Config นี้"
                end

                safeNotify("Config", "ลบไม่สำเร็จ: " .. reason, 3, "circle-alert")
                return
            end

            -- กัน autosave ตอนปิด UI เขียนไฟล์ที่เพิ่งลบกลับมา
            if State.Config and State.Config == configCache[name] then
                State.Config = nil
            end
            configCache[name] = nil

            configName = DEFAULT_CONFIG
            safeCall(function() ConfigNameInput:Set(configName) end)

            local list = refreshConfigList(nil)
            if contains(list, DEFAULT_CONFIG) then
                refreshConfigList(DEFAULT_CONFIG)
            end

            safeNotify("Config", "ลบ: " .. name, 3, "trash-2")
        end

        SettingsTab:Button({
            Title = "ลบ Config",
            Desc = "ลบไฟล์ Config ที่เลือก (กู้คืนไม่ได้)",
            Icon = "trash-2",

            Callback = function()
                local name = configName

                local shown = safeCall(function()
                    Window:Dialog({
                        Title = "ลบ Config",
                        Content = "ต้องการลบ \"" .. name .. "\" ใช่หรือไม่?\nลบแล้วกู้คืนไม่ได้",
                        Buttons = {
                            {
                                Title = "ยกเลิก",
                                Variant = "Secondary",
                                Callback = function() end,
                            },
                            {
                                Title = "ลบ",
                                Variant = "Primary",
                                Callback = function()
                                    deleteConfig(name)
                                end,
                            },
                        },
                    })
                end)

                if not shown then
                    safeNotify("Config", "เปิดหน้าต่างยืนยันไม่สำเร็จ", 3, "circle-alert")
                end
            end,
        })

        -- Config หลักสำหรับ autosave ตอนปิด UI
        State.Config = getConfig(DEFAULT_CONFIG)
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
            safeCall(function() UIPresetDropdown:Select("RVX Classic") end)
            safeCall(function() TransparencySlider:Set(DEFAULTS.Transparency) end)
            safeCall(function() UIScaleSlider:Set(DEFAULTS.UIScale) end)
            safeCall(function() BackgroundInput:Set(DEFAULTS.Background) end)
            safeCall(function() ToggleKeyElement:Set(DEFAULTS.ToggleKey) end)
            safeCall(function() OpenButtonToggle:Set(DEFAULTS.OpenButton) end)
            safeCall(function() OpenButtonScaleSlider:Set(DEFAULTS.OpenButtonScale) end)
            safeCall(function() NotificationToggle:Set(DEFAULTS.Notifications) end)

            State.Theme = DEFAULTS.Theme
            safeCall(function() WindUI:SetTheme(DEFAULTS.Theme) end)
            applyOpenButton(Window)
            applyUIScale(Window, DEFAULTS.UIScale)
            applyBackground(Window, DEFAULTS.Background)

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
