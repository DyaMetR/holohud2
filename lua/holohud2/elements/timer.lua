
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.timer",
    helptext    = "#holohud2.timer.helptext",
    parameters  = {
        blinking                    = { name = "#holohud2.clock.hour_separator", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.timer.blinking.helptext" },
        
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 70, y = 24 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        origin                      = { name = "#holohud2.clock.origin", type = HOLOHUD2.PARAM_VECTOR, value = { x = 35, y = 3 } },
        spacing                     = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 1 },
        align                       = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },

        minutes                     = { name = "#holohud2.clock.minutes", type = HOLOHUD2.PARAM_BOOL, value = true },
        minutes_offset              = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        minutes_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 0, italic = false } },
        minutes_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_LEADINGZEROS },
        minutes_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        minutes_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        separator                   = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_offset            = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = -1 } },
        separator_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 1000, italic = false } },
        separator_background        = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        seconds                     = { name = "#holohud2.clock.seconds", type = HOLOHUD2.PARAM_BOOL, value = true },
        seconds_offset              = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        seconds_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 0, italic = false } },
        seconds_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_LEADINGZEROS },
        seconds_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        seconds_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "TIME" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
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
            { id = "minutes", parameters = {
                { id = "minutes_offset" },
                { id = "minutes_font" },
                { id = "minutes_rendermode" },
                { id = "minutes_background" },
                { id = "minutes_align" }
            } },
            { id = "separator", parameters = {
                { id = "separator_offset" },
                { id = "separator_font" },
                { id = "separator_background" }
            } },
            { id = "seconds", parameters = {
                { id = "seconds_offset" },
                { id = "seconds_font" },
                { id = "seconds_rendermode" },
                { id = "seconds_background" },
                { id = "seconds_align" }
            } }
        } },

        { category = "#holohud2.category.other", parameters = {
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
        { id = "blinking" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "Clock", parameters = {
            { id = "origin" },
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
            } }
        } },
        
        { category = "Other", parameters = {
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
local hudtimer = HOLOHUD2.component.Create( "HudExtensionTimer" )
local layout = HOLOHUD2.layout.Register( "timer" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawTimer", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawTimer", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudtimer:PaintBackground( x, y )

    hook_Call( "DrawOverTimer", x, y, self._w, self._h, LAYER_BACKGROUND, hudtimer )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawTimer", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudtimer:Paint( x, y )

    hook_Call( "DrawOverTimer", x, y, self._w, self._h, LAYER_FOREGROUND, hudtimer )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawTimer", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudtimer:PaintScanlines( x, y )

    hook_Call( "DrawOverTimer", x, y, self._w, self._h, LAYER_SCANLINES, hudtimer )

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
function ELEMENT:PreDraw( settings )

    if startup then return end
    
    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and hook_Call( "ShouldDrawTimer" ) == true )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudtimer:SetTime( hook_Call( "GetTime" ) or 0 )
    hudtimer:Think()

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
local preview_hudtimer = HOLOHUD2.component.Create( "HudExtensionTimer" )
preview_hudtimer:SetTime( 300 )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()
    local u, v = settings.size.x * scale, settings.size.y * scale
    local x, y = x + w / 2 - u / 2, y + h / 2 - v / 2
    
    if settings.background then

        draw.RoundedBox( 0, x, y, u, v, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, u, v )

    preview_hudtimer:Think()
    preview_hudtimer:PaintBackground( x, y )
    preview_hudtimer:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudtimer:ApplySettings( settings, self.preview_fonts )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then
        
        panel:SetVisible( false )
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

    hudtimer:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudtimer:InvalidateLayout()

end

HOLOHUD2.element.Register( "timer", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudtimer    = hudtimer
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "timer", "animation" )
HOLOHUD2.modifier.Add( "background", "timer", "background" )
HOLOHUD2.modifier.Add( "background_color", "timer", "background_color" )
HOLOHUD2.modifier.Add( "color", "timer", "color" )
HOLOHUD2.modifier.Add( "color2", "timer", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "timer", { "minutes_rendermode", "seconds_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "timer", { "minutes_background", "seconds_background" } )
HOLOHUD2.modifier.Add( "number3_font", "timer", { "minutes_font", "seconds_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "timer", { "minutes_offset", "seconds_offset" } )
HOLOHUD2.modifier.Add( "text_font", "timer", "text_font" )
HOLOHUD2.modifier.Add( "text_offset", "timer", "text_pos" )

---
--- Presets
---
HOLOHUD2.presets.Register( "timer", "element/timer" )