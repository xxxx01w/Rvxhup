--[[
    RVX Hub - Moved Notice
    ไฟล์นี้สำหรับวางทับ main.lua บนโฮสต์เก่า (ที่ไม่อัปเดตแล้ว)
    เมื่อมีคนรันลิงก์เดิม จะขึ้นหน้าต่างแจ้งว่าย้ายลิงก์ พร้อมปุ่มคัดลอกลิงก์เว็บและ Discord
    สคริปต์เดิมจะไม่ถูกโหลดต่อ
--]]

-- ============================================================
-- ตั้งค่า (แก้ 2 บรรทัดนี้ให้เป็นลิงก์จริงของคุณ)
-- ============================================================

local WEBSITE_LINK = "https://script-vault-production.up.railway.app/"
local DISCORD_LINK = "https://discord.gg/WQePykh3yJ"

-- ถ้าอยากให้มีปุ่มคัดลอกสคริปต์ตัวใหม่ด้วย ใส่ loadstring ไว้ตรงนี้ (เว้นว่าง "" = ไม่แสดง)
local NEW_SCRIPT = ""

local TITLE   = "เราย้ายลิงก์สคริปต์แล้ว"
local MESSAGE = "ลิงก์นี้ไม่ได้รับการอัปเดตอีกต่อไป กรุณาไปรับสคริปต์ล่าสุดที่เว็บด้านล่าง หรือเข้า Discord เพื่อรับข่าวสาร"

-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local function getParent()
    local ok, p = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if ok and p then return p end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local parent = getParent()
local oldGui = parent:FindFirstChild("RVXMoved")
if oldGui then pcall(function() oldGui:Destroy() end) end
local oldBlur = Lighting:FindFirstChild("RVXMovedBlur")
if oldBlur then pcall(function() oldBlur:Destroy() end) end

local clip = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)

local gui = Instance.new("ScreenGui")
gui.Name = "RVXMoved"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() gui.Parent = parent end)
if not okParent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local blur = Instance.new("BlurEffect")
blur.Name = "RVXMovedBlur"
blur.Size = 0
blur.Parent = Lighting

local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.Parent = gui

local card = Instance.new("CanvasGroup")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 24)
card.Size = UDim2.fromOffset(420, 0)
card.AutomaticSize = Enum.AutomaticSize.Y
card.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
card.BorderSizePixel = 0
card.GroupTransparency = 1
card.Parent = gui

do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 14); c.Parent = card
    local s = Instance.new("UIStroke"); s.Color = Color3.new(1, 1, 1); s.Transparency = 0.85; s.Thickness = 1; s.Parent = card
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 18); pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 20); pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = card
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12); list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = card
end

-- แถวหัวเรื่อง (ลากหน้าต่างได้จากตรงนี้) + ปุ่มปิด
local head = Instance.new("Frame")
head.LayoutOrder = 1
head.Size = UDim2.new(1, 0, 0, 28)
head.BackgroundTransparency = 1
head.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 1, 0)
title.BackgroundTransparency = 1
title.Text = TITLE
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = head

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.new(1, 0, 0.5, 0)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
closeBtn.AutoButtonColor = false
closeBtn.Parent = head

local msg = Instance.new("TextLabel")
msg.LayoutOrder = 2
msg.Size = UDim2.new(1, 0, 0, 0)
msg.AutomaticSize = Enum.AutomaticSize.Y
msg.BackgroundTransparency = 1
msg.Text = MESSAGE
msg.Font = Enum.Font.Gotham
msg.TextSize = 14
msg.TextWrapped = true
msg.TextXAlignment = Enum.TextXAlignment.Left
msg.TextYAlignment = Enum.TextYAlignment.Top
msg.TextColor3 = Color3.fromRGB(175, 175, 175)
msg.Parent = card

-- แถวลิงก์ + ปุ่มคัดลอก
local function copyText(text)
    if not clip then return false end
    return (pcall(clip, text))
end

local function makeRow(order, label, link, btnText)
    local row = Instance.new("Frame")
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundTransparency = 1
    row.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(130, 130, 130)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Position = UDim2.fromOffset(0, 24)
    box.Size = UDim2.new(1, -92, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    box.BorderSizePixel = 0
    box.Text = link
    box.ClearTextOnFocus = false
    box.TextTruncate = Enum.TextTruncate.AtEnd
    box.Font = Enum.Font.Code
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(235, 235, 235)
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = row
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = box
    local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 10); bp.PaddingRight = UDim.new(0, 10); bp.Parent = box
    -- กันแก้ข้อความ (ยังเลือกคัดลอกเองได้)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if box.Text ~= link then box.Text = link end
    end)

    local btn = Instance.new("TextButton")
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.Position = UDim2.new(1, 0, 0, 24)
    btn.Size = UDim2.fromOffset(84, 36)
    btn.BackgroundColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.Text = btnText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.AutoButtonColor = true
    btn.Parent = row
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 8); cc.Parent = btn

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        local ok = copyText(link)
        btn.Text = ok and "คัดลอกแล้ว" or "เลือกคัดลอกเอง"
        if not ok then box:CaptureFocus() end
        task.delay(1.6, function()
            if btn.Parent then btn.Text = btnText end
            busy = false
        end)
    end)
end

makeRow(3, "เว็บสำหรับรับสคริปต์ใหม่", WEBSITE_LINK, "คัดลอก")
makeRow(4, "Discord (ข่าวสารและอัปเดต)", DISCORD_LINK, "คัดลอก")
if NEW_SCRIPT ~= "" then
    makeRow(5, "สคริปต์ตัวใหม่", NEW_SCRIPT, "คัดลอก")
end

-- ============================================================
-- เปิด / ปิด / ลากหน้าต่าง
-- ============================================================

local closed = false
local function close()
    if closed then return end
    closed = true
    local t = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(card, t, { GroupTransparency = 1, Position = card.Position + UDim2.fromOffset(0, 16) }):Play()
    TweenService:Create(dim, t, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blur, t, { Size = 0 }):Play()
    task.delay(0.4, function()
        pcall(function() blur:Destroy() end)
        pcall(function() gui:Destroy() end)
    end)
end

closeBtn.MouseButton1Click:Connect(close)
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.new(1, 1, 1) end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150) end)

local dragging, dragStart, startPos
head.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = card.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local tin = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(blur, tin, { Size = 18 }):Play()
TweenService:Create(dim, tin, { BackgroundTransparency = 0.5 }):Play()
TweenService:Create(card, tin, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) }):Play()
