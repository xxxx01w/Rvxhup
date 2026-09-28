--[[
    RVX Hub - Ride A Pet (Auto Egg Farm) (fixed)
    Module pattern: return table with Init(Window, WindUI)
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

    -- ===== ระบบจดจำการตั้งค่า (Auto Save Config) =====
    local CONFIG_FILE = "RVXHub_RideAPetConfig.json"

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

    -- ตารางข้อมูลไข่
    -- หมายเหตุ: Tidal Egg และ Bloom Egg ค่า priority/rarity เป็นค่าประมาณ ปรับให้ตรงกับเกมจริงได้
    local EGG_DATA = {
        ["Volcanic Egg"]   = { priority = 2500000000000, rarity = "Ethereal" },
        ["Cherub Egg"]     = { priority = 1000000000000, rarity = "Ethereal" },
        ["Asteroid Egg"]   = { priority = 500000000000,  rarity = "Ethereal" },
        ["Solaris Egg"]    = { priority = 300000000000,  rarity = "Ethereal" },
        ["Blackhole Egg"]  = { priority = 100000000000,  rarity = "Ethereal" },
        ["Galaxy Egg"]     = { priority = 1500000000,    rarity = "Divine" },
        ["Aurora Egg"]     = { priority = 300000000,     rarity = "Divine" },
        ["Soul Egg"]       = { priority = 7000000,       rarity = "Mythic" },
        ["Sinister Egg"]   = { priority = 3000000,       rarity = "Mythic" },
        ["Flaming Egg"]    = { priority = 1000000,       rarity = "Mythic" },
        ["Dominus Egg"]    = { priority = 700000,        rarity = "Mythic" },
        ["Skull Egg"]      = { priority = 250000,        rarity = "Mythic" },
        ["Crystal Egg"]    = { priority = 150000,        rarity = "Mythic" },
        ["Diamond Egg"]    = { priority = 80000,         rarity = "Legendary" },
        ["Tidal Egg"]      = { priority = 50000,         rarity = "Legendary" },
        ["Golden Egg"]     = { priority = 30000,         rarity = "Legendary" },
        ["Glass Egg"]      = { priority = 10000,         rarity = "Legendary" },
        ["Ice Egg"]        = { priority = 3000,          rarity = "Epic" },
        ["Slime Egg"]      = { priority = 1000,          rarity = "Epic" },
        ["Flower Egg"]     = { priority = 750,           rarity = "Epic" },
        ["Bloom Egg"]      = { priority = 600,           rarity = "Epic" },
        ["Mushroom Egg"]   = { priority = 500,           rarity = "Epic" },
        ["Leaf Egg"]       = { priority = 200,           rarity = "Rare" },
        ["Stone Egg"]      = { priority = 100,           rarity = "Rare" },
        ["Easter Egg"]     = { priority = 50,            rarity = "Rare" },
        ["Cracked Egg"]    = { priority = 30,            rarity = "Rare" },
        ["Brown Egg"]      = { priority = 5,             rarity = "Common" },
        ["White Egg"]      = { priority = 1,             rarity = "Common" },
    }

    local function normalizeEggName(name)
        return (tostring(name):gsub("%s+", ""):lower())
    end

    local NORMALIZED_EGG_DATA = {}
    for eggName, info in pairs(EGG_DATA) do
        NORMALIZED_EGG_DATA[normalizeEggName(eggName)] = info
    end

    local WarnedUnknownEggs = {}
    local function lookupEggInfo(eggName)
        local info = NORMALIZED_EGG_DATA[normalizeEggName(eggName)]
        if not info and tostring(eggName):lower():find("egg", 1, true) and not WarnedUnknownEggs[eggName] then
            WarnedUnknownEggs[eggName] = true
            warn("[RideAPet] พบชื่อไข่ที่ไม่มีในตาราง EGG_DATA: \"" .. tostring(eggName) .. "\"")
        end
        return info
    end

    -- ===== สแกนรายชื่อไข่สดจากเกมอัตโนมัติ (เรียงตาม Priority) =====
    local AvailableEggOptions = {}
    local OptionToRawName = {}

    local function RefreshDynamicEggList()
        AvailableEggOptions = {}
        OptionToRawName = {}
        local foundNames = {}

        local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
        if renderedEggs then
            for _, item in ipairs(renderedEggs:GetChildren()) do
                if item:IsA("Model") and not foundNames[item.Name] then
                    foundNames[item.Name] = true
                end
            end
        end

        for rawName, _ in pairs(EGG_DATA) do
            foundNames[rawName] = true
        end

        local eggListTemp = {}
        for rawName in pairs(foundNames) do
            local info = lookupEggInfo(rawName)
            local priority = info and info.priority or 0
            local rarity = info and info.rarity or "Unknown"
            local label = string.format("[%s] %s", rarity, rawName)

            table.insert(eggListTemp, {
                label = label,
                rawName = rawName,
                priority = priority
            })
            OptionToRawName[label] = rawName
        end

        table.sort(eggListTemp, function(a, b)
            if a.priority == b.priority then
                return a.rawName < b.rawName
            end
            return a.priority > b.priority
        end)

        for _, egg in ipairs(eggListTemp) do
            table.insert(AvailableEggOptions, egg.label)
        end
    end

    RefreshDynamicEggList()

    -- แปลงค่าที่ Dropdown คืนมา (array / map / string) เป็น set ของชื่อไข่ที่ normalize แล้ว
    local function parseSelection(selected)
        local result = {}

        local function add(value)
            if type(value) ~= "string" then return end
            local rawName = OptionToRawName[value] or value
            result[normalizeEggName(rawName)] = true
        end

        if type(selected) == "table" then
            for k, item in pairs(selected) do
                if type(k) == "string" and (item == true or item == 1) then
                    add(k)
                else
                    add(item)
                end
            end
        elseif type(selected) == "string" then
            add(selected)
        end

        return result
    end

    -- โหลดค่าไข่สำหรับ Auto Farm
    local SelectedEggTypes = {}
    for _, rawName in ipairs(SavedConfig.SelectedEggNames or {}) do
        SelectedEggTypes[normalizeEggName(rawName)] = true
    end

    -- โหลดค่าไข่สำหรับ ESP
    local SelectedEspEggTypes = {}
    for _, rawName in ipairs(SavedConfig.SelectedEspEggNames or {}) do
        SelectedEspEggTypes[normalizeEggName(rawName)] = true
    end

    -- โหลดค่าไข่สำหรับ Auto Place
    local SelectedPlaceEggTypes = {}
    for _, rawName in ipairs(SavedConfig.SelectedPlaceEggNames or {}) do
        SelectedPlaceEggTypes[normalizeEggName(rawName)] = true
    end

    local AutoFarmEnabled = false
    local AutoPlaceEnabled = false
    local PlaceMode = SavedConfig.PlaceMode or "วางเฉพาะที่เลือก"
    local AutoPlaceBusy = false
    local AutoPlaceBlockedEggs = {}
    local MyPlotCFrame = nil

    local MOVEMENT_MODE_OPTIONS = { "บิน (Tween ลื่นๆ)", "วาป (Teleport ทันที)" }
    local CurrentMovementMode = "วาป (Teleport ทันที)"

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

    -- วนจากรายชื่อที่สแกนได้จริง (OptionToRawName) ไม่ใช่แค่ EGG_DATA
    -- ไข่ใหม่ที่ยังไม่อยู่ในตารางจะได้บันทึกค่าติดด้วย
    local function collectSelected(set)
        local list, seen = {}, {}
        for _, rawName in pairs(OptionToRawName) do
            if set[normalizeEggName(rawName)] and not seen[rawName] then
                seen[rawName] = true
                table.insert(list, rawName)
            end
        end
        table.sort(list)
        return list
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

    local function tweenTo(targetCFrame, speed)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local time = math.clamp(distance / (speed or 40), 0.3, 3)

        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
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

    local function isEggTypeSelected(eggName)
        return SelectedEggTypes[normalizeEggName(eggName)] == true
    end

    local function isEspEggTypeSelected(eggName)
        return SelectedEspEggTypes[normalizeEggName(eggName)] == true
    end

    local function getAvailableEggs()
        local renderedEggs = Workspace:FindFirstChild("RenderedEggs")
        if not renderedEggs then return {} end

        local eggList = {}
        for _, item in ipairs(renderedEggs:GetChildren()) do
            if item:IsA("Model") then
                local prompt = findPickupPrompt(item)
                if prompt and prompt.Parent then
                    local info = lookupEggInfo(item.Name)
                    local priority = info and info.priority or 1
                    local rarity = info and info.rarity or "Unknown"

                    if isEggTypeSelected(item.Name) then
                        table.insert(eggList, {
                            model = item,
                            name = item.Name,
                            prompt = prompt,
                            priority = priority,
                            rarity = rarity,
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
        local n = normalizeEggName(name)
        return NORMALIZED_EGG_DATA[n] ~= nil or n:find("egg", 1, true) ~= nil
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

    local function isPlaceEggSelected(toolName)
        return SelectedPlaceEggTypes[normalizeEggName(toolName)] == true
    end

    local function shouldPlaceTool(tool)
        if not tool or not tool.Parent then return false end
        if AutoPlaceBlockedEggs and AutoPlaceBlockedEggs[normalizeEggName(tool.Name)] then return false end
        if PlaceMode == "วางทั้งหมด" then return true end
        return isPlaceEggSelected(tool.Name)
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

        -- เลื่อนเมาส์ซ้ำหลัง Equip เพราะบางเกมรีเซ็ต Mouse.Hit ตอนเปลี่ยน Tool
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

        -- ห่อด้วย pcall เพื่อให้ AutoPlaceBusy ถูกรีเซ็ตเสมอ แม้เกิด error กลางทาง
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

    local function processEggCollection(eggData)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not eggData or not eggData.model or not eggData.model.Parent then return false end

        if not MyPlotCFrame then saveHomePosition() end

        setNoClip(true)

        local prompt = eggData.prompt
        local targetPart = nil
        if prompt and prompt.Parent then
            if prompt.Parent:IsA("BasePart") then
                targetPart = prompt.Parent
            elseif prompt.Parent:IsA("Attachment") and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") then
                targetPart = prompt.Parent.Parent
            end
        end

        local targetPos
        if targetPart then
            targetPos = targetPart.Position
        else
            targetPos = eggData.model:GetPivot().Position
        end

        local targetCF = CFrame.new(targetPos + Vector3.new(0, 1.5, 0))

        if CurrentMovementMode == "วาป (Teleport ทันที)" then
            hrp.CFrame = targetCF
        else
            tweenTo(targetCF, 45)
        end

        task.wait(0.25)

        local collected = false
        local startTime = tick()

        while tick() - startTime < 3 do
            if not eggData.model or not eggData.model.Parent then
                collected = true
                break
            end

            if prompt and prompt.Parent then
                local firePrompt = fireproximityprompt or (getgenv and getgenv().fireproximityprompt)
                if firePrompt then
                    pcall(function() firePrompt(prompt, 1, true) end)
                else
                    pcall(function() prompt:InputHoldBegin() end)
                    task.wait(0.15)
                    pcall(function() prompt:InputHoldEnd() end)
                end
            end

            -- remote เป็น fallback เท่านั้น
            if EggPickupRemote then
                pcall(function() EggPickupRemote:FireServer(eggData.model) end)
            end

            task.wait(0.15)
        end

        if not eggData.model or not eggData.model.Parent then
            collected = true
        end

        if collected then
            setStatus("เก็บ " .. eggData.name .. " แล้ว กำลังวาปกลับบ้าน...")

            if MyPlotCFrame then
                pcall(function() LocalPlayer:RequestStreamAroundAsync(MyPlotCFrame.Position) end)
                task.wait(0.15)

                setStatus("กำลังวาปกลับเข้าแปลง...")
                hrp.CFrame = MyPlotCFrame
                task.wait(0.15)
            end
        else
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
        Desc = "บินไปเก็บไข่ที่ตรงเงื่อนไข แล้วบินกลับบ้านอัตโนมัติ",
        Value = false,
        Callback = function(state)
            AutoFarmEnabled = state
            if AutoFarmEnabled then
                if not MyPlotCFrame then saveHomePosition() end
                setStatus("กำลังทำงาน...")
            else
                setStatus("หยุดแล้ว")
                setNoClip(false)
            end
        end,
    })

    secFarm:Dropdown({
        Title = "วิธีไปเก็บไข่ (Movement)",
        Desc = "บิน = Tween ไปหาไข่และบินกลับ | วาป = ไปถึงทันที",
        Values = MOVEMENT_MODE_OPTIONS,
        Value = "วาป (Teleport ทันที)",
        Callback = function(selected) CurrentMovementMode = selected end,
    })

    local function buildInitialLabels(set)
        local labels = {}
        for label, rawName in pairs(OptionToRawName) do
            if set[normalizeEggName(rawName)] then
                table.insert(labels, label)
            end
        end
        return labels
    end

    secFarm:Dropdown({
        Title = "เลือกไข่ที่จะเก็บ",
        Desc = "สแกนไข่สดจากเกมเรียบร้อย (เรียงจากระดับสูงสุดไปต่ำสุด)",
        Values = AvailableEggOptions,
        Value = buildInitialLabels(SelectedEggTypes),
        Multi = true,
        Search = true,
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

    secPlace:Dropdown({
        Title = "เลือกไข่ที่จะวาง",
        Desc = "เลือกหลายชนิดได้เหมือนเมนูเลือกไข่ที่จะเก็บ",
        Values = AvailableEggOptions,
        Value = buildInitialLabels(SelectedPlaceEggTypes),
        Multi = true,
        Search = true,
        AllowNone = true,
        Callback = function(selected)
            SelectedPlaceEggTypes = parseSelection(selected)
            -- เลือกไข่ใหม่แล้ว ให้ล้างรายการที่เคยถูกบล็อกไว้
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

            -- ถ้ายังไม่เคยเลือกชนิดไข่ ให้ ESP แสดงไข่ที่รู้จักทั้งหมดเมื่อเปิด
            if EspEnabled and next(SelectedEspEggTypes) == nil then
                for rawName in pairs(EGG_DATA) do
                    SelectedEspEggTypes[normalizeEggName(rawName)] = true
                end
            end

            PersistEggConfig()
            if not EspEnabled then
                clearAllEsp()
            end
        end,
    })

    secEsp:Dropdown({
        Title = "เลือกไข่ที่จะแสดง ESP",
        Desc = "เลือกประเภทไข่ที่ต้องการโชว์ป้าย (หากไม่เลือกจะไม่โชว์ป้าย)",
        Values = AvailableEggOptions,
        Value = buildInitialLabels(SelectedEspEggTypes),
        Multi = true,
        Search = true,
        AllowNone = true,
        Callback = function(selected)
            SelectedEspEggTypes = parseSelection(selected)
            clearAllEsp()
            PersistEggConfig()
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
                            if isEspEggTypeSelected(eggModel.Name) then
                                if not EspBillboards[eggModel] then
                                    local info = lookupEggInfo(eggModel.Name)
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

    print("[RideAPet] Loaded Successfully")
end

return RideAPet
