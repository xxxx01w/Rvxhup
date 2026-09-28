-- RVX Hub - Ride A Pet SAFE TEST module
-- Passive module: does not touch egg pickup, remotes, teleport, noclip, basket, or prompts.
local RideAPet = {}

function RideAPet.Init(Window, WindUI)
    print("[RideAPet SAFE TEST] Loaded — passive module")
    print("[RideAPet SAFE TEST] Auto Farm: OFF | Auto Place: OFF | Teleport: OFF | Remote: OFF | Prompt: OFF")

    local GameSection = Window.RVXGameSection or Window
    local Tab = GameSection:Tab({ Title = "Ride A Pet Test", Icon = "shield-check" })
    local Section = Tab:Section({ Title = "Safe Test" })
    Section:Paragraph({
        Title = "สถานะ",
        Desc = "โหมดทดสอบแบบ Passive — ไม่มีระบบเก็บไข่หรือวาปทำงาน",
    })

    Section:Button({
        Title = "ตรวจสถานะ",
        Desc = "แสดงว่าโมดูลนี้ไม่ได้เรียกระบบเก็บไข่",
        Callback = function()
            print("[RideAPet SAFE TEST] Pickup Remote: OFF | ProximityPrompt: OFF | Teleport: OFF")
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Ride A Pet SAFE TEST",
                    Content = "Passive mode: ไม่มี Pickup/Prompt/Teleport",
                    Duration = 3,
                })
            end
        end,
    })
end

return RideAPet
