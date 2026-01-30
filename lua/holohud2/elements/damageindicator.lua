local EyePos = EyePos
local EyeAngles = EyeAngles
local ScrW = ScrW
local ScrH = ScrH
local CurTime = CurTime
local FrameTime = FrameTime
local LocalPlayer = LocalPlayer
local GetScreenSize = HOLOHUD2.layout.GetScreenSize
local Lerp = Lerp
local hook_Call = HOLOHUD2.hook.Call

local STYLE_ARROW   = 1
local STYLE_SIMPLE  = 2

local LOWHEALTH_NONE        = 1
local LOWHEALTH_SIMPLE      = 2
local LOWHEALTH_DMGTYPE     = 3

local vfx                   = true
local vfx_flickering        = true
local vfx_shaking           = true
local vfx_distortion        = true
local lowhealth_threshold   = 25
local color_vector          = Vector( 0, 0, 0 ) -- colour parameter in vector form

local ELEMENT = {
    name        = "#holohud2.damageindicator",
    helptext    = "#holohud2.damageindicator.helptext",
    hide        = { "CHudDamageIndicator",  "CHudPoisonDamageIndicator" },
    parameters  = {
        style                   = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.damageindicator.category.arrows", "#holohud2.damageindicator.category.simple" }, value = STYLE_ARROW },
        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 70, 60 ) },
        pain_alpha              = { name = "#holohud2.damageindicator.pain_alpha", type = HOLOHUD2.PARAM_RANGE, value = .5, min = 0, max = 1, decimals = 1 },
        vfx                     = { name = "#holohud2.damageindicator.vfx", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.damageindicator.vfx.helptext" },
        flickering              = { name = "#holohud2.damageindicator.flickering", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.damageindicator.flickering.helptext" },
        shaking                 = { name = "#holohud2.damageindicator.shaking", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.damageindicator.shaking.helptext" },
        distortion              = { name = "#holohud2.damageindicator.distortion", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.damageindicator.distortion.helptext" },
        lowhealth               = { name = "#holohud2.damageindicator.low_health", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.damageindicator.low_health_0", "#holohud2.damageindicator.low_health_1", "#holohud2.damageindicator.low_health_2" }, value = LOWHEALTH_DMGTYPE, helptext = "#holohud2.damageindicator.low_health.helptext" },
        lowhealth_threshold     = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_NUMBER, value = 25, min = 0 },
        lowhealth_flickering    = { name = "#holohud2.damageindicator.flickering", type = HOLOHUD2.PARAM_BOOL, value = true },
        lowhealth_distortion    = { name = "#holohud2.damageindicator.distortion", type = HOLOHUD2.PARAM_BOOL, value = true },
        arrow_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 100, min = 0 },
        arrow_offset            = { name = "#holohud2.damageindicator.offset", type = HOLOHUD2.PARAM_NUMBER, value = 194, min = 0, max = 300 },
        arrow_stack             = { name = "#holohud2.damageindicator.arrow_stack", type = HOLOHUD2.PARAM_BOOL, value = true },
        arrow_max               = { name = "#holohud2.damageindicator.arrow_max", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0 },
        simple_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 256, min = 0 },
        simple_centered         = { name = "#holohud2.damageindicator.centered", type = HOLOHUD2.PARAM_BOOL, value = true },
        simple_offset           = { name = "#holohud2.damageindicator.offset", type = HOLOHUD2.PARAM_NUMBER, value = 244, min = 0, max = 300 },
        simple_margin           = { name = "#holohud2.damageindicator.margin", type = HOLOHUD2.PARAM_NUMBER, value = 48 }
    },
    menu = {
        { id = "style" },
        { id = "color" },
        { id = "pain_alpha" },
        { id = "vfx", parameters = {
            { id = "flickering" },
            { id = "shaking" },
            { id = "distortion" },
            { id = "lowhealth", parameters = {
                { id = "lowhealth_threshold" },
                { id = "lowhealth_flickering" },
                { id = "lowhealth_distortion" }
            } }
        } },

        { category = "#holohud2.damageindicator.category.arrows", parameters = {
            { id = "arrow_size" },
            { id = "arrow_offset" },
            { id = "arrow_stack" },
            { id = "arrow_max" }
        } },

        { category = "#holohud2.damageindicator.category.simple", parameters = {
            { id = "simple_size" },
            { id = "simple_centered", parameters = {
                { id = "simple_offset" },
                { id = "simple_margin" }
            } }
        } }
    },
    quickmenu = {
        { id = "style" },
        { id = "color" },
        { id = "pain_alpha" },
        { id = "vfx", parameters = {
            { id = "lowhealth" }
        } }
    }
}

-- damage types that will trigger the pain overlay instead of the directional indicators
local SHAPELESS_DAMAGE  = {
    [ DMG_GENERIC ]     = true,
    [ DMG_CRUSH ]       = true,
    [ DMG_VEHICLE ]     = true,
    [ DMG_FALL ]        = true,
    [ DMG_DROWN ]       = true,
    [ DMG_PARALYZE ]    = true,
    [ DMG_NERVEGAS ]    = true,
    [ DMG_POISON ]      = true,
    [ 17 ]              = true, -- DMG_VEHICLE_CRUSH
    [ DMG_SLOWBURN ]    = true
}

local RESOURCE_PAIN             = surface.GetTextureID( "holohud2/damage/pain" )
local PAIN_FADE_TIME            = 1

local SIMPLE_FADE_TIME          = 1

local ARROW_MAX_TIME            = 9
local ARROW_MIN_TIME            = 2
local ARROW_FADE_TIME           = .3
local ARROW_DAMAGE_THRESHOLD    = 15

local DAMAGE_FLICKER_TIME       = 2
local DAMAGE_FLICKER_INTENSITY  = .7
local DAMAGE_FLICKER_RATE       = .03
local DAMAGE_DISTORTION_TIME    = 1
local DAMAGE_SHAKE_MIN_DMG      = 7
local DAMAGE_SHAKE_MIN_TIME     = .66
local DAMAGE_SHAKE_MAX_DMG      = 25
local DAMAGE_SHAKE_MAX_TIME     = 2.33
local DAMAGE_SHAKE_RATE         = .01

local LOWHEALTH_SIMPLE_FLICKER      = .6
local LOWHEALTH_SIMPLE_DISTORTION   = .2

local LOWHEALTH_DMGTYPE_FLICKER     = .6
local LOWHEALTH_DMGTYPE_DISTORTION  = .4

---
--- Accessibility options
---
local r_flickering  = CreateClientConVar( "holohud2_r_flickering", 1, true, false, "Enables the flickering effect.", 0, 1 )
local r_shaking     = CreateClientConVar( "holohud2_r_shaking", 1, true, false, "Enables the damage shaking effect.", 0, 1 )
local r_shaking_min = CreateClientConVar( "holohud2_r_shaking_min", 1, true, false, "Minimum shaking intensity.", 0 )
local r_shaking_add = CreateClientConVar( "holohud2_r_shaking_add", 3, true, false, "Maximum amount of added shaking intensity.", 0 )

---
--- Scanlined pain overlay texture
---
local RT_PAIN, MAT_PAIN

--- Generates the scanlined pain overlay.
local function generate_pain_overlay( w, h )

    render.PushRenderTarget( RT_PAIN )
    render.Clear( 0, 0, 0, 0, true )
    cam.Start2D()

    surface.SetTexture( RESOURCE_PAIN )
    surface.SetDrawColor( color_white )
    surface.DrawTexturedRect( 0, 0, w, h )

    HOLOHUD2.render.DrawScanlines()

    cam.End2D()
    render.PopRenderTarget()

end

--- Generates the render target to make the pain overlay.
local function generate_pain_texture( w, h )

    RT_PAIN     = GetRenderTarget( "holohud2/damageindicator/pain_" .. w .. "_" .. h, w, h )
    MAT_PAIN    = CreateMaterial( "holohud2/damageindicator/pain", "UnlitGeneric", {
        [ "$additive" ]     = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_PAIN:SetTexture( "$basetexture", RT_PAIN )

    generate_pain_overlay( w, h )

end

HOLOHUD2.hook.Add( "RefreshScreenTextures", "damageindicator", generate_pain_texture )
HOLOHUD2.hook.Add( "RefreshScanlinesTexture", "damageindicator", generate_pain_overlay )

---
--- Initialize directional damage indicators
---
local arrows = { -- tri-arrow instances
    instances   = {}, -- total amount of arrow component instances
    active      = {} -- active arrow components (not scheduled for removal)
}

local indicators = {} -- simple directional damage indicators
for i=0, 3 do

    local component = HOLOHUD2.component.Create( "DamageIndicator" )
    component:SetAngle( 90 * i )
    component:SetVisible( false )

    table.insert( indicators, component )

end

---
--- Damage effects
---
local pain          = 0 -- opacity of the pain overlay

local flickering    = 0 -- flickering intensity
local flicker       = 0 -- current flicker amount
local next_flicker  = 0 -- time before the flicker updates

local distortion    = 0 -- chromatic aberration distortion
local _distortion   = 0

local shaking       = 0 -- shaking intensity
local shake         = { x = 0, y = 0 } -- current shake amount
local next_shake    = 0 -- time before the shake updates

---
--- Low health effects
---
local lowhealth_flickering_cur   = 0
local lowhealth_flickering_max  = 0
local lowhealth_distortion_cur  = 0
local lowhealth_distortion_max  = 0

local localplayer
local last_health = 100
function ELEMENT:CalcLowHealthEffects( settings )

    if settings.lowhealth == LOWHEALTH_NONE then return 0, 0 end

    localplayer = localplayer or LocalPlayer()
    local health = localplayer:Health()

    local flickering, distortion = 0, 0
    local lowhealth = math.max( 1 - ( health / lowhealth_threshold ), 0 )

    -- select effects intensity
    if settings.lowhealth == LOWHEALTH_SIMPLE then

        flickering = lowhealth * LOWHEALTH_SIMPLE_FLICKER
        distortion = lowhealth * LOWHEALTH_SIMPLE_DISTORTION

    elseif settings.lowhealth == LOWHEALTH_DMGTYPE then

        flickering = settings.lowhealth_flickering and lowhealth_flickering_cur or 0
        distortion = settings.lowhealth_distortion and lowhealth_distortion_cur or 0

    end

    -- reduce intensity of effects upon healing
    if health ~= last_health then

        if health > last_health then

            lowhealth_flickering_cur = math.min( lowhealth_flickering_max * lowhealth, LOWHEALTH_DMGTYPE_FLICKER )
            lowhealth_distortion_cur = math.min( lowhealth_distortion_max * lowhealth, LOWHEALTH_DMGTYPE_DISTORTION )

        end

        last_health = health

    end

    return flickering, distortion

end

---
--- Startup sequence
---
local startup_arrows = {}
for i=0, 3 do

    local component = HOLOHUD2.component.Create( "DamageArrow" )
    component:SetAngle( i * 90 )
    component._anim = 1 -- they're always deployed (never animated)
    table.insert( startup_arrows, component )

end

local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_SHOWCASE  = 2
local STARTUP_FADING    = 3

local STARTUP_TIMINGS   = { 1, 2, 1 }

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    -- reset indicators
    for i=1, 4 do

        startup_arrows[ i ]:SetVisible( false )
        indicators[ i ]:SetVisible( false )

    end

    -- remove any active arrows
    table.Empty( arrows.instances )
    table.Empty( arrows.active )

    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    startup_phase = STARTUP_STANDBY
    next_startup_phase = CurTime() + STARTUP_TIMINGS[ STARTUP_STANDBY ]

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:IsStartupOver()

    return startup_phase == STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.damageindicator.startup"

end

function ELEMENT:DoStartupSequence( settings )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_FADING then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            -- hide simple indicators since the sequence is over
            for _, indicator in ipairs( indicators ) do

                indicator:SetVisible( false )

            end

            startup_phase = STARTUP_NONE -- finish startup sequence
            return

        end

    end

    if startup_phase == STARTUP_STANDBY then return true end

    local time = math.Clamp( ( next_startup_phase - curtime ) / STARTUP_TIMINGS[ startup_phase ], 0, 1 )
    local alpha = startup_phase == STARTUP_FADING and time or 1

    -- animate indicators
    if settings.style == STYLE_ARROW then

        local intensity = startup_phase == STARTUP_SHOWCASE and math.Round( 3 * ( 1 - time ) ) or 3

        for _, arrow in ipairs( startup_arrows ) do

            arrow._alpha = alpha
            arrow:SetVisible( true )
            arrow:SetIntensity( intensity )
            arrow:Think()

        end

    else

        for _, indicator in ipairs( indicators ) do

            indicator._alpha = alpha
            indicator:SetVisible( true )
            indicator:Think()

        end

    end

    return true

end

---
--- Receive damage taken
---
local queue = {}
HOLOHUD2.hook.Add( "OnTakeDamage", "damageindicator", function( damage, dmgtype, origin )

    if not HOLOHUD2.IsVisible() or not ELEMENT:IsVisible() or startup_phase ~= STARTUP_NONE then return end

    -- high damage effect
    if damage >= 25 then

        pain = 1

    end

    -- minor violent impact damage effect
    if damage >= DAMAGE_SHAKE_MIN_DMG and bit.band( dmgtype, bit.bor( DMG_BULLET, DMG_SLASH, DMG_FALL, DMG_BLAST, DMG_CLUB, DMG_DISSOLVE, DMG_BUCKSHOT, DMG_SNIPER, DMG_MISSILEDEFENSE ) ) ~= 0 then

        shaking = math.min( math.max( DAMAGE_SHAKE_MIN_TIME + ( DAMAGE_SHAKE_MAX_TIME - DAMAGE_SHAKE_MIN_TIME ) * ( damage - DAMAGE_SHAKE_MIN_DMG ) / ( DAMAGE_SHAKE_MAX_DMG - DAMAGE_SHAKE_MIN_DMG ), shaking ), DAMAGE_SHAKE_MAX_TIME )

    end

    -- burn damage effect
    if bit.band( dmgtype, bit.bor( DMG_BURN, DMG_SLOWBURN ) ) ~= 0 then

        distortion = .5

    end

    -- explosion damage effect
    if bit.band( dmgtype, DMG_BLAST ) ~= 0 then

        distortion = 1.4

    end

    -- electric damage effect
    if bit.band( dmgtype, DMG_SHOCK ) ~= 0 then

        flickering = 1
        distortion = .5

    end

    -- radiation damage effect
    if bit.band( dmgtype, DMG_RADIATION ) ~= 0 then

        flickering = 1
        distortion = 1
        pain = 1

    end

    -- corrosive damage effect
    if bit.band( dmgtype, DMG_ACID ) ~= 0 then

        flickering = 1.2
        distortion = .2

    end

    -- laser damage effect
    if bit.band( dmgtype, DMG_ENERGYBEAM ) ~= 0 then

        flickering = .4
        distortion = .2

    end

    -- freeze damage effect
    if bit.band( dmgtype, DMG_PARALYZE ) ~= 0 then

        flickering = .8

    end

    -- calculate low health effects
    local lowhealth = 1 - ( LocalPlayer():Health() / lowhealth_threshold )

    if lowhealth > 0 then

        -- flickering
        local lowhealth_flickering = flickering * lowhealth

        if lowhealth_flickering > lowhealth_flickering_cur then

            lowhealth_flickering_cur = math.min( lowhealth_flickering, LOWHEALTH_DMGTYPE_FLICKER )
            lowhealth_flickering_max = flickering

        end

        -- distortion
        local lowhealth_distortion = distortion * lowhealth

        if lowhealth_distortion > lowhealth_distortion_cur then

            lowhealth_distortion_cur = math.min( lowhealth_distortion, LOWHEALTH_DMGTYPE_DISTORTION )
            lowhealth_distortion_max = distortion

        end

    end

    -- shapeless damage trigger the pain overlay only
    if SHAPELESS_DAMAGE[ dmgtype ] then

        pain = 1
        return

    end

    -- trigger directional damage indicator
    local pos, ang = EyePos(), EyeAngles()
    local yaw = WorldToLocal( origin, angle_zero, pos, ang ):Angle().y
    table.insert( queue, { yaw = ang.y, direction = yaw, damage = damage } )

end)

---
--- Apply damage effects to post processing
---
HOLOHUD2.hook.Add( "CalcPostProcessing", "damageindicator", function( pp )

    if not ELEMENT:IsVisible() or not vfx then return end

    if vfx_distortion and distortion > 0 then

        pp.aberration_dist = pp.aberration_dist * ( 1 + ( _distortion * 4 ) )

    end

    if not r_flickering:GetBool() or not vfx_flickering or flickering <= 0 then return end

    pp.alpha = pp.alpha * flicker

end)

---
--- Apply damage effects to offset
---
HOLOHUD2.hook.Add( "CalcOffset", "damageindicator", function( offset )

    if not r_shaking:GetBool() or not vfx_shaking then return end

    offset.x = offset.x + shake.x
    offset.y = offset.y + shake.y

end)

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    if self:DoStartupSequence( settings ) then return end

    local curtime = CurTime()
    local frametime = FrameTime()

    -- fade out pain overlay
    pain = math.max( pain - frametime / PAIN_FADE_TIME, 0 )

    -- do a controlled flickering effect to reduce eye strain
    if next_flicker < curtime then

        flicker = math.random( 1 - ( DAMAGE_FLICKER_INTENSITY * math.min( math.sqrt( flickering ), 1 ) ), 1 )
        next_flicker = curtime + DAMAGE_FLICKER_RATE

    end

    -- do a controlled shaking effect to reduce motion sickness
    if next_shake < curtime then

        local min_intensity = r_shaking_min:GetFloat()
        local add_intensity = r_shaking_add:GetFloat()
        local max_intensity = min_intensity + add_intensity

        local intensity = shaking * min_intensity / DAMAGE_SHAKE_MIN_TIME

        -- NOTE: I'm not smart enough to come up with a formula so here's an "if" :)
        if shaking > DAMAGE_SHAKE_MIN_TIME then

            intensity = min_intensity + ( math.max( shaking - DAMAGE_SHAKE_MIN_TIME, 0 ) / ( DAMAGE_SHAKE_MAX_TIME - DAMAGE_SHAKE_MIN_TIME ) ) * ( max_intensity - min_intensity )

        end

        shake.x = math.Rand( -1, 1 ) * intensity
        shake.y = math.Rand( -1, 1 ) * intensity
        next_shake = curtime + DAMAGE_SHAKE_RATE

    end

    -- damage effects
    local min_flickering, min_distortion = self:CalcLowHealthEffects( settings )
    flickering = math.max( flickering - frametime / DAMAGE_FLICKER_TIME, min_flickering )

    distortion = math.max( distortion - frametime / DAMAGE_DISTORTION_TIME, min_distortion )
    _distortion = Lerp( frametime * 24, _distortion, distortion ) -- smoothen distortion as much as possible

    shaking = math.max( shaking - frametime, 0 )

    -- animate damage indicators
    if settings.style == STYLE_ARROW then

        local scrw, scrh = GetScreenSize()

        -- add queued damage as arrows
        for _, queued in ipairs( queue ) do

            local component = HOLOHUD2.component.Create( "DamageArrow" )
            component:SetPos( scrw / 2, scrh / 2 )
            component:SetOffset( settings.arrow_offset )
            component:SetSize( settings.arrow_size )
            component:SetStacked( settings.arrow_stack )
            component:SetColor( settings.color )
            component:SetIntensity( math.floor( queued.damage / ARROW_DAMAGE_THRESHOLD * 3 ) )
            component:SetDuration( ARROW_MIN_TIME + ( ARROW_MAX_TIME - ARROW_MIN_TIME ) * math.min( queued.damage / ARROW_DAMAGE_THRESHOLD, 1 ) )
            component:SetFadeDuration( component.duration * ARROW_FADE_TIME * ( component.intensity + 1 ) )
            component:SetAnimated( true )

            table.insert(arrows.instances, { component = component, angle = queued.direction + queued.yaw })
            table.insert(arrows.active, component)

            if #arrows.active > settings.arrow_max then

                arrows.active[1]:Skip()
                table.remove( arrows.active, 1 )

            end

            table.remove( queue, 1 )

        end

        -- rotate arrows based on relative view angle
        local yaw = EyeAngles().y
        local i = 1
        for _, arrow in ipairs( arrows.instances ) do

            arrow.component:SetAngle( yaw - arrow.angle )
            arrow.component:Think()

            if arrow.component._elapsed < arrow.component.duration then

                i = i + 1
                continue

            end

            table.remove( arrows.instances, i )
        end

        -- we run the active list separately because discarded arrows are faded out, not removed
        local i = 1
        for _, component in ipairs( arrows.active ) do

            if not component:IsFading() then

                i = i + 1
                continue

            end

            table.remove( arrows.active, i )

        end

        return

    end

    -- trigger directional indicators from queue
    for _, queued in ipairs( queue ) do

        local angle = queued.direction
        -- local indicator = indicators[ 4 ] -- default to forward

        -- forward
        if angle <= 60 or angle >= 300 then

            local indicator = indicators[ 1 ]
            indicator:SetVisible( true )
            indicator:SetAnimated( true )

        end

        -- left
        if angle >= 30 and angle <= 150 then

            local indicator = indicators[ 2 ]
            indicator:SetVisible( true )
            indicator:SetAnimated( true )

        end

        -- down
        if angle >= 120 and angle <= 240 then

            local indicator = indicators[ 3 ]
            indicator:SetVisible( true )
            indicator:SetAnimated( true )

        end

        -- right
        if angle >= 210 and angle <= 330 then

            local indicator = indicators[ 4 ]
            indicator:SetVisible( true )
            indicator:SetAnimated( true )

        end

        table.remove( queue, 1 )

    end

    -- tick all indicators
    for _, indicator in ipairs( indicators ) do

        indicator:Think()

    end

end

---
--- Paint
---
function ELEMENT:Paint( settings, x, y )

    if hook_Call( "DrawDamageIndicator", x, y ) then return end

    if settings.style == STYLE_ARROW then

        -- draw startup arrows
        if startup_phase ~= STARTUP_NONE then

            for _, arrow in ipairs( startup_arrows ) do

                arrow:Paint( x, y )

            end

        end

        for _, arrow in ipairs( arrows.instances ) do

            arrow.component:Paint( x, y )

        end

        return

    end

    for _, indicator in ipairs( indicators ) do

        indicator:Paint( x, y )

    end

end
ELEMENT.PaintScanlines = ELEMENT.Paint

function ELEMENT:PaintOver( settings )

    if hook_Call( "DrawDamageIndicatorOverlay" ) then return end

    if pain <= 0 then return end
    if not MAT_PAIN then return end

    MAT_PAIN:SetVector( "$color", color_vector )
    MAT_PAIN:SetFloat( "$alpha", ( settings.color.a / 255 ) * ( pain * settings.pain_alpha ) )

    render.SetMaterial( MAT_PAIN )
    render.DrawScreenQuad()

end

---
--- Preview
---
local preview_arrow = HOLOHUD2.component.Create( "DamageArrow" )
preview_arrow:SetIntensity( 2 )
preview_arrow._anim = 1

local preview_indicator = HOLOHUD2.component.Create( "DamageIndicator" )
preview_indicator._alpha = 1

function ELEMENT:OnPreviewChanged( settings )

    preview_arrow:SetStacked( settings.arrow_stack )
    preview_arrow:SetSize( settings.arrow_size )
    preview_arrow:SetColor( settings.color )

    preview_indicator:SetSize( settings.simple_size )
    preview_indicator:SetColor( settings.color )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    if settings.style == STYLE_ARROW then

        preview_arrow:Think()
        preview_arrow:Paint( x, y )

    else

        preview_indicator:Think()
        preview_indicator:Paint( x, y )

    end

    surface.SetTexture( RESOURCE_PAIN )
    surface.SetDrawColor( settings.color.r, settings.color.g, settings.color.b, settings.color.a * settings.pain_alpha )
    surface.DrawTexturedRect( 0, 0, w, h )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    vfx = settings.vfx
    vfx_flickering = settings.flickering
    vfx_shaking = settings.shaking
    vfx_distortion = settings.distortion
    lowhealth_threshold = settings.lowhealth_threshold

    if not settings._visible then

        table.Empty( arrows.instances )
        table.Empty( arrows.active )

        return

    end

    -- update pain overlay color
    color_vector:SetUnpacked( settings.color.r / 255, settings.color.g / 255, settings.color.b / 255 )

    local scrw, scrh = GetScreenSize()

    if settings.style == STYLE_ARROW then

        for _, arrow in ipairs( startup_arrows ) do

            arrow:SetPos( scrw / 2, scrh / 2 )
            arrow:SetOffset( settings.arrow_offset )
            arrow:SetSize( settings.arrow_size )
            arrow:SetStacked( settings.arrow_stack )
            arrow:SetColor( settings.color )

        end

        for _, arrow in ipairs( arrows.instances ) do

            arrow.component:SetPos( scrw / 2, scrh / 2 )
            arrow.component:SetOffset( settings.arrow_offset )
            arrow.component:SetSize( settings.arrow_size )
            arrow.component:SetStacked( settings.arrow_stack )
            arrow.component:SetColor( settings.color )

        end

        return

    end

    if settings.simple_centered then

        indicators[1]:SetPos( scrw / 2, scrh / 2 - settings.simple_offset )
        indicators[2]:SetPos( scrw / 2 - settings.simple_offset, scrh / 2 )
        indicators[3]:SetPos( scrw / 2, scrh / 2 + settings.simple_offset )
        indicators[4]:SetPos( scrw / 2 + settings.simple_offset, scrh / 2 )

    else

        indicators[1]:SetPos( scrw / 2, settings.simple_margin )
        indicators[2]:SetPos( settings.simple_margin, scrh / 2 )
        indicators[3]:SetPos( scrw / 2, scrh - settings.simple_margin )
        indicators[4]:SetPos( scrw - settings.simple_margin, scrh / 2 )

    end

    for _, indicator in ipairs( indicators ) do

        indicator:SetColor( settings.color )
        indicator:SetSize( settings.simple_size )
        indicator:SetDuration( SIMPLE_FADE_TIME )
    end

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    for _, arrow in ipairs( arrows.instances ) do

        arrow.component:InvalidateLayout()

    end

    for _, indicator in ipairs( indicators ) do

        indicator:InvalidateLayout()

    end

end

HOLOHUD2.element.Register( "damageindicator", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    arrows      = arrows,
    indicators  = indicators
}

---
--- Presets
---
HOLOHUD2.presets.Register( "damageindicator", "element/damageindicator" )
