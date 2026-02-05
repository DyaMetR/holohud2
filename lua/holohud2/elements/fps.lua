HOLOHUD2.AddCSLuaFile( "fps/hudfps.lua" )

if SERVER then return end

local FrameTime = FrameTime
local CurTime = CurTime
local LocalPlayer = LocalPlayer
local hook_Call = HOLOHUD2.hook.Call

local ELEMENT = {
    name        = "#holohud2.framerate",
    helptext    = "#holohud2.framerate.helptext",
    parameters  = {
        autohide                = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay          = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        autohide_threshold      = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_NUMBER, value = 30, min = 0, max = 300, helptext = "#holohud2.framerate.threshold.helptext" },
        smooth                  = { name = "#holohud2.framerate.smooth", type = HOLOHUD2.PARAM_BOOL, value = true },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 156, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 32 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 50, y = 26 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [20] = Color( 255, 44, 44 ), [30] = Color( 255, 192, 108 ), [55] = Color( 255, 255, 255 ), [300] = Color( 184, 184, 184 ) }, fraction = false, gradual = false } },
        color2                  = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12) }, fraction = false, gradual = false }  },

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
        text_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.FRAMERATE" },
        text_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "autohide", parameters = {
            { id = "autohide_delay" },
            { id = "autohide_threshold" }
        } },
        { id = "smooth" },

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
                { id = "number_align" }
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
        { id = "autohide" },
        { id = "smooth" },

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
--- Composition
---
local hudfps    = HOLOHUD2.component.Create( "HudFramerate" )
local layout    = HOLOHUD2.layout.Register( "fps" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawFramerate", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawFramerate", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudfps:PaintBackground( x, y )

    hook_Call( "DrawOverFramerate", x, y, self._w, self._h, LAYER_BACKGROUND, hudfps )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawFramerate", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudfps:Paint( x, y )

    hook_Call( "DrawOverFramerate", x, y, self._w, self._h, LAYER_FOREGROUND, hudfps )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawFramerate", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudfps:PaintScanlines( x, y )

    hook_Call( "DrawOverFramerate", x, y, self._w, self._h, LAYER_SCANLINES, hudfps )

end

---
--- Startup
---
local max_fps = GetConVar( "fps_max" )

local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_EMPTY     = 2
local STARTUP_FILL      = 3

local STARTUP_TIMINGS   = { 1, 1, 2 }

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    panel:Close()
    hudfps:SetValue( 0 )
    hudfps._value = 0
    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    startup_phase = STARTUP_STANDBY
    next_startup_phase = CurTime() + STARTUP_TIMINGS[ startup_phase ]

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:IsStartupOver()

    return startup_phase == STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.framerate.startup"

end

function ELEMENT:DoStartupSequence( curtime, frametime )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_FILL then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    if startup_phase == STARTUP_FILL then

        hudfps:SetMaxValue( max_fps:GetInt() )
        hudfps:SetValue( frametime ~= 0 and 1 / frametime or 0 )

    end

    hudfps:Think()

    panel:Think()
    panel:SetDeployed( true )

    layout:SetVisible( panel:IsVisible() )

    return true

end

---
--- Logic
---
local localplayer
local time, gracetime = 0, 0
function ELEMENT:PreDraw( settings )

    localplayer = localplayer or LocalPlayer()
    local frametime = FrameTime()
    local curtime = CurTime()

    if self:DoStartupSequence( curtime, frametime ) then return end

    if frametime == 0 then return end

    local fps = math.Round( 1 / frametime )

    hudfps:SetMaxValue( max_fps:GetInt() )
    hudfps:SetValue( fps )

    if fps > settings.autohide_threshold then

        gracetime = curtime + 1

    else

        if gracetime < curtime then

            time = curtime + settings.autohide_delay

        end

    end

    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or not settings.autohide or time > curtime ) )
    panel:Think()

    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then

        hudfps._value = fps
        return

    end

    hudfps:Think()

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

    if startup_phase == STARTUP_STANDBY then return end

    panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    if startup_phase == STARTUP_STANDBY then return end

    panel:PaintScanlines( x, y )

end

---
--- Preview
---
local preview_hudfps = HOLOHUD2.component.Create( "HudFramerate" )

preview_hudfps:SetValue( 60 )
preview_hudfps:SetMaxValue( 300 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudfps:ApplySettings( settings, self.preview_fonts )

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

    preview_hudfps:Think()
    preview_hudfps:PaintBackground( x, y )
    preview_hudfps:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    local control = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    control:SetWide( 172 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() )
    control:SetIcon( "icon16/photos.png" )
    control:SetMinMax( 0, 300 )
    control:SetValue( preview_hudfps.value )
    control.OnValueChanged = function( _, value )

        preview_hudfps:SetValue( math.Round( value ) )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( 176, panel:GetTall() - reset:GetTall() - 5 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        control:SetValue( 60 )

    end

end


---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

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

    hudfps:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudfps:InvalidateLayout()

end

HOLOHUD2.element.Register( "fps", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudfps      = hudfps
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "fps", "animation" )
HOLOHUD2.modifier.Add( "background", "fps", "background" )
HOLOHUD2.modifier.Add( "background_color", "fps", "background_color" )
HOLOHUD2.modifier.Add( "color2", "fps", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "fps", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "fps", "number_background" )
HOLOHUD2.modifier.Add( "number3_font", "fps", "number_font" )
HOLOHUD2.modifier.Add( "number3_offset", "fps", "number_pos" )
HOLOHUD2.modifier.Add( "scale", "fps", {
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
HOLOHUD2.presets.Register( "fps", "element/fps" )
