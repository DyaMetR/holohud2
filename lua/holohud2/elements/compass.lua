HOLOHUD2.AddCSLuaFile( "compass/hudcompass.lua" )

if SERVER then return end

local EyeAngles = EyeAngles
local hook_Call = HOLOHUD2.hook.Call
local StartAlphaMultiplier, EndAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier, HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local threesixty = false

local ELEMENT = {
    name        = "#holohud2.compass",
    helptext    = "#holohud2.compass.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 32 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 140, y = 20 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        inverted                    = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = false },
        padding                     = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 0, min = 0 },
        scale                       = { name = "#holohud2.compass.visible_width", type = HOLOHUD2.PARAM_RANGE, value = .5, min = 0, max = 1, decimals = 1, helptext = "#holohud2.compass.visible_width.helptext" },
        mode                        = { name = "#holohud2.compass.scroll_style", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.compass.scroll_style_0", "#holohud2.compass.scroll_style_1", "#holohud2.compass.scroll_style_2" }, value = 3 },
        eightwind                   = { name = "#holohud2.compass.eightwind", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.compass.eightwind.helptext" },

        font                        = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 0, italic = false } },
        on_background               = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        graduation                  = { name = "#holohud2.compass.graduation", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.compass.graduation_0", "#holohud2.compass.graduation_1", "#holohud2.compass.graduation_2" }, value = 2 },
        graduation_segments         = { name = "#holohud2.compass.segments", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 0 },
        graduation_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 8, min = 0 },
        graduation_font             = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 8, weight = 0, italic = false } },
        graduation_on_background    = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = true },

        axis                        = { name = "#holohud2.compass.axis", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.compass.axis.helptext" },
        axis_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 6, weight = 1000, italic = false } },
        axis_colorx                 = { name = "#holohud2.compass.axis_x_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 192, 24, 24 ) },
        axis_colory                 = { name = "#holohud2.compass.axis_y_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 24, 192, 24 ) },

        threesixty                  = { name = "#holohud2.compass.threesixty", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.compass.threesixty.helptext" },
        northzero                   = { name = "#holohud2.compass.north_zero", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.compass.north_zero.helptext" },

        gauge                       = { name = "#holohud2.common.visible", type = HOLOHUD2.PARAM_BOOL, value = false },
        gauge_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 106 } },
        gauge_dock                  = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        gauge_margin                = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4 },
        gauge_direction             = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        gauge_padding               = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 0 },
        gauge_font                  = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 13, weight = 1000, italic = false } },
        gauge_rendermode            = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        gauge_background            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        gauge_align                 = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT }
    },
    menu = {
        { id = "inverted" },
        { id = "mode" },
        { id = "eightwind" },
        { id = "threesixty" },
        { id = "northzero" },

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
            { id = "padding" },
            { id = "scale" },
            { name = "#holohud2.compass.cardinal_points", parameters = {
                { id = "font" },
                { id = "on_background" }
            } },
            { id = "graduation", parameters = {
                { id = "graduation_segments" },
                { id = "graduation_size" },
                { id = "graduation_font" },
                { id = "graduation_on_background" }
            } },
            { id = "axis", parameters = {
                { id = "axis_font" },
                { id = "axis_colorx" },
                { id = "axis_colory" }
            } }
        } },

        { category = "#holohud2.compass.angle_panel", parameters = {
            { id = "gauge" },
            { id = "gauge_pos", parameters = {
                { id = "gauge_dock" },
                { id = "gauge_margin" },
                { id = "gauge_direction" }
            } },
            { id = "gauge_padding" },
            { name = "#holohud2.component.number", parameters = {
                { id = "gauge_font" },
                { id = "gauge_rendermode" },
                { id = "gauge_background" },
                { id = "gauge_align" }
            } }
        } }
    },
    quickmenu = {
        { id = "inverted" },
        { id = "eightwind" },
        { id = "threesixty" },
        { id = "northzero" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "font", name = "#holohud2.compass.cardinal_font" },
            { id = "graduation", parameters = {
                { id = "graduation_size"},
                { id = "graduation_font" }
            } },
            { id = "axis", parameters = {
                { id = "axis_font" },
                { id = "axis_colorx" },
                { id = "axis_colory" }
            } }
        } },

        { category = "#holohud2.compass.category.angle_panel", parameters = {
            { id = "gauge" },
            { id = "gauge_pos" },
            { id = "gauge_font" }
        } }
    }
}

---
--- Composition
---
local hudcompass, gauge     = HOLOHUD2.component.Create( "HudCompass" ), HOLOHUD2.component.Create( "Number" )
local layout, gauge_layout  = HOLOHUD2.layout.Register( "compass" ), HOLOHUD2.layout.Register( "compass_gauge" )
local panel, gauge_panel    = HOLOHUD2.component.Create( "AnimatedPanel" ), HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )
gauge_panel:SetLayout( gauge_layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawCompass", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawCompass", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudcompass:PaintBackground( x, y )

    hook_Call( "DrawOverCompass", x, y, self._w, self._h, LAYER_BACKGROUND, hudcompass )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawCompass", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudcompass:Paint( x, y )

    hook_Call( "DrawOverCompass", x, y, self._w, self._h, LAYER_FOREGROUND, hudcompass )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawCompass", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudcompass:PaintScanlines( x, y )

    hook_Call( "DrawOverCompass", x, y, self._w, self._h, LAYER_SCANLINES, hudcompass )

end

gauge_panel.PaintOverBackground = function( self, x, y )

    gauge:PaintBackground( x, y )

end

gauge_panel.PaintOver = function( self, x, y )

    gauge:Paint( x, y )

end

gauge_panel.PaintOverScanlines = function( self, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    gauge:Paint( x, y )
    EndAlphaMultiplier()

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

    return "#holohud2.compass.startup"

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
function ELEMENT:PreDraw( settings )

    if startup_phase == STARTUP_QUEUED then return end

    hudcompass:SetYaw( EyeAngles().y )
    hudcompass:Think()

    gauge:SetValue( math.floor( EyeAngles().y + ( settings.threesixty and 180 or 0 ) ) )
    gauge:PerformLayout()

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() )

    gauge_panel:Think()
    gauge_panel:SetDeployed( settings.gauge and panel.deployed )

    gauge_layout:SetSize( gauge.__w + settings.gauge_padding * 3, gauge.__h + settings.gauge_padding * 2 )

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )
    
    panel:PaintFrame( x, y )
    gauge_panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )

    panel:PaintBackground( x, y )
    gauge_panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )

    panel:Paint( x, y )
    gauge_panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    panel:PaintScanlines( x, y )
    gauge_panel:PaintScanlines( x, y )

end


---
--- Preview
---
local preview_hudcompass = HOLOHUD2.component.Create( "HudCompass" )
local preview_gauge = HOLOHUD2.component.Create( "Number" )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudcompass:ApplySettings( settings, self.preview_fonts )

    preview_gauge:SetPos( settings.gauge_padding * 1.5, settings.gauge_padding )
    preview_gauge:SetColor( settings.color )
    preview_gauge:SetColor2( settings.color2 )
    preview_gauge:SetFont( self.preview_fonts.gauge_font )
    preview_gauge:SetDigits( settings.threesixty and 3 or 4 )
    preview_gauge:SetRenderMode( settings.gauge_rendermode )
    preview_gauge:SetBackground( settings.gauge_background )
    preview_gauge:SetAlign( settings.gauge_align )

end

function ELEMENT:PreviewInit( panel )

    local control = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    control:SetWide( 172 )
    control:SetIcon( "icon16/time.png" )
    control:SetMinMax( -180, 180 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() )
    control.OnValueChanged = function( _, value )

        preview_hudcompass:SetYaw( value )
        preview_gauge:SetValue( math.floor( value + ( threesixty and 180 or 0 ) ) )

    end
    
    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( control:GetX() + control:GetWide() + 4, panel:GetTall() - reset:GetTall() - 5 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        control:SetValue( 0 )

    end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()
    local w0, h0 = settings.size.x * scale, settings.size.y * scale
    local w1, h1 = 0, 0
    local margin = 4 * scale

    if settings.gauge then

        w1, h1 = ( preview_gauge.__w + settings.gauge_padding * 3 ) * scale, ( preview_gauge.__h + settings.gauge_padding * 2 ) * scale

    end

    local x0, y0 = x - w0 / 2, y - ( h0 + h1 + margin ) / 2

    if settings.background then

        draw.RoundedBox( 0, x0, y0, w0, h0, settings.background_color )

    end

    surface.SetDrawColor( wireframe_color )
    surface.DrawOutlinedRect( x0, y0, w0, h0 )

    preview_hudcompass:Think()
    preview_hudcompass:PaintBackground( x0, y0 )
    preview_hudcompass:Paint( x0, y0 )

    if not settings.gauge then return end

    local x1, y1 = x - w1 / 2, y0 + h0 + margin

    if settings.background then

        draw.RoundedBox( 0, x1, y1, w1, h1, settings.background_color )

    end

    surface.SetDrawColor( wireframe_color )
    surface.DrawOutlinedRect( x1, y1, w1, h1 )

    preview_gauge:PerformLayout()
    preview_gauge:PaintBackground( x1, y1 )
    preview_gauge:Paint( x1, y1 )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then
        
        layout:SetVisible( false )
        gauge_layout:SetVisible( false )
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

    hudcompass:ApplySettings( settings, self.fonts )
    
    gauge_layout:SetVisible( settings.gauge )
    gauge_layout:SetPos( settings.gauge_pos.x, settings.gauge_pos.y )
    gauge_layout:SetDock( settings.gauge_dock )
    gauge_layout:SetMargin( settings.gauge_margin )
    gauge_layout:SetDirection( settings.gauge_direction )
    gauge_layout:SetOrder( settings.order + .1 )

    gauge_panel:SetAnimation( settings.animation )
    gauge_panel:SetAnimationDirection( settings.animation_direction )
    gauge_panel:SetDrawBackground( settings.background )
    gauge_panel:SetColor( settings.background_color )

    gauge:SetPos( settings.gauge_padding * 1.5, settings.gauge_padding )
    gauge:SetColor( settings.color )
    gauge:SetColor2( settings.color2 )
    gauge:SetFont( self.fonts.gauge_font )
    gauge:SetDigits( settings.threesixty and 3 or 4 )
    gauge:SetRenderMode( settings.gauge_rendermode )
    gauge:SetBackground( settings.gauge_background )
    gauge:SetAlign( settings.gauge_align )

    threesixty = settings.threesixty

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudcompass:InvalidateLayout()

end

HOLOHUD2.element.Register( "compass", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudcompass  = hudcompass
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "compass", "animation" )
HOLOHUD2.modifier.Add( "background", "compass", "background" )
HOLOHUD2.modifier.Add( "background_color", "compass", "background_color" )
HOLOHUD2.modifier.Add( "color", "compass", "color" )
HOLOHUD2.modifier.Add( "color2", "compass", "color2" )
HOLOHUD2.modifier.Add( "text_font", "compass", { "font", "graduation_font" } )
HOLOHUD2.modifier.Add( "number2_font", "compass", "gauge_font" )
-- TODO: offset, graduation_offset and gauge_offset

---
--- Presets
---
HOLOHUD2.presets.Register( "compass", "element/compass" )
HOLOHUD2.presets.Add( "compass", "Classic", {
    scale = 0.4,
    pos = {
        y = 24,
        x = 12,
    },
    size = {
        y = 17,
        x = 244,
    },
    eightwind = false,
    axis = false,
    mode = 2,
    font = {
        italic = false,
        weight = 0,
        font = "Roboto Light",
        size = 14,
    },
    dock = 2,
} )