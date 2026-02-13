-- Killstreak HUD by Matsilagi

if not HOLOHUD2 then return end

if SERVER then return end

local IsEnabled = HOLOHUD2.IsEnabled
local element_killstreak = HOLOHUD2.element.Get("killstreak")
local LocalPlayer = LocalPlayer

local streak = -1

HOLOHUD2.hook.Add("ShouldDrawKillstreak", "killstreak", function()
    streak = LocalPlayer():GetNW2Int("killstreak", -1)
    if streak == -1 then return end
    return true
end)

HOLOHUD2.hook.Add("GetStreak", "killstreak", function()
    if streak == -1 then return end
    return streak
end)

hook.Add("ffgs_utils_killstreak_draw", "holohud2", function()
    if streak == -1 then return end
    if not IsEnabled() or not element_killstreak:IsVisible() then return end
    return true
end)