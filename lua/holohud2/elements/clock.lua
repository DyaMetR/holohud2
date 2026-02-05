HOLOHUD2.AddCSLuaFile( "clock/hudclock.lua" )

if SERVER then return end

local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.clock",
    helptext    = "#holohud2.clock.helptext",
    parameters  = {
        twelvehours                 = { name = "#holohud2.clock.twelve_hours", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.clock.twelve_hours.helptext" },
        blinking                    = { name = "#holohud2.clock.blinking", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.clock.blinking.helptext" },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 48 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 140, y = 20 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        origin                      = { name = "#holohud2.clock.origin", type = HOLOHUD2.PARAM_VECTOR, value = { x = 70, y = 3 } },
        spacing                     = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 1 },
        align                       = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },

        hour                        = { name = "#holohud2.clock.hour", type = HOLOHUD2.PARAM_BOOL, value = true },
        hour_offset                 = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        hour_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 0, italic = false } },
        hour_rendermode             = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_LEADINGZEROS },
        hour_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        hour_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        hour_separator              = { name = "#holohud2.clock.hour_separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        hour_separator_offset       = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = -1 } },
        hour_separator_font         = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false } },
        hour_separator_background   = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        minutes                     = { name = "#holohud2.clock.minutes", type = HOLOHUD2.PARAM_BOOL, value = true },
        minutes_offset              = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        minutes_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 0, italic = false } },
        minutes_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_LEADINGZEROS },
        minutes_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        minutes_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        minutes_separator           = { name = "#holohud2.clock.minutes_separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        minutes_separator_offset    = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = -1 } },
        minutes_separator_font      = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false } },
        minutes_separator_background= { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        seconds                     = { name = "#holohud2.clock.seconds", type = HOLOHUD2.PARAM_BOOL, value = true },
        seconds_offset              = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        seconds_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 0, italic = false } },
        seconds_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_LEADINGZEROS },
        seconds_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        seconds_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        am                          = { name = "#holohud2.common.AM", type = HOLOHUD2.PARAM_BOOL, value = true },
        am_offset                   = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 0 } },
        am_font                     = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 0, italic = false } },
        am_background               = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        pm                          = { name = "#holohud2.common.PM", type = HOLOHUD2.PARAM_BOOL, value = true },
        pm_offset                   = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 0 } },
        pm_font                     = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 0, italic = false } },
        pm_background               = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        date                        = { name = "#holohud2.clock.date", type = HOLOHUD2.PARAM_BOOL, value = false },
        date_format                 = { name = "#holohud2.parameter.format", type = HOLOHUD2.PARAM_STRING, value = "{weekday}, {month} {ordinal}", helptext = "#holohud2.clock.format.helptext" },
        date_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 70, y = 18 } },
        date_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 10, weight = 0, italic = false } },
        date_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.TIME" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "twelvehours" },
        { id = "blinking" },

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

        { category = "#holohud2.clock", parameters = {
            { id = "origin" },
            { id = "spacing" },
            { id = "align" },
            { id = "hour", parameters = {
                { id = "hour_offset" },
                { id = "hour_font" },
                { id = "hour_rendermode" },
                { id = "hour_background" },
                { id = "hour_align" }
            } },
            { id = "hour_separator", parameters = {
                { id = "hour_separator_offset" },
                { id = "hour_separator_font" },
                { id = "hour_separator_background" }
            } },
            { id = "minutes", parameters = {
                { id = "minutes_offset" },
                { id = "minutes_font" },
                { id = "minutes_rendermode" },
                { id = "minutes_background" },
                { id = "minutes_align" }
            } },
            { id = "minutes_separator", parameters = {
                { id = "minutes_separator_offset" },
                { id = "minutes_separator_font" },
                { id = "minutes_separator_background" }
            } },
            { id = "seconds", parameters = {
                { id = "seconds_offset" },
                { id = "seconds_font" },
                { id = "seconds_rendermode" },
                { id = "seconds_background" },
                { id = "seconds_align" }
            } },
            { id = "am", parameters = {
                { id = "am_offset" },
                { id = "am_font" },
                { id = "am_background" }
            } },
            { id = "pm", parameters = {
                { id = "pm_offset" },
                { id = "pm_font" },
                { id = "pm_background" }
            } }
        } },
        { category = "#holohud2.category.other", parameters = {
            { id = "date", parameters = {
                { id = "date_format" },
                { id = "date_pos" },
                { id = "date_font" },
                { id = "date_align" }
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
        { id = "twelvehours" },
        { id = "blinking" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" },
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.clock", parameters = {
            { id = "origin" },
            { id = "hour", parameters = {
                { id = "hour_offset" },
                { id = "hour_font" }
            } },
            { id = "hour_separator", parameters = {
                { id = "hour_separator_offset" },
                { id = "hour_separator_font" }
            } },
            { id = "minutes", parameters = {
                { id = "minutes_offset" },
                { id = "minutes_font" }
            } },
            { id = "minutes_separator", parameters = {
                { id = "minutes_separator_offset" },
                { id = "minutes_separator_font" }
            } },
            { id = "seconds", parameters = {
                { id = "seconds_offset" },
                { id = "seconds_font" }
            } },
            { id = "am", parameters = {
                { id = "am_offset" },
                { id = "am_font" }
            } },
            { id = "pm", parameters = {
                { id = "pm_offset" },
                { id = "pm_font" }
            } }
        } },
        { category = "#holohud2.category.other", parameters = {
            { id = "date", parameters = {
                { id = "date_pos" },
                { id = "date_font" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } }
    }
}

---
--- Components
---
local hudclock      = HOLOHUD2.component.Create( "HudClock" )
local layout        = HOLOHUD2.layout.Register( "clock" )
local panel         = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawClock", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawClock", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudclock:PaintBackground( x, y )

    hook_Call( "DrawOverClock", x, y, self._w, self._h, LAYER_BACKGROUND, hudclock )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawClock", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudclock:Paint( x, y )

    hook_Call( "DrawOverClock", x, y, self._w, self._h, LAYER_FOREGROUND, hudclock )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawClock", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudclock:PaintScanlines( x, y )

    hook_Call( "DrawOverClock", x, y, self._w, self._h, LAYER_SCANLINES, hudclock )

end

---
--- Startup
---
local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_EMPTY     = 2
local STARTUP_SYNC      = 3

local STARTUP_TIMINGS   = { 1, 1, 2 }

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    panel:Close()

    hudclock.Hours:SetValue( 0 )
    hudclock.Minutes:SetValue( 0 )
    hudclock.Seconds:SetValue( 0 )
    hudclock:Think()

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

    return "#holohud2.clock.startup"

end

function ELEMENT:DoStartupSequence()

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_SYNC then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    if startup_phase == STARTUP_SYNC then

        hudclock:SetTime( os.time() )
        hudclock:Think()

    end

    panel:SetDeployed( true )
    panel:Think()

    return true

end

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    if self:DoStartupSequence() then return end

    hudclock:SetTime( os.time() )
    hudclock:Think()

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() )

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
local preview_hudclock = HOLOHUD2.component.Create( "HudClock" )
local preview_value = 0

function ELEMENT:OnPreviewChanged( settings )

    preview_hudclock:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewInit( panel )

    preview_value = os.time()
    preview_hudclock:SetTime( preview_value )

    local control = vgui.Create( "Panel", panel )
    control:SetSize( 128, 72 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() - 4 )

        local add = vgui.Create( "Panel", control )
        add:Dock( TOP )

            local hour = vgui.Create( "DButton", add )
            hour:SetSize( 41, 22 )
            hour:SetText( "/\\" )
            hour.DoClick = function()

                preview_value = preview_value + 3600
                preview_hudclock:SetTime( preview_value )

            end

            local minutes = vgui.Create( "DButton", add )
            minutes:SetX( 44 )
            minutes:SetSize( 41, 22 )
            minutes:SetText( "/\\" )
            minutes.DoClick = function()

                preview_value = preview_value + 60
                preview_hudclock:SetTime( preview_value )

            end

            local seconds = vgui.Create( "DButton", add )
            seconds:SetX( 87 )
            seconds:SetSize( 41, 22 )
            seconds:SetText( "/\\" )
            seconds.DoClick = function()

                preview_value = preview_value + 1
                preview_hudclock:SetTime( preview_value )

            end

        local indicator = vgui.Create( "DPanel", control )
        indicator:Dock( TOP )

            local label = vgui.Create( "DLabel", indicator )
            label:Dock( FILL )
            label:SetTextColor( panel:GetSkin().Colours.Label.Dark )
            label:SetText( "HH    :    MM    :    SS" )
            label:SetContentAlignment( 5 )

        local sub = vgui.Create( "Panel", control )
        sub:Dock( TOP )

            local hour = vgui.Create( "DButton", sub )
            hour:SetY( 2 )
            hour:SetSize( 41, 22 )
            hour:SetText( "\\/" )
            hour.DoClick = function()

                preview_value = preview_value - 3600
                preview_hudclock:SetTime( preview_value )

            end

            local minutes = vgui.Create( "DButton", sub )
            minutes:SetPos( 44, 2 )
            minutes:SetSize( 41, 22 )
            minutes:SetText( "\\/" )
            minutes.DoClick = function()

                preview_value = preview_value - 60
                preview_hudclock:SetTime( preview_value )

            end

            local seconds = vgui.Create( "DButton", sub )
            seconds:SetPos( 87, 2 )
            seconds:SetSize( 41, 22 )
            seconds:SetText( "\\/" )
            seconds.DoClick = function()

                preview_value = preview_value - 1
                preview_hudclock:SetTime( preview_value )

            end

        local reset = vgui.Create( "DImageButton", panel )
        reset:SetSize( 16, 16 )
        reset:SetPos( control:GetX() + control:GetWide() + 4, control:GetY() + control:GetTall() - reset:GetTall() - 2 )
        reset:SetImage( "icon16/arrow_refresh.png" )
        reset.DoClick = function()

            preview_value = os.time()
            preview_hudclock:SetTime( preview_value )

        end

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

    preview_hudclock:Think()
    preview_hudclock:PaintBackground( x, y )
    preview_hudclock:Paint( x, y )

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

    hudclock:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudclock:InvalidateLayout()

end

HOLOHUD2.element.Register( "clock", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudclock    = hudclock
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "clock", "animation" )
HOLOHUD2.modifier.Add( "background", "clock", "background" )
HOLOHUD2.modifier.Add( "background_color", "clock", "background_color" )
HOLOHUD2.modifier.Add( "color", "clock", "color" )
HOLOHUD2.modifier.Add( "color2", "clock", "color2" )
HOLOHUD2.modifier.Add( "number_background", "clock", { "hour_background", "minutes_background", "seconds_background" } )
HOLOHUD2.modifier.Add( "number3_font", "clock", { "hour_font", "minutes_font", "seconds_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "clock", { "hour_offset", "minutes_offset", "seconds_offset" } )
HOLOHUD2.modifier.Add( "text_font", "clock", "date_font" )
HOLOHUD2.modifier.Add( "text_offset", "clock", "date_pos" )
HOLOHUD2.modifier.Add( "scale", "clock", {
    "pos", "margin", "size", "origin", "spacing",
    "hour_offset", "hour_font", "hour_separator_offset", "hour_separator_font",
    "minutes_offset", "minutes_font", "minutes_separator_offset", "minutes_separator_font",
    "seconds_offset", "seconds_font",
    "am_offset", "am_font", "pm_offset", "pm_font",
    "date_pos", "date_font",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "clock", "element/clock" )
HOLOHUD2.presets.Add( "clock", "Classic", {
    origin = {
        y = 3,
        x = 31,
    },
    pos = {
        y = 24,
        x = 12,
    },
    size = {
        y = 20,
        x = 62,
    },
    dock = 2
} )
HOLOHUD2.presets.Add( "clock", "Classic - Date", {
    date_pos = {
        y = 18,
        x = 46,
    },
    pos = {
        y = 24,
        x = 12,
    },
    size = {
        y = 31,
        x = 92,
    },
    origin = {
        y = 3,
        x = 46,
    },
    date = true,
    date_align = 1,
    dock = 2
} )
HOLOHUD2.presets.Add( "clock", "Classic - Digital", {
    minutes_separator = false,
    date_align = 0,
    dock = 2,
    hour_separator = false,
    hour_font = {
        italic = false,
        weight = 0,
        font = "Roboto Light",
        size = 34,
    },
    size = {
        y = 50,
        x = 92,
    },
    date_font = {
        italic = false,
        weight = 1000,
        font = "Roboto Light",
        size = 11,
    },
    seconds_offset = {
        y = 0,
        x = -24,
    },
    date_format = "{shortweekday} {monthnumber}/{day}",
    seconds_font = {
        italic = false,
        weight = 0,
        font = "Roboto Light",
        size = 18,
    },
    date = true,
    hour_offset = {
        y = -4,
        x = 0,
    },
    pos = {
        y = 24,
        x = 12,
    },
    align = 0,
    origin = {
        y = 4,
        x = 6,
    },
    date_pos = {
        y = 21,
        x = 40,
    },
    hour_rendermode = 1,
    minutes_font = {
        italic = false,
        weight = 1000,
        font = "Roboto Light",
        size = 22,
    },
    minutes_offset = {
        y = 23,
        x = -24,
    },
    am_pos = {
        x = -41,
        y = 29
    },
    pm_pos = {
        x = -41,
        y = 29
    }
} )
