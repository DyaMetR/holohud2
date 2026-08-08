---
--- Warzone Armor System
--- https://steamcommunity.com/sharedfiles/filedetails/?id=3422752213
---

if SERVER then return end

local hooks = hook.GetTable().OnScreenSizeChanged

if not hooks or not hooks.wz_armorcounter then return end

---
--- Component
---
local BaseClass = HOLOHUD2.component.Get( "HudExtensionCounter" )

local COMPONENT = {}

function COMPONENT:Init()

    BaseClass.Init( self )

    self.Icon:SetTexture( surface.GetTextureID( "holohud2/suit/shield" ), 64, 64 )

end

function COMPONENT:ApplySettings( settings, fonts )

    local icon = self.Icon
    icon:SetVisible( settings.icon )
    icon:SetPos( settings.icon_pos.x, settings.icon_pos.y )
    icon:SetSize( settings.icon_size )
    icon:SetColor( settings.color )

    local number = self.Number
    number:SetVisible( settings.number )
    number:SetPos( settings.number_pos.x, settings.number_pos.y )
    number:SetFont( fonts.number_font )
    number:SetRenderMode( settings.number_rendermode )
    number:SetBackground( settings.number_background )
    number:SetAlign( settings.number_align )
    number:SetDigits( settings.number_digits )
    number:SetColor( settings.color )
    number:SetColor2( settings.color2 )

    local text = self.Text
    text:SetVisible( settings.text )
    text:SetPos( settings.text_pos.x, settings.text_pos.y )
    text:SetFont( fonts.text_font )
    text:SetAlign( settings.text_align )
    text:SetColor( settings.color )
    self:SetDrawTextOnBackground( settings.text_on_background )

end

HOLOHUD2.component.Register( "WZ_HudArmorPlates", COMPONENT, "HudExtensionCounter" )

---
--- Element
---
local ELEMENT = {
    name        = "#holohud2.wz_armorplates",
    helptext    = "#holohud2.wz_armorplates.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 60 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 44, y = 22 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        icon                        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 5, y = 4 } },
        icon_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 14 },

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
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.WZ_ARMORPLATES" },
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
local layout = HOLOHUD2.layout.Register( "wz_armorplates" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

local hudarmorplates = HOLOHUD2.component.Create( "WZ_HudArmorPlates" )

panel.PaintOverBackground = function( _, x, y )

    hudarmorplates:PaintBackground( x, y )

end

panel.PaintOver = function( _, x, y )

    hudarmorplates:Paint( x, y )

end

panel.PaintOverScanlines = function( _, x, y )

    hudarmorplates:PaintScanlines( x, y )

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

    local plates = LocalPlayer():GetAmmoCount( "WZ_ARMORPLATE" )

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and plates > 0 )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudarmorplates:SetValue( plates )
    hudarmorplates:Think()

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
local preview_hudarmorplates = HOLOHUD2.component.Create( "WZ_HudArmorPlates" )
preview_hudarmorplates:SetValue( 2 )

function ELEMENT:PreviewInit( panel )

    local armorplates = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", panel )
    armorplates:SetSize( 172, 24 )
    armorplates:SetPos( 4, panel:GetTall() - armorplates:GetTall() - 4 )
    armorplates:SetIcon( "icon16/shield.png" )
    armorplates.Slider:SetMax( 99 )
    armorplates:SetValue( preview_hudarmorplates.value )
    armorplates.OnValueChanged = function( _, value )

        preview_hudarmorplates:SetValue( value )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( armorplates:GetWide() + 4, panel:GetTall() - reset:GetTall() - 8 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        armorplates:SetValue( 2 )

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

    preview_hudarmorplates:Think()
    preview_hudarmorplates:PaintBackground( x, y )
    preview_hudarmorplates:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudarmorplates:ApplySettings( settings, self.preview_fonts )

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

    hudarmorplates:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:PerformLayout( true )
    hudarmorplates:InvalidateLayout()

end

HOLOHUD2.element.Register( "mwz_armorplates", ELEMENT )

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "wz_armorplates", "animation" )
HOLOHUD2.modifier.Add( "background", "wz_armorplates", "background" )
HOLOHUD2.modifier.Add( "background_color", "wz_armorplates", "background_color" )
HOLOHUD2.modifier.Add( "number3_font", "wz_armorplates", "number_font" )
HOLOHUD2.modifier.Add( "number3_pos", "wz_armorplates", "number_offset" )
HOLOHUD2.modifier.Add( "color2", "wz_armorplates", "color2" )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudarmorplates  = hudarmorplates
}

---
--- Presets
---
HOLOHUD2.presets.Register( "wz_armorplates", "element/wz_armorplates" )
