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
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character

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

    local AutoCollectEnabled = false
    local AutoPlaceEnabled = false
    local PlaceMode = SavedConfig.PlaceMode or "วางเฉพาะที่เลือก"
    local AutoPlaceBusy = false
    local AutoPlaceBlockedEggs = {}
    local MyPlotCFrame = nil


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

    local lastPauseScan = 0
    RunService.RenderStepped:Connect(function()
        if AutoCollectEnabled and tick() - lastPauseScan >= 0.2 then
            lastPauseScan = tick()
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
        task.wait(0.25)

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
            task.wait(0.25)
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
    -- 1) วาปไปหาไข่  2) ใช้ ProximityPrompt เหมือนการเก็บด้วยมือ
    -- 3) รอให้ไข่เข้า Basket/มือจริง  4) วาปกลับฐาน + ฝากไข่จาก Basket
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

    -- ============================================================
    -- AUTO COLLECT (ระบบเก็บไข่จาก RVX Hub เดิม)
    -- 1) วาป/บิน ไปที่ไข่  2) กด ProximityPrompt + ยิง EggPickup ซ้ำจนไข่หาย
    -- 3) วาปกลับจุดบ้าน (Set Home)
    -- ============================================================

    local MOVE_TELEPORT = "วาป (Teleport ทันที)"
    local MOVE_TWEEN = "บิน (Tween ลื่นๆ)"
    local MoveMode = MOVE_TELEPORT

    local function setAutoCollectNoclip(enabled)
        setNoClip(enabled)
    end

    local function tweenToCFrame(targetCFrame, speed)
        local char, hrp = getChar()
        if not hrp then return end
        local duration = math.clamp((hrp.Position - targetCFrame.Position).Magnitude / (speed or 40), 0.3, 3)
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
    end

    local function zeroVelocity(hrp)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    local function getPromptPosition(prompt, model)
        local parent = prompt and prompt.Parent
        local part = nil
        if parent then
            if parent:IsA("BasePart") then
                part = parent
            elseif parent:IsA("Attachment") and parent.Parent and parent.Parent:IsA("BasePart") then
                part = parent.Parent
            end
        end
        if part then return part.Position end
        return model:GetPivot().Position
    end

    local function eggIsGone(model)
        return not model or not model.Parent
    end

    local function fireEggPrompt(prompt)
        local fire = fireproximityprompt
        if not fire and getgenv then
            fire = getgenv().fireproximityprompt
        end
        if fire then
            pcall(function() fire(prompt, 1, true) end)
        else
            pcall(function() prompt:InputHoldBegin() end)
            task.wait(0.05)
            pcall(function() prompt:InputHoldEnd() end)
        end
    end

    local function teleportHome()
        local _, hrp = getChar()
        if not hrp or not MyPlotCFrame then return end

        pcall(function() LocalPlayer:RequestStreamAroundAsync(MyPlotCFrame.Position) end)
        pcall(function()
            hrp.CFrame = MyPlotCFrame
            zeroVelocity(hrp)
        end)
        task.wait(0.1)

        if (hrp.Position - MyPlotCFrame.Position).Magnitude > 15 then
            pcall(function()
                hrp.CFrame = MyPlotCFrame
                zeroVelocity(hrp)
            end)
        end
    end

    -- เก็บไข่ 1 ใบ: คืน true ถ้าเก็บได้ (ไข่หายจากแมพ)
    local function collectEgg(target)
        local _, hrp = getChar()
        if not hrp or eggIsGone(target.model) then return false end

        if not MyPlotCFrame then saveHomePosition() end
        setAutoCollectNoclip(true)

        local prompt = target.prompt
        local eggPos = getPromptPosition(prompt, target.model)
        local targetCFrame = CFrame.new(eggPos + Vector3.new(0, 4.5, 0))

        setStatus("วาปไป " .. target.name)
        if MoveMode == MOVE_TELEPORT then
            hrp.CFrame = targetCFrame
            zeroVelocity(hrp)
        else
            tweenToCFrame(targetCFrame, 45)
        end
        task.wait(0.1)

        local collected = false
        local startTime = tick()
        setStatus("กำลังกดหยิบ " .. target.name)

        while tick() - startTime < 2.5 do
            if eggIsGone(target.model) then
                collected = true
                break
            end

            if prompt and prompt.Parent then
                fireEggPrompt(prompt)
            end

            if EggPickupRemote then
                pcall(function() EggPickupRemote:FireServer(target.model) end)
            end

            task.wait(0.1)
        end

        if eggIsGone(target.model) then collected = true end

        if collected then
            setStatus("ถือไข่แล้ว → วาปกลับบ้าน")
            teleportHome()
        else
            setStatus("การเก็บล้มเหลว " .. target.name .. " — ลองใหม่...")
        end

        setAutoCollectNoclip(false)
        return collected
    end

    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        task.defer(function()
            if not AutoCollectEnabled then
                for _, obj in ipairs(newCharacter:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanCollide = true
                    end
                end
            end
        end)
    end)


    -- ===== UI Interface =====
    local GameSection = Window.RVXGameSection or Window

    local FarmTab = GameSection:Tab({ Title = "Auto Egg", Icon = "egg" })
    local secFarm = FarmTab:Section({ Title = "ฟาร์มไข่อัตโนมัติ (Auto Egg Farm)" })

    secFarm:Toggle({
        Title = "เก็บไข่อัตโนมัติ (Auto Collect)",
        Desc = "บิน/วาป ไปเก็บไข่ที่ตรงเงื่อนไข แล้วกลับบ้านอัตโนมัติ",
        Value = false,
        Callback = function(state)
            AutoCollectEnabled = state
            if AutoCollectEnabled then
                if not MyPlotCFrame then saveHomePosition() end
                setStatus("กำลังทำงาน...")
            else
                setStatus("หยุดแล้ว")
                setAutoCollectNoclip(false)
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

    secFarm:Dropdown({
        Title = "วิธีไปเก็บไข่ (Movement)",
        Desc = "บิน = Tween ไปหาไข่ | วาป = Teleport ถึงจุดและกลับทันที",
        Values = { MOVE_TWEEN, MOVE_TELEPORT },
        Value = MOVE_TELEPORT,
        Callback = function(selected)
            MoveMode = selected
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
            if AutoCollectEnabled then
                local ok, err = pcall(function()
                    local eggs = getAvailableEggs()
                    if #eggs > 0 then
                        local target = eggs[1]
                        setStatus("เป้าหมาย: " .. target.name .. " (" .. target.rarity .. ")")
                        collectEgg(target)
                    else
                        setStatus("รอไข่ชนิดที่เลือกไว้...")
                    end
                end)
                if not ok then
                    warn("[RideAPet] AutoCollect error: " .. tostring(err))
                    setAutoCollectNoclip(false)
                end
            end
            task.wait(0.6)
        end
    end)

    task.spawn(function()
        while true do
            if AutoPlaceEnabled and (not AutoCollectEnabled or isNearHomeForPlace()) then
                processAutoPlaceOnce()
            end
            task.wait(1.2)
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
