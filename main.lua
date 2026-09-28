--[[
    RVX Hub - Main Loader
    One link for all supported maps.
    Repository: xxxx01w/Rvxhup
--]]

local REPO = "https://raw.githubusercontent.com/xxxx01w/Rvxhup/main"

local function loadRemote(path)
    local url = REPO .. "/" .. path

    local source = game:HttpGet(url)
    if type(source) ~= "string" or source == "" then
        error("[RVX Hub] Empty response: " .. url)
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        error("[RVX Hub] Compile failed: " .. path .. "\n" .. tostring(compileError))
    end

    return chunk()
end

-- ============================================================
-- CORE
-- ============================================================

local okCore, Core = pcall(function()
    return loadRemote("core.lua")
end)

if not okCore then
    error("[RVX Hub] Core load failed:\n" .. tostring(Core))
end

if type(Core) ~= "table" or type(Core.Init) ~= "function" then
    error("[RVX Hub] core.lua ไม่ได้ return Core ที่มี Init(mapName)")
end

-- ============================================================
-- MAP NAME
-- ============================================================

local mapName = "Unknown Map"

pcall(function()
    local MarketplaceService = game:GetService("MarketplaceService")
    local info = MarketplaceService:GetProductInfo(game.PlaceId)

    if info and info.Name and info.Name ~= "" then
        mapName = info.Name
    end
end)

-- ============================================================
-- INITIALIZE CORE
-- ============================================================

local okInit, Window, WindUI = pcall(function()
    return Core.Init(mapName)
end)

if not okInit then
    error("[RVX Hub] Core.Init failed:\n" .. tostring(Window))
end

if not Window then
    error("[RVX Hub] Core.Init did not return Window")
end

-- ============================================================
-- GAME MODULES
-- ============================================================

local MAP_MODULES = {
    [124216119978534] = "games/rideapet.lua",
}

local modulePath = MAP_MODULES[game.PlaceId]

if not modulePath then
    if WindUI then
        pcall(function()
            WindUI:Notify({
                Title = "RVX Hub",
                Content = "ยังไม่มีฟังก์ชันสำหรับแมพนี้",
                Duration = 4,
            })
        end)
    end
    return
end

local okModule, Module = pcall(function()
    return loadRemote(modulePath)
end)

if not okModule then
    warn("[RVX Hub] Failed to load " .. modulePath .. ": " .. tostring(Module))

    if WindUI then
        pcall(function()
            WindUI:Notify({
                Title = "RVX Hub",
                Content = "โหลดไฟล์แมพไม่สำเร็จ",
                Duration = 5,
            })
        end)
    end

    return
end

if type(Module) ~= "table" or type(Module.Init) ~= "function" then
    warn("[RVX Hub] Invalid game module: " .. modulePath)
    return
end

-- ============================================================
-- START GAME MODULE
-- ============================================================

local okGame, gameError = pcall(function()
    Module.Init(Window, WindUI)
end)

if not okGame then
    warn("[RVX Hub] Game module Init error: " .. tostring(gameError))

    if WindUI then
        pcall(function()
            WindUI:Notify({
                Title = "RVX Hub",
                Content = "เกิดข้อผิดพลาดในการโหลดฟังก์ชันของแมพ",
                Duration = 5,
            })
        end)
    end
end
