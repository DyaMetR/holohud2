
if SERVER then return end

local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.stims",
    helptext    = "#holohud2.stims.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 48 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 44, y = 22 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        icon                        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 5, y = 5 } },
        icon_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 13 },

        number                      = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        number_pos                  = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 22, y = 2 } },
        number_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 18, weight = 1000, italic = false } },
        number_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, min = 1, value = 2 },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.STIMS" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
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
                { id = "icon_size" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_align" },
                { id = "number_digits" }
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
local layout = HOLOHUD2.layout.Register( "stims" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

local hudstims = HOLOHUD2.component.Create( "HudExtensionStims" )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawStims", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( _, x, y )

    if hook_Call( "DrawStims", x, y, LAYER_BACKGROUND ) then return end

    hudstims:PaintBackground( x, y )

    hook_Call( "DrawOverStims", x, y, LAYER_BACKGROUND, hudstims )

end

panel.PaintOver = function( _, x, y )

    if hook_Call( "DrawStims", x, y, LAYER_FOREGROUND ) then return end

    hudstims:Paint( x, y )

    hook_Call( "DrawOverStims", x, y, LAYER_FOREGROUND, hudstims )

end

panel.PaintOverScanlines = function( _, x, y )

    if hook_Call( "DrawStims", x, y, LAYER_SCANLINES ) then return end

    hudstims:PaintScanlines( x, y )

    hook_Call( "DrawOverStims", x, y, LAYER_SCANLINES, hudstims )

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
    panel:SetDeployed( not self:IsMinimized() and hook_Call( "ShouldDrawStims" ) == true )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudstims:SetValue( hook_Call( "GetStims" ) or 0 )
    hudstims:Think()

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
local preview_hudstims = HOLOHUD2.component.Create( "HudExtensionStims" )
preview_hudstims:SetValue( 2 )

function ELEMENT:PreviewInit( panel )

    local stims = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    stims:SetSize( 172, 24 )
    stims:SetPos( 4, panel:GetTall() - stims:GetTall() - 4 )
    stims:SetIcon( "icon16/pill.png" )
    stims.Slider:SetMax( 99 )
    stims:SetValue( preview_hudstims.value )
    stims.OnValueChanged = function( _, value )

        preview_hudstims:SetValue( value )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( stims:GetWide() + 4, panel:GetTall() - reset:GetTall() - 8 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        stims:SetValue( 2 )

    end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()
    local u, v = settings.size.x * scale, settings.size.y * scale
    local x, y = x + w / 2 - u / 2, y + h / 2 - v / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, u, v, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, u, v )

    preview_hudstims:Think()
    preview_hudstims:PaintBackground( x, y )
    preview_hudstims:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudstims:ApplySettings( settings, self.preview_fonts )

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

    hudstims:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudstims:InvalidateLayout()

end

HOLOHUD2.element.Register( "stims", ELEMENT )

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "stims", "animation" )
HOLOHUD2.modifier.Add( "background", "stims", "background" )
HOLOHUD2.modifier.Add( "background_color", "stims", "background_color" )
HOLOHUD2.modifier.Add( "number3_font", "stims", "number_font" )
HOLOHUD2.modifier.Add( "number3_pos", "stims", "number_offset" )
HOLOHUD2.modifier.Add( "color2", "stims", "color2" )
HOLOHUD2.modifier.Add( "scale", "stims", {
    "pos", "margin", "size",
    "icon_pos", "icon_size",
    "number_pos", "number_font",
    "text_pos", "text_font"
} )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudstims    = hudstims
}

---
--- Presets
---
HOLOHUD2.presets.Register( "stims", "element/stims" )
