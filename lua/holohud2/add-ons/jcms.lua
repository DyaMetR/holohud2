---
--- Map Sweepers support
--- https://steamcommunity.com/sharedfiles/filedetails/?id=3523033966
---

if SERVER then return end

if not jcms then return end

local jcms_health       = jcms.draw_HUDHealthbar
local jcms_ammo         = jcms.draw_HUDAmmo
local jcms_compass      = jcms.draw_Compass
local jcms_notifsammo   = jcms.draw_NotifsAmmo
local jcms_information  = jcms.draw_Information

local IsVisible                 = HOLOHUD2.IsVisible
local element_health            = HOLOHUD2.element.Get( "health" )
local element_ammo              = HOLOHUD2.element.Get( "ammo" )
local element_compass           = HOLOHUD2.element.Get( "compass" )
local element_resourcehistory   = HOLOHUD2.element.Get( "resourcehistory" )
local element_money             = HOLOHUD2.element.Get( "money" )

---
--- Use gamemode's money
---
HOLOHUD2.hook.Add( "ShouldDrawMoney", "jcms", function()

    return true

end)

HOLOHUD2.hook.Add( "GetMoney", "jcms", function()

    return jcms.locPly:GetNWInt("jcms_cash", 0)

end)

---
--- Override original HUD
---
jcms.draw_HUDHealthbar = function()

    if IsVisible() and element_health:IsVisible() then return end

    jcms_health()

end

jcms.draw_HUDAmmo = function()

    if IsVisible() and element_ammo:IsVisible() then return end

    jcms_ammo()

end

jcms.draw_Compass = function()

    if IsVisible() and element_compass:IsVisible() then return end

    jcms_compass()

end

jcms.draw_NotifsAmmo = function()

    if IsVisible() and element_resourcehistory:IsVisible() then return end

    jcms_notifsammo()

end

--- TODO: objectives
