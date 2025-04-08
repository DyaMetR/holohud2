---
--- D/GL4: Customizable Holographic HUD
--- 1.0.9
--- April 9th, 2025
--- Made by DyaMetR
--- * full credits found in the details below
---

HOLOHUD2 = HOLOHUD2 or {}

if CLIENT then

    -- addon properties
    HOLOHUD2.Name           = "D/GL4 HUD"
    HOLOHUD2.Version        = "1.0.9"
    HOLOHUD2.Date           = 1744153749 -- epoch timestamp of the build date
    HOLOHUD2.Credits        = { -- { name, { contribution, ... } }

        { "DyaMetR", { "code", "design", "art", "locale_es-ES" } }
        
    }

    HOLOHUD2.CodeName       = "D/GL4" -- overly technical nomenclature for aesthetic purposes

end

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