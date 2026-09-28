-- RideAPet SAFE TEST
-- Diagnostic build: intentionally does NOT interact with egg pickup, remotes,
-- ProximityPrompts, teleportation, noclip, Basket, or Auto Farm/Auto Place.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

warn("[RideAPet SAFE TEST] Loaded — no egg pickup systems are running")
warn("[RideAPet SAFE TEST] Auto Farm: OFF | Auto Place: OFF | Teleport: OFF | Remote: OFF")

-- Keep this script passive so manually collecting an egg is exactly the same
-- as collecting it without the script running.
return {
    Name = "RideAPet SAFE TEST",
    AutoFarm = false,
    AutoPlace = false,
    Teleport = false,
    EggPickupRemote = false,
    ProximityPromptHooks = false,
    NoClip = false,
}
