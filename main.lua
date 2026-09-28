--[[
    RVX HUB - Main Loader
    Repository: https://github.com/xxxx01w/Rvxhup
]]

local REPO = "https://raw.githubusercontent.com/xxxx01w/Rvxhup/main"

local function loadRemote(path)
    local url = REPO .. "/" .. path
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk, err = loadstring(source)
        if not chunk then error(err or ("Failed to compile: " .. path)) end
        return chunk()
    end)
    if not ok then
        error("[RVX HUB] Failed to load " .. path .. ": " .. tostring(result))
    end
    return result
end

local Core = loadRemote("core.lua")

if type(Core) ~= "table" or type(Core.Init) ~= "function" then
    error("[RVX HUB] core.lua did not return Core.Init()")
end

local mapName = "Universal"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name and info.Name ~= "" then
        mapName = info.Name
    end
end)

local Window, WindUI = Core.Init(mapName)
if not Window then
    error("[RVX HUB] Core.Init() did not return a Window")
end

local MAP_MODULES = {
    [124216119978534] = "games/rideapet.lua",
}

local modulePath = MAP_MODULES[game.PlaceId]
if not modulePath then
    pcall(function()
        WindUI:Notify({
            Title = "RVX HUB",
            Content = "ยังไม่มีฟังก์ชันสำหรับแมพนี้",
            Duration = 4,
        })
    end)
    return
end

local Module = loadRemote(modulePath)

if type(Module) ~= "table" or type(Module.Init) ~= "function" then
    error("[RVX HUB] " .. modulePath .. " ต้อง return table ที่มี Init(Window, WindUI)")
end

local ok, err = pcall(function()
    Module.Init(Window, WindUI)
end)

if not ok then
    warn("[RVX HUB] Game module error: " .. tostring(err))
    pcall(function()
        WindUI:Notify({
            Title = "RVX HUB",
            Content = "เกิดข้อผิดพลาดในการโหลดฟังก์ชันของแมพ",
            Duration = 5,
        })
    end)
end
