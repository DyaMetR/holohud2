
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local RESOURCE = { surface.GetTextureID("holohud2/auxpower/flashlight"), 64, 32, 0, 0, 64, 17 }

local ELEMENT = {
    name        = "#holohud2.flashlight",
    helptext    = "#holohud2.flashlight.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 80 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 68, y = 16 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [100] = Color( 255, 186, 92 ) }, fraction = true, gradual = false } },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        icon                        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 5, y = 5 } },
        icon_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 5 },
        icon_rendermode             = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ICONRENDERMODES, value = HOLOHUD2.ICONRENDERMODE_STATIC },
        icon_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_lerp                   = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        number                      = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = false },
        number_pos                  = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 18, y = 3 } },
        number_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 15, weight = 1000, italic = false } },
        number_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, min = 1, value = 3 },

        progressbar                 = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        progressbar_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 26, y = 5 } },
        progressbar_size            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 38, y = 6 }, min_x = 1, min_y = 1 },
        progressbar_style           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        progressbar_growdirection   = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        progressbar_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        progressbar_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#Valve_Hud_FLASHLIGHT" },
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
                { id = "icon_size" },
                { id = "icon_rendermode" },
                { id = "icon_background" },
                { id = "icon_lerp" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_align" },
                { id = "number_digits" }
            } },
            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" },
                { id = "progressbar_style" },
                { id = "progressbar_growdirection" },
                { id = "progressbar_background" },
                { id = "progressbar_lerp" }
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
            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" }
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
local layout = HOLOHUD2.layout.Register( "flashlight" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

local hudflashlight = HOLOHUD2.component.Create( "HudExtensionMeter" )
hudflashlight.Blur:SetEnabled( false )
hudflashlight.IconBackground:SetTexture( RESOURCE )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawFlashlight", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( _, x, y )

    if hook_Call( "DrawFlashlight", x, y, LAYER_BACKGROUND ) then return end

    hudflashlight:PaintBackground( x, y )

    hook_Call( "DrawOverFlashlight", x, y, LAYER_BACKGROUND, hudflashlight )

end

panel.PaintOver = function( _, x, y )

    if hook_Call( "DrawFlashlight", x, y, LAYER_FOREGROUND ) then return end

    hudflashlight:Paint( x, y )

    hook_Call( "DrawOverFlashlight", x, y, LAYER_FOREGROUND, hudflashlight )

end

panel.PaintOverScanlines = function( _, x, y )

    if hook_Call( "DrawFlashlight", x, y, LAYER_SCANLINES ) then return end

    hudflashlight:PaintScanlines( x, y )

    hook_Call( "DrawOverFlashlight", x, y, LAYER_SCANLINES, hudflashlight )

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
    panel:SetDeployed( not self:IsMinimized() and hook_Call( "ShouldDrawFlashlight" ) == true )
    layout:SetVisible( panel:IsVisible() )


    if not panel:IsVisible() then return end

    hudflashlight:SetMaxValue( hook_Call( "GetMaxFlashlight" ) or 100 )
    hudflashlight:SetValue( hook_Call( "GetFlashlight" ) or 0 )
    hudflashlight:Think()

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
local preview_hudflashlight = HOLOHUD2.component.Create( "HudExtensionMeter" )
preview_hudflashlight.IconBackground:SetTexture( RESOURCE )
preview_hudflashlight:SetMaxValue( 100 )
preview_hudflashlight:SetValue( 100 )

function ELEMENT:PreviewInit( panel )

    local flashlight = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    flashlight:SetSize( 172, 24 )
    flashlight:SetPos( 4, panel:GetTall() - flashlight:GetTall() - 4 )
    flashlight:SetIcon( "icon16/database_lightning.png" )
    flashlight:SetValue( preview_hudflashlight.value )
    flashlight.OnValueChanged = function( _, value )

        preview_hudflashlight:SetValue( value )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( flashlight:GetWide() + 4, panel:GetTall() - reset:GetTall() - 8 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        flashlight:SetValue( 100 )

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

    preview_hudflashlight:Think()
    preview_hudflashlight:PaintBackground( x, y )
    preview_hudflashlight:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudflashlight:ApplySettings( settings, self.preview_fonts )

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

    hudflashlight:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudflashlight:InvalidateLayout()

end

HOLOHUD2.element.Register( "flashlight", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudflashlight   = hudflashlight
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "flashlight", "animation" )
HOLOHUD2.modifier.Add( "background", "flashlight", "background" )
HOLOHUD2.modifier.Add( "background_color", "flashlight", "background_color" )
HOLOHUD2.modifier.Add( "color2", "flashlight", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "flashlight", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "flashlight", "number_background" )
HOLOHUD2.modifier.Add( "number3_font", "flashlight", "number_font" )
HOLOHUD2.modifier.Add( "number3_offset", "flashlight", "number_pos" )
HOLOHUD2.modifier.Add( "text_font", "flashlight", "text_font" )
HOLOHUD2.modifier.Add( "text_offset", "flashlight", "text_pos" )
HOLOHUD2.modifier.Add( "scale", "flashlight", {
    "pos", "margin", "size",
    "icon_pos", "icon_size",
    "number_pos", "number_font",
    "progressbar_pos", "progressbar_size",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "flashlight", "element/flashlight" )
