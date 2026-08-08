
HOLOHUD2.render = {}

local ScrW = ScrW
local ScrH = ScrH

local MATERIAL_CONVARS = { -- convars that wreck havoc when changed
    "mat_fullbright",
    "mat_specular",
    "mat_aaquality",
    "mat_picmip",
    "mat_showlowresimage",
    -- "mat_reloadallmaterials" -- not a convar. can't detect command calls :(
}

local BLURSCREEN_MATERIAL   = Material( "pp/blurscreen" )

local r_pp              = CreateClientConVar( "holohud2_r_pp", 1, true, false, "Overrides all post processing.", 0, 1 )
local r_blurscreen      = CreateClientConVar( "holohud2_r_blur", 1, true, false, "Blurs the panels' backgrounds.", 0, 1 )

local alpha_queue = {}

--- Stores the previous alpha multiplier and sets a new one.
--- @param alpha number
--- @param absolute boolean ignore past alpha
function HOLOHUD2.render.StartAlphaMultiplier( alpha, absolute )

    if #alpha_queue > 1024 then error( "Alpha multiplier buffer overflow! Are you properly restoring alpha after multiplying it?" ) end

    -- take into account nested calls
    if not absolute then alpha = alpha * surface.GetAlphaMultiplier() end

    -- register the last multiplier
    table.insert( alpha_queue, surface.GetAlphaMultiplier() )

    -- apply multiplier
    surface.SetAlphaMultiplier( alpha )

end

--- Ends the previous alpha multiplier and restores the last one.
function HOLOHUD2.render.EndAlphaMultiplier()

    if #alpha_queue <= 0 then error( "Called EndAlphaMul without having called StartAlphaMul first! Or called EndAlphaMul more times than StartAlphaMul." ) end

    -- restore previous multiplier
    surface.SetAlphaMultiplier( alpha_queue[ #alpha_queue ] )

    -- remove call
    table.remove( alpha_queue, #alpha_queue )

end

--- Alias of SetStencilEnable( false ).
function HOLOHUD2.render.EndStencilScissor()

    render.SetStencilEnable( false )

end

--- Computes the blur once per frame.
function HOLOHUD2.render.ComputeBlur()

    if not r_blurscreen:GetBool() then return end

    BLURSCREEN_MATERIAL:SetFloat( "$blur", 4 )
    BLURSCREEN_MATERIAL:Recompute()

    render.UpdateScreenEffectTexture()

end

--- Blurs a portion of the screen.
--- @param x number
--- @param y number
--- @param w number
--- @param h number
function HOLOHUD2.render.BlurRect( x, y, w, h )

    if not r_pp:GetBool() or not r_blurscreen:GetBool() then return end

    local scrw, scrh = ScrW(), ScrH()

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( BLURSCREEN_MATERIAL )
    surface.DrawTexturedRectUV( x, y, w, h, x / scrw, y / scrh, ( x + w ) / scrw, ( y + h ) / scrh )

end

---
--- Notify when a material convar has been changed.
---
local function invalidate_materials()

    timer.Simple( .16, function() -- HACK: wait for the game to resume before invalidating materials

        HOLOHUD2.hook.Call( "InvalidateMaterials" )

    end)

end

---
--- Console command to manually invalidate materials.
---
concommand.Add("holohud2_reloadmaterials", invalidate_materials)

for _, convar in ipairs( MATERIAL_CONVARS ) do

    cvars.AddChangeCallback( convar, invalidate_materials )

end
