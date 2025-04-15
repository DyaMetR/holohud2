---
--- D/GL4: Customizable Holographic HUD
--- 1.4.3
--- April 15th, 2025
--- Made by DyaMetR
--- * full credits found in the details below
---

HOLOHUD2 = HOLOHUD2 or {}

---
--- Addon properties
---
HOLOHUD2.Name           = "D/GL4 HUD"
HOLOHUD2.CodeName       = "D/GL4" -- overly technical nomenclature for aesthetic purposes
HOLOHUD2.Version        = "1.4.3"
HOLOHUD2.Date           = 1744713361 -- epoch timestamp of the build date
HOLOHUD2.Credits        = { -- { name, { contribution, ... } }

    { "DyaMetR", { "code", "design", "art", "locale_es-ES" } },
    { "8Z", { "bugfix" } },
    { "IBRS", { "locale_zh-CN" } },
    { "homonovus", { "misc" } }
    
}

--- Adds a client side file.
--- @param path string
function HOLOHUD2.AddCSLuaFile( path )

    if CLIENT then include( path ) end
    if SERVER then AddCSLuaFile( path ) end

end

--- Adds a shared file.
--- @param path string
function HOLOHUD2.AddSharedFile( path )

    include( path )
    if SERVER then AddCSLuaFile( path ) end

end

---
--- Initialize HUD.
---
HOLOHUD2.AddSharedFile( "holohud2/init.lua" )