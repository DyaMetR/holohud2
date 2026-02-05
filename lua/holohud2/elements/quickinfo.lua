HOLOHUD2.AddCSLuaFile( "quickinfo/hudquickinfo.lua" )
HOLOHUD2.AddCSLuaFile( "quickinfo/hudquickinfo0.lua" )
HOLOHUD2.AddCSLuaFile( "quickinfo/hudquickinfo1.lua" )

if SERVER then return end

local hideonads = CreateClientConVar( "holohud2_quickinfo_hideonads", 1, true, false, "Whether the Quick Info element should hide when aiming down sights.", 0, 1 )

local IsValid = IsValid
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local FrameTime = FrameTime
local ScrW, ScrH = ScrW, ScrH
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow
local GetPrimaryAmmo = HOLOHUD2.util.GetPrimaryAmmo
local GetSecondaryAmmo = HOLOHUD2.util.GetSecondaryAmmo
local GetWeapon = HOLOHUD2.util.GetWeapon
local hook_Call = HOLOHUD2.hook.Call

local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local offset = 0

local ELEMENT = {
    name        = "#holohud2.quickinfo",
    hide        = "CHUDQuickInfo",
    helptext    = "#holohud2.quickinfo.helptext",
    visible     = false,
    parameters  = {
        antiglow                = { name = "#holohud2.quickinfo.antiglow", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.quickinfo.antiglow.helptext" },
        offset                  = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 10 },
        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 36 },
        inverted                = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.quickinfo.inverted.helptext" },
        animated                = { name = "#holohud2.parameter.animated", type = HOLOHUD2.PARAM_BOOL, value = true },
        max_alpha               = { name = "#holohud2.quickinfo.max_alpha", type = HOLOHUD2.PARAM_RANGE, value = 255, min = 0, max = 255 },
        min_alpha               = { name = "#holohud2.quickinfo.min_alpha", type = HOLOHUD2.PARAM_RANGE, value = 64, min = 0, max = 255 },
        warning                 = { name = "#holohud2.quickinfo.warning", type = HOLOHUD2.PARAM_BOOL, value = true },
        warning_sound           = { name = "#holohud2.parameter.sound", type = HOLOHUD2.PARAM_BOOL, value = true },
        warning_sound_volume    = { name = "#holohud2.parameter.sound_volume", type = HOLOHUD2.PARAM_RANGE, value = 80, min = 0, max = 200 },
        warning_sound_path      = { name = "#holohud2.parameter.sound_path", type = HOLOHUD2.PARAM_STRING, value = "hl1/fvox/buzz.wav" },
        warning_sound_pitch     = { name = "#holohud2.parameter.sound_pitch", type = HOLOHUD2.PARAM_RANGE, value = 80, min = 0, max = 255 },
        health                  = { name = "#holohud2.health", type = HOLOHUD2.PARAM_BOOL, value = true },
        frame0                  = { name = "#holohud2.parameter.frame", type = HOLOHUD2.PARAM_BOOL, value = true },
        frame0_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 24 ) },
        frame0_color2           = { name = "#holohud2.quickinfo.warning_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32 ) },
        health_color            = { name = "#holohud2.quickinfo.health_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 162, 72 ), [100] = Color(72, 255, 72) }, fraction = true, gradual = false } },
        suit_color              = { name = "#holohud2.quickinfo.suit_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color(92, 163, 255) }, fraction = true, gradual = false } },
        ammo                    = { name = "#holohud2.ammo", type = HOLOHUD2.PARAM_BOOL, value = true },
        frame1                  = { name = "#holohud2.parameter.frame", type = HOLOHUD2.PARAM_BOOL, value = true },
        frame1_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 24 ) },
        frame1_color2           = { name = "#holohud2.quickinfo.warning_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32 ) },
        ammo_color              = { name = "#holohud2.quickinfo.primary_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color(255, 60, 50), [100] = Color(255, 186, 92) }, fraction = true, gradual = false } },
        ammo2_color             = { name = "#holohud2.quickinfo.secondary_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color(255, 60, 50), [100] = Color(255, 186, 92) }, fraction = true, gradual = false } }
    },
    menu = {
        { id = "antiglow" },
        { id = "offset" },
        { id = "size" },
        { id = "inverted" },
        { id = "animated" },
        { id = "warning", parameters = {
            { id = "warning_sound", parameters = {
                { id = "warning_sound_volume" },
                { id = "warning_sound_path" },
                { id = "warning_sound_pitch" }
            } }
        } },
        { id = "health", parameters = {
            { id = "frame0", parameters = {
                { id = "frame0_color" },
                { id = "frame0_color2" }
            } },
            { id = "health_color" },
            { id = "suit_color" }
        } },
        { id = "ammo", parameters = {
            { id = "frame1", parameters = {
                { id = "frame1_color" },
                { id = "frame1_color2" }
            } },
            { id = "ammo_color" },
            { id = "ammo2_color" }
        } }
    },
    quickmenu = {
        { id = "antiglow" },
        { id = "offset" },
        { id = "size" },
        { id = "inverted" },
        { id = "animated" },
        { id = "warning", parameters = {
            { id = "warning_sound" }
        } },
        { id = "health", parameters = {
            { id = "health_color" },
            { id = "suit_color" }
        } },
        { id = "ammo", parameters = {
            { id = "ammo_color" },
            { id = "ammo2_color" }
        } }
    }
}

local FADE_IN_TIME      = .25
local FADE_OUT_TIME     = 4
local ZOOM_FADE_OUT     = .25
local WARNING_THRESHOLD = .25

---
--- Components
---
local left = HOLOHUD2.component.Create( "HudQuickInfo0" )
local right = HOLOHUD2.component.Create( "HudQuickInfo1" )

---
--- Startup
---
local alpha = 1 -- element opacity

local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_FILL      = 2

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    left:SetVisible( false )
    left:SetValue( 0 )
    left:SetValue2( 0 )

    right:SetVisible( false )
    right:SetValue( 0 )
    right:SetValue2( 0 )

    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    left:SetVisible( true )
    right:SetVisible( true )

    startup_phase = STARTUP_STANDBY
    next_startup_phase = CurTime() + 2

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.quickinfo.startup"

end

function ELEMENT:IsStartupOver()

    return startup_phase == STARTUP_NONE

end

function ELEMENT:DoStartupSequence( settings )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()

    if next_startup_phase < curtime then

        if startup_phase == STARTUP_FILL then

            startup_phase = STARTUP_NONE
            return

        end

        startup_phase = startup_phase + 1
        next_startup_phase = curtime + 1

    end

    left:Think()
    right:Think()

    alpha = settings.min_alpha / 255

    return startup_phase == STARTUP_STANDBY

end

---
--- Logic
---
local localplayer
local animated = false
local animation = 0
local zoom = 0
local _health, _armor, _healthwarn = 0, 0, false
local _ammo, _ammo2, _ammowarn = 0, 0, false
local _x, _y = 0, 0
function ELEMENT:PreDraw( settings )

    if self:DoStartupSequence( settings ) then return end

    local frametime = FrameTime()

    localplayer = localplayer or LocalPlayer()
    local warned = false -- should play warning sound

    -- hide if dead or in a vehicle
    local visible = localplayer:Alive() and not localplayer:InVehicle()
    left:SetVisible( visible )
    right:SetVisible( visible )

    -- health and armor
    local health, max_health = localplayer:Health(), localplayer:GetMaxHealth()
    local armor, max_armor = localplayer:Armor(), localplayer:GetMaxArmor()

    if health ~= _health then

        local warn = health / max_health <= WARNING_THRESHOLD

        if not _healthwarn and warn then

            warned = true

        end

        animated = true
        _health = health
        _healthwarn = warn

    end

    if armor ~= _armor then

        animated = true
        _armor = armor

    end

    left:SetValue( health )
    left:SetMaxValue( max_health )
    left:SetValue2( armor )
    left:SetMaxValue2( max_armor )
    left:SetWarning( settings.warning and health / max_health <= WARNING_THRESHOLD )

    -- primary ammo
    local clip1, max_clip1, ammo1, max_ammo1, primary = GetPrimaryAmmo()

    if primary > 0 then

        local ammo, max_ammo = 0, 0

        if clip1 ~= -1 then

            ammo, max_ammo = clip1, max_clip1

        else

            ammo, max_ammo = ammo1, max_ammo1

        end

        if ammo ~= _ammo then

            local warn = ammo / max_ammo <= WARNING_THRESHOLD

            if not _ammowarn and warn then

                warned = true

            end

            animated = true
            _ammo = ammo
            _ammowarn = warn

        end

        right:SetValue( ammo )
        right:SetMaxValue( max_ammo )
        right:SetWarning( settings.warning and ammo / max_ammo <= WARNING_THRESHOLD )

    else

        right:SetValue( 0 )
        right:SetMaxValue( 1 )
        right:SetWarning( false )
        _ammo = -1
        _ammowarn = false

    end

    -- secondary ammo
    local clip2, max_clip2, ammo2, max_ammo2, secondary = GetSecondaryAmmo()

    if secondary > 0 then

        local ammo = 0

        if clip2 ~= -1 then

            ammo = clip2
            right:SetMaxValue2( max_clip2 )

        else

            ammo = ammo2
            right:SetMaxValue2( max_ammo2 )

        end

        if ammo ~= _ammo2 then

            animated = true
            _ammo2 = ammo

        end

        right:SetValue2( ammo )

    else

        right:SetValue2( 0 )
        right:SetMaxValue2( 1 )

    end

    left:Think()
    right:Think()

    -- play warning sound
    if warned and settings.warning and settings.warning_sound then

        localplayer:EmitSound( settings.warning_sound_path, SNDLVL_NONE, settings.warning_sound_pitch, settings.warning_sound_volume / 100 )

        if settings.warning_sound_volume > 100 then

            localplayer:EmitSound( settings.warning_sound_path, SNDLVL_NONE, settings.warning_sound_pitch, ( settings.warning_sound_volume - 100 ) / 100 )

        end

    end

    -- get can zoom
    local can_zoom = hook_Call( "CanZoom" )
    if can_zoom == nil then can_zoom = localplayer:GetCanZoom() end

    -- fade out if using zoom
    if self:IsMinimized() or ( hook_Call( "ForceQuickInfoFadeOut" ) and hideonads:GetBool() ) or ( localplayer:KeyDown( IN_ZOOM ) and can_zoom ) then

        zoom = math.min( zoom + frametime / ZOOM_FADE_OUT, 1 )

    else

        zoom = math.max( zoom - frametime / ZOOM_FADE_OUT, 0 )

    end

    -- dimming animation
    if self:IsInspecting() or animated then

        animation = math.min( animation + frametime / FADE_IN_TIME, 1 )

        if animation == 1 then

            animated = false

        end

    else

        animation = math.max( animation - frametime / FADE_OUT_TIME, 0 )

    end

    alpha = ( ( settings.min_alpha + ( settings.max_alpha - settings.min_alpha ) * animation ) / 255 ) * ( 1 - zoom )

    -- follow crosshair
    local trace = localplayer:GetEyeTraceNoCursor()

    if not localplayer:ShouldDrawLocalPlayer() or not trace.Hit then

        _x, _y = 0, 0
        return

    end

    local center_x, center_y = ScrW() * .5, ScrH() * .5
    local aimpos = trace.HitPos:ToScreen()

    _x, _y = aimpos.x - center_x, aimpos.y - center_y

end

---
--- Paint
---
function ELEMENT:PaintBackground( settings, x, y )

    x, y = x + _x, y + _y

    if hook_Call( "DrawQuickInfo", x, y, alpha, LAYER_BACKGROUND ) then return end

    StartAlphaMultiplier( alpha )

    left:PaintBackground( x, y )
    right:PaintBackground( x, y )

    EndAlphaMultiplier()

end

function ELEMENT:Paint( settings, x, y )

    x, y = x + _x, y + _y

    if hook_Call( "DrawQuickInfo", x, y, alpha, LAYER_FOREGROUND ) then return end

    StartAlphaMultiplier( alpha )

    left:Paint( x, y )
    right:Paint( x, y )

    EndAlphaMultiplier()

end

function ELEMENT:PaintScanlines( settings, x, y )

    if hook_Call( "DrawQuickInfo", x + _x, y + _y, alpha, LAYER_SCANLINES ) then return end

    local alpha = GetMinimumGlow()

    if settings.antiglow then

        alpha = alpha * .3

    end

    StartAlphaMultiplier( alpha )
    self:Paint( settings, x, y )
    EndAlphaMultiplier()

end

---
--- Preview
---
local preview_left = HOLOHUD2.component.Create( "HudQuickInfo0" )
local preview_right = HOLOHUD2.component.Create( "HudQuickInfo1" )

preview_left:SetValue( 1 )
preview_right:SetValue( 1 )

local preview_sound, preview_volume, preview_pitch, preview_warning

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 140, 122 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() )

        local health = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", controls )
        health:Dock( TOP )
        health:SetIcon( "icon16/heart.png" )
        health:SetValue( preview_left.value * 100 )
        health.OnValueChanged = function( _, value )

            preview_left:SetValue( value / 100 )

        end

        local armor = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", controls )
        armor:Dock( TOP )
        armor:SetIcon( "icon16/shield.png" )
        armor:SetValue( preview_left.value2 * 100 )
        armor.OnValueChanged = function( _, value )

            preview_left:SetValue2( value / 100 )

        end

        local ammo1 = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", controls )
        ammo1:Dock( TOP )
        ammo1:SetIcon( "icon16/gun.png" )
        ammo1:SetValue( preview_right.value * 100 )
        ammo1.OnValueChanged = function( _, value )

            preview_right:SetValue( value / 100 )

        end

        local ammo2 = vgui.Create( "HOLOHUD2_DPreviewProperty_NumSlider", controls )
        ammo2:Dock( TOP )
        ammo2:SetIcon( "icon16/bomb.png" )
        ammo2:SetValue( preview_right.value2 * 100 )
        ammo2.OnValueChanged = function( _, value )

            preview_right:SetValue2( value / 100 )

        end

        local sound = vgui.Create( "DButton", controls )
        sound:Dock( TOP )
        sound:SetText( "#holohud2.quickinfo.preview.sound" )
        sound:SetImage( "icon16/sound.png" )
        sound.DoClick = function()

            LocalPlayer():EmitSound( preview_sound, SNDLVL_NONE, preview_pitch, preview_volume / 100 )

            if preview_volume <= 100 then return end

            LocalPlayer():EmitSound( preview_sound, SNDLVL_NONE, preview_pitch, ( preview_volume - 100 ) / 100 )

        end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( controls:GetWide() + 8, panel:GetTall() - reset:GetTall() - 6 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        health:SetValue( 100 )
        armor:SetValue( 0 )
        ammo1:SetValue( 100 )
        ammo2:SetValue( 0 )

    end

end

function ELEMENT:OnPreviewChanged( settings )

    preview_left:ApplySettings( settings )
    preview_left:PerformLayout()

    preview_right:ApplySettings( settings )

    local x1, x2, y = -settings.offset - preview_left.__w, settings.offset, -preview_left.__h / 2
    preview_left:SetPos( self.inverted and x2 or x1, y )
    preview_right:SetPos( self.inverted and x1 or x2, y )

    preview_sound = settings.warning_sound_path
    preview_pitch = settings.warning_sound_pitch
    preview_volume = settings.warning_sound_volume
    preview_warning = settings.warning

    preview_left:SetWarning( settings.warning and preview_left.value <= .25 )
    preview_right:SetWarning( settings.warning and preview_right.value <= .25 )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    preview_left:Think()
    preview_left:PaintBackground( x, y )
    preview_left:Paint( x, y )

    preview_right:Think()
    preview_right:PaintBackground( x, y )
    preview_right:Paint( x, y )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    left:ApplySettings( settings )
    left:PerformLayout()

    right:ApplySettings( settings )

    local w, h = HOLOHUD2.layout.GetScreenSize()
    local x1, x2, y = w / 2 - settings.offset - left.__w, w / 2 + settings.offset, h / 2 - left.__h / 2
    left:SetPos( self.inverted and x2 or x1, y )
    right:SetPos( self.inverted and x1 or x2, y )

    offset = settings.offset

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    left:PerformLayout( true )

    local w, h = HOLOHUD2.layout.GetScreenSize()
    local x1, x2, y = w / 2 - offset - left.__w, w / 2 + offset, h / 2 - left.__h / 2
    left:SetPos( self.inverted and x2 or x1, y )
    right:SetPos( self.inverted and x1 or x2, y )

end

HOLOHUD2.element.Register( "quickinfo", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    left        = left,
    right       = right
}

---
--- Apply modifiers
---
HOLOHUD2.modifier.Add( "scale", "quickinfo", { "offset", "size" } )

---
--- Presets
---
HOLOHUD2.presets.Register( "quickinfo", "element/quickinfo" )
