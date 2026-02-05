HOLOHUD2.AddCSLuaFile( "suitpower/hudsuitpower.lua" )

if SERVER then return end

local LocalPlayer = LocalPlayer
local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.suitpower",
    helptext    = "#holohud2.suitpower.helptext",
    hide        = "CHudSuitPower",
    parameters  = {
        autohide                = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 56 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 32 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 186, 92 ) }, fraction = true, gradual = false } },
        color2                  = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        icon                    = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 7, y = 5 } },
        icon_size               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 10 },
        icon_background         = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        number                  = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = false },
        number_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 24, y = 3 } },
        number_font             = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 15, weight = 1000, italic = false } },
        number_rendermode       = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background       = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align            = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        graph                   = { name = "#holohud2.component.graph", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.suitpower.graph.helptext" },
        graph_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 22, y = 5 } },
        graph_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 85, y = 10 } },
        graph_inverted          = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = false },
        graph_guide             = { name = "#holohud2.parameter.guide", type = HOLOHUD2.PARAM_BOOL, value = true },

        powerbar                = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        powerbar_pos            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 5, y = 18 } },
        powerbar_size           = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 105, y = 5 }, min_x = 1, min_y = 1 },
        powerbar_style          = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        powerbar_growdirection  = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        powerbar_background     = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        powerbar_guide          = { name = "#holohud2.parameter.guide", type = HOLOHUD2.PARAM_BOOL, value = true },
        powerbar_guide_inverted = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = true },

        icontray                = { name = "#holohud2.suitpower.icon_tray", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.suitpower.icon_tray_helptext" },
        icontray_pos            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 104, y = 10 } },
        icontray_margin         = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0 },
        icontray_direction      = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT },

        sprint                  = { name = "#holohud2.suitpower.sprint_icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        sprint_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 96, y = 5 } },
        sprint_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 10, min = 0 },
        sprint_background       = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        oxygen                  = { name = "#holohud2.suitpower.oxygen_icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        oxygen_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 82, y = 5 } },
        oxygen_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 10, min = 0 },
        oxygen_background       = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        flashlight              = { name = "#holohud2.suitpower.flashlight_icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        flashlight_pos          = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 62, y = 9 } },
        flashlight_size         = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        flashlight_background   = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },

        text                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#Valve_Hud_AUX_POWER" },
        text_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "autohide" },

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
                { id = "icon_background" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_align" }
            } },
            { id = "graph", parameters = {
                { id = "graph_pos" },
                { id = "graph_size" },
                { id = "graph_inverted" },
                { id = "graph_guide" }
            } },
            { id = "powerbar", parameters = {
                { id = "powerbar_pos" },
                { id = "powerbar_size" },
                { id = "powerbar_style" },
                { id = "powerbar_growdirection" },
                { id = "powerbar_background" },
                { id = "powerbar_guide", parameters = {
                    { id = "powerbar_guide_inverted" }
                } }
            } },
            { id = "icontray", parameters = {
                { id = "icontray_pos" },
                { id = "icontray_margin" },
                { id = "icontray_direction" }
            } },
            { id = "sprint", parameters = {
                { id = "sprint_pos" },
                { id = "sprint_size" },
                { id = "sprint_background" }
            } },
            { id = "oxygen", parameters = {
                { id = "oxygen_pos" },
                { id = "oxygen_size" },
                { id = "oxygen_background" }
            } },
            { id = "flashlight", parameters = {
                { id = "flashlight_pos" },
                { id = "flashlight_size" },
                { id = "flashlight_background" }
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
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" }
            } },
            { id = "number", parameters = {
                { id = "number_pos" },
                { id = "number_font" }
            } },
            { id = "graph", parameters = {
                { id = "graph_pos" },
                { id = "graph_size" }
            } },
            { id = "powerbar", parameters = {
                { id = "powerbar_pos" },
                { id = "powerbar_size" },
                { id = "powerbar_guide" }
            } },
            { id = "icontray", parameters = {
                { id = "icontray_pos" },
                { id = "icontray_direction" }
            } },
            { id = "sprint", parameters = {
                { id = "sprint_pos" },
                { id = "sprint_size" }
            } },
            { id = "oxygen", parameters = {
                { id = "oxygen_pos" },
                { id = "oxygen_size" }
            } },
            { id = "flashlight", parameters = {
                { id = "flashlight_pos" },
                { id = "flashlight_size" }
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
local hudsuitpower  = HOLOHUD2.component.Create( "HudSuitPower" )
local layout        = HOLOHUD2.layout.Register( "suitpower" )
local panel         = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawSuitPower", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawSuitPower", x, y, LAYER_BACKGROUND ) then return end

    hudsuitpower:PaintBackground( x, y )

    hook_Call( "DrawOverSuitPower", x, y, LAYER_BACKGROUND, hudsuitpower )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawSuitPower", x, y, LAYER_FOREGROUND ) then return end

    hudsuitpower:Paint( x, y )

    hook_Call( "DrawOverSuitPower", x, y, LAYER_FOREGROUND, hudsuitpower )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawSuitPower", x, y, LAYER_SCANLINES ) then return end

    hudsuitpower:PaintScanlines( x, y )

    hook_Call( "DrawOverSuitPower", x, y, LAYER_SCANLINES, hudsuitpower )

end

---
--- Startup
---
local localplayer -- reference set in PreDraw

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
    hudsuitpower:SetValue( -1 )

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

    return "#holohud2.suitpower.startup"

end

function ELEMENT:DoStartupSequence( settings, curtime )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_FILL then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    if startup_phase == STARTUP_EMPTY then

        hudsuitpower:SetValue( 0 )

    elseif startup_phase == STARTUP_FILL then

        local suitpower = math.max( hook_Call( "GetSuitPower" ) or localplayer:GetSuitPower(), 0 )
        local time = ( next_startup_phase - curtime ) / STARTUP_TIMINGS[ startup_phase ]
        local anim = ( 1 - time ) * 3

        hudsuitpower:SetValue( math.min( math.ceil( anim * suitpower ), suitpower ) )
        hudsuitpower:SetSprinting( time > .3 and time <= .5 )
        hudsuitpower:SetUnderwater( time > .5 and time <= .7 )
        hudsuitpower:SetFlashlightOn( time > .7 and time <= .9 )

    end

    hudsuitpower:Think()
    panel:Think()
    panel:SetDeployed( true )
    layout:SetVisible( panel:IsVisible() )

    return true

end

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    localplayer = localplayer or LocalPlayer()

    if self:DoStartupSequence( settings ) then return end

    local suitpower = math.max( hook_Call( "GetSuitPower" ) or localplayer:GetSuitPower(), 0 )
    hudsuitpower:SetValue( math.Round( suitpower ) )
    hudsuitpower:SetSprinting( localplayer:IsSprinting() )
    hudsuitpower:SetUnderwater( localplayer:WaterLevel() >= 3 )
    hudsuitpower:SetFlashlightOn( localplayer:FlashlightIsOn() )
    hudsuitpower:SetDrawFlashlight( hook_Call( "ShouldHideSuitFlashlight" ) ~= true )

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or not settings.autohide or suitpower < 100 ) )

    layout:SetVisible( panel:IsVisible() )

    if panel:IsVisible() then

        hudsuitpower:Think()

    end

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
local preview_hudsuitpower = HOLOHUD2.component.Create( "HudSuitPower" )
preview_hudsuitpower:SetValue( 100 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudsuitpower:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewInit( panel )

    local control = vgui.Create( "Panel", panel )
    control:SetSize( 172, 78 )
    control:SetPos( 4, panel:GetTall() - control:GetTall() - 4 )

        local sprint = vgui.Create( "DCheckBoxLabel", control )
        sprint:Dock( TOP )
        sprint:DockMargin( 2, 0, 0, 2 )
        sprint:SetText( "Sprinting" )
        sprint:SetValue( preview_hudsuitpower.sprinting )
        sprint.OnChange = function( _, value )

            preview_hudsuitpower:SetSprinting( value )

        end

        local oxygen = vgui.Create( "DCheckBoxLabel", control )
        oxygen:Dock( TOP )
        oxygen:DockMargin( 2, 0, 0, 2 )
        oxygen:SetText( "Underwater" )
        oxygen:SetValue( preview_hudsuitpower.underwater )
        oxygen.OnChange = function( _, value )

            preview_hudsuitpower:SetUnderwater( value )

        end

        local flashlight = vgui.Create( "DCheckBoxLabel", control )
        flashlight:Dock( TOP )
        flashlight:DockMargin( 2, 0, 0, 2 )
        flashlight:SetText( "Flashlight" )
        flashlight:SetValue( preview_hudsuitpower.flashlight )
        flashlight.OnChange = function( _, value )

            preview_hudsuitpower:SetFlashlightOn( value )

        end

        local power = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", control )
        power:Dock( TOP )
        power:DockMargin( 0, 4, 0, 0 )
        power:SetIcon( "icon16/lightning.png" )
        power:SetValue( preview_hudsuitpower.value )
        power.OnValueChanged = function( _, value )

            preview_hudsuitpower:SetValue( value )

        end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( control:GetWide() + 4, panel:GetTall() - reset:GetTall() - 8 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        sprint:SetValue( false )
        oxygen:SetValue( false )
        flashlight:SetValue( false )
        power:SetValue( 100 )

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

    preview_hudsuitpower:Think()
    preview_hudsuitpower:PaintBackground( x, y )
    preview_hudsuitpower:Paint( x, y )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        panel:SetVisible( false )
        return

    end

    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )
    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetPos( layout.x, layout.y )

    hudsuitpower:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudsuitpower:InvalidateLayout()
    hudsuitpower:InvalidateComponents()

end

HOLOHUD2.element.Register( "suitpower", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudsuitpower    = hudsuitpower
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "suitpower", "animation" )
HOLOHUD2.modifier.Add( "background", "suitpower", "background" )
HOLOHUD2.modifier.Add( "background_color", "suitpower", "background_color" )
HOLOHUD2.modifier.Add( "color2", "suitpower", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "suitpower", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "suitpower", "number_background" )
HOLOHUD2.modifier.Add( "number3_font", "suitpower", "number_font" )
HOLOHUD2.modifier.Add( "number3_offset", "suitpower", "number_pos" )
HOLOHUD2.modifier.Add( "text_font", "suitpower", "text_font" )
HOLOHUD2.modifier.Add( "text_offset", "suitpower", "text_pos" )
HOLOHUD2.modifier.Add( "scale", "suitpower", {
    "pos", "margin", "size",
    "icon_pos", "icon_size",
    "number_pos", "number_font",
    "graph_pos", "graph_size",
    "powerbar_pos", "powerbar_size",
    "icontray_pos", "icontray_margin",
    "sprint_pos", "sprint_size",
    "oxygen_pos", "oxygen_size",
    "flashlight_pos", "flashlight_size",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "suitpower", "element/suitpower" )
