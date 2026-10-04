--[[
    RVX Hub - Main Loader
    One link for all supported maps.
    Repository: xxxx01w/Rvxhup

    รายชื่อแมพอยู่ในไฟล์ maps.lua (แก้ที่นั่นได้เลย ไม่ต้องแก้ไฟล์นี้)
--]]

local REPO = "https://script-vault-production.up.railway.app/raw/cca31b760609d8fc"

-- ============================================================
-- SPLASH (โลโก้กลางจอ + เบลอฉากรอบๆ จนกว่าเมนูจะโหลดเสร็จ แล้วค่อยๆ จางหาย)
-- ============================================================

local LOGO_IMAGE = "rbxassetid://101001702908437"  -- รูปโลโก้ (เว้นว่าง "" = ใช้ตัวอักษรด้านล่างแทน)
local LOGO_TEXT  = "RVX"
local LOGO_SUB   = "H  U  B"

local closeSplash = function() end

pcall(function()
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local started = os.clock()
    local closed = false

    local gui = Instance.new("ScreenGui")
    gui.Name = "RVXSplash"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local okParent = pcall(function()
        gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if not okParent then
        gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- เบลอฉากเกม (BlurEffect เบลอเฉพาะโลก 3D โลโก้จึงยังคมชัด)
    local blur = Instance.new("BlurEffect")
    blur.Name = "RVXSplashBlur"
    blur.Size = 0
    blur.Parent = Lighting

    -- ฉากมืดบางๆ ช่วยให้โลโก้เด่น
    local dim = Instance.new("Frame")
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 1
    dim.BorderSizePixel = 0
    dim.Parent = gui

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.fromScale(0.5, 0.5)
    box.Size = UDim2.fromOffset(300, 150)
    box.BackgroundTransparency = 1
    box.Parent = gui

    local logo
    if LOGO_IMAGE ~= "" then
        logo = Instance.new("ImageLabel")
        logo.Image = LOGO_IMAGE
        logo.BackgroundTransparency = 1
        logo.ImageTransparency = 1
        logo.AnchorPoint = Vector2.new(0.5, 0)
        logo.Position = UDim2.fromScale(0.5, 0)
        logo.Size = UDim2.fromOffset(88, 88)
        logo.ScaleType = Enum.ScaleType.Fit
    else
        logo = Instance.new("TextLabel")
        logo.Text = LOGO_TEXT
        logo.Font = Enum.Font.GothamBlack
        logo.TextSize = 72
        logo.TextColor3 = Color3.new(1, 1, 1)
        logo.TextTransparency = 1
        logo.BackgroundTransparency = 1
        logo.Size = UDim2.new(1, 0, 0, 84)
    end
    logo.Parent = box

    local sub = Instance.new("TextLabel")
    sub.Text = LOGO_SUB
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 16
    sub.TextColor3 = Color3.fromRGB(190, 190, 190)
    sub.TextTransparency = 1
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 94)
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Parent = box

    -- แถบโหลดบางๆ (วิ่งวน)
    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(0.5, 0)
    track.Position = UDim2.new(0.5, 0, 0, 128)
    track.Size = UDim2.fromOffset(120, 2)
    track.BackgroundColor3 = Color3.new(1, 1, 1)
    track.BackgroundTransparency = 1
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.Parent = box

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0.35, 1)
    fill.Position = UDim2.fromScale(-0.4, 0)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = track

    -- fade in
    local tin = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(blur, tin, { Size = 28 }):Play()
    TweenService:Create(dim, tin, { BackgroundTransparency = 0.55 }):Play()
    TweenService:Create(logo, tin, logo:IsA("ImageLabel") and { ImageTransparency = 0 } or { TextTransparency = 0 }):Play()
    TweenService:Create(sub, tin, { TextTransparency = 0.2 }):Play()
    TweenService:Create(track, tin, { BackgroundTransparency = 0.85 }):Play()
    TweenService:Create(fill, tin, { BackgroundTransparency = 0 }):Play()

    -- แถบโหลดวิ่งวนระหว่างรอ
    task.spawn(function()
        while not closed and gui.Parent do
            fill.Position = UDim2.fromScale(-0.4, 0)
            local t = TweenService:Create(fill, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Position = UDim2.fromScale(1.05, 0) })
            t:Play()
            t.Completed:Wait()
        end
    end)

    closeSplash = function()
        if closed then return end
        closed = true
        task.spawn(function()
            -- แสดงอย่างน้อย 1.2 วิ กันกะพริบเมื่อโหลดเร็ว
            local left = 1.2 - (os.clock() - started)
            if left > 0 then task.wait(left) end

            local tout = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            pcall(function()
                TweenService:Create(blur, tout, { Size = 0 }):Play()
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        TweenService:Create(d, tout, { TextTransparency = 1 }):Play()
                    elseif d:IsA("ImageLabel") then
                        TweenService:Create(d, tout, { ImageTransparency = 1 }):Play()
                    elseif d:IsA("Frame") then
                        TweenService:Create(d, tout, { BackgroundTransparency = 1 }):Play()
                    end
                end
            end)
            task.wait(1.1)
            pcall(function() blur:Destroy() end)
            pcall(function() gui:Destroy() end)
        end)
    end

    -- กันค้าง: ถ้าผ่านไป 25 วินาทีแล้วยังไม่ปิด ให้ปิดเอง
    task.delay(25, closeSplash)
end)

-- ============================================================
-- LIVE TRACKER (ส่งสถานะออนไลน์ไปหน้า Live ทุก 30 วินาที)
-- รันแยก thread + pcall ทั้งหมด ถ้าพังจะไม่กระทบสคริปต์หลัก
-- ============================================================

task.spawn(function()
    pcall(function()
        -- กันรันซ้ำ ถ้าผู้ใช้เปิดสคริปต์สองครั้งในเกมเดียวกัน
        local env = (getgenv and getgenv()) or _G
        if env.__RVX_LIVE then return end
        env.__RVX_LIVE = true

        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local Market = game:GetService("MarketplaceService")
        local send = (syn and syn.request) or (http and http.request) or http_request or request
        if not send then return end

        local URL = "https://script-vault-production.up.railway.app/track/cca31b760609d8fc"
        local lp = Players.LocalPlayer
        local sid = HttpService:GenerateGUID(false)
        local gameName = "Unknown"
        pcall(function() gameName = Market:GetProductInfo(game.PlaceId).Name end)
        local cc -- ประเทศที่ Roblox รู้ (แม่นกว่าดูจาก IP โดยเฉพาะเน็ตมือถือ)
        pcall(function() cc = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(lp) end)

        local function ping(leave)
            pcall(send, {
                Url = URL, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    sid = sid, uid = lp.UserId, user = lp.Name,
                    placeId = game.PlaceId, game = gameName, jobId = game.JobId, cc = cc, leave = leave
                })
            })
        end

        ping()
        task.spawn(function() while task.wait(30) do ping() end end)
        Players.PlayerRemoving:Connect(function(p) if p == lp then ping(true) end end)
    end)
end)

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
    closeSplash()
    error("[RVX Hub] Core load failed:\n" .. tostring(Core))
end

if type(Core) ~= "table" or type(Core.Init) ~= "function" then
    closeSplash()
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
    closeSplash()
    error("[RVX Hub] Core.Init failed:\n" .. tostring(Window))
end

if not Window then
    closeSplash()
    error("[RVX Hub] Core.Init did not return Window")
end

-- ============================================================
-- MAP LIST (โหลดจาก maps.lua)
-- ============================================================

-- สำรองไว้ ถ้า maps.lua โหลดไม่ได้หรือมี syntax error ก็ยังใช้ Ride a Pet ได้
local FALLBACK_MODULES = {
    [124216119978534] = "games/rideapet.lua",
}

local MAP_MODULES = FALLBACK_MODULES

local okMaps, mapsResult = pcall(function()
    return loadRemote("maps.lua")
end)

if okMaps and type(mapsResult) == "table" then
    MAP_MODULES = mapsResult
else
    warn("[RVX Hub] maps.lua load failed, using fallback list: " .. tostring(mapsResult))
end

local modulePath = MAP_MODULES[game.PlaceId]

if not modulePath then
    closeSplash()
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

-- ============================================================
-- GAME MODULES
-- ============================================================

local okModule, Module = pcall(function()
    return loadRemote(modulePath)
end)

if not okModule then
    closeSplash()
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
    closeSplash()
    warn("[RVX Hub] Invalid game module: " .. modulePath)
    return
end

-- ============================================================
-- START GAME MODULE
-- ============================================================

local okGame, gameError = pcall(function()
    Module.Init(Window, WindUI)
end)

closeSplash() -- เมนูพร้อมแล้ว: โลโก้จางหาย เบลอหาย

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
