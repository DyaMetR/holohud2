HOLOHUD2.AddCSLuaFile( "ping/hudping.lua" )

if SERVER then return end

local LocalPlayer = LocalPlayer
local hook_Call = HOLOHUD2.hook.Call
local game_SinglePlayer = game.SinglePlayer

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.ping",
    helptext    = "#holohud2.ping.helptext",
    parameters  = {
        singleplayer            = { name = "#holohud2.parameter.singleplayer_inclusive", type = HOLOHUD2.PARAM_BOOL, value = false },
        threshold               = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_RANGE, value = 50, min = 0, max = 300, helptext = "From which ping value does the panel start displaying." },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 156, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 48 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 50, y = 26 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 184, 184, 184 ), [50] = Color( 255, 255, 255 ), [100] = Color( 255, 162, 72 ), [300] = Color( 255, 64, 48 ) }, fraction = false, gradual = true } },
        color2                  = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = false, gradual = true } },

        icon                    = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 5 } },
        icon_size               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 8 },
        icon_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        number                  = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        number_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 16, y = 1 } },
        number_font             = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 16, weight = 1000, italic = false } },
        number_rendermode       = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background       = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align            = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits           = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        unit                    = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_BOOL, value = true },
        unit_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 39, y = 8 } },
        unit_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 6, weight = 0, italic = false } },
        unit_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        graph                   = { name = "#holohud2.component.graph", type = HOLOHUD2.PARAM_BOOL, value = true },
        graph_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 16 } },
        graph_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 42, y = 8 } },
        graph_inverted          = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = false },
        graph_guide             = { name = "#holohud2.parameter.guide", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 10, weight = 1000, italic = false } },
        text_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "PING" },
        text_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "singleplayer" },
        { id = "threshold" },

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

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" },
                { id = "icon_on_background" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_align" },
                { id = "number_digits" }
            } },
            { id = "unit", parameters = {
                { id = "unit_pos" },
                { id = "unit_font" },
                { id = "unit_on_background" }
            } },
            { id = "graph", parameters = {
                { id = "graph_pos" },
                { id = "graph_size" },
                { id = "graph_inverted" },
                { id = "graph_guide" }
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
        { id = "threshold" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" }
            } },
            { id = "unit", parameters = {
                { id = "unit_pos" },
                { id = "unit_font" }
            } },
            { id = "graph", parameters = {
                { id = "graph_pos" },
                { id = "graph_size" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } }
    }
}

---
--- Startup sequence
---
local startup -- is the element awaiting startup
function ELEMENT:QueueStartup() startup = true end
function ELEMENT:Startup() startup = false end

---
--- Composition
---
local hudping   = HOLOHUD2.component.Create( "HudPing" )
local layout    = HOLOHUD2.layout.Register( "ping" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawPing", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawPing", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudping:PaintBackground( x, y )

    hook_Call( "DrawOverPing", x, y, self._w, self._h, LAYER_BACKGROUND, hudping )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawPing", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudping:Paint( x, y )

    hook_Call( "DrawOverPing", x, y, self._w, self._h, LAYER_FOREGROUND, hudping )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawPing", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudping:PaintScanlines( x, y )

    hook_Call( "DrawOverPing", x, y, self._w, self._h, LAYER_SCANLINES, hudping )

end

---
--- Logic
---
local localplayer
function ELEMENT:PreDraw( settings )

    if startup then return end

    localplayer = localplayer or LocalPlayer()
    local ping = localplayer:Ping()

    hudping:SetValue( ping )

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or ( not game_SinglePlayer() or settings.singleplayer ) and ping >= settings.threshold ) )

    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudping:Think()

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
local preview_hudping = HOLOHUD2.component.Create( "HudPing" )

preview_hudping:SetValue( 5 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudping:ApplySettings( settings, self.preview_fonts )

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

    preview_hudping:Think()
    preview_hudping:PaintBackground( x, y )

    if game_SinglePlayer() and not settings.singleplayer then return end

    preview_hudping:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    local control = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    control:SetWide( 172 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() )
    control:SetIcon( "icon16/transmit.png" )
    control:SetMinMax( 0, 300 )
    control:SetValue( preview_hudping.value )
    control.OnValueChanged = function( _, value )

        preview_hudping:SetValue( math.Round( value ) )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( 176, panel:GetTall() - reset:GetTall() - 5 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        control:SetValue( 5 )

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

    hudping:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudping:InvalidateLayout()

end

HOLOHUD2.element.Register( "ping", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudping     = hudping
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "ping", "animation" )
HOLOHUD2.modifier.Add( "background", "ping", "background" )
HOLOHUD2.modifier.Add( "background_color", "ping", "background_color" )
HOLOHUD2.modifier.Add( "color2", "ping", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "ping", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "ping", "number_background" )
HOLOHUD2.modifier.Add( "number3_font", "ping", "number_font" )
HOLOHUD2.modifier.Add( "number3_offset", "ping", "number_pos" )
HOLOHUD2.modifier.Add( "scale", "ping", {
    "pos", "margin", "size",
    "icon_pos", "icon_size",
    "number_pos", "number_font",
    "unit_pos", "unit_font",
    "graph_pos", "graph_size",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "ping", "element/ping" )
