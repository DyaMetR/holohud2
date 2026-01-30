-- TODO: add option to toggle layered bar dots and change its size
-- SUGGESTION: add armor bar (for InsaneStats)
-- SUGGESTION: health bar alignment for dynamic sizing (when it's smaller than usual)

HOLOHUD2.AddCSLuaFile( "npcid/hudnpcid.lua" )

if SERVER then

    ---
    --- Set a networked value to use the server-side NPC name.
    ---
    hook.Add( "OnEntityCreated", "holohud2_npcid", function( ent )

        if not ent:IsNPC() then return end

        timer.Simple( .16, function()

            if not IsValid( ent ) then return end

            ent:SetNW2String( "holohud2_name", HOLOHUD2.util.GetDeathNoticeEntityName( ent ) )

        end)

    end)

    return

end

local util = util
local IsValid = IsValid
local IsFriendEntityName = IsFriendEntityName
local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local entityid = false

local ELEMENT = {
    name        = "#holohud2.npcid",
    helptext    = "#holohud2.npcid.helptext",
    parameters  = {
        entityid                        = { name = "#holohud2.parameter.entityid", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.parameter.entityid.helptext" },

        pos                             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 148 } },
        dock                            = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP },
        direction                       = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                          = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                           = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        background                      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color                = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },

        animation                       = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction             = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_CENTER_VERTICAL },

        padding                         = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 0 },
        name                            = { name = "#holohud2.npcid.name", type = HOLOHUD2.PARAM_BOOL, value = true },
        name_align                      = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        name_offset                     = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        name_font                       = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 0, italic = false } },
        name_color                      = { name = "#holohud2.npcid.name", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        name_on_background              = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        healthbar                       = { name = "#holohud2.npcid.health_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NPCID_POS, value = HOLOHUD2.NPCID_BOTTOM },
        healthbar_margin                = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        healthbar_size                  = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 132, y = 6 }, min_x = 1, min_y = 1 },
        healthbar_dynamic               = { name = "#holohud2.dynamic_sizing", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_growdirection         = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthbar_style                 = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        healthbar_colorfoe              = { name = "#holohud2.npcid.hostile_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 72, 64 ) },
        healthbar_colorfriend           = { name = "#holohud2.npcid.friend_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 64, 255, 92 ) },
        healthbar_background            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_color2                = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        healthbar_layered               = { name = "#holohud2.percentage_bar.layered", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_lerp                  = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        healthnums                      = { name = "#holohud2.npcid.health_numbers", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthnums_spacing              = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        healthnums_anchor               = { name = "#holohud2.parameter.anchor", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NPCID_ANCHORS, value = HOLOHUD2.NPCID_ANCHOR_HEALTHBAR },
        healthnums_y                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NPCID_POS, value = HOLOHUD2.NPCID_BOTTOM },
        healthnums_offset               = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        healthnums_margin               = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        healthnums_x                    = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT, helptext = "Alignment within the panel." },

        healthnum                       = { name = "#holohud2.npcid.health_number", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthnum_color                 = { name = "#holohud2.npcid.health_number", type = HOLOHUD2.PARAM_COLOR, value = Color( 192, 192, 192 ) },
        healthnum_font                  = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 1000, italic = false } },
        healthnum_rendermode            = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        healthnum_background            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        healthnum_color2                = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        healthnum_align                 = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthnum_digits                = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },
        healthnum_lerp                  = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },

        healthnum_separator             = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthnum_separator_offset      = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        healthnum_separator_size        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 1, y = 8 } },

        healthnum2                      = { name = "#holohud2.npcid.max_health_number", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthnum2_color                = { name = "#holohud2.npcid.max_health_number", type = HOLOHUD2.PARAM_COLOR, value = Color( 144, 144, 144 ) },
        healthnum2_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 12, weight = 1000, italic = false } },
        healthnum2_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        healthnum2_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_NONE },
        healthnum2_color2               = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        healthnum2_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        healthnum2_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 }
    },
    menu = {
        { id = "entityid" },

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
            { name = "#holohud2.npcid.health_bar", parameters = {
                { id = "healthbar_colorfoe" },
                { id = "healthbar_colorfriend" },
                { id = "healthbar_color2" },
            } },
            { id = "healthnum_color", parameters = {
                { id = "healthnum_color2" }
            } },
            { id = "healthnum2_color", parameters = {
                { id = "healthnum2_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "name", parameters = {
                { id = "name_align" },
                { id = "name_offset" },
                { id = "name_font" },
                { id = "name_on_background" }
            } },
            { id = "healthbar", parameters = {
                { id = "healthbar_pos" },
                { id = "healthbar_margin" },
                { id = "healthbar_size" },
                { id = "healthbar_dynamic" },
                { id = "healthbar_growdirection" },
                { id = "healthbar_style" },
                { id = "healthbar_background" },
                { id = "healthbar_layered" },
                { id = "healthbar_lerp" }
            } },
            { id = "healthnums", parameters = {
                { id = "healthnums_spacing" },
                { id = "healthnums_anchor", parameters = {
                    { id = "healthnums_y" },
                    { id = "healthnums_x" }
                } },
                { id = "healthnums_margin" },
                { id = "healthnums_offset" },
                { id = "healthnum", parameters = {
                    { id = "healthnum_font" },
                    { id = "healthnum_rendermode" },
                    { id = "healthnum_background" },
                    { id = "healthnum_align" },
                    { id = "healthnum_digits" },
                    { id = "healthnum_lerp" }
                } },
                { id = "healthnum_separator", parameters = {
                    { id = "healthnum_separator_offset" },
                    { id = "healthnum_separator_size" }
                } },
                { id = "healthnum2", parameters = {
                    { id = "healthnum2_font" },
                    { id = "healthnum2_rendermode" },
                    { id = "healthnum2_background" },
                    { id = "healthnum2_align" },
                    { id = "healthnum2_digits" }
                } }
            } }
        } }
    },
    quickmenu = {
        { id = "entityid" },
        { id = "pos" },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "name_color" },
            { name = "#holohud2.npcid.health_bar", parameters = {
                { id = "healthbar_colorfoe" },
                { id = "healthbar_colorfriend" },
                { id = "healthbar_color2" },
            } },
            { id = "healthnum_color", parameters = {
                { id = "healthnum_color2" }
            } },
            { id = "healthnum2_color", parameters = {
                { id = "healthnum2_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "name", parameters = {
                { id = "name_align" },
                { id = "name_offset" },
                { id = "name_font" }
            } },
            { id = "healthbar", parameters = {
                { id = "healthbar_margin" },
                { id = "healthbar_size" },
                { id = "healthbar_dynamic" }
            } },
            { id = "healthnums", parameters = {
                { id = "healthnums_spacing" },
                { id = "healthnums_x" },
                { id = "healthnums_offset" },
                { id = "healthnum_font", name = "Health number font" },
                { id = "healthnum_separator_offset", name = "Separator offset" },
                { id = "healthnum2_font", name = "Maximum health number font"}
            } }
        } }
    }
}

local WARMUP    = .08
local TIME      = .84

---
--- Override Object Information element.
---
HOLOHUD2.hook.Add( "ShouldShowEntityID", "npcid", function( target )

    if entityid then return end
    if not target:IsNPC() and not target:IsNextBot() then return end

    return false

end)

---
--- Composition
---
local hudnpcid  = HOLOHUD2.component.Create( "HudNPCID" )
local layout    = HOLOHUD2.layout.Register( "npcid" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawNPCHealth", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawNPCHealth", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudnpcid:PaintBackground( x, y )

    hook_Call( "DrawOverNPCHealth", x, y, self._w, self._h, LAYER_BACKGROUND, hudnpcid )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawNPCHealth", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudnpcid:Paint( x, y )

    hook_Call( "DrawOverNPCHealth", x, y, self._w, self._h, LAYER_FOREGROUND, hudnpcid )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawNPCHealth", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudnpcid:PaintScanlines( x, y )

    hook_Call( "DrawOverNPCHealth", x, y, self._w, self._h, LAYER_SCANLINES, hudnpcid )

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
local _target = NULL
local warmup, time = 0, 0
local trace = {
    collisiongroup = COLLISION_GROUP_NPC,
    mins = Vector( -16, -16, -16 ),
    maxs = Vector( 16, 16, 16 )
}
function ELEMENT:PreDraw( settings )

    if startup then return end

    local localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and time > curtime )

    local w, h = hudnpcid:GetSize()
    layout:SetSize( w + settings.padding * 2, h + settings.padding * 2 )
    layout:SetVisible( panel:IsVisible() )

    if panel:IsVisible() then

        if IsValid( _target ) then

            hudnpcid:SetName( _target:GetNW2String( "holohud2_name", language.GetPhrase( _target:GetClass() ) ) )

        end

        hudnpcid:SetHealth( IsValid( _target ) and math.max( _target:Health(), 0 ) or 0 )
        hudnpcid:Think()
        hudnpcid.Blur:SetEnabled( true )

    end

    local result = localplayer:GetEyeTrace()

    -- make NPC detection easier by using a fallback hull trace
    if not result.Hit or not IsValid( result.Entity ) or not ( result.Entity:IsNPC() or result.Entity:IsNextBot() ) then

        trace.start = localplayer:GetShootPos()
        trace.endpos = localplayer:GetShootPos() + localplayer:GetAimVector() * 4096
        trace.filter = localplayer

        result = util.TraceHull( trace )

    end

    if not result.Hit then

        warmup = curtime + WARMUP
        return

    end

    local target = result.Entity

    if not IsValid( target ) or not ( target:IsNPC() or target:IsNextBot() ) then

        warmup = curtime + WARMUP
        return

    end

    if target == _target then

        if time < curtime and warmup > curtime then return end

        time = curtime + TIME
        return

    end

    local is_friend = hook_Call( "IsFriendEntity", target )
    if is_friend == nil then

        is_friend = IsFriendEntityName( target:GetClass() )

    end

    hudnpcid.Blur:SetEnabled( false )
    hudnpcid:SetHealth( target:Health() )
    hudnpcid:SetMaxHealth( target:GetMaxHealth() )
    hudnpcid:SetHealthBarColor( is_friend and settings.healthbar_colorfriend or settings.healthbar_colorfoe )
    hudnpcid._health = hudnpcid.health
    hudnpcid:InvalidateLayout()

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
local PREVIEW_NAME = "#holohud2.npcid.preview.name"
local preview_hudnpcid = HOLOHUD2.component.Create( "HudNPCID" )
local preview_colorfoe, preview_colorfriend = color_white, color_white

preview_hudnpcid:SetName( PREVIEW_NAME )
preview_hudnpcid:SetHealth( 100 )
preview_hudnpcid:SetMaxHealth( 100 )
local preview_friendly = false

-- FIXME: when changing health values the transition between one bar and multiple bars is not flawless

function ELEMENT:OnPreviewChanged( settings )

    preview_hudnpcid:ApplySettings( settings, self.preview_fonts )
    preview_colorfoe = settings.healthbar_colorfoe
    preview_colorfriend = settings.healthbar_colorfriend
    preview_hudnpcid:SetHealthBarColor( preview_friendly and preview_colorfriend or preview_colorfoe )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    local w, h = ( preview_hudnpcid.__w + settings.padding * 2 ) * scale, ( preview_hudnpcid.__h + settings.padding * 2 ) * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudnpcid:Think()
    preview_hudnpcid:PaintBackground( x, y )
    preview_hudnpcid:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 172, 67 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() )

        local friendly = vgui.Create( "DCheckBoxLabel", controls )
        friendly:Dock( TOP )
        friendly:DockMargin( 0, 0, 0, 4 )
        friendly:SetValue( preview_friendly )
        friendly:SetText( "#holohud2.npcid.preview.friendly" )
        friendly.OnChange = function( _, value )

            preview_friendly = value
            preview_hudnpcid:SetHealthBarColor( value and preview_colorfriend or preview_colorfoe )

        end

        local name = vgui.Create( "DTextEntry", controls )
        name:Dock( TOP )
        name:DockMargin( 0, 0, 0, 4 )
        name:SetValue( preview_hudnpcid.name )
        name.OnChange = function( _ )

            preview_hudnpcid:SetName( name:GetValue() )

        end

        local health = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", controls )
        health:Dock( TOP )
        health:SetMinMax( 0, 2147483647 )
        health:SetIcon( "icon16/heart.png" )
        health:SetValue( preview_hudnpcid.health )
        health:SetMaxValue( preview_hudnpcid.max_health )
        health.OnValueChanged = function( _, value )

            preview_hudnpcid:SetHealth( value )

        end
        health.OnMaxValueChanged = function( _, max_value )

            preview_hudnpcid:SetMaxHealth( max_value )

        end

        local reset = vgui.Create( "DImageButton", panel )
        reset:SetSize( 16, 16 )
        reset:SetPos( 134, panel:GetTall() - reset:GetTall() - 5 )
        reset:SetImage( "icon16/arrow_refresh.png" )
        reset.DoClick = function()

            preview_hudnpcid:SetName( PREVIEW_NAME )
            name:SetValue( preview_hudnpcid.name )
            friendly:SetValue( false )
            health:SetValue( 100 )
            health:SetMaxValue( 100 )

        end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    entityid = settings.entityid

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

    hudnpcid:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudnpcid:InvalidateLayout()

end

HOLOHUD2.element.Register( "npcid", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudnpcid    = hudnpcid
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "npcid", "animation" )
HOLOHUD2.modifier.Add( "background", "npcid", "background" )
HOLOHUD2.modifier.Add( "background_color", "npcid", "background_color" )
HOLOHUD2.modifier.Add( "color", "npcid", { "name_color", "healthnum_color", "separator_color", "healthnum2_color" } )
HOLOHUD2.modifier.Add( "color2", "npcid", { "healthbar_color2", "healthnum_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "npcid", "healthnum_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "npcid", "healthnum_background" )
HOLOHUD2.modifier.Add( "number3_font", "npcid", { "healthnum_font", "healthnum2_font" } )
HOLOHUD2.modifier.Add( "text_font", "npcid", "name_font" )

---
--- Presets
---
HOLOHUD2.presets.Register( "npcid", "element/npcid" )
