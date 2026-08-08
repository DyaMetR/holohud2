---
--- ARC9
--- https://steamcommunity.com/sharedfiles/filedetails/?id=2910505837
---

if not ARC9 then return end

HOLOHUD2.AddCSLuaFile( "arc9/thermometer.lua" )
HOLOHUD2.AddCSLuaFile( "arc9/progressthermometer.lua" )

if SERVER then return end

local surface = surface
local draw = draw
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier

local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local FIREMODE_SAFE     = HOLOHUD2.FIREMODE_SAFE
local FIREMODE_SEMI     = HOLOHUD2.FIREMODE_SEMI
local FIREMODE_AUTO     = HOLOHUD2.FIREMODE_AUTO
local FIREMODE_3BURST   = HOLOHUD2.FIREMODE_3BURST
local FIREMODE_2BURST   = HOLOHUD2.FIREMODE_2BURST

local FIREMODE_TRANSLATE = {
    [ 1 ] = FIREMODE_SEMI,
    [ 2 ] = FIREMODE_2BURST,
    [ 3 ] = FIREMODE_3BURST,
    [ -1 ] = FIREMODE_AUTO
}

---
--- Extend settings
---
local element_ammo = HOLOHUD2.element.Get( "ammo" )

-- JAMMED!
element_ammo:DefineParameter( "arc9_jammed", { name = "#holohud2.arc9.jammed", type = HOLOHUD2.PARAM_BOOL, value = true } )
element_ammo:DefineParameter( "arc9_jammed_color", { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 72, 72 ) } )
element_ammo:DefineParameter( "arc9_jammed_font", { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 1000, italic = false } } )
element_ammo:DefineParameter( "arc9_jammed_vertical", { name = "#holohud2.arc9.vertical", type = HOLOHUD2.PARAM_BOOL, value = false } )
element_ammo:DefineParameter( "arc9_jammed_override", { name = "#holohud2.parameter.override", type = HOLOHUD2.PARAM_STRING, value = "", helptext = "Leave blank to use default values" } )

-- Thermometer
element_ammo:DefineParameter( "arc9_thermometer", { name = "#holohud2.arc9.thermometer", type = HOLOHUD2.PARAM_BOOL, value = true } )
element_ammo:DefineParameter( "arc9_thermometer_pos", { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 70, y = 26 } } )
element_ammo:DefineParameter( "arc9_thermometer_size", { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 24, y = 2 } } )
element_ammo:DefineParameter( "arc9_thermometer_vertical", { name = "#holohud2.arc9.vertical", type = HOLOHUD2.PARAM_BOOL, value = false } )
element_ammo:DefineParameter( "arc9_thermometer_background", { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true } )
element_ammo:DefineParameter( "arc9_thermometer_separate", { name = "#holohud2.parameter.standalone", type = HOLOHUD2.PARAM_BOOL, value = false } )
element_ammo:DefineParameter( "arc9_thermometer_separate_pos", { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 62 } } )
element_ammo:DefineParameter( "arc9_thermometer_separate_dock", { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT } )
element_ammo:DefineParameter( "arc9_thermometer_separate_direction", { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT } )
element_ammo:DefineParameter( "arc9_thermometer_separate_margin", { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 4 } )
element_ammo:DefineParameter( "arc9_thermometer_separate_order", { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 21 } )
element_ammo:DefineParameter( "arc9_thermometer_separate_padding", { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 3 } } )
element_ammo:DefineParameter( "arc9_thermometer_separate_background", { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true } )
element_ammo:DefineParameter( "arc9_thermometer_separate_background_color", { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) } )
element_ammo:DefineParameter( "arc9_thermometer_separate_animation", { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH } )
element_ammo:DefineParameter( "arc9_thermometer_separate_animation_direction", { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP } )

local tab, quicktab = element_ammo:FindMenuTab( "ARC9" ), element_ammo:FindQuickTab( "ARC9" )
if not tab then tab = element_ammo:AddMenuTab( "ARC9", { icon = "arc9/icon_16.png" } ) end
if not quicktab then quicktab = element_ammo:AddQuickTab( "ARC9", { icon = "arc9/icon_16.png" } ) end

element_ammo:AddMenuParameter( { tab = tab, id = "arc9_jammed", parameters = {
    { id = "arc9_jammed_color" },
    { id = "arc9_jammed_font" },
    { id = "arc9_jammed_vertical" },
    { id = "arc9_jammed_override" }
} } )

element_ammo:AddMenuParameter( { tab = tab, id = "arc9_thermometer", parameters = {
    { id = "arc9_thermometer_pos"  },
    { id = "arc9_thermometer_size" },
    { id = "arc9_thermometer_vertical" },
    { id = "arc9_thermometer_background" },
    { id = "arc9_thermometer_separate", parameters = {
        { id = "arc9_thermometer_separate_pos", parameters = {
            { id = "arc9_thermometer_separate_dock" },
            { id = "arc9_thermometer_separate_direction" },
            { id = "arc9_thermometer_separate_margin" },
            { id = "arc9_thermometer_separate_order" }
        } },
        { id = "arc9_thermometer_separate_padding" },
        { id = "arc9_thermometer_separate_background", parameters = {
            { id = "arc9_thermometer_separate_background_color" }
        } },
        { id = "arc9_thermometer_separate_animation", parameters = {
            { id = "arc9_thermometer_separate_animation_direction" }
        } }
    } }
} } )


element_ammo:AddQuickParameter( { tab = tab, id = "arc9_jammed", parameters = {
    { id = "arc9_jammed_font" },
    { id = "arc9_jammed_vertical" }
} } )

element_ammo:AddQuickParameter( { tab = quicktab, id = "arc9_thermometer", parameters = {
    { id = "arc9_thermometer_pos"  },
    { id = "arc9_thermometer_size" },
    { id = "arc9_thermometer_separate", parameters = {
        { id = "arc9_thermometer_separate_pos" },
        { id = "arc9_thermometer_separate_padding" }
    } }
} })

HOLOHUD2.modifier.Add( "background", "ammo", "arc9_thermometer_separate_background" )
HOLOHUD2.modifier.Add( "background_color", "ammo", "arc9_thermometer_separate_background_color" )
HOLOHUD2.modifier.Add( "text_font", "ammo", "arc9_jammed_font" )

---
--- Thermometer
---
local thermometerbackground = HOLOHUD2.component.Create( "ARC9_Thermometer" )
local thermometer = HOLOHUD2.component.Create( "ARC9_ProgressThermometer" )
local layout = HOLOHUD2.layout.Register( "arc9_thermometer" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverBackground = function( _, x, y )

    thermometerbackground:Paint( x, y )

end

panel.PaintOver = function( _, x, y )

    thermometer:Paint( x, y )

end

local separate = true
local visible = true
local background = true

local jammed_color = color_white
local jammed_vertical = false
local jammed_override = ""

HOLOHUD2.hook.Add( "PreDrawHUD", "arc9", function()

    if not visible then return end

    local weapon = LocalPlayer():GetActiveWeapon()
    local can_overheat = IsValid( weapon ) and weapon.ARC9 and weapon:GetProcessedValue( "Overheat", true )

    thermometerbackground:SetVisible( ( separate or can_overheat ) and visible and background )
    thermometer:SetVisible( ( separate or can_overheat ) and visible )

    if can_overheat then

        thermometer:SetValue( weapon:GetHeatAmount() / weapon:GetProcessedValue( "HeatCapacity", true ) )

    end

    thermometerbackground:PerformLayout()
    thermometer:PerformLayout()
    thermometer:PerformProgressLayout()

    if not separate then return end

    panel:Think()
    panel:SetDeployed( element_ammo.components.clip1_panel.deployed and visible and can_overheat )
    layout:SetVisible( panel:IsVisible() )

end)

HOLOHUD2.hook.Add( "HUDPaintFrame", "arc9", function( settings, x, y, on_overlay )

    if not separate or on_overlay then return end

    panel:PaintFrame( x, y )

end)

HOLOHUD2.hook.Add( "HUDPaintBackground", "arc9", function( settings, x, y, on_overlay )

    if not separate or on_overlay then return end

    panel:PaintBackground( x, y )

end)

HOLOHUD2.hook.Add( "HUDPaint", "arc9", function( settings, x, y, on_overlay )

    if not separate or on_overlay then return end

    panel:Paint( x, y )

end)

HOLOHUD2.hook.Add( "HUDPaintScanlines", "arc9", function( settings, x, y, on_overlay )

    if not separate or on_overlay then return end

    StartAlphaMultiplier( element_ammo.components.hudclip1.Blur:GetAmount() )
    panel:Paint( x, y )
    EndAlphaMultiplier()

end)

HOLOHUD2.hook.Add( "OnSettingsChanged", "arc9", function( settings )

    settings = settings.ammo

    visible = settings.arc9_thermometer
    separate = settings.arc9_thermometer_separate
    background = settings.arc9_thermometer_background

    jammed_vertical = settings.arc9_jammed_vertical
    jammed_color = settings.arc9_jammed_color
    jammed_override = settings.arc9_jammed_override

    layout:SetPos( settings.arc9_thermometer_separate_pos.x, settings.arc9_thermometer_separate_pos.y )
    layout:SetSize( settings.arc9_thermometer_size.x, settings.arc9_thermometer_size.y )
    layout:SetDock( settings.arc9_thermometer_separate_dock )
    layout:SetOrder( settings.arc9_thermometer_separate_order )
    layout:SetDirection( settings.arc9_thermometer_separate_direction )
    layout:SetMargin( settings.arc9_thermometer_separate_margin )

    panel:SetDrawBackground( settings.arc9_thermometer_separate_background )
    panel:SetColor( settings.arc9_thermometer_separate_background_color )
    panel:SetAnimation( settings.arc9_thermometer_separate_animation )
    panel:SetAnimationDirection( settings.arc9_thermometer_separate_animation_direction )

    thermometerbackground:SetPos( settings.arc9_thermometer_pos.x, settings.arc9_thermometer_pos.y )
    thermometerbackground:SetSize( settings.arc9_thermometer_size.x, settings.arc9_thermometer_size.y )
    thermometerbackground:SetVertical( settings.arc9_thermometer_vertical )
    thermometer:Copy( thermometerbackground )

    thermometer:SetVisible( visible )
    thermometer:SetColor( element_ammo.components.hudclip1.Colors:GetColor() )

    thermometerbackground:SetVisible( visible and settings.arc9_thermometer_background )
    thermometerbackground:SetColor( element_ammo.components.hudclip1.Colors2:GetColor() )

    if settings.arc9_thermometer_separate then

        thermometerbackground:SetPos( settings.arc9_thermometer_separate_padding.x, settings.arc9_thermometer_separate_padding.y )
        thermometerbackground:PerformLayout( true )
        thermometer:Copy( thermometerbackground )
        layout:SetSize( thermometerbackground.__w + settings.arc9_thermometer_separate_padding.x * 2, thermometerbackground.__h + settings.arc9_thermometer_separate_padding.y * 2 )

    end

    if not visible then

        layout:SetVisible( false )

    end

end)

HOLOHUD2.hook.Add( "OnScaleChanged", "arc9", function()

    panel:PerformLayout( true )
    thermometerbackground:InvalidateLayout()
    thermometer:InvalidateLayout()

end)

---
--- Paint integrated components
---
local JAMMED_FONT = "holohud2_ammo_arc9_jammed_font"
HOLOHUD2.hook.Add( "DrawOverClip1", "arc9", function( x, y, w, h, layer )

    -- Thermometer
    if not separate then

        if layer == LAYER_BACKGROUND then

            thermometerbackground:Paint( x, y )
            return

        end

        if layer == LAYER_SCANLINES then StartAlphaMultiplier( element_ammo.components.hudclip1.Blur:GetAmount() ) end

        thermometer:Paint( x, y )

        if layer == LAYER_SCANLINES then EndAlphaMultiplier() end

    end

    -- JAMMED!
    local weapon = LocalPlayer():GetActiveWeapon()

    if not IsValid( weapon ) or not weapon.ARC9 or not weapon:GetJammed() then return end

    draw.RoundedBox( 0, x, y, w, h, Color( 0, 0, 0, 214 ) )

    if layer ~= LAYER_BACKGROUND and CurTime() % .4 >= .2 then

        local str = utf8.len( jammed_override ) ~= 0 and jammed_override or ARC9:GetPhrase( "hud.jammed" )

        if not jammed_vertical then

            draw.SimpleText( str, JAMMED_FONT, x + w / 2, y + h / 2, jammed_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        else

            surface.SetFont( JAMMED_FONT )
            local strw, strh = surface.GetTextSize( str )
            local len = utf8.len( str )

            x = x + w / 2
            y = y + h / 2 - ( strh * (len - 1) ) / 2

            for i=1, len do

                draw.SimpleText( utf8.sub( str, i, i ), JAMMED_FONT, x, y + strh * ( i - 1 ), jammed_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            end

        end

    end

end)

---
--- Fire mode
---
HOLOHUD2.hook.Add( "GetWeaponFiremode", "arc9", function( weapon )

    if not weapon.ARC9 then return end

    if weapon:GetSafe() then

        return FIREMODE_SAFE

    end

    if #weapon.Firemodes <= 1 then return end

    local firemode = FIREMODE_TRANSLATE[ weapon:GetCurrentFiremodeTable().Mode ]

    if firemode then

        return firemode

    end

    return FIREMODE_AUTO

end)

---
--- Inspecting
---
HOLOHUD2.hook.Add( "IsInspectingWeapon", "arc9", function( weapon )

    if not weapon.ARC9 then return end
    if not weapon:GetInspecting() or not weapon:HasAnimation( "inspect" ) then return end

    return true

end)

---
--- ADS
---
HOLOHUD2.hook.Add( "ForceQuickInfoFadeOut", "arc9", function()

    local weapon = LocalPlayer():GetActiveWeapon()

    if not IsValid( weapon ) or not weapon.ARC9 then return end

    return weapon:GetInSights()

end)
