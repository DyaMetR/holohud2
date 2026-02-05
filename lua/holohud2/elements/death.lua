HOLOHUD2.AddCSLuaFile( "death/huddeath.lua" )
HOLOHUD2.AddCSLuaFile( "death/huddeathicon.lua" )

if SERVER then return end

local CurTime = CurTime
local LocalPlayer = LocalPlayer
local IsEnabled = HOLOHUD2.IsEnabled
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier

local STYLE_NOTHING     = 1
local STYLE_IMMEDIATE   = 2
local STYLE_DELAYED     = 3
local STYLE_DEFAULT     = 4

local flickering = GetConVar( "holohud2_r_flickering" )
local style = STYLE_DEFAULT

local ELEMENT = {
    name        = "#holohud2.death",
    helptext    = "#holohud2.death.helptext",
    parameters  = {
        style           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.death.style_0", "#holohud2.death.style_1", "#holohud2.death.style_2", "#holohud2.death.style_3" }, value = STYLE_DEFAULT },
        color           = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 84, 84 ) },

        text            = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_BOOL, value = true },
        text_pos        = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 16, y = 16 } },
        text_font       = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 18, weight = 0, italic = true } },
        text_margin     = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 12 },
        text_spacing    = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        text_bullet     = { name = "#holohud2.parameter.bullet", type = HOLOHUD2.PARAM_STRING, value = ">" },
        text_speed      = { name = "#holohud2.parameter.speed", type = HOLOHUD2.PARAM_RANGE, min = 0.01, max = 2, decimals = 2, value = 1 },
        text_delay      = { name = "#holohud2.death.line_delay", type = HOLOHUD2.PARAM_NUMBER, min = 0, decimals = 2, value = 0 },

        icon            = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos        = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 16, y = 16 } },
        icon_size       = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 48 },

        messages        = { name = "#holohud2.parameter.messages", type = HOLOHUD2.PARAM_STRINGTABLE, value = {
            "#holohud2.death.message_0",
            "#holohud2.death.message_1",
            "#holohud2.death.message_2",
            "#holohud2.death.message_3",
            "#holohud2.death.message_4",
            "#holohud2.death.message_5"
        } }
    },
    menu = {
        { id = "style" },
        { id = "color" },

        { id = "text", parameters = {
            { id = "text_pos" },
            { id = "text_font" },
            { id = "text_margin" },
            { id = "text_spacing" },
            { id = "text_bullet" },
            { id = "text_speed" },
            { id = "text_delay" }
        } },

        { id = "icon", parameters = {
            { id = "icon_pos" },
            { id = "icon_size" }
        } },

        { id = "messages" }
    },
    quickmenu = {
        { id = "color" },

        { id = "text", parameters = {
            { id = "text_pos" },
            { id = "text_font" },
            { id = "text_margin" }
        } },

        { id = "icon", parameters = {
            { id = "icon_pos" },
            { id = "icon_size" }
        } }
    },
    _alpha = 0 -- text alpha
}

---
--- Composition
---
local huddeath = HOLOHUD2.component.Create( "HudDeath" )
local huddeathicon = HOLOHUD2.component.Create( "HudDeathIcon" )
huddeathicon:SetAnchoredToScreen( true )

---
--- Logic
---
local localplayer
local alive = true
local panel_time = 0
local draw_time = 0
local next = 0
local cur = 1
function ELEMENT:PreDraw( settings )

    localplayer = localplayer or LocalPlayer()
    alive = localplayer:Alive()

    local curtime = CurTime()

    if alive then

        self._alpha = 1
        huddeath:Purge()
        cur = 1

        if settings.style == STYLE_DEFAULT then

            panel_time = curtime + 2

        end

        return

    end

    -- do end of sequence flickering
    if draw_time < curtime then

        self._alpha = 0

    elseif draw_time >= curtime and flickering:GetBool() and draw_time - .5 < curtime then

        self._alpha = math.Rand( 0, 1 )

    else

        self._alpha = 1

    end

    huddeath:Think()
    huddeathicon:PerformLayout()

    if cur > #settings.messages then return end

    if settings.style == STYLE_DELAYED then

        panel_time = curtime + 1

    end

    if next > curtime then return end

    local text = language.GetPhrase( settings.messages[ cur ] )
    next = curtime + utf8.len( text ) * huddeath.letter_rate + settings.text_delay
    huddeath:AddMessage( text )
    cur = cur + 1
    draw_time = next + 1

end

---
--- Paint
---
function ELEMENT:Paint( settings, x, y )

    if alive then return end

    StartAlphaMultiplier( self._alpha )
    huddeath:Paint( x, y )
    huddeathicon:Paint( x, y )
    EndAlphaMultiplier()

end

---
--- Preview
---
local preview_huddeathicon = HOLOHUD2.component.Create( "HudDeathIcon" )
local preview_huddeath = HOLOHUD2.component.Create( "HudDeath" )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    preview_huddeath:Think()
    preview_huddeath:Paint( x, y )

    preview_huddeathicon:PerformLayout()
    preview_huddeathicon:Paint( w - preview_huddeathicon._w - preview_huddeathicon._x * 2, 0 )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_huddeathicon:ApplySettings( settings )
    preview_huddeath:ApplySettings( settings, self.preview_fonts )
    preview_huddeath:Purge()

    for _, message in ipairs( settings.messages ) do

        if utf8.len( message ) == 0 then continue end

        preview_huddeath:AddMessage( message )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    style = settings.style
    cur = 1

    huddeath:Purge()
    huddeath:ApplySettings( settings, self.fonts )
    huddeathicon:ApplySettings( settings )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    huddeath:InvalidateLayout()
    huddeathicon:InvalidateLayout()

end

HOLOHUD2.element.Register( "death", ELEMENT )

---
--- Add modifiers
---
HOLOHUD2.modifier.Add( "scale", "death", {
    "text_pos", "text_font", "text_margin", "text_spacing",
    "icon_pos", "icon_size"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "death", "element/death" )

HOLOHUD2.presets.Add( "death", "Alternate - Minimal", {
    style   = STYLE_IMMEDIATE,
    text    = false,
    icon    = false
} )

---
--- Hide HUD after sequence is over
---
HOLOHUD2.hook.Add( "IsMinimized", "death", function()

    if not IsEnabled() or not ELEMENT:IsVisible() then return end
    if alive then return end
    if style == STYLE_NOTHING or panel_time > CurTime() then return end

    return true

end)
