--[[
    RVX Hub - Ride A Pet (Auto Egg Farm) v3
    Module pattern: return table with Init(Window, WindUI)

    รายชื่อไข่ดึงสดจาก ReplicatedStorage.GameData.Eggs (ข้อมูลจริงของเกม)
    ไข่ที่เกมเพิ่มใหม่จะขึ้นเองโดยไม่ต้องแก้โค้ด
--]]

local RideAPet = {}

function RideAPet.Init(Window, WindUI)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer

    -- ===== ระบบจดจำการตั้งค่า (Auto Save Config) =====
    local CONFIG_FILE = "RVXHub_RideAPetConfig.json"
    local ALL_LABEL = "All / ทั้งหมด"

    local function isAllSelection(value)
        if type(value) ~= "string" then return false end
        local s = value:lower():gsub("^%s+", "")
        return s:match("^all%s*/") ~= nil or s == "all" or value:find("ทั้งหมด", 1, true) ~= nil
    end

    local function LoadSavedConfig()
        local defaults = {
            EspEnabled = false,
            SelectedEggNames = {},
            SelectedEspEggNames = {},
            SelectedPlaceEggNames = {},
            PlaceMode = "วางเฉพาะที่เลือก"
        }
        if isfile and isfile(CONFIG_FILE) then
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
            if ok and type(data) == "table" then
                if type(data.EspEnabled) == "boolean" then defaults.EspEnabled = data.EspEnabled end
                if type(data.SelectedEggNames) == "table" then defaults.SelectedEggNames = data.SelectedEggNames end
                if type(data.SelectedEspEggNames) == "table" then defaults.SelectedEspEggNames = data.SelectedEspEggNames end
                if type(data.SelectedPlaceEggNames) == "table" then defaults.SelectedPlaceEggNames = data.SelectedPlaceEggNames end
                if type(data.PlaceMode) == "string" then defaults.PlaceMode = data.PlaceMode end
            end
        end
        return defaults
    end

    local SavedConfig = LoadSavedConfig()

    -- Remotes
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local GameRemotes = Remotes and Remotes:WaitForChild("Game", 10)
    local EggPickupRemote = GameRemotes and GameRemotes:WaitForChild("EggPickup", 10)

    -- ============================================================
    -- ข้อมูลไข่
    -- ============================================================

    -- ชื่อไข่ -> คีย์กลาง: ตัดวงเล็บ [..] (..), เว้นวรรค, คำว่า Egg แล้วเป็นตัวพิมพ์เล็ก
    -- "Cherub Egg", "Cherub", "Cherub Egg [50 KG]" และ "[Ethereal] Cherub Egg" จึงเป็นคีย์เดียวกัน
    local function normalizeEggName(name)
        local s = tostring(name or "")
        s = s:gsub("%s*%b[]", "")
        s = s:gsub("%s*%b()", "")
        s = s:lower()
        s = s:gsub("%s+", "")
        s = s:gsub("egg", "")
        return s
    end

    local RARITY_RANK = {
        Common = 1, Uncommon = 2, Rare = 3, Epic = 4,
        Legendary = 5, Mythic = 6, Divine = 7, Ethereal = 8,
    }

    -- ข้อมูลจริงจากเกม (Rarity / Luck / Image)
    local GameEggsData = {}
    pcall(function()
        local gameData = ReplicatedStorage:WaitForChild("GameData", 5)
        local module = gameData and gameData:WaitForChild("Eggs", 5)
        if module then
            local data = require(module)
            if type(data) == "table" then GameEggsData = data end
        end
    end)

    -- ข้อมูลสำรอง ใช้เฉพาะกรณีอ่านจากเกมไม่ได้
    local FALLBACK_EGGS = {
        ["Volcanic Egg"] = { luck = 2500000000000, rarity = "Ethereal" },
        ["Cherub Egg"]   = { luck = 1000000000000, rarity = "Ethereal" },
        ["Asteroid Egg"] = { luck = 500000000000,  rarity = "Ethereal" },
        ["Solaris Egg"]  = { luck = 300000000000,  rarity = "Ethereal" },
        ["Blackhole Egg"]= { luck = 100000000000,  rarity = "Ethereal" },
        ["Galaxy Egg"]   = { luck = 1500000000,    rarity = "Divine" },
        ["Aurora Egg"]   = { luck = 300000000,     rarity = "Divine" },
        ["Soul Egg"]     = { luck = 7000000,       rarity = "Mythic" },
        ["Sinister Egg"] = { luck = 3000000,       rarity = "Mythic" },
        ["Flaming Egg"]  = { luck = 1000000,       rarity = "Mythic" },
        ["Dominus Egg"]  = { luck = 700000,        rarity = "Mythic" },
        ["Skull Egg"]    = { luck = 250000,        rarity = "Mythic" },
        ["Crystal Egg"]  = { luck = 150000,        rarity = "Mythic" },
        ["Diamond Egg"]  = { luck = 80000,         rarity = "Legendary" },
        ["Tidal Egg"]    = { luck = 50000,         rarity = "Legendary" },
        ["Golden Egg"]   = { luck = 30000,         rarity = "Legendary" },
        ["Glass Egg"]    = { luck = 10000,         rarity = "Legendary" },
        ["Ice Egg"]      = { luck = 3000,          rarity = "Epic" },
        ["Slime Egg"]    = { luck = 1000,          rarity = "Epic" },
        ["Flower Egg"]   = { luck = 750,           rarity = "Epic" },
        ["Bloom Egg"]    = { luck = 600,           rarity = "Epic" },
        ["Mushroom Egg"] = { luck = 500,           rarity = "Epic" },
        ["Leaf Egg"]     = { luck = 200,           rarity = "Rare" },
        ["Stone Egg"]    = { luck = 100,           rarity = "Rare" },
        ["Easter Egg"]   = { luck = 50,            rarity = "Rare" },
        ["Cracked Egg"]  = { luck = 30,            rarity = "Rare" },
        ["Brown Egg"]    = { luck = 5,             rarity = "Common" },
        ["White Egg"]    = { luck = 1,             rarity = "Common" },
    }

    local function getEggImage(data)
        if type(data) ~= "table" then return nil end
        for _, key in ipairs({ "Image", "ImageId", "Icon", "IconId", "Thumbnail", "ThumbnailId", "Texture", "TextureId" }) do
            local v = data[key]
            if v ~= nil then
                local t = tostring(v)
                if t ~= "" then
                    if t:find("rbxassetid://", 1, true) == 1 or t:find("rbxthumb://", 1, true) == 1 then
                        return t
                    end
                    local id = t:match("(%d+)")
                    if id then return "rbxassetid://" .. id end
                end
            end
        end
        return nil
    end

    local function makeInfo(rarity, luck, image)
        local rank = RARITY_RANK[rarity] or 0
        return {
            rarity = rarity or "Unknown",
            priority = rank * 1e13 + (tonumber(luck) or 1),
            image = image,
        }
    end

    local EGG_INFO = {}       -- normalizedName -> info
    local EGG_RAW_NAME = {}   -- normalizedName -> ชื่อจริงในเกม

    local function buildEggInfo()
        EGG_INFO, EGG_RAW_NAME = {}, {}

        local hasGameData = next(GameEggsData) ~= nil

        if hasGameData then
            for key, data in pairs(GameEggsData) do
                if type(data) == "table" then
                    local n = normalizeEggName(key)
                    if n ~= "" then
                        local rarity = type(data.Rarity) == "string" and data.Rarity or "Common"
                        EGG_INFO[n] = makeInfo(rarity, data.Luck or data.luck, getEggImage(data))
                        EGG_RAW_NAME[n] = tostring(key)
                    end
                end
            end
        else
            for name, d in pairs(FALLBACK_EGGS) do
                local n = normalizeEggName(name)
                EGG_INFO[n] = makeInfo(d.rarity, d.luck, nil)
                EGG_RAW_NAME[n] = name
            end
        end
    end

    buildEggInfo()

    local WarnedUnknownEggs = {}
    local function lookupEggInfo(eggName)
        local n = normalizeEggName(eggName)
        local info = EGG_INFO[n]
        if not info and tostring(eggName):lower():find("egg", 1, true) and not WarnedUnknownEggs[n] then
            WarnedUnknownEggs[n] = true
            warn("[RideAPet] พบไข่ที่ไม่มีข้อมูล: \"" .. tostring(eggName) .. "\"")
        end
        return info
    end

    -- ============================================================
    -- รายชื่อไข่สำหรับ Dropdown (สแกนสด + เรียงจากหายากสุด)
    -- ============================================================

    local SortedEggs = {}       -- { label, rawName, priority, image }
    local OptionToRawName = {}  -- label -> rawName

    local function cleanEggTitle(rawName)
        local s = tostring(rawName):gsub("%s*%b[]", ""):gsub("%s*%b()", "")
        s = s:gsub("%s*[Ee]gg%s*$", "")
        s = s:gsub("^%s+", ""):gsub("%s+$", "")
        if s == "" then s = tostring(rawName) end
        return s
    end

    local function RefreshDynamicEggList()
        SortedEggs = {}
        OptionToRawName = {}

        local found = {} -- normalizedName -> rawName

        for n, raw in pairs(EGG_RAW_NAME) do
            found[n] = raw
        end

        local function addFromWorld(nameToCheck)
            if type(nameToCheck) ~= "string" or nameToCheck == "" then return end
            if nameToCheck:find("^[0-9]+$") then return end
            local n = normalizeEggName(nameToCheck)
            if n ~= "" and not found[n] then
                found[n] = nameToCheck
            end
        end

        local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
        if renderedEggs then
            for _, item in ipairs(renderedEggs:GetChildren()) do
                if item:IsA("Model") then
                    local attr = item:GetAttribute("Egg") or item:GetAttribute("EggType") or item:GetAttribute("Type")
                    addFromWorld(type(attr) == "string" and attr or item.Name)
                end
            end
        end

        local serverData = ReplicatedStorage:FindFirstChild("ServerData")
        local activeEggs = serverData and serverData:FindFirstChild("ActiveEggs")
        if activeEggs then
            for _, ae in ipairs(activeEggs:GetChildren()) do
                local attr = ae:GetAttribute("Egg") or ae:GetAttribute("EggType")
                addFromWorld(type(attr) == "string" and attr or ae.Name)
            end
        end

        for n, raw in pairs(found) do
            local info = EGG_INFO[n] or lookupEggInfo(raw)
            local rarity = info and info.rarity or "Unknown"
            local label = string.format("%s [%s]", cleanEggTitle(raw), rarity)
            table.insert(SortedEggs, {
                label = label,
                rawName = raw,
                priority = info and info.priority or 0,
                image = info and info.image or nil,
            })
            OptionToRawName[label] = raw
        end

        table.sort(SortedEggs, function(a, b)
            if a.priority == b.priority then
                return a.label < b.label
            end
            return a.priority > b.priority
        end)
    end

    RefreshDynamicEggList()

    -- ค่าที่ส่งให้ Dropdown แบบมีไอคอน (Advanced Dropdown ของ WindUI)
    local function getDropdownValues()
        local values = { { Title = ALL_LABEL, Icon = "check-check" } }
        for _, egg in ipairs(SortedEggs) do
            table.insert(values, { Title = egg.label, Icon = egg.image or "egg" })
        end
        return values
    end

    -- ============================================================
    -- Selection (set ของ normalizedName + ธง __ALL)
    -- ============================================================

    local function parseSelection(selected)
        local result = {}

        local function add(value)
            if type(value) == "table" then
                local title = value.Title or value.Value or value.Name
                if title then add(title) end
                return
            end
            if type(value) ~= "string" then return end
            if isAllSelection(value) then
                result.__ALL = true
                return
            end
            local rawName = OptionToRawName[value] or value
            local n = normalizeEggName(rawName)
            if n ~= "" then result[n] = true end
        end

        if type(selected) == "table" then
            for k, item in pairs(selected) do
                if type(k) == "string" and (item == true or item == 1) then
                    add(k)
                else
                    add(item)
                end
            end
        else
            add(selected)
        end

        return result
    end

    local function loadSelection(list)
        local set = {}
        for _, name in ipairs(list or {}) do
            if isAllSelection(name) then
                set.__ALL = true
            else
                local n = normalizeEggName(name)
                if n ~= "" then set[n] = true end
            end
        end
        return set
    end

    local function isSelected(set, eggName)
        if set.__ALL then return true end
        return set[normalizeEggName(eggName)] == true
    end

    local function collectSelected(set)
        local list = {}
        if set.__ALL then table.insert(list, ALL_LABEL) end
        local seen = {}
        for _, egg in ipairs(SortedEggs) do
            local n = normalizeEggName(egg.rawName)
            if set[n] and not seen[n] then
                seen[n] = true
                table.insert(list, egg.rawName)
            end
        end
        return list
    end

    local function buildInitialLabels(set)
        local labels = {}
        if set.__ALL then table.insert(labels, ALL_LABEL) end
        for _, egg in ipairs(SortedEggs) do
            if set[normalizeEggName(egg.rawName)] then
                table.insert(labels, egg.label)
            end
        end
        return labels
    end

    local SelectedEggTypes = loadSelection(SavedConfig.SelectedEggNames)
    local SelectedEspEggTypes = loadSelection(SavedConfig.SelectedEspEggNames)
    local SelectedPlaceEggTypes = loadSelection(SavedConfig.SelectedPlaceEggNames)

    local AutoFarmEnabled = false
    local AutoPlaceEnabled = false
    local PlaceMode = SavedConfig.PlaceMode or "วางเฉพาะที่เลือก"
    local AutoPlaceBusy = false
    local AutoPlaceBlockedEggs = {}
    local MyPlotCFrame = nil


    -- ซ่อนเฉพาะข้อความแจ้งเตือน "Your Egg Was Returned" ถ้าเกมสร้างขึ้นมา
    -- (เป็นการซ่อน UI เท่านั้น ไม่ได้เปลี่ยนผลลัพธ์ที่เซิร์ฟเวอร์ตรวจสอบ)
    local ReturnedPopupConnection = nil
    local function suppressReturnedEggPopup()
        local function scan(root)
            if not root then return end
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    local s = tostring(obj.Text or ""):lower()
                    if s:find("your egg was returned", 1, true)
                        or s:find("egg was returned", 1, true)
                        or s:find("ไข่ของคุณถูกส่งคืนแล้ว", 1, true)
                    then
                        pcall(function() obj.Visible = false end)
                    end
                end
            end
        end

        if ReturnedPopupConnection then
            ReturnedPopupConnection:Disconnect()
        end
        ReturnedPopupConnection = RunService.RenderStepped:Connect(function()
            scan(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
            scan(CoreGui)
        end)
    end

    local function stopSuppressReturnedEggPopup()
        if ReturnedPopupConnection then
            ReturnedPopupConnection:Disconnect()
            ReturnedPopupConnection = nil
        end
    end

    local statusParagraph = nil
    local function setStatus(text)
        if statusParagraph then
            pcall(function() statusParagraph:SetDesc(text) end)
        end
    end

    local function SaveConfig(cfg)
        if writefile then
            pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end)
        end
    end

    local function PersistEggConfig()
        SaveConfig({
            EspEnabled = SavedConfig.EspEnabled,
            SelectedEggNames = collectSelected(SelectedEggTypes),
            SelectedEspEggNames = collectSelected(SelectedEspEggTypes),
            SelectedPlaceEggNames = collectSelected(SelectedPlaceEggTypes),
            PlaceMode = PlaceMode
        })
    end

    RunService.RenderStepped:Connect(function()
        if AutoFarmEnabled then
            pcall(function() GuiService:SetMenuIsOpen(false) end)
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui.Name == "StreamingPauseGui" or gui:FindFirstChild("PauseFrame") or gui.Name:find("Pause") then
                        pcall(function() gui.Enabled = false end)
                    end
                end
            end
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui then
                local pauseGui = robloxGui:FindFirstChild("StreamingPauseGui")
                if pauseGui then pcall(function() pauseGui.Enabled = false end) end
            end
        end
    end)

    local NoClipConnection = nil
    local function setNoClip(enabled)
        if enabled then
            if not NoClipConnection then
                NoClipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetChildren()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            end
        else
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    local function saveHomePosition()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            MyPlotCFrame = hrp.CFrame
            return true
        end
        return false
    end

    local function findPickupPrompt(eggModel)
        return eggModel and eggModel:FindFirstChild("Pickup", true)
    end

    local function eggModelName(item)
        local attr = item:GetAttribute("Egg") or item:GetAttribute("EggType")
        return type(attr) == "string" and attr ~= "" and attr or item.Name
    end

    local function getAvailableEggs()
        local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
        if not renderedEggs then return {} end

        local eggList = {}
        for _, item in ipairs(renderedEggs:GetChildren()) do
            if item:IsA("Model") then
                local prompt = findPickupPrompt(item)
                if prompt and prompt.Parent then
                    local eggName = eggModelName(item)
                    if isSelected(SelectedEggTypes, eggName) then
                        local info = lookupEggInfo(eggName)
                        table.insert(eggList, {
                            model = item,
                            name = eggName,
                            prompt = prompt,
                            priority = info and info.priority or 1,
                            rarity = info and info.rarity or "Unknown",
                        })
                    end
                end
            end
        end

        table.sort(eggList, function(a, b) return a.priority > b.priority end)
        return eggList
    end

    -- ===== Auto Place Egg =====
    local PlaceFullMax = nil
    local PlaceEggFolder = nil
    local PlaceGuiLabel = nil
    local PlaceLastCapacityScan = 0

    local function isLikelyEggName(name)
        return tostring(name):lower():find("egg", 1, true) ~= nil or EGG_INFO[normalizeEggName(name)] ~= nil
    end

    local function getEggTools()
        local tools, seen = {}, {}
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local char = LocalPlayer.Character
        for _, container in ipairs({backpack, char}) do
            if container then
                for _, obj in ipairs(container:GetChildren()) do
                    if obj:IsA("Tool") and not seen[obj] and isLikelyEggName(obj.Name) then
                        seen[obj] = true
                        table.insert(tools, obj)
                    end
                end
            end
        end
        table.sort(tools, function(a, b)
            local ai = lookupEggInfo(a.Name)
            local bi = lookupEggInfo(b.Name)
            return (ai and ai.priority or 0) > (bi and bi.priority or 0)
        end)
        return tools
    end

    local function shouldPlaceTool(tool)
        if not tool or not tool.Parent then return false end
        if AutoPlaceBlockedEggs[normalizeEggName(tool.Name)] then return false end
        if PlaceMode == "วางทั้งหมด" then return true end
        return isSelected(SelectedPlaceEggTypes, tool.Name)
    end

    local function getMyEggFolder()
        if PlaceEggFolder and PlaceEggFolder.Parent then return PlaceEggFolder end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local ref = MyPlotCFrame and MyPlotCFrame.Position
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        ref = ref or (hrp and hrp.Position)
        if not ref then return nil end
        local best, dist = nil, math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            local folder = plot:FindFirstChild("Eggs", true)
            if folder and folder:IsA("Folder") then
                local ok, pos = pcall(function() return plot:GetPivot().Position end)
                if ok and pos then
                    local d = (pos - ref).Magnitude
                    if d < dist then best, dist = folder, d end
                end
            end
        end
        PlaceEggFolder = best
        return best
    end

    local function getPlacedEggCount()
        local folder = getMyEggFolder()
        if not folder then return 0 end
        local n = 0
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then n = n + 1 end
        end
        return n
    end

    local function getCapacity()
        local now = tick()
        if now - PlaceLastCapacityScan < 0.7 and PlaceFullMax then
            return PlaceFullMax
        end
        PlaceLastCapacityScan = now
        if PlaceGuiLabel and PlaceGuiLabel.Parent then
            local text = tostring(PlaceGuiLabel.Text or "")
            local cur, max = text:match("[Mm][Aa][Xx]%s*(%d+)%s*/%s*(%d+)")
            if cur and max then
                PlaceFullMax = tonumber(max)
                return PlaceFullMax
            end
        end
        local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not gui then return PlaceFullMax end
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local text = tostring(obj.Text or "")
                local lower = text:lower()
                local cur, max = text:match("[Mm][Aa][Xx]%s*(%d+)%s*/%s*(%d+)")
                if cur and max and lower:find("egg", 1, true) and lower:find("plot", 1, true) then
                    PlaceGuiLabel = obj
                    PlaceFullMax = tonumber(max)
                    return PlaceFullMax
                end
            end
        end
        return PlaceFullMax
    end

    local function gardenIsFull()
        local max = getCapacity()
        local placed = getPlacedEggCount()
        return max ~= nil and placed >= max, placed, max
    end

    local PlaceGridIndex = 0
    local PlaceGridPoints = nil

    local function getMyPlotModel()
        local folder = getMyEggFolder()
        return folder and folder.Parent
    end

    local function buildPlaceGrid()
        local plot = getMyPlotModel()
        if not plot then return nil end
        local ok, pivot = pcall(function() return plot:GetPivot() end)
        if not ok or not pivot then return nil end
        local okSize, size = pcall(function() return plot:GetExtentsSize() end)
        if not okSize or not size then size = Vector3.new(40, 10, 40) end

        local halfX = math.max(6, math.min(size.X * 0.5 - 3, 24))
        local halfZ = math.max(6, math.min(size.Z * 0.5 - 3, 24))
        local spacing = 4.5
        local points = {}
        local rows = math.max(1, math.floor((halfZ * 2) / spacing))
        local cols = math.max(1, math.floor((halfX * 2) / spacing))

        for rz = 0, rows - 1 do
            local z = -halfZ + spacing * 0.5 + rz * spacing
            for cx = 0, cols - 1 do
                local x = -halfX + spacing * 0.5 + cx * spacing
                table.insert(points, pivot:PointToWorldSpace(Vector3.new(x, 1.5, z)))
            end
        end
        PlaceGridPoints = points
        PlaceGridIndex = 0
        return points
    end

    local function getNextPlacePoint()
        local points = PlaceGridPoints or buildPlaceGrid()
        if not points or #points == 0 then return nil end

        local folder = getMyEggFolder()
        local occupied = {}
        if folder then
            for _, egg in ipairs(folder:GetChildren()) do
                if egg:IsA("Model") then
                    local ok, pos = pcall(function() return egg:GetPivot().Position end)
                    if ok and pos then
                        for i, point in ipairs(points) do
                            if (pos - point).Magnitude < 2.2 then occupied[i] = true end
                        end
                    end
                end
            end
        end

        for n = 1, #points do
            PlaceGridIndex = (PlaceGridIndex % #points) + 1
            if not occupied[PlaceGridIndex] then
                return points[PlaceGridIndex]
            end
        end
        return nil
    end

    local function moveMouseToWorld(worldPos)
        if not worldPos then return false end
        local camera = Workspace.CurrentCamera
        if not camera then return false end
        local screen, visible = camera:WorldToViewportPoint(worldPos)
        if not visible or screen.Z <= 0 then return false end
        local x, y = math.floor(screen.X), math.floor(screen.Y)

        local ok = pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseMoveEvent(x, y, game)
        end)
        if ok then return true end

        if mousemoverel and UserInputService and UserInputService.GetMouseLocation then
            local cur = UserInputService:GetMouseLocation()
            pcall(function() mousemoverel(x - cur.X, y - cur.Y) end)
            return true
        end
        return false
    end

    local function activateEggTool(tool)
        if not tool or not tool.Parent then return false end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        local before = getPlacedEggCount()
        if gardenIsFull() then return false end

        local target = getNextPlacePoint()
        if target then
            moveMouseToWorld(target)
            task.wait(0.08)
        end

        if not pcall(function() hum:EquipTool(tool) end) then return false end
        task.wait(0.12)

        if target then
            moveMouseToWorld(target)
            task.wait(0.05)
        end

        if not pcall(function() tool:Activate() end) then return false end
        local deadline = tick() + 1.2
        while tick() < deadline do
            if not AutoPlaceEnabled then return false end
            local full, placed = gardenIsFull()
            if placed > before then return true end
            if full then return false end
            task.wait(0.15)
        end
        return false
    end

    local function isNearHomeForPlace()
        if not MyPlotCFrame then return true end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        return (hrp.Position - MyPlotCFrame.Position).Magnitude <= 35
    end

    local function processAutoPlaceOnce()
        if AutoPlaceBusy or not AutoPlaceEnabled or not isNearHomeForPlace() then return end
        AutoPlaceBusy = true

        local ok, err = pcall(function()
            local full, placed, max = gardenIsFull()
            if full then
                setStatus(string.format("พื้นที่ในสวนเต็ม (%d/%d) — หยุดการวาง", placed, max))
                return
            end
            local tools = getEggTools()
            local made = 0
            for _, tool in ipairs(tools) do
                if not AutoPlaceEnabled then break end
                local liveFull = gardenIsFull()
                if liveFull then break end
                if shouldPlaceTool(tool) then
                    setStatus("กำลังวางไข่: " .. tool.Name)
                    local placedOk = activateEggTool(tool)
                    if placedOk then
                        made = made + 1
                        AutoPlaceBlockedEggs[normalizeEggName(tool.Name)] = nil
                    else
                        AutoPlaceBlockedEggs[normalizeEggName(tool.Name)] = true
                    end
                end
            end
            local afterFull, afterPlaced, afterMax = gardenIsFull()
            if afterFull then
                setStatus(string.format("พื้นที่ในสวนเต็ม (%d/%d) — หยุดการวาง", afterPlaced, afterMax))
            elseif made > 0 then
                setStatus("วางไข่สำเร็จ " .. made .. " ฟอง")
            else
                setStatus("รอช่องว่างในสวน...")
            end
        end)

        if not ok then
            warn("[RideAPet] AutoPlace error: " .. tostring(err))
        end
        AutoPlaceBusy = false
    end

    -- ============================================================
    -- ระบบเก็บไข่
    -- 1) วาปไปหาไข่  2) ยิง prompt + ส่ง UUID ของไข่ให้ remote
    -- 3) รอให้ไข่เข้า Basket/มือ แล้วหน่วงให้เซิร์ฟเวอร์ยืนยัน  4) วาปกลับฐาน + ฝากไข่จาก Basket
    -- ============================================================
    local function getChar()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        return char, hrp, hum
    end

    local function ownsPlot(p)
        local ownerId = p:GetAttribute("NestsOwnerLoaded") or p:GetAttribute("OwnerUserId")
        local ownerName = p:GetAttribute("Owner")
        local dataOwner = p:FindFirstChild("Data") and p.Data:FindFirstChild("Owner")
        local dataOwnerVal = dataOwner and (typeof(dataOwner.Value) == "Instance" and dataOwner.Value.Name or tostring(dataOwner.Value))
        return (ownerId and (tostring(ownerId) == tostring(LocalPlayer.UserId)))
            or (ownerName and tostring(ownerName) == LocalPlayer.Name)
            or (dataOwnerVal and dataOwnerVal:find(LocalPlayer.Name, 1, true) ~= nil)
    end

    local cachedPlot = nil
    local function getMyPlot()
        if cachedPlot and cachedPlot.Parent and ownsPlot(cachedPlot) then return cachedPlot end
        cachedPlot = nil
        local ok, General = pcall(function() return require(ReplicatedStorage.GameServices.General) end)
        if ok and General and General.GetPlot then
            local okPlot, p = pcall(function() return General:GetPlot(LocalPlayer) end)
            if okPlot and p then cachedPlot = p return p end
        end
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            for _, p in ipairs(plots:GetChildren()) do
                if ownsPlot(p) then cachedPlot = p return p end
            end
        end
        return nil
    end

    local function getBasePos()
        local plot = getMyPlot()
        if plot then
            local bp = plot:FindFirstChild("Baseplate")
            if bp then return bp.Position + Vector3.new(0, 4.5, 0), bp end
            local ok, pivot = pcall(function() return plot:GetPivot().Position end)
            if ok and pivot then return pivot + Vector3.new(0, 4, 0), nil end
        end
        if MyPlotCFrame then return MyPlotCFrame.Position, nil end
        return nil, nil
    end

    local function isOnMyPlot()
        local _, hrp = getChar()
        if not hrp then return false end
        local pos, bp = getBasePos()
        if not pos then return false end
        local ref = bp and bp.Position or pos
        local flat = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(ref.X, 0, ref.Z)).Magnitude
        return flat <= 38
    end

    -- ระบบเดินทาง: ใช้ Teleport โดยตรง ไม่ใช้ระบบบิน/Tween
    local function teleportTo(pos)
        local _, hrp = getChar()
        if not hrp or not pos then return false end

        local target = CFrame.new(pos) * hrp.CFrame.Rotation
        local ok = pcall(function()
            hrp.CFrame = target
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        return ok
    end

    local function triggerPrompt(prompt, holdTime)
        if not prompt or not prompt.Parent then return end
        local executed = false
        if fireproximityprompt then
            executed = pcall(function() fireproximityprompt(prompt, 0) end)
        end
        if not executed and prompt.InputHoldBegin and prompt.InputHoldEnd then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(holdTime or (prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.05) or 0.15))
                prompt:InputHoldEnd()
            end)
        end
    end

    -- หา UUID ของไข่จาก ReplicatedStorage.ServerData.ActiveEggs (จับคู่จากตำแหน่ง)
    local function getEggUuid(eggModel)
        local part = eggModel:FindFirstChildWhichIsA("BasePart", true) or eggModel.PrimaryPart
        local eggPos = part and part.Position or eggModel:GetPivot().Position
        local sd = ReplicatedStorage:FindFirstChild("ServerData")
        local folder = sd and sd:FindFirstChild("ActiveEggs")
        if folder then
            local best, bestDist = nil, 25
            for _, ae in ipairs(folder:GetChildren()) do
                local pos = ae:GetAttribute("Position")
                if typeof(pos) == "string" then
                    local c = string.split(pos, ",")
                    if #c == 3 then pos = Vector3.new(tonumber(c[1]), tonumber(c[2]), tonumber(c[3])) end
                end
                if typeof(pos) == "Vector3" then
                    local h = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(eggPos.X, 0, eggPos.Z)).Magnitude
                    local v = math.abs(pos.Y - eggPos.Y)
                    if h < 15 and v < 45 and h < bestDist then best, bestDist = ae, h end
                end
            end
            if best then return best.Name end
        end
        -- fallback: ดึง UUID จาก upvalue ของ prompt (ต้องใช้ getconnections)
        local prompt = eggModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and getconnections and getupvalues then
            local uuid
            pcall(function()
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then
                        for _, u in pairs(getupvalues(c.Function)) do
                            if typeof(u) == "Instance" and u.Parent and u.Parent.Name == "ActiveEggs" then
                                uuid = u.Name break
                            elseif type(u) == "string" and #u > 20 and u:find("-") then
                                uuid = u break
                            end
                        end
                    end
                    if uuid then break end
                end
            end)
            return uuid
        end
        return nil
    end

    local function isEggTool(it)
        return it:IsA("Tool") and (it.Name:find("Egg") or it:GetAttribute("Egg") or it:GetAttribute("IsEgg"))
    end

    -- ฝากไข่จาก Basket เข้ากระเป๋า โดยแตะ Baseplate ของแปลงตัวเอง
    local function depositBasket()
        local plot = getMyPlot()
        local baseplate = plot and plot:FindFirstChild("Baseplate")
        local _, hrp = getChar()
        if not baseplate or not hrp then return false end
        local basket = LocalPlayer:FindFirstChild("Basket")
        if not basket or #basket:GetChildren() == 0 then return true end

        local rel = baseplate.CFrame:PointToObjectSpace(hrp.Position)
        local onPlate = math.abs(rel.X) <= (baseplate.Size.X / 2 + 5) and math.abs(rel.Z) <= (baseplate.Size.Z / 2 + 5)
        if not onPlate then
            local y = baseplate.Position.Y + baseplate.Size.Y / 2 + 2.5
            hrp.CFrame = CFrame.new(Vector3.new(baseplate.Position.X, y, baseplate.Position.Z))
            task.wait(0.04)
        end
        if firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, baseplate, 0)
                task.wait(0.04)
                firetouchinterest(hrp, baseplate, 1)
            end)
        end
        local t0 = tick()
        while tick() - t0 < 0.8 and #basket:GetChildren() > 0 do
            task.wait(0.04)
        end
        return true
    end

    -- ตั้งค่าจังหวะเวลา — ใช้ Teleport ไปเก็บและ Teleport กลับ
    local Settings = {
        ArriveDelay = 0.05, -- รอหลังวาปถึงไข่ ก่อนกดเก็บ
        SettleDelay = 0.1,  -- รอหลังเก็บได้ ให้เซิร์ฟเวอร์ยืนยันก่อนวาปกลับ
        BaseDelay = 0.1,    -- รอหลังวาปถึงฐาน ก่อนฝากไข่
    }

    local function processEggCollection(eggData)
        local char, hrp, hum = getChar()
        if not hrp or not hum or hum.Health <= 0 then return false end
        if not eggData or not eggData.model or not eggData.model.Parent then return false end

        if not MyPlotCFrame then saveHomePosition() end

        -- ฝากไข่ที่ค้างใน Basket ก่อนเริ่มรอบใหม่
        local basket = LocalPlayer:FindFirstChild("Basket")
        if basket and #basket:GetChildren() > 0 then
            depositBasket()
            task.wait(0.08)
        end

        local model = eggData.model
        local prompt = eggData.prompt
        if not prompt or not prompt.Parent then
            prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
        end

        local part = model:FindFirstChildWhichIsA("BasePart", true) or model.PrimaryPart
        local eggPos = part and part.Position or model:GetPivot().Position
        local targetPos = eggPos + Vector3.new(0, 1.8, 0)

        local uuid = getEggUuid(model)

        setNoClip(true)

        setStatus("กำลังวาปไปหา " .. eggData.name .. "...")
        teleportTo(targetPos)

        -- รอให้เซิร์ฟเวอร์รับตำแหน่งใหม่ (เร็วเกินไป = ระยะเก็บไม่ผ่าน)
        task.wait(Settings.ArriveDelay)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)

        local basketNow = LocalPlayer:FindFirstChild("Basket")
        local prevBasketCount = basketNow and #basketNow:GetChildren() or 0

        local signal = nil
        local function acquired()
            local b = LocalPlayer:FindFirstChild("Basket")
            if b and #b:GetChildren() > prevBasketCount then signal = "basket" return true end
            local c = LocalPlayer.Character
            if c then
                for _, it in ipairs(c:GetChildren()) do
                    if isEggTool(it) then signal = "tool" return true end
                end
            end
            if not model or not model.Parent then signal = "model-gone" return true end
            return false
        end

        local pickupOk = false
        local pickupTime = 0
        local deadline = tick() + 2.5
        local attempt = 0
        while tick() < deadline and not pickupOk do
            attempt = attempt + 1
            if prompt and prompt.Parent and prompt.Enabled then
                if attempt == 1 then
                    triggerPrompt(prompt, 0.05)
                else
                    -- รอบถัดไปจำลองการกดค้างตาม HoldDuration จริงของ prompt
                    pcall(function()
                        prompt:InputHoldBegin()
                        task.wait((prompt.HoldDuration or 0) + 0.08)
                        prompt:InputHoldEnd()
                    end)
                end
            end
            -- remote รับ UUID ของไข่ (ไม่ใช่ Model)
            if EggPickupRemote and uuid then
                pcall(function() EggPickupRemote:FireServer(uuid) end)
            end
            task.wait(0.15)
            if acquired() then
                pickupOk = true
                pickupTime = tick()
            end
        end

        local collected = false
        if pickupOk then
            -- หน่วงให้เซิร์ฟเวอร์ยืนยันว่าไข่เป็นของเราแล้ว ก่อนวาปกลับ
            task.wait(Settings.SettleDelay)
            setStatus("เก็บ " .. eggData.name .. " แล้ว กำลังวาปกลับบ้าน...")

            local basePos = getBasePos()
            if basePos then
                pcall(function() LocalPlayer:RequestStreamAroundAsync(basePos) end)
                teleportTo(basePos)
                task.wait(Settings.BaseDelay)

                if not isOnMyPlot() then
                    teleportTo(basePos)
                    task.wait(Settings.BaseDelay)
                end
            elseif MyPlotCFrame then
                teleportTo(MyPlotCFrame.Position)
                task.wait(Settings.BaseDelay)
            end

            depositBasket()

            pcall(function() hum:UnequipTools() end)
            task.wait(0.08)

            local b = LocalPlayer:FindFirstChild("Basket")
            local basketLeft = b and #b:GetChildren() or 0
            collected = basketLeft == 0
            warn(string.format(
                "[RideAPet] %s | signal=%s uuid=%s hold=%s basketLeft=%d onPlot=%s carry=%.2fs",
                eggData.name, tostring(signal), tostring(uuid ~= nil),
                tostring(prompt and prompt.HoldDuration), basketLeft,
                tostring(isOnMyPlot()),
                tick() - pickupTime
            ))
            setStatus(collected and ("เก็บ " .. eggData.name .. " เข้ากระเป๋าแล้ว") or "ไข่ยังค้างในตะกร้า — ลองฝากใหม่...")
        else
            warn(string.format(
                "[RideAPet] เก็บ %s ไม่สำเร็จ | uuid=%s hold=%s enabled=%s attempts=%d",
                eggData.name, tostring(uuid ~= nil),
                tostring(prompt and prompt.HoldDuration), tostring(prompt and prompt.Enabled), attempt
            ))
            setStatus("เกมยังไม่ยอมรับการเก็บ " .. eggData.name .. " — ลองใหม่...")
        end

        setNoClip(false)
        return collected
    end

    -- ===== UI Interface =====
    local GameSection = Window.RVXGameSection or Window

    local FarmTab = GameSection:Tab({ Title = "Auto Egg", Icon = "egg" })
    local secFarm = FarmTab:Section({ Title = "ฟาร์มไข่อัตโนมัติ (Auto Egg Farm)" })

    secFarm:Toggle({
        Title = "เก็บไข่อัตโนมัติ (Auto Steal)",
        Desc = "วาปไปเก็บไข่ที่ตรงเงื่อนไข แล้ววาปกลับบ้านอัตโนมัติ",
        Value = false,
        Callback = function(state)
            AutoFarmEnabled = state
            if AutoFarmEnabled then
                if not MyPlotCFrame then saveHomePosition() end
                suppressReturnedEggPopup()
                setStatus("กำลังทำงาน...")
            else
                stopSuppressReturnedEggPopup()
                setStatus("หยุดแล้ว")
                setNoClip(false)
            end
        end,
    })

    local FarmDropdown = secFarm:Dropdown({
        Title = "เลือกไข่ที่จะเก็บ",
        Desc = "ดึงจากข้อมูลเกมจริง เรียงจากหายากสุดไปน้อยสุด",
        Values = getDropdownValues(),
        Value = buildInitialLabels(SelectedEggTypes),
        Multi = true,
        SearchBarEnabled = true,
        AllowNone = true,
        Callback = function(selected)
            SelectedEggTypes = parseSelection(selected)
            PersistEggConfig()
        end,
    })


    secFarm:Button({
        Title = "บันทึกจุดรังไข่ในแปลง (Set Home)",
        Desc = "บันทึกตำแหน่งปัจจุบันไว้เป็นจุดกลับบ้าน",
        Callback = function()
            local ok = saveHomePosition()
            WindUI:Notify({ Title = "Ride A Pet", Content = ok and "บันทึกจุดเรียบร้อย!" or "ล้มเหลว", Duration = 3 })
        end,
    })

    statusParagraph = secFarm:Paragraph({ Title = "สถานะ (Status)", Desc = "ปิดอยู่ (Idle)" })

    -- ===== Auto Place UI =====
    local PlaceTab = GameSection:Tab({ Title = "Auto Place", Icon = "package" })
    local secPlace = PlaceTab:Section({ Title = "วางไข่อัตโนมัติ (Auto Place Egg)" })

    secPlace:Toggle({
        Title = "วางไข่อัตโนมัติ (Auto Place)",
        Desc = "วางไข่ลงในสวนอัตโนมัติ โดยใช้ Tool ของไข่โดยตรง",
        Value = false,
        Callback = function(state)
            AutoPlaceEnabled = state
            if AutoPlaceEnabled then
                if not MyPlotCFrame then saveHomePosition() end
                setStatus("เปิด Auto Place — รออยู่ในแปลง...")
            else
                AutoPlaceBusy = false
                setStatus("ปิด Auto Place แล้ว")
            end
        end,
    })

    secPlace:Dropdown({
        Title = "โหมดวางไข่",
        Desc = "เลือกว่าจะวางไข่ทั้งหมด หรือเฉพาะไข่ที่เลือกด้านล่าง",
        Values = { "วางทั้งหมด", "วางเฉพาะที่เลือก" },
        Value = PlaceMode,
        Callback = function(selected)
            PlaceMode = selected
            PersistEggConfig()
        end,
    })

    local PlaceDropdown = secPlace:Dropdown({
        Title = "เลือกไข่ที่จะวาง",
        Desc = "เลือกหลายชนิดได้ หรือเลือก All เพื่อวางทุกชนิด",
        Values = getDropdownValues(),
        Value = buildInitialLabels(SelectedPlaceEggTypes),
        Multi = true,
        SearchBarEnabled = true,
        AllowNone = true,
        Callback = function(selected)
            SelectedPlaceEggTypes = parseSelection(selected)
            AutoPlaceBlockedEggs = {}
            PersistEggConfig()
        end,
    })

    task.spawn(function()
        while true do
            if AutoFarmEnabled then
                local ok, err = pcall(function()
                    local eggs = getAvailableEggs()
                    if #eggs > 0 then
                        local bestTarget = eggs[1]
                        setStatus("เป้าหมาย: " .. bestTarget.name .. " (" .. bestTarget.rarity .. ")")
                        processEggCollection(bestTarget)
                    else
                        setStatus("รอไข่ชนิดที่เลือกไว้...")
                    end
                end)
                if not ok then
                    warn("[RideAPet] AutoFarm error: " .. tostring(err))
                    setNoClip(false)
                end
            end
            task.wait(0.6)
        end
    end)

    task.spawn(function()
        while true do
            if AutoPlaceEnabled and (not AutoFarmEnabled or isNearHomeForPlace()) then
                processAutoPlaceOnce()
            end
            task.wait(0.8)
        end
    end)

    -- ===== ESP Tab =====
    local EspTab = GameSection:Tab({ Title = "ESP", Icon = "eye" })
    local secEsp = EspTab:Section({ Title = "แสดงตำแหน่งไข่พร้อมระยะห่าง" })

    local EspEnabled = SavedConfig.EspEnabled
    local EspBillboards = {}

    local function getEspGuiParent()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            return playerGui
        end
        local ok, hui = pcall(function()
            return gethui and gethui()
        end)
        if ok and hui then return hui end
        return CoreGui
    end

    local function destroyEspBillboard(eggModel)
        if EspBillboards[eggModel] then
            if EspBillboards[eggModel].gui then
                EspBillboards[eggModel].gui:Destroy()
            end
            EspBillboards[eggModel] = nil
        end
    end

    local function clearAllEsp()
        for eggModel in pairs(EspBillboards) do
            destroyEspBillboard(eggModel)
        end
    end

    local function createEspBillboard(eggModel, eggInfo)
        local part = eggModel:FindFirstChild("EggBase", true) or eggModel.PrimaryPart or eggModel:FindFirstChildWhichIsA("BasePart", true)
        if not part then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RVX_EggESP"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 150, 0, 45)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = eggModel.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Parent = billboard

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0.6, 0)
        infoLabel.Position = UDim2.new(0, 0, 0.4, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "[" .. (eggInfo and eggInfo.rarity or "Unknown") .. "] | ...m"
        infoLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 11
        infoLabel.Parent = billboard

        billboard.Parent = getEspGuiParent()
        EspBillboards[eggModel] = { gui = billboard, infoLabel = infoLabel, targetPart = part, rarity = eggInfo and eggInfo.rarity or "Unknown" }
    end

    secEsp:Toggle({
        Title = "เปิดใช้งาน ESP ไข่",
        Value = EspEnabled,
        Callback = function(state)
            EspEnabled = state
            SavedConfig.EspEnabled = state

            -- ถ้ายังไม่เคยเลือกชนิดไข่ ให้ ESP แสดงทุกชนิดเมื่อเปิด
            if EspEnabled and next(SelectedEspEggTypes) == nil then
                SelectedEspEggTypes.__ALL = true
            end

            PersistEggConfig()
            if not EspEnabled then
                clearAllEsp()
            end
        end,
    })

    local EspDropdown = secEsp:Dropdown({
        Title = "เลือกไข่ที่จะแสดง ESP",
        Desc = "เลือกประเภทไข่ที่ต้องการโชว์ป้าย หรือเลือก All",
        Values = getDropdownValues(),
        Value = buildInitialLabels(SelectedEspEggTypes),
        Multi = true,
        SearchBarEnabled = true,
        AllowNone = true,
        Callback = function(selected)
            SelectedEspEggTypes = parseSelection(selected)
            clearAllEsp()
            PersistEggConfig()
        end,
    })

    -- ===== ปุ่มรีเฟรชรายชื่อไข่ =====
    secFarm:Button({
        Title = "รีเฟรชรายชื่อไข่ (Refresh Eggs)",
        Desc = "สแกนรายชื่อไข่จากเกมใหม่ แล้วอัปเดตทุกเมนู",
        Callback = function()
            RefreshDynamicEggList()
            local values = getDropdownValues()
            for _, dd in ipairs({ FarmDropdown, PlaceDropdown, EspDropdown }) do
                pcall(function()
                    if dd.Refresh then
                        dd:Refresh(values)
                    elseif dd.SetValues then
                        dd:SetValues(values)
                    end
                end)
            end
            WindUI:Notify({
                Title = "Ride A Pet",
                Content = "พบไข่ " .. #SortedEggs .. " ชนิด",
                Duration = 3,
            })
        end,
    })

    task.spawn(function()
        while true do
            if EspEnabled then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local myPos = hrp and hrp.Position

                for eggModel, data in pairs(EspBillboards) do
                    if eggModel and eggModel.Parent and data.targetPart and data.targetPart.Parent then
                        if myPos then
                            local dist = math.floor((myPos - data.targetPart.Position).Magnitude)
                            data.infoLabel.Text = string.format("[%s] | %dm", data.rarity, dist)
                        end
                    else
                        destroyEspBillboard(eggModel)
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while true do
            if EspEnabled then
                local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
                if renderedEggs then
                    for _, eggModel in ipairs(renderedEggs:GetChildren()) do
                        if eggModel:IsA("Model") then
                            local eggName = eggModelName(eggModel)
                            if isSelected(SelectedEspEggTypes, eggName) then
                                if not EspBillboards[eggModel] then
                                    local info = lookupEggInfo(eggName)
                                    pcall(function() createEspBillboard(eggModel, info) end)
                                end
                            elseif EspBillboards[eggModel] then
                                destroyEspBillboard(eggModel)
                            end
                        end
                    end
                end
            else
                if next(EspBillboards) then
                    clearAllEsp()
                end
            end
            task.wait(0.5)
        end
    end)

    print("[RideAPet] Loaded Successfully — eggs: " .. #SortedEggs)
end

return RideAPet
