HOLOHUD2.AddCSLuaFile( "propcount/hudpropcount.lua" )

if SERVER then return end

local LocalPlayer = LocalPlayer
local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call
local game_SinglePlayer = game.SinglePlayer

local ELEMENT = {
    name        = "#holohud2.props",
    helptext    = "#holohud2.props.helptext",
    parameters  = {
        singleplayer                = { name = "#holohud2.parameter.singleplayer_inclusive", type = HOLOHUD2.PARAM_BOOL, value = false },
        autohide                    = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay              = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        autohide_threshold          = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_RANGE, value = 75, min = 0, max = 100, helptext = "Percentage above which it stops automatically hiding." },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 156, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 64 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 60, y = 25 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [75] = Color( 255, 255, 255 ), [100] = Color( 255, 64, 48 ) }, fraction = true, gradual = true } },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = true } },

        number                      = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        number_pos                  = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 24, y = 0 } },
        number_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 24, weight = 1000, italic = false } },
        number_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_lerp                 = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        number_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        separator                   = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = false },
        separator_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 60, y = 4 } },
        separator_is_rect           = { name = "#holohud2.parameter.separator_is_rect", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 1, y = 18 } },
        separator_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 22, weight = 1000, italic = false } },

        number2                     = { name = "#holohud2.component.max_number", type = HOLOHUD2.PARAM_BOOL, value = false },
        number2_pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 66, y = 4 } },
        number2_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 18, weight = 0, italic = false } },
        number2_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number2_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number2_lerp                = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        number2_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number2_digits              = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        progressbar                 = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = false },
        progressbar_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 25 } },
        progressbar_size            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 56, y = 4 }, min_x = 1, min_y = 1 },
        progressbar_style           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        progressbar_growdirection   = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        progressbar_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        progressbar_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        icon                        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        icon_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 16 },
        icon_rendermode             = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ICONRENDERMODES, value = HOLOHUD2.ICONRENDERMODE_PROGRESS },
        icon_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_lerp                   = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.PROPS" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "singleplayer" },
        { id = "autohide", parameters = {
            { id = "autohide_delay" },
            { id = "autohide_threshold" }
        } },

        { category = "#holohud2.category.panel", parameters = {
            { id = "autohide", parameters = {
                { id = "autohide_delay" },
                { id = "autohide_threshold" }
            } },
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

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_lerp" },
                { id = "number_align" },
                { id = "number_digits" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_is_rect", parameters = {
                    { id = "separator_size" },
                    { id = "separator_font" }
                } }
            } },
            { id = "number2", parameters = {
                { id = "number2_pos" },
                { id = "number2_font" },
                { id = "number2_rendermode" },
                { id = "number2_background" },
                { id = "number2_lerp" },
                { id = "number2_align" },
                { id = "number2_digits" }
            } },
            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" },
                { id = "progressbar_style" },
                { id = "progressbar_growdirection" },
                { id = "progressbar_background" },
                { id = "progressbar_lerp" }
            } },
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" },
                { id = "icon_rendermode" },
                { id = "icon_background" },
                { id = "icon_lerp" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" },
                { id = "text_text" },
                { id = "text_align" },
                { id = "text_on_background" }
            } }
        } }
    },
    quickmenu = {
        { id = "singleplayer" },
        { id = "autohide" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_is_rect", parameters = {
                    { id = "separator_size" },
                    { id = "separator_font" }
                } }
            } },
            { id = "number2", parameters = {
                { id = "number2_pos" },
                { id = "number2_font" }
            } },
            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" }
            } },
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } }
    }
}

---
--- Composition
---
local hudpropcount  = HOLOHUD2.component.Create( "HudPropCount" )
local layout        = HOLOHUD2.layout.Register( "propcount" )
local panel         = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawPropCount", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawPropCount", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudpropcount:PaintBackground( x, y )

    hook_Call( "DrawOverPropCount", x, y, self._w, self._h, LAYER_BACKGROUND, hudpropcount )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawPropCount", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudpropcount:Paint( x, y )

    hook_Call( "DrawOverPropCount", x, y, self._w, self._h, LAYER_FOREGROUND, hudpropcount )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawPropCount", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudpropcount:PaintScanlines( x, y )

    hook_Call( "DrawOverPropCount", x, y, self._w, self._h, LAYER_SCANLINES, hudpropcount )

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
local convar = GetConVar( "sbox_maxprops" )
local _props, time = 0, 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()
    local props, max_props = localplayer.GetCount and localplayer:GetCount( "props" ) or 0, convar:GetInt()

    if props ~= _props then

        time = curtime + settings.autohide_delay
        _props = props

    end

    hudpropcount:SetValue( props )
    hudpropcount:SetMaxValue( max_props )

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or ( not game_SinglePlayer() or settings.singleplayer ) and ( not settings.autohide or ( time > curtime or props / max_props >= settings.autohide_threshold / 100 ) ) ) )

    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudpropcount:Think()

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

    if game_SinglePlayer() and not settings.singleplayer then return end

    panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    if game_SinglePlayer() and not settings.singleplayer then return end

    panel:PaintScanlines( x, y )

end

---
--- Preview
---
local preview_hudpropcount = HOLOHUD2.component.Create( "HudPropCount" )

preview_hudpropcount:SetMaxValue( 30 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudpropcount:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    local w, h = settings.size.x * scale, settings.size.y * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudpropcount:Think()
    preview_hudpropcount:PaintBackground( x, y )

    if game_SinglePlayer() and not settings.singleplayer then return end

    preview_hudpropcount:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    local control = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", panel )
    control:SetWide( 132 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() )
    control:SetIcon( "icon16/bricks.png" )
    control:SetMinMax( 0, 1024 )
    control:SetValue( preview_hudpropcount.value )
    control:SetMaxValue( preview_hudpropcount.max_value )
    control.OnValueChanged = function( _, value )

        preview_hudpropcount:SetValue( math.Round( value ) )

    end
    control.OnMaxValueChanged = function( _, value )

        preview_hudpropcount:SetMaxValue( math.Round( value ) )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( 136, panel:GetTall() - reset:GetTall() - 6 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        control:SetValue( 0 )
        control:SetMaxValue( 30 )

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
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )

    hudpropcount:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudpropcount:InvalidateLayout()

end

HOLOHUD2.element.Register( "propcount", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudpropcount    = hudpropcount
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "propcount", "animation" )
HOLOHUD2.modifier.Add( "background", "propcount", "background" )
HOLOHUD2.modifier.Add( "background_color", "propcount", "background_color" )
HOLOHUD2.modifier.Add( "color2", "propcount", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "propcount", { "number_rendermode", "number2_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "propcount", { "number_background", "number2_background" } )
HOLOHUD2.modifier.Add( "number3_font", "propcount", { "number_font", "number2_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "propcount", { "number_pos", "number2_pos" } )
HOLOHUD2.modifier.Add( "scale", "propcount", {
    "pos", "margin", "size",
    "number_pos", "number_font",
    "separator_pos", "separator_size",
    "number2_pos", "number2_font",
    "progressbar_pos", "progressbar_size",
    "icon_pos", "icon_size",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "propcount", "element/propcount" )
