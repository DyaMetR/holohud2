
HOLOHUD2.AddCSLuaFile( "speedometer/hudspeedometer.lua" )

if SERVER then return end

local worldsize = CreateClientConVar( "holohud2_speedometer_worldsize", 0, true, false, "Calculates the speed relative to world size instead of player size.", 0, 1 )

local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.speedometer",
    helptext    = "#holohud2.speedometer.helptext",
    parameters  = {
        unit                        = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.common.hus", "#holohud2.common.kmh", "#holohud2.common.mph" }, value = HOLOHUD2.DISTANCE_METRIC },
        onfoot                      = { name = "#holohud2.speedometer.on_foot", type = HOLOHUD2.PARAM_BOOL, value = false },
        onfoot_maxspeed             = { name = "#holohud2.speedometer.max_speed", type = HOLOHUD2.PARAM_NUMBER, value = 440, min = 0, helptext = "#holohud2.speedometer.max_speed.helptext" },

        invehicle                   = { name = "#holohud2.speedometer.in_vehicle", type = HOLOHUD2.PARAM_BOOL, value = true },
        nopod                       = { name = "#holohud2.speedometer.no_pod", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.speedometer.no_pod.helptext" },
        invehicle_maxspeed          = { name = "#holohud2.speedometer.max_speed", type = HOLOHUD2.PARAM_NUMBER, value = 2200, min = 0, helptext = "#holohud2.speedometer.max_speed.helptext" },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 144, y = 48 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 220, 220, 220 ) },
        color2                      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        num                         = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        num_pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 91, y = 0 } },
        num_font                    = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 37, weight = 1000, italic = false } },
        num_rendermode              = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        num_background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        num_align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        num_digits                  = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        label                       = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_BOOL, value = true },
        label_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 93, y = 32 } },
        label_font                  = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 11, weight = 1000, italic = false } },
        label_align                 = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        label_on_background         = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        revcounter                  = { name = "#holohud2.speedometer.rpm_counter", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.speedometer.rpm_counter.helptext" },
        revcounter_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 6, y = 13 } },
        revcounter_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 80, y = 29 } },
        revcounter_segments         = { name = "#holohud2.speedometer.rpm_counter_segments", type = HOLOHUD2.PARAM_NUMBER, value = 8, min = 1 },
        revcounter_margin           = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        revcounter_color            = { name = "#holohud2.speedometer.rpm_counter", type = HOLOHUD2.PARAM_COLOR, value = Color( 220, 220, 220 ) },
        revcounter_color2           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLOR, value = Color( 220, 220, 220, 32 ) },

        revcounter_num              = { name = "#holohud2.speedometer.redline_numbers", type = HOLOHUD2.PARAM_BOOL, value = true },
        revcounter_num_short        = { name = "#holohud2.speedometer.redline_numbers_shortened", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.speedometer.redline_numbers_shortened.helptext" },
        revcounter_num_offset       = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 0 },
        revcounter_num_font         = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 8, weight = 1000, italic = true } },

        revcounter_redline          = { name = "#holohud2.speedometer.redline", type = HOLOHUD2.PARAM_RANGE, value = .2, min = 0, max = 1, decimals = 2 },
        revcounter_colormax         = { name = "#holohud2.speedometer.redline_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32 ) },
        revcounter_colormax2        = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32, 32 ) },

        revcounter_negative         = { name = "#holohud2.speedometer.negative_space", type = HOLOHUD2.PARAM_RANGE, value = .8, min = 0, max = 1, decimals = 2, helptext = "#holohud2.speedometer.negative_space.helptext" },
        revcounter_negative_size    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_RANGE, value = .4, min = 0, max = 1, decimals = 2 },

        damagebar                   = { name = "#holohud2.speedometer.health_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        damagebar_color             = { name = "#holohud2.speedometer.health_bar", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 162, 72 ), [100] = Color(72, 255, 72) }, fraction = true, gradual = true } },
        damagebar_color2            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = true } },
        damagebar_inverted          = { name = "#holohud2.speedometer.damage_bar", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.speedometer.damage_bar.helptext" },
        damagebar_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 7, y = 34 } },
        damagebar_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 48, y = 8 }, min_x = 1, min_y = 1 },
        damagebar_style             = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        damagebar_growdirection     = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        damagebar_background        = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        damagebar_smooth            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        gearcounter                 = { name = "#holohud2.speedometer.gear_counter", type = HOLOHUD2.PARAM_BOOL, value = true },
        gearcounter_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 56, y = 30 } },
        gearcounter_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false } },
        gearcounter_rendermode      = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        gearcounter_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },

        text                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.SPEED" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "unit" },
        { id = "onfoot", parameters = {
            { id = "onfoot_maxspeed" }
        } },
        { id = "invehicle", parameters = {
            { id = "nopod" },
            { id = "invehicle_maxspeed" }
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
            { id = "color", parameters = {
                { id = "color2" }
            } },
            { id = "revcounter_color", parameters = {
                { id = "revcounter_color2" }
            } },
            { id = "revcounter_colormax", parameters = {
                { id = "revcounter_colormax2" }
            } },
            { id = "damagebar_color", parameters = {
                { id = "damagebar_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" },
                { id = "num_rendermode" },
                { id = "num_background" },
                { id = "num_align" },
                { id = "num_digits" }
            } },
            { id = "label", parameters = {
                { id = "label_pos" },
                { id = "label_font" },
                { id = "label_align" },
                { id = "label_on_background" }
            } },
            { id = "revcounter", parameters = {
                { id = "revcounter_pos" },
                { id = "revcounter_size" },
                { id = "revcounter_segments" },
                { id = "revcounter_margin" },
                { id = "revcounter_num", parameters = {
                    { id = "revcounter_num_short" },
                    { id = "revcounter_num_offset" },
                    { id = "revcounter_num_font" }
                } },
                { id = "revcounter_redline" },
                { id = "revcounter_negative", parameters = {
                    { id = "revcounter_negative_size" }
                } }
            } },
            { id = "damagebar", parameters = {
                { id = "damagebar_inverted" },
                { id = "damagebar_pos" },
                { id = "damagebar_size" },
                { id = "damagebar_style" },
                { id = "damagebar_growdirection" },
                { id = "damagebar_background" },
                { id = "damagebar_smooth" }
            } },
            { id = "gearcounter", parameters = {
                { id = "gearcounter_pos" },
                { id = "gearcounter_font" },
                { id = "gearcounter_rendermode" },
                { id = "gearcounter_background" }
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
        { id = "unit" },
        { id = "onfoot" },
        { id = "invehicle" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color", parameters = {
                { id = "color2" }
            } },
            { id = "revcounter_color", parameters = {
                { id = "revcounter_color2" }
            } },
            { id = "revcounter_colormax", parameters = {
                { id = "revcounter_colormax2" }
            } },
            { id = "damagebar_color", parameters = {
                { id = "damagebar_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" }
            } },
            { id = "label", parameters = {
                { id = "label_pos" },
                { id = "label_font" }
            } },
            { id = "revcounter", parameters = {
                { id = "revcounter_pos" },
                { id = "revcounter_size" },
                { id = "revcounter_segments" },
                { id = "revcounter_num", parameters = {
                    { id = "revcounter_num_offset" },
                    { id = "revcounter_num_font" }
                } },
                { id = "revcounter_redline" }
            } },
            { id = "damagebar", parameters = {
                { id = "damagebar_inverted" },
                { id = "damagebar_pos" },
                { id = "damagebar_size" }
            } },
            { id = "gearcounter", parameters = {
                { id = "gearcounter_pos" },
                { id = "gearcounter_font" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } }
    }
}

local POD_BLACKLIST = {
    [ "prop_vehicle_prisoner_pod" ] = true,
    [ "prop_vehicle_choreo_generic" ] = true
}

local POD_PARENT_BLACKLIST = {
    [ "func_tracktrain" ] = true
}

---
--- Components
---
local hudspeedometer    = HOLOHUD2.component.Create( "HudSpeedometer" )
local layout            = HOLOHUD2.layout.Register( "speedometer" )
local panel             = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawSpeedometer", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawSpeedometer", x, y, LAYER_BACKGROUND ) then return end

    hudspeedometer:PaintBackground( x, y )

    hook_Call( "DrawOverSpeedometer", x, y, LAYER_BACKGROUND, hudspeedometer )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawSpeedometer", x, y, LAYER_FOREGROUND ) then return end

    hudspeedometer:Paint( x, y )

    hook_Call( "DrawOverSpeedometer", x, y, LAYER_FOREGROUND, hudspeedometer )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawSpeedometer", x, y, LAYER_SCANLINES ) then return end

    hudspeedometer:PaintScanlines( x, y )

    hook_Call( "DrawOverSpeedometer", x, y, LAYER_SCANLINES, hudspeedometer )

end

---
--- Startup
---
local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_EMPTY     = 2
local STARTUP_FILL      = 3
local STARTUP_ENDING    = 4

local STARTUP_TIMINGS   = { 1, 1, 1.5, .5 }

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    panel:Close()
    hudspeedometer:SetDrawUnitOnBackground( true )
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

    return "#holohud2.speedometer.startup"

end

function ELEMENT:DoStartupSequence( settings )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()

    if startup_phase == STARTUP_FILL then

        local max_speed = 2048
        local time = math.max( next_startup_phase - curtime, 0 ) / STARTUP_TIMINGS[ startup_phase ]
        local anim = 1 - math.abs( ( time - .5 ) / .5 )
        hudspeedometer:SetRPMValue( anim )
        hudspeedometer:SetSpeed( max_speed * anim )
        hudspeedometer:SetDrawUnitOnBackground( settings.unit_on_background )

    end

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_ENDING then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    hudspeedometer:Think()

    panel:Think()
    panel:SetDeployed( true )

    layout:SetVisible( panel:IsVisible() )

    return true

end

---
--- Logic
---
local localplayer
function ELEMENT:PreDraw( settings )

    if self:DoStartupSequence( settings ) then return end

    localplayer = localplayer or LocalPlayer()

    if self:IsMinimized() then

        panel:SetDeployed( false )

    elseif self:IsInspecting() then

        panel:SetDeployed( true )

    else

        if localplayer:InVehicle() then

            local vehicle = localplayer:GetVehicle()

            if POD_BLACKLIST[ vehicle:GetClass() ] and ( not IsValid( vehicle:GetMoveParent() ) or POD_PARENT_BLACKLIST[ vehicle:GetMoveParent():GetClass() ] ) then

                panel:SetDeployed( settings.invehicle and not settings.nopod )

            else

                panel:SetDeployed( settings.invehicle )

            end

        else

            panel:SetDeployed( settings.onfoot )

        end

    end

    panel:Think()

    layout:SetVisible( panel:IsVisible() )

    if not panel:IsDeployed() then return end

    -- fetch for speed and calculate rpm values
    if localplayer:InVehicle() then

        local vehicle = localplayer:GetVehicle()

        -- is it a Lua vehicle
        if IsValid( vehicle:GetMoveParent() ) then

            vehicle = vehicle:GetMoveParent()

        end

        local speed = vehicle:GetVelocity():Length()

        if worldsize:GetBool() then

            speed = speed * .75

        end

        hudspeedometer:SetSpeed( speed )

        -- get vehicle damage
        hudspeedometer:SetDamage( hook_Call( "GetVehicleHealth", vehicle ) or 0 )

        -- get RPM values
        local rpm, max_rpm = hook_Call( "GetVehicleRPM", vehicle )

        if rpm and max_rpm then

            local segments = math.Round( max_rpm / 1000 )

            hudspeedometer:SetRPMValue( rpm / max_rpm )
            hudspeedometer:SetMaxRPM( segments )
            hudspeedometer:SetSegments( segments )

        else

            hudspeedometer:SetRPMValue( speed / settings.invehicle_maxspeed )
            hudspeedometer:SetMaxRPM( math.floor( settings.invehicle_maxspeed / ( settings.revcounter_num_short and 10 or 1 ) ), true )
            hudspeedometer:SetSegments( settings.revcounter_segments )

        end

        hudspeedometer:SetGear( hook_Call( "GetVehicleGear", vehicle ) or -2 )

    else

        local speed = math.Round( localplayer:GetVelocity():Length() )
        hudspeedometer:SetSpeed( speed )
        hudspeedometer:SetRPMValue( speed / settings.onfoot_maxspeed )
        hudspeedometer:SetMaxRPM( math.floor( settings.onfoot_maxspeed / ( settings.revcounter_num_short and 10 or 1 ) ), true )
        hudspeedometer:SetSegments( settings.revcounter_segments )
        hudspeedometer:SetDamage( 0 )
        hudspeedometer:SetGear( -2 )

    end

    hudspeedometer:Think()

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
local preview_hudspeedometer = HOLOHUD2.component.Create( "HudSpeedometer" )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()

    w, h = settings.size.x * scale, settings.size.y * scale
    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudspeedometer:Think()
    preview_hudspeedometer:PaintBackground( x, y )
    preview_hudspeedometer:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudspeedometer:ApplySettings( settings, self.preview_fonts )
    preview_hudspeedometer:SetSpeed( math.min( preview_hudspeedometer.value, 999 / preview_hudspeedometer._conversion ) )

end

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 140, 76 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() - 4 )

    local gear = vgui.Create( "Panel", controls )
    gear:Dock( TOP )

        local label = vgui.Create( "DLabel", gear )
        label:SetText( "#holohud2.speedometer.preview.gear" )

        local gear_value = vgui.Create( "DNumberWang", gear )
        gear_value:SetX( 64 )
        gear_value:SetMinMax( -1, 6 )
        gear_value:SetValue( preview_hudspeedometer.gear )
        gear_value.OnValueChanged = function( _, value )

            preview_hudspeedometer:SetGear( value )

        end

    local rpm = vgui.Create( "DNumSlider", controls )
    rpm:Dock( TOP )
    rpm:SetText( "RPM" )
    rpm:SetMinMax( 0, 1 )
    rpm:SetValue( preview_hudspeedometer.RevCounter.value )
    rpm.TextArea:Hide()
    rpm.OnValueChanged = function( _, value )

        preview_hudspeedometer:SetRPMValue( value )

    end

    local speed = vgui.Create( "Panel", controls )
    speed:Dock( TOP )

        local label = vgui.Create( "DLabel", speed )
        label:SetText( "#holohud2.speedometer.preview.speed" )

        local value = vgui.Create( "DNumberWang", speed )
        value:SetX( 64 )
        value:SetMinMax( 0, 999 )
        value:SetValue( preview_hudspeedometer.value )
        value.OnValueChanged = function( _, value )

            preview_hudspeedometer:SetSpeed( value / preview_hudspeedometer._conversion )

        end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( 136, panel:GetTall() - reset:GetTall() - 5 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        rpm:SetValue( 0 )
        value:SetValue( 0 )
        gear_value:SetValue( 0 )

    end

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

    hudspeedometer:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudspeedometer:InvalidateLayout()

end

HOLOHUD2.element.Register( "speedometer", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudspeedometer  = hudspeedometer
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "speedometer", "animation" )
HOLOHUD2.modifier.Add( "background", "speedometer", "background" )
HOLOHUD2.modifier.Add( "background_color", "speedometer", "background_color" )
HOLOHUD2.modifier.Add( "color", "speedometer", { "color", "revcounter_color" } )
HOLOHUD2.modifier.Add( "color2", "speedometer", { "color2", "revcounter_color2", "damagebar_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "speedometer", { "num_rendermode", "gearcounter_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "speedometer", { "num_background", "gearcounter_background" } )
HOLOHUD2.modifier.Add( "number3_font", "speedometer", { "num_font", "gearcounter_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "speedometer", { "num_pos", "gearcounter_pos" } )
HOLOHUD2.modifier.Add( "text_font", "speedometer", { "label_font", "text_font" } )
HOLOHUD2.modifier.Add( "scale", "speedometer", {
    "pos", "margin", "size",
    "num_pos", "num_font",
    "label_pos", "label_font",
    "revcounter_pos", "revcounter_size", "revcounter_margin",
    "revcounter_num_offset", "revcounter_num_font",
    "damagebar_pos", "damagebar_size",
    "gearcounter_pos", "gearcounter_font",
    "text_pos", "text_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "speedometer", "element/speedometer" )
