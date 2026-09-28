--[[
    RVX Hub - Main Loader
    One link for all supported maps.
]]

local Core = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xxxx01w/RVX-hub/main/core.lua"
))()

local ok, info = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
end)

local mapName = (ok and info and info.Name) or "Unknown Map"
local Window, WindUI = Core.Init(mapName)

local MAP_MODULES = {
    [124216119978534] = "rideapet.lua",
}

local moduleFile = MAP_MODULES[game.PlaceId]

if not moduleFile then
    pcall(function()
        WindUI:Notify({
            Title = "RVX Hub",
            Content = "ยังไม่มีฟังก์ชันสำหรับแมพนี้",
            Duration = 4,
        })
    end)
    return
end

local moduleUrl =
    "https://raw.githubusercontent.com/xxxx01w/RVX-hub/main/games/"
    .. moduleFile

local loadOk, moduleOrError = pcall(function()
    local source = game:HttpGet(moduleUrl)
    local chunk, compileError = loadstring(source)

    if not chunk then
        error(compileError or "Module compile failed")
    end

    return chunk()
end)

if not loadOk then
    warn("[RVX Hub] Failed to load " .. moduleFile .. ": " .. tostring(moduleOrError))
    pcall(function()
        WindUI:Notify({
            Title = "RVX Hub",
            Content = "โหลดไฟล์แมพไม่สำเร็จ",
            Duration = 5,
        })
    end)
    return
end

if type(moduleOrError) ~= "table" or type(moduleOrError.Init) ~= "function" then
    warn("[RVX Hub] Invalid game module: " .. moduleFile)
    return
end

local initOk, initError = pcall(function()
    moduleOrError.Init(Window, WindUI)
end)

if not initOk then
    warn("[RVX Hub] Game module Init error: " .. tostring(initError))
end
