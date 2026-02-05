
local hook_Call = HOLOHUD2.hook.Call

local ELEMENT = {
    name        = "#holohud2.money",
    helptext    = "#holohud2.money.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 128 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 92, y = 22 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 96, 255, 72 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        currency                    = { name = "#holohud2.money.currency", type = HOLOHUD2.PARAM_BOOL, value = true },
        currency_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        currency_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 1000, italic = false } },
        currency_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "$" },
        currency_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        currency_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        number                      = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        number_pos                  = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 16, y = 2 } },
        number_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 18, weight = 1000, italic = false } },
        number_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, min = 1, value = 8 },
        number_lerp                 = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.MONEY" },
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
            { id = "currency", parameters = {
                { id = "currency_pos" },
                { id = "currency_font" },
                { id = "currency_text" },
                { id = "currency_align" },
                { id = "currency_on_background" }
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
            { id = "currency", parameters = {
                { id = "currency_pos" },
                { id = "currency_font" }
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
local hudmoney = HOLOHUD2.component.Create( "HudExtensionMoney" )
local layout = HOLOHUD2.layout.Register( "money" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawMoney", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( _, x, y )

    if hook_Call( "DrawMoney", x, y, LAYER_BACKGROUND ) then return end

    hudmoney:PaintBackground( x, y )

    hook_Call( "DrawOverMoney", x, y, LAYER_BACKGROUND, hudmoney )

end

panel.PaintOver = function( _, x, y )

    if hook_Call( "DrawMoney", x, y, LAYER_FOREGROUND ) then return end

    hudmoney:Paint( x, y )

    hook_Call( "DrawOverMoney", x, y, LAYER_FOREGROUND, hudmoney )

end

panel.PaintOverScanlines = function( _, x, y )

    if hook_Call( "DrawMoney", x, y, LAYER_SCANLINES ) then return end

    hudmoney:PaintScanlines( x, y )

    hook_Call( "DrawOverMoney", x, y, LAYER_SCANLINES, hudmoney )

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
    panel:SetDeployed( not self:IsMinimized() and hook_Call( "ShouldDrawMoney" ) == true )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudmoney:SetValue( hook_Call( "GetMoney" ) or 0 )
    hudmoney:Think()

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
local preview_hudmoney = HOLOHUD2.component.Create( "HudExtensionMoney" )
preview_hudmoney:SetValue( 500 )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()
    local u, v = settings.size.x * scale, settings.size.y * scale
    local x, y = x + w / 2 - u / 2, y + h / 2 - v / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, u, v, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, u, v )

    preview_hudmoney:Think()
    preview_hudmoney:PaintBackground( x, y )
    preview_hudmoney:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudmoney:ApplySettings( settings, self.preview_fonts )

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

    hudmoney:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudmoney:InvalidateLayout()

end

HOLOHUD2.element.Register( "money", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudmoney    = hudmoney
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "money", "animation" )
HOLOHUD2.modifier.Add( "background", "money", "background" )
HOLOHUD2.modifier.Add( "background_color", "money", "background_color" )
HOLOHUD2.modifier.Add( "color2", "money", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "money", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "money", "number_background" )
HOLOHUD2.modifier.Add( "number2_font", "money", { "currency_font", "number_font" } )
HOLOHUD2.modifier.Add( "number2_offset", "money", { "currency_pos", "number_pos" } )
HOLOHUD2.modifier.Add( "text_font", "money", "text_font" )
HOLOHUD2.modifier.Add( "text_offset", "money", "text_pos" )
HOLOHUD2.modifier.Add( "scale", "money", {
    "pos", "margin", "size",
    "currency_pos", "currency_font",
    "number_pos", "number_font",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "money", "element/money" )
