HOLOHUD2.AddCSLuaFile( "entityid/hudentityid.lua" )

if SERVER then return end

local IsValid = IsValid
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local util_NicePath = HOLOHUD2.util.NicePath
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.entityid",
    helptext    = "#holohud2.entityid.helptext",
    parameters  = {
        filter                  = { name = "#holohud2.entityid.filter", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.entityid.filter.helptext" },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 114 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.CENTER },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_CENTER_HORIZONTAL },

        padding                 = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        name                    = { name = "#holohud2.entityid.name", type = HOLOHUD2.PARAM_BOOL, value = true },
        name_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 0, italic = false } },
        name_color              = { name = "#holohud2.entityid.name_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200 ) },
        name_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },
        details                 = { name = "#holohud2.entityid.details", type = HOLOHUD2.PARAM_BOOL, value = true },
        details_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ENTID_POS, value = HOLOHUD2.ENTID_BOTTOM },
        details_margin          = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 0, min = 0 },
        details_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 10, weight = 1000, italic = true } },
        details_color           = { name = "#holohud2.entityid.details_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200, 144 ) },
        details_on_background   = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar               = { name = "#holohud2.entityid.health_bar", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.entityid.health_bar.helptext" },
        healthbar_anchor        = { name = "#holohud2.parameter.anchor", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ENTID_ANCHORS, value = HOLOHUD2.ENTID_ANCHOR_DETAILS },
        healthbar_pos           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ENTID_POS, value = HOLOHUD2.ENTID_BOTTOM },
        healthbar_margin        = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 0 },
        healthbar_size          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 72, y = 4 }, min_x = 1, min_y = 1 },
        healthbar_growdirection = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthbar_style         = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        healthbar_color         = { name = "#holohud2.entityid.health_bar_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 70, 60 ) },
        healthbar_background    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_color2        = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        healthbar_lerp          = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true }
    },
    menu = {
        { id = "filter" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos", parameters = {
                { id = "dock" },
                { id = "direction" },
                { id = "margin" },
                { id = "order" }
            } },
            { id = "background", parameters = {
                { id = "background_color" }
            } },
            { id = "animation", parameters = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "name_color" },
            { id = "details_color" },
            { id = "healthbar_color", parameters = {
                { id = "healthbar_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "align" },
            { id = "name", parameters = {
                { id = "name_font" },
                { id = "name_on_background" }
            } },
            { id = "details", parameters = {
                { id = "details_pos" },
                { id = "details_margin" },
                { id = "details_font" },
                { id = "details_on_background" }
            } },
            { id = "healthbar", parameters = {
                { id = "healthbar_anchor" },
                { id = "healthbar_pos" },
                { id = "healthbar_margin" },
                { id = "healthbar_size" },
                { id = "healthbar_growdirection" },
                { id = "healthbar_style" },
                { id = "healthbar_background" },
                { id = "healthbar_lerp" }
            } }
        } }
    },
    quickmenu = {
        { id = "filter" },
        { id = "pos" },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "name_color" },
            { id = "details_color" },
            { id = "healthbar_color", parameters = {
                { id = "healthbar_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "align" },
            { id = "name", parameters = {
                { id = "name_font" }
            } },
            { id = "details", parameters = {
                { id = "details_pos" },
                { id = "details_font" }
            } },
            { id = "healthbar", parameters = {
                { id = "healthbar_anchor" },
                { id = "healthbar_pos" },
                { id = "healthbar_size" }
            } }
        } }
    }
}

local FILTER_WEAPONS    = {
    weapon_physgun  = true,
    gmod_tool       = true
}

local FILTER_CLASS      = {
    [ "class C_BaseEntity" ]    = true,
    [ "class C_BaseAnimating" ] = true,
    prop_vehicle_choreo_generic = true,
    func_monitor                = true,
    func_brush                  = true,
    func_detail                 = true,
    func_door                   = true,
    func_door_rotating          = true,
    func_wall                   = true,
    func_ladder                 = true,
    func_lod                    = true,
    func_physbox                = true,
    func_reflective_glass       = true,
    prop_dynamic                = true,
    prop_door_rotating          = true,
    prop_physics                = true,
    prop_physics_multiplayer    = true,
    prop_physics_override       = true,
    prop_ragdoll                = true,
    crossbow_bolt               = true,
    worldspawn                  = true,
}

local PROP_CLASS        = {
    prop_physics                = true,
    prop_physics_multiplayer    = true,
    prop_physics_override       = true,
    prop_ragdoll                = true,
    prop_dynamic                = true,
    prop_door                   = true,
    prop_door_rotating          = true,
    prop_vehicle_prisoner_pod   = true,
    prop_vehicle_jeep           = true,
    prop_vehicle_airboat        = true
}

local WARMUP    = .2
local DELAY     = .6

---
--- Composition
---
local hudentid  = HOLOHUD2.component.Create( "HudEntityID" )
local layout    = HOLOHUD2.layout.Register( "entityid" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawEntityInfo", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawEntityInfo", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudentid:PaintBackground( x, y )

    hook_Call( "DrawOverEntityInfo", x, y, self._w, self._h, LAYER_BACKGROUND, hudentid )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawEntityInfo", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudentid:Paint( x, y )

    hook_Call( "DrawOverEntityInfo", x, y, self._w, self._h, LAYER_FOREGROUND, hudentid )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawEntityInfo", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudentid:PaintScanlines( x, y )

    hook_Call( "DrawOverEntityInfo", x, y, self._w, self._h, LAYER_SCANLINES, hudentid )

end

---
--- Startup sequence
---
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    panel:Close()
    startup = true

end

function ELEMENT:Startup()

    startup = false

end

---
--- Logic
---
local localplayer
local _target, _weapon = NULL, NULL
local warmup, time = 0, 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()

    -- if weapon changes, reset target (in case we're no longer using a building weapon)
    local weapon = localplayer:GetActiveWeapon()
    if weapon ~= _weapon then

        _target = NULL
        _weapon = weapon

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and time > curtime )

    layout:SetVisible( panel:IsVisible() )

    if panel:IsVisible() then

        hudentid:SetHealth( IsValid( _target ) and ( _target:Health() / math.max( _target:GetMaxHealth(), 1 ) ) or 0 )
        hudentid:Think()

    end

    -- avoid having our vehicle's name constantly on screen
    if localplayer:InVehicle() then return end

    local result = localplayer:GetEyeTrace()

    if not result.Hit then

        warmup = curtime + WARMUP
        return

    end

    local target = result.Entity

    if not IsValid( target ) or hook_Call( "ShouldShowEntityID", target, result ) == false then

        warmup = curtime + WARMUP
        return

    end

    local health = target:Health()

    -- if there's nothing to show -- just don't!
    if ( health <= 0 or not settings.healthbar ) and not settings.name and not settings.details then return end

    -- only start showing the entity information if we stare at it
    if _target == target then

        if warmup > curtime then return end

        time = curtime + DELAY
        return

    end

    -- if enabled, apply the building filter
    if settings.filter and FILTER_CLASS[ target:GetClass() ] and health <= 0 then

        local weapon = localplayer:GetActiveWeapon()

        if not IsValid( weapon ) or not FILTER_WEAPONS[ weapon:GetClass() ] then return end

    end

    hudentid.HealthBar:SetVisible( settings.healthbar and health > 0 )
    hudentid.HealthBarBackground:SetVisible( hudentid.HealthBar.visible and settings.healthbar_background )

    if target:IsPlayer() then

        hudentid:SetName( target:Name() )
        hudentid:SetDetails( hook_Call( "GetTargetTeam", target ) or team.GetName( target:Team() ) )
        hudentid.Details:SetVisible( settings.details )

    elseif target:IsNPC() or target:IsNextBot() then

        hudentid:SetName( language.GetPhrase( target:GetClass() ) )
        hudentid.Details:SetVisible( false )

    else

        local class = target:GetClass()

        hudentid:SetName( language.GetPhrase( target:IsWeapon() and ( target.GetPrintName and target:GetPrintName() or target.PrintName ) or class ) )

        if target:IsScripted() then

            hudentid:SetDetails( target.Category or "" )
            hudentid.Details:SetVisible( settings.details and target.Category )

        elseif PROP_CLASS[ class ] then

            hudentid:SetDetails( util_NicePath( target:GetModel() ) )
            hudentid.Details:SetVisible( settings.details )

        else

            hudentid.Details:SetVisible( false )

        end

    end

    hudentid:SetHealth( target:Health() / math.max( target:GetMaxHealth(), 1 ) )
    hudentid:PerformLayout( true )

    local w, h = hudentid:GetSize()
    layout:SetSize( w + settings.padding * 2 + 2, h + settings.padding * 2 )

    _target = target

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )

    panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )

    panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    panel:PaintScanlines( x, y )

end

---
--- Preview
---
local PREVIEW_NAME, PREVIEW_DETAILS, PREVIEW_HEALTH = "#holohud2.entityid.preview.name", "#holohud2.entityid.preview.details", 1
local preview_hudentityid = HOLOHUD2.component.Create( "HudEntityID" )
preview_hudentityid:SetName( PREVIEW_NAME )
preview_hudentityid:SetDetails( PREVIEW_DETAILS )
preview_hudentityid:SetHealth( PREVIEW_HEALTH )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudentityid:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    local w, h = ( preview_hudentityid.__w + settings.padding * 2 ) * scale, ( preview_hudentityid.__h + settings.padding * 2 ) * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudentityid:Think()
    preview_hudentityid:PaintBackground( x, y )
    preview_hudentityid:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 172, 64 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() - 2 )

        local name = vgui.Create( "DTextEntry", controls )
        name:Dock( TOP )
        name:DockMargin( 0, 0, 0, 2 )
        name.OnChange = function( _ )

            preview_hudentityid:SetName( name:GetValue() )

        end
        name:SetValue( PREVIEW_NAME )

        local details = vgui.Create( "DTextEntry", controls )
        details:Dock( TOP )
        details:DockMargin( 0, 0, 0, 2 )
        details.OnChange = function( _ )

            preview_hudentityid:SetName( details:GetValue() )

        end
        details:SetValue( PREVIEW_DETAILS )

        local health = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", controls )
        health:Dock( TOP )
        health:SetIcon( "icon16/heart.png" )
        health.OnValueChanged = function( _, value )

            preview_hudentityid:SetHealth( value / 100 )

        end
        health:SetValue( PREVIEW_HEALTH * 100 )

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( controls:GetX() + controls:GetWide() + 4, panel:GetTall() - reset:GetTall() - 4 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        preview_hudentityid:SetName( PREVIEW_NAME )
        preview_hudentityid:SetDetails( PREVIEW_DETAILS )

        name:SetValue( PREVIEW_NAME )
        details:SetValue( PREVIEW_DETAILS )
        health:SetValue( PREVIEW_HEALTH * 100 )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )

    hudentid:ApplySettings( settings, self.fonts )

    _target = NULL
    _weapon = NULL

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudentid:InvalidateLayout()

end

HOLOHUD2.element.Register( "entityid", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudentid    = hudentid
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "entityid", "animation" )
HOLOHUD2.modifier.Add( "background", "entityid", "background" )
HOLOHUD2.modifier.Add( "background_color", "entityid", "background_color" )
HOLOHUD2.modifier.Add( "color", "entityid", "name_color" )
HOLOHUD2.modifier.Add( "color2", "entityid", "details_color" )
HOLOHUD2.modifier.Add( "text_font", "entityid", "name_font" )
HOLOHUD2.modifier.Add( "text2_font", "entityid", "details_font" )
HOLOHUD2.modifier.Add( "scale", "entityid", {
    "pos", "margin", "padding",
    "name_font", "details_pos", "details_margin", "details_font",
    "healthbar_pos", "healthbar_margin", "healthbar_size"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "entityid", "element/entityid" )
