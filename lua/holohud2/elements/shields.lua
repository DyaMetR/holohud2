
local CurTime = CurTime
local LocalPlayer = LocalPlayer
local hook_Call = HOLOHUD2.hook.Call

local ELEMENT = {
    name        = "#holohud2.shields",
    helptext    = "#holohud2.shields.helptext",
    parameters  = {
        autohide                = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay          = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        autohide_threshold      = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_RANGE, value = 99, min = 0, max = 100 },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 24 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 14 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 200, 72, 68 ), [100] = Color( 92, 163, 255 ) }, fraction = true, gradual = false } },
        color2                  = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 74, 74, 12 ), [ 100 ] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        num                     = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = false },
        num_pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        num_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 1000, italic = false } },
        num_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        num_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        num_lerp                = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        num_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        num_digits              = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        bar                     = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        bar_pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 13, y = 4 } },
        bar_size                = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 98, y = 6 }, min_x = 1, min_y = 1 },
        bar_style               = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        bar_growdirection       = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        bar_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        bar_lerp                = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        icon                    = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 3 } },
        icon_size               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 9 },
        icon_rendermode         = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ICONRENDERMODES, value = HOLOHUD2.ICONRENDERMODE_STATIC },
        icon_background         = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_lerp               = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                    = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.SHIELDS" },
        text_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "autohide", parameters = {
            { id = "autohide_threshold" },
            { id = "autohide_delay" }
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

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" },
                { id = "num_rendermode" },
                { id = "num_background" },
                { id = "num_lerp" },
                { id = "num_align" },
                { id = "num_digits" }
            } },

            { id = "bar", parameters = {
                { id = "bar_pos" },
                { id = "bar_size" },
                { id = "bar_style" },
                { id = "bar_growdirection" },
                { id = "bar_background" },
                { id = "bar_lerp" }
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
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" }
            } },

            { id = "bar", parameters = {
                { id = "bar_pos" },
                { id = "bar_size" }
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
local hudshields = HOLOHUD2.component.Create( "HudExtensionShields" )
local layout = HOLOHUD2.layout.Register( "shields" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverBackground = function( _, x, y )

    hudshields:PaintBackground( x, y )

end

panel.PaintOver = function( _, x, y )

    hudshields:Paint( x, y )

end

panel.PaintOverScanlines = function( _, x, y )

    hudshields:PaintScanlines( x, y )

end

---
--- Startup
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
local last_shields = 0
local time = 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    if not hook_Call( "ShouldDrawShields" ) then

        panel:SetDeployed( false )
        panel:Think()

        return

    end

    local localplayer = LocalPlayer()
    local curtime = CurTime()
    local shields, max_shields = hook_Call( "GetShields" ), hook_Call( "GetMaxShields" )

    if last_shields ~= shields then

        time = curtime + settings.autohide_delay
        last_shields = shields

    end

    panel:Think()
    panel:SetDeployed( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or not settings.autohide or ( shields / max_shields * 100 ) <= settings.autohide_threshold or time > curtime )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudshields:SetValue( shields )
    hudshields:SetMaxValue( max_shields )
    hudshields:Think()

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
local preview_hudshields = HOLOHUD2.component.Create( "HudExtensionShields" )

preview_hudshields:SetValue( 100 )
preview_hudshields:SetMaxValue( 100 )

function ELEMENT:PreviewInit( panel )

    local shields = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    shields:SetSize( 172, 24 )
    shields:SetPos( 4, panel:GetTall() - shields:GetTall() - 4 )
    shields:SetIcon( "icon16/shield.png" )
    shields:SetValue( preview_hudshields.value )
    shields.OnValueChanged = function( _, value )

        preview_hudshields:SetValue( value )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( shields:GetWide() + 4, panel:GetTall() - reset:GetTall() - 8 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        shields:SetValue( 100 )

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

    preview_hudshields:Think()
    preview_hudshields:PaintBackground( x, y )
    preview_hudshields:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudshields:ApplySettings( settings, self.preview_fonts )

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
    layout:SetDirection( settings.direction )
    layout:SetMargin( settings.margin )
    layout:SetOrder( settings.order )

    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )

    hudshields:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudshields:InvalidateLayout()

end

HOLOHUD2.element.Register( "shields", ELEMENT )

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "background", "shields", "background" )
HOLOHUD2.modifier.Add( "background_color", "shields", "background_color" )
HOLOHUD2.modifier.Add( "color2", "shields", "color2" )
HOLOHUD2.modifier.Add( "number2_offset", "shields", "num_pos" )
HOLOHUD2.modifier.Add( "number2_font", "shields", "num_font" )
HOLOHUD2.modifier.Add( "text_offset", "shields", "text_pos" )
HOLOHUD2.modifier.Add( "text_font", "shields", "text_font" )
HOLOHUD2.modifier.Add( "scale", "shields", {
    "pos", "margin", "size",
    "num_pos", "num_font",
    "bar_pos", "bar_size",
    "icon_pos", "icon_size",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "shields", "element/shields" )
HOLOHUD2.presets.Add( "shields", "Alternate - Halo", {
    dock                = 2,
    size                = { x = 197, y = 24 },
    animation_direction = 6,
    color2              = { colors = { [0] = Color( 255, 74, 74, 192 ), [ 100 ] = Color( 132, 203, 255, 12 ) }, fraction = true, gradual = false },
    bar_pos             = { x = 5, y = 5 },
    bar_size            = { x = 186, y = 14 },
    icon                = false
} )
