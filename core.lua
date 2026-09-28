--[[
    RVX HUB - Core V4
    Clean Pro Layout
    Shared WindUI loader + centralized UI system.

    Layout:
      Home
      Game (current game features)
      Tools
      Settings (Appearance / Controls / Notifications / Performance / Config / System)

    Game modules can keep using:
        Module.Init(Window, WindUI)

    For modules that want their game section:
        local GameSection = Window.RVXGameSection
        local Tab = GameSection:Tab({...})
]]

local Core = {}

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

local CONFIG_FILE = "RVXHub_V4.json"

local State = {
    Theme = "RVX Purple Pink",
    Transparency = 0.08,
    Keybind = Enum.KeyCode.RightShift,
    OpenButton = true,
    Notifications = true,
    PerformanceMode = false,
    AutoSave = true,
}

local function safeRead()
    if not isfile or not isfile(CONFIG_FILE) then
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)

    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            if State[k] ~= nil then
                State[k] = v
            end
        end
    end
end

local function safeSave()
    if not writefile then
        return
    end

    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(State))
    end)
end

safeRead()

local function getGameName()
    local name = "Universal"

    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name and info.Name ~= "" then
            name = info.Name
        end
    end)

    return name
end

local function notify(title, content, duration)
    if not State.Notifications then
        return
    end

    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
        })
    end)
end

local function refreshProfile()
    if not LocalPlayer then
        return
    end

    -- WindUI handles the user display. This helper exists so modules/core
    -- have one centralized place to refresh profile-related state.
    return LocalPlayer.Name
end

local function setTheme(name)
    -- Store the preference without calling undocumented theme internals.
    -- This keeps Core compatible with more WindUI releases.
    State.Theme = name
end

function Core.Init(mapName)
    mapName = mapName or getGameName()

    local Window = WindUI:CreateWindow({
        Title = "RVX HUB",
        Icon = "egg",
        Author = mapName,
        Folder = "RVXHub",
        Size = UDim2.fromOffset(620, 480),
        Transparent = true,
        User = {
            Enabled = true,
            Anonymous = false,
            Callback = function()
                refreshProfile()
            end,
        },
    })

    -- ============================================================
    -- THEME
    -- ============================================================
    -- Keep WindUI's built-in theme system here. Some WindUI releases
    -- require internal theme fields (for example PanelBackground), so
    -- injecting a partial custom theme can break CreateWindow.
    -- The UI layout remains centralized.

    -- ============================================================
    -- SIDEBAR SECTIONS
    -- ============================================================

    local HomeSection = Window:Section({
        Title = "🏠 Home",
        Opened = true,
    })

    local GameSection = Window:Section({
        Title = "🎮 " .. tostring(mapName),
        Opened = true,
    })

    local ToolsSection = Window:Section({
        Title = "🧰 Tools",
        Opened = false,
    })

    local SettingsSection = Window:Section({
        Title = "⚙ Settings",
        Opened = false,
    })

    -- Expose the current-game section to game modules.
    Window.RVXGameSection = GameSection
    Window.RVXHomeSection = HomeSection
    Window.RVXToolsSection = ToolsSection
    Window.RVXSettingsSection = SettingsSection
    Window.RVXCoreState = State
    Window.RVXNotify = notify

    -- ============================================================
    -- HOME
    -- ============================================================

    local HomeTab = HomeSection:Tab({
        Title = "Dashboard",
        Icon = "house",
    })

    HomeTab:Paragraph({
        Title = "RVX HUB",
        Desc = "Clean Pro interface",
    })

    HomeTab:Paragraph({
        Title = "Current Game",
        Desc = tostring(mapName),
    })

    HomeTab:Paragraph({
        Title = "Status",
        Desc = "Core loaded successfully.",
    })

    HomeTab:Button({
        Title = "Refresh Profile",
        Desc = "Refresh the account display used by RVX HUB.",
        Callback = function()
            refreshProfile()
            notify("RVX HUB", "Profile refreshed.", 2)
        end,
    })

    HomeTab:Button({
        Title = "Copy Place ID",
        Desc = tostring(game.PlaceId),
        Callback = function()
            if setclipboard then
                setclipboard(tostring(game.PlaceId))
                notify("RVX HUB", "Place ID copied.", 2)
            end
        end,
    })

    -- ============================================================
    -- TOOLS
    -- ============================================================

    local ToolsTab = ToolsSection:Tab({
        Title = "Utilities",
        Icon = "wrench",
    })

    ToolsTab:Button({
        Title = "Copy Job ID",
        Desc = tostring(game.JobId),
        Callback = function()
            if setclipboard then
                setclipboard(tostring(game.JobId))
                notify("RVX HUB", "Job ID copied.", 2)
            end
        end,
    })

    ToolsTab:Button({
        Title = "Copy Place ID",
        Desc = tostring(game.PlaceId),
        Callback = function()
            if setclipboard then
                setclipboard(tostring(game.PlaceId))
                notify("RVX HUB", "Place ID copied.", 2)
            end
        end,
    })

    ToolsTab:Button({
        Title = "Rejoin Server",
        Desc = "Reconnect to the current experience.",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end,
    })

    ToolsTab:Button({
        Title = "Server Hop",
        Desc = "Reserved for centralized server tools.",
        Callback = function()
            notify("RVX HUB", "Server Hop is not configured yet.", 3)
        end,
    })

    -- ============================================================
    -- SETTINGS
    -- All shared UI controls are grouped here.
    -- ============================================================

    local AppearanceTab = SettingsSection:Tab({
        Title = "Appearance",
        Icon = "palette",
    })

    AppearanceTab:Dropdown({
        Title = "Theme",
        Values = {
            "RVX Purple Pink",
            "Dark",
            "Light",
        },
        Value = State.Theme,
        Callback = function(value)
            setTheme(value)
            notify("Appearance", "Theme changed to " .. tostring(value), 2)
        end,
    })

    AppearanceTab:Slider({
        Title = "Transparency",
        Desc = "Adjust the shared UI transparency preference.",
        Value = {
            Min = 0,
            Max = 0.35,
            Default = State.Transparency,
        },
        Step = 0.01,
        Callback = function(value)
            State.Transparency = value
        end,
    })

    AppearanceTab:Toggle({
        Title = "Floating Open Button",
        Desc = "Show or hide the floating UI button.",
        Value = State.OpenButton,
        Callback = function(value)
            State.OpenButton = value
            pcall(function()
                if Window.SetToggleKey then
                    -- Keep WindUI's own toggle behavior intact.
                end
            end)
        end,
    })

    local ControlsTab = SettingsSection:Tab({
        Title = "Controls",
        Icon = "keyboard",
    })

    ControlsTab:Keybind({
        Title = "Toggle UI",
        Desc = "Press a key to open or hide RVX HUB.",
        Value = State.Keybind,
        Callback = function(value)
            State.Keybind = value
        end,
    })

    ControlsTab:Paragraph({
        Title = "Recommended",
        Desc = "RightShift is the default PC toggle key.",
    })

    local NotificationsTab = SettingsSection:Tab({
        Title = "Notifications",
        Icon = "bell",
    })

    NotificationsTab:Toggle({
        Title = "Enable Notifications",
        Desc = "Allow RVX HUB status notifications.",
        Value = State.Notifications,
        Callback = function(value)
            State.Notifications = value
        end,
    })

    NotificationsTab:Button({
        Title = "Test Notification",
        Desc = "Preview the RVX notification style.",
        Callback = function()
            notify("RVX HUB", "Notification system is working.", 3)
        end,
    })

    local PerformanceTab = SettingsSection:Tab({
        Title = "Performance",
        Icon = "gauge",
    })

    PerformanceTab:Toggle({
        Title = "Performance Mode",
        Desc = "Lets game modules read a shared low-load preference.",
        Value = State.PerformanceMode,
        Callback = function(value)
            State.PerformanceMode = value
            notify(
                "Performance",
                value and "Performance mode enabled." or "Performance mode disabled.",
                2
            )
        end,
    })

    PerformanceTab:Paragraph({
        Title = "Shared State",
        Desc = "Game modules can read Window.RVXCoreState.PerformanceMode.",
    })

    local ConfigTab = SettingsSection:Tab({
        Title = "Config",
        Icon = "save",
    })

    ConfigTab:Toggle({
        Title = "Auto Save",
        Desc = "Save shared RVX HUB settings when possible.",
        Value = State.AutoSave,
        Callback = function(value)
            State.AutoSave = value
        end,
    })

    ConfigTab:Button({
        Title = "Save Settings",
        Desc = "Save RVX HUB settings locally.",
        Callback = function()
            safeSave()
            notify("Config", "Settings saved.", 2)
        end,
    })

    ConfigTab:Button({
        Title = "Reset Settings",
        Desc = "Restore the shared UI defaults.",
        Callback = function()
            State.Theme = "RVX Purple Pink"
            State.Transparency = 0.08
            State.Keybind = Enum.KeyCode.RightShift
            State.OpenButton = true
            State.Notifications = true
            State.PerformanceMode = false
            State.AutoSave = true

            pcall(function()
                setTheme(State.Theme)
            end)

            notify("Config", "Shared settings reset.", 2)
        end,
    })

    local SystemTab = SettingsSection:Tab({
        Title = "System",
        Icon = "info",
    })

    SystemTab:Paragraph({
        Title = "RVX HUB Core V4",
        Desc = "Centralized UI system with grouped navigation.",
    })

    SystemTab:Paragraph({
        Title = "Game",
        Desc = tostring(mapName),
    })

    SystemTab:Paragraph({
        Title = "Place ID",
        Desc = tostring(game.PlaceId),
    })

    SystemTab:Paragraph({
        Title = "Job ID",
        Desc = tostring(game.JobId),
    })

    -- ============================================================
    -- KEY TOGGLE
    -- ============================================================

    local toggleConnection
    toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == State.Keybind then
            pcall(function()
                if Window.Toggle then
                    Window:Toggle()
                elseif Window.ToggleUI then
                    Window:ToggleUI()
                end
            end)
        end
    end)

    -- Keep connections tied to the window lifetime where possible.
    Window.RVXToggleConnection = toggleConnection

    -- ============================================================
    -- AUTO SAVE
    -- ============================================================

    if State.AutoSave then
        task.spawn(function()
            while Window and State.AutoSave do
                task.wait(30)
                if State.AutoSave then
                    safeSave()
                end
            end
        end)
    end

    notify("RVX HUB", tostring(mapName) .. " loaded.", 3)

    return Window, WindUI
end

return Core
