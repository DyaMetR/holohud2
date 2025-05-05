---
--- swcs / CS:GO Weapons
--- https://steamcommunity.com/sharedfiles/filedetails/?id=2193997180
---

if SERVER then return end

if not swcs then return end

local FIREMODE_SEMI     = HOLOHUD2.FIREMODE_SEMI
local FIREMODE_AUTO     = HOLOHUD2.FIREMODE_AUTO
local FIREMODE_3BURST   = HOLOHUD2.FIREMODE_3BURST

---
--- Fire mode
---

HOLOHUD2.hook.Add( "GetWeaponFiremode", "swcs", function( weapon )
    local wepTable = weapon:GetTable()
    if not wepTable.IsSWCSWeapon then return end

    if wepTable.GetHasBurstMode( weapon ) then
        if wepTable.GetWeaponMode( weapon ) == 1 then -- secondary fire mode
            return FIREMODE_3BURST
        elseif wepTable.GetIsFullAuto( weapon ) then
            return FIREMODE_AUTO
        else
            return FIREMODE_SEMI
        end
    end
end)

HOLOHUD2.hook.Add( "IsInspectingWeapon", "swcs", function( weapon )
    local wepTable = weapon:GetTable()
    if not wepTable.IsSWCSWeapon then return end

    return wepTable.GetIsLookingAtWeapon(weapon)
end)

local function CheckTargetID( ent, trace )
    if swcs.IsLineBlockedBySmoke( trace.StartPos, trace.HitPos, 1 ) then
        return false
    end
end
HOLOHUD2.hook.Add( "ShouldShowEntityID", "swcs", CheckTargetID )
HOLOHUD2.hook.Add( "ShouldShowTargetID", "swcs", CheckTargetID )

---
--- ADS
---

HOLOHUD2.hook.Add( "ForceQuickInfoFadeOut", "swcs", function()
    local weapon = LocalPlayer():GetActiveWeapon()
    if not IsValid( weapon ) or not weapons.IsBasedOn( weapon:GetClass(), "weapon_swcs_base" ) then return end
    local wepTable = weapon:GetTable()

    return wepTable.GetHasZoom(weapon) and wepTable.GetZoomLevel(weapon) > 0
end)

---
--- Ammo type icons
---

HOLOHUD2.ammo.Register( "BULLET_PLAYER_9MM", "Pistol" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_357SIG", "Pistol" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_357SIG_P250", "Pistol" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_357SIG_MIN", "Pistol" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_357SIG_SMALL", "Pistol" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_50AE", "357" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_BUCKSHOT", "Buckshot" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_762MM", "AR2" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_556MM", "AR2" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_556MM_SMALL", "AR2" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_556MM_BOX", "AR2" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_45ACP", "SMG1" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_57MM", "SMG1" )
HOLOHUD2.ammo.Register( "BULLET_PLAYER_338MAG", "AR2" )
