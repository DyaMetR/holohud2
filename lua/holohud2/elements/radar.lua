HOLOHUD2.AddCSLuaFile( "radar/hudradar.lua" )

local PLAYERVIS_NONE    = 0
local PLAYERVIS_FRIEND  = 1
local PLAYERVIS_ALL     = 2

local NPCVIS_NONE   = 0
local NPCVIS_FRIEND = 1
local NPCVIS_ALL    = 2

local player_vis    = CreateConVar( "holohud2_radar_playervis", PLAYERVIS_ALL, FCVAR_REPLICATED )
local npc_vis       = CreateConVar( "holohud2_radar_npcvis", NPCVIS_ALL, FCVAR_REPLICATED )
local range         = CreateConVar( "holohud2_radar_maxrange", 300, FCVAR_REPLICATED )

if SERVER then return end

local CurTime = CurTime
local EyeAngles = EyeAngles
local hook_Call = HOLOHUD2.hook.Call
local util_IsInSight = HOLOHUD2.util.IsInSight

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local CONVERSION_RANGE = 1 / HOLOHUD2.HU_TO_M

local ELEMENT = {
    name        = "#holohud2.radar",
    helptext    = "#holohud2.radar.helptext",
    parameters  = {
        range                       = { name = "#holohud2.radar.range", type = HOLOHUD2.PARAM_RANGE, value = 50, min = 0, max = 300, helptext = "#holohud2.radar.range.helptext" },
        insight                     = { name = "#holohud2.radar.line_of_sight", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.radar.line_of_sight.helptext" },
        insight_fov                 = { name = "#holohud2.radar.field_of_view", type = HOLOHUD2.PARAM_RANGE, value = 60, min = 0, max = 180, helptext = "#holohud2.radar.field_of_view.helptext" },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 140, y = 90 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        color_foe                   = { name = "#holohud2.radar.hostile_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 72, 64 ) },
        color_friend                = { name = "#holohud2.radar.friend_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 64, 255, 92 ) },

        overlay                     = { name = "#holohud2.radar.overlay", type = HOLOHUD2.PARAM_BOOL, value = true },
        overlay_color               = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        overlay_fov                 = { name = "#holohud2.radar.overlay.fov", type = HOLOHUD2.PARAM_BOOL, value = true },
        overlay_grid                = { name = "#holohud2.radar.overlay.grid", type = HOLOHUD2.PARAM_BOOL, value = true },
        overlay_cross               = { name = "#holohud2.radar.overlay.cross", type = HOLOHUD2.PARAM_BOOL, value = true },

        rangelabel                  = { name = "#holohud2.radar.range_label", type = HOLOHUD2.PARAM_BOOL, value = true },
        rangelabel_unit             = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.DISTANCEUNITS, value = HOLOHUD2.DISTANCE_METRIC },
        rangelabel_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 134, y = 76 } },
        rangelabel_font             = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 11, weight = 1000, italic = false } },
        rangelabel_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        rangelabel_align            = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXT_ALIGN, value = TEXT_ALIGN_RIGHT },
        rangelabel_on_background    = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_color                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "RADAR" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        sweep                       = { name = "#holohud2.radar.sweep", type = HOLOHUD2.PARAM_BOOL, value = false },
        sweep_color                 = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 72 ) },
        sweep_time                  = { name = "#holohud2.parameter.duration", type = HOLOHUD2.PARAM_NUMBER, value = 1, helptext = "#holohud2.radar.sweep_time.helptext" },
        sweep_delay                 = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 1.5, helptext = "#holohud2.radar.sweep_delay.helptext" },
        sweep_update                = { name = "#holohud2.radar.sweep_update", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.radar.sweep_update.helptext" }
    },
    menu = {
        { id = "range" },
        { id = "insight", parameters = {
            { id = "insight_fov" }
        } },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos", parameters = {
                { id = "dock" },
                { id = "direction" },
                { id = "margin" },
                { id = "order" }
            } },
            { id = "size" },
            { id = "background", parameters = {
                { id = "background_color" }
            } },
            { id = "animation", parameters = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.radar", parameters = {
            { id = "color" },
            { id = "color_foe" },
            { id = "color_friend" },
            { id = "overlay", parameters = {
                { id = "overlay_color" },
                { id = "overlay_fov" },
                { id = "overlay_grid" },
                { id = "overlay_cross" }
            } },
            { id = "rangelabel", parameters = {
                { id = "rangelabel_unit" },
                { id = "rangelabel_pos" },
                { id = "rangelabel_font" },
                { id = "rangelabel_color" },
                { id = "rangelabel_align" },
                { id = "rangelabel_on_background" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" },
                { id = "text_color" },
                { id = "text_text" },
                { id = "text_align" },
                { id = "text_on_background" }
            } },
            { id = "sweep", parameters = {
                { id = "sweep_color" },
                { id = "sweep_time" },
                { id = "sweep_delay" },
                { id = "sweep_update" }
            } }
        } }
    },
    quickmenu = {
        { id = "range" },
        { id = "insight" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.radar", parameters = {
            { id = "color" },
            { id = "color_foe" },
            { id = "color_friend" },
            { id = "overlay", parameters = {
                { id = "overlay_color" }
            } },
            { id = "rangelabel", parameters = {
                { id = "rangelabel_unit" },
                { id = "rangelabel_pos" },
                { id = "rangelabel_font" },
                { id = "rangelabel_color" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" },
                { id = "text_color" }
            } },
            { id = "sweep", parameters = {
                { id = "sweep_update" }
            } }
        } }
    }
}

---
--- Composition
---
local hudradar  = HOLOHUD2.component.Create( "HudRadar" )
local layout    = HOLOHUD2.layout.Register( "radar" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawRadar", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawRadar", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudradar:PaintBackground( x, y )

    hook_Call( "DrawOverRadar", x, y, self._w, self._h, LAYER_BACKGROUND, hudradar )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawRadar", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudradar:Paint( x, y )

    hook_Call( "DrawOverRadar", x, y, self._w, self._h, LAYER_FOREGROUND, hudradar )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawRadar", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudradar:PaintScanlines( x, y )

    hook_Call( "DrawOverRadar", x, y, self._w, self._h, LAYER_SCANLINES, hudradar )

end

---
--- Startup
---
local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_ACTIVATED = 1

local startup_phase = STARTUP_NONE
local startup_time = 0

function ELEMENT:QueueStartup()

    panel:Close()
    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    startup_phase = STARTUP_ACTIVATED
    startup_time = CurTime() + 3

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.radar.startup"

end

function ELEMENT:IsStartupOver()

    if startup_phase == STARTUP_ACTIVATED and startup_time < CurTime() then

        startup_phase = STARTUP_NONE

    end

    return startup_phase == STARTUP_NONE

end

---
--- Logic
---
local localplayer
local mins, maxs = Vector( 0, 0, 0 ), Vector( 0, 0, 0 )
local time = 0
local _cache = Vector( 0, 0, 0 )
function ELEMENT:PreDraw( settings )

    if startup_phase == STARTUP_QUEUED then return end

    localplayer = localplayer or LocalPlayer()
    local pos = localplayer:GetPos()
    local curtime = CurTime()

    _cache:SetUnpacked( pos.x, pos.y, pos.z + 32 )
    hudradar:SetOrigin( _cache )
    hudradar:SetYaw( EyeAngles().y )
    hudradar:Think()

    panel:SetDeployed( not self:IsMinimized() )
    panel:Think()

    if settings.sweep and settings.sweep_update and time > curtime then return end

    local rangehalf = math.min( settings.range, range:GetFloat() ) * CONVERSION_RANGE
    mins:SetUnpacked( pos.x - rangehalf, pos.y - rangehalf, pos.z - rangehalf )
    maxs:SetUnpacked( pos.x + rangehalf, pos.y + rangehalf, pos.z + rangehalf )

    local entities = {}
    for _, ent in ipairs( ents.FindInBox( mins, maxs ) ) do

        if ent == localplayer then continue end

        -- check visibility hook
        local override = hook_Call( "VisibleOnRadar", ent, not settings.insight or util_IsInSight( ent, settings.insight_fov ) )

        if override ~= nil then

            if override then

                table.insert( entities, ent )

            end

            continue

        end


        -- check player visibility
        if ent:IsPlayer() then

            if not ent:Alive() then continue end

            local vis = player_vis:GetInt()

            if vis == PLAYERVIS_NONE then continue end
            if vis == PLAYERVIS_FRIEND and ent:Team() ~= localplayer:Team() then continue end

            if settings.insight and not util_IsInSight( ent, settings.insight_fov ) then continue end

            table.insert( entities, ent )

            continue

        end

        -- check NPC visibility
        if not ent:IsNPC() and not ent:IsNextBot() then continue end

        local vis = npc_vis:GetInt()

        if vis == NPCVIS_NONE then continue end
        if vis == NPCVIS_FRIEND and IsEnemyEntityName( ent:GetClass() ) then continue end -- NOTE: this includes neutral entities
        if settings.insight and not util_IsInSight( ent, settings.insight_fov ) then continue end

        table.insert( entities, ent )

    end

    hudradar:SetEntities( entities )
    time = curtime + settings.sweep_delay

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
local preview_hudradar = HOLOHUD2.component.Create( "HudRadar" )
preview_hudradar:AddBlip( Vector( 512, 128, 128 ) )
preview_hudradar:AddBlip( Vector( -512, 128, -128 ) )
preview_hudradar:AddBlip( Vector( 64, 512, 0 ) )
preview_hudradar:AddBlip( Vector( -256, -256, 0 ) )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudradar:ApplySettings( settings, self.preview_fonts )

    preview_hudradar._entities[ 1 ].color = settings.color_foe
    preview_hudradar._entities[ 2 ].color = ( settings.insight and settings.insight_fov < 170 ) and color_transparent or settings.color_friend
    preview_hudradar._entities[ 3 ].color = ( settings.insight and settings.insight_fov < 85 ) and color_transparent or settings.color_foe
    preview_hudradar._entities[ 4 ].color = ( settings.insight and settings.insight_fov < 135 ) and color_transparent or settings.color

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()
    local w, h = settings.size.x * scale, settings.size.y * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudradar:Think()
    preview_hudradar:PaintBackground( x, y )
    preview_hudradar:Paint( x, y )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetVisible( true )
    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )

    hudradar:ApplySettings( settings, self.fonts )
    hudradar:SetRange( settings.range * CONVERSION_RANGE )

    time = 0

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudradar:InvalidateLayout()

end

HOLOHUD2.element.Register( "radar", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudradar    = hudradar
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "radar", "animation" )
HOLOHUD2.modifier.Add( "background", "radar", "background" )
HOLOHUD2.modifier.Add( "background_color", "radar", "background_color" )
HOLOHUD2.modifier.Add( "color", "radar", { "color", "text_color", "sweep_color" } )
HOLOHUD2.modifier.Add( "color2", "radar", { "overlay_color", "rangelabel_color" } )
HOLOHUD2.modifier.Add( "text_font", "radar", "rangelabel_font" )
HOLOHUD2.modifier.Add( "scale", "radar", {
    "pos", "margin", "size",
    "rangelabel_pos", "rangelabel_font",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "radar", "element/radar" )
