HOLOHUD2.AddCSLuaFile( "startup/hudwelcome.lua" )

if SERVER then return end

-- TODO: make first and last message also customizable for regular startup (with the chance of changing the "Good morning" message with the time and/or date)
-- TODO: add a way to change the startup order

local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local MODE_NONE     = 1
local MODE_WELCOME  = 2
local MODE_STARTUP  = 3
local MODES         = { "#holohud2.startup.mode_0", "#holohud2.startup.mode_1", "#holohud2.startup.mode_2" }

local suiton    = MODE_STARTUP

local ELEMENT = {
    name        = "#holohud2.startup",
    helptext    = "#holohud2.startup.helptext",
    parameters  = {
        initialspawn            = { name = "#holohud2.startup.initial_spawn", type = HOLOHUD2.PARAM_OPTION, options = MODES, value = MODE_WELCOME },
        suiton                  = { name = "#holohud2.startup.suit_equip", type = HOLOHUD2.PARAM_OPTION, options = MODES, value = MODE_STARTUP },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_RIGHT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 212, y = 118 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        tint                    = { name = "#holohud2.parameter.tint", type = HOLOHUD2.PARAM_COLOR, value = Color( 100, 160, 200 ) },
        messages_color          = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },

        title                   = { name = "#holohud2.startup.title", type = HOLOHUD2.PARAM_BOOL, value = true },
        title_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        title_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto", size = 17, weight = 1000, italic = true } },
        title_override          = { name = "#holohud2.parameter.override", type = HOLOHUD2.PARAM_STRING, value = "", helptext = "#holohud2.parameter.override.helptext" },
        version                 = { name = "#holohud2.startup.version", type = HOLOHUD2.PARAM_BOOL, value = true },
        version_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 48, y = 9 } },
        version_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto", size = 9, weight = 0, italic = true } },
        version_override        = { name = "#holohud2.parameter.override", type = HOLOHUD2.PARAM_STRING, value = "", helptext = "#holohud2.parameter.override.helptext" },
        separator               = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_pos           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 20 } },
        separator_size          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 204, y = 1 } },

        messages_pos            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 25 } },
        messages_size           = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 204, y = 90 } },
        messages_font           = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 13, weight = 0, italic = false } },
        messages_spacing        = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        messages_margin         = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 8 },

        startup_premessages     = { name = "#holohud2.startup.init_warmup", type = HOLOHUD2.PARAM_STRINGTABLE, value = { "#holohud2.startup.init_0", "#holohud2.startup.init_1" } },
        startup_postmessages    = { name = "#holohud2.startup.init_subload", type = HOLOHUD2.PARAM_STRINGTABLE, value = { "#holohud2.startup.init_2" } },
        startup_ending          = { name = "#holohud2.startup.init_ending", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.startup.init_3" },
    },
    menu = {
        { id = "initialspawn" },
        { id = "suiton" },

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
            { id = "animation", parameter = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "tint" },
            { id = "messages_color" }
        } },

        { category = "#holohud2.category.header", parameters = {
            { id = "title", parameters = {
                { id = "title_pos" },
                { id = "title_font" },
                { id = "title_override" }
            } },
            { id = "version", parameters = {
                { id = "version_pos" },
                { id = "version_font" },
                { id = "version_override" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_size" }
            } }
        } },

        { category = "#holohud2.parameter.messages", parameters = {
            { id = "messages_pos" },
            { id = "messages_size" },
            { id = "messages_font" },
            { id = "messages_spacing" },
            { id = "messages_margin" }
        } },

        { category = "#holohud2.startup.mode_2", parameters = {
            { id = "startup_premessages" },
            { id = "startup_postmessages" },
            { id = "startup_ending" }
        } }
    },
    quickmenu = {
        { id = "initialspawn" },
        { id = "suiton" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "tint" },
            { id = "messages_color" }
        } },

        { category = "#holohud2.category.header", parameters = {
            { id = "title", parameters = {
                { id = "title_pos" },
                { id = "title_font" }
            } },
            { id = "version", parameters = {
                { id = "version_pos" },
                { id = "version_font" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_size" }
            } }
        } },

        { category = "#holohud2.category.messages", parameters = {
            { id = "messages_pos" },
            { id = "messages_size" }
        } }
    }
}

local ANIM_STANDBY  = -1
local ANIM_NONE     = 0
local ANIM_WELCOME  = 1
local ANIM_STARTUP  = 2

local index = HOLOHUD2.element.Index()
local elements = HOLOHUD2.element.All()
local anim = ANIM_STANDBY -- current animation

---
--- Composition
---
local hudwelcome    = HOLOHUD2.component.Create( "HudWelcome" )
local layout        = HOLOHUD2.layout.Register( "welcome" )
local panel         = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawWelcomeScreen", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    hook_Call( "DrawWelcomeScreen", x, y, self._w, self._h, LAYER_BACKGROUND, hudwelcome )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawWelcomeScreen", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudwelcome:Paint( x, y )

    hook_Call( "DrawOverWelcomeScreen", x, y, self._w, self._h, LAYER_FOREGROUND, hudwelcome )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawWelcomeScreen", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudwelcome:PaintScanlines( x, y )

    hook_Call( "DrawOverWelcomeScreen", x, y, self._w, self._h, LAYER_SCANLINES, hudwelcome )

end

---
--- Build MOTD
---
local MOTD = {}
local speed = 0

HOLOHUD2.hook.Add( "OnInitialized", "startup", function()

    speed = hudwelcome.MessageBox.letter_rate

    MOTD[ 1 ] = "holohud2.startup.welcome_0"
    MOTD[ 2 ] = "holohud2.startup.welcome_1"
    MOTD[ 3 ] = { "holohud2.startup.welcome_2", string.format( language.GetPhrase( "holohud2.startup.welcome_2b" ), #index ) }

    local temp = HOLOHUD2.persistence.ReadTemp()
    MOTD[ 4 ] = { "holohud2.startup.welcome_3", temp and "holohud2.startup.welcome_3b" or "holohud2.startup.welcome_3c" }

    local presets = HOLOHUD2.persistence.Find()
    MOTD[ 5 ] = { "holohud2.startup.welcome_4", #presets > 0 and string.format( language.GetPhrase( "holohud2.startup.welcome_4b" ), #presets ) or "holohud2.startup.welcome_4c" }

    MOTD[ 6 ] = hook_Call( "WelcomeSecretMessage" ) or "holohud2.startup.welcome_5"

end)

---
--- Welcome message
---
local finished = false -- whether the sequence has finished
local next = 0 -- time for next message
local cur = 0 -- current message to display

function ELEMENT:InitWelcome()

    -- cancel startup sequence
    if anim == ANIM_STARTUP then

        for _, element in pairs( elements ) do

            element:CancelStartup()

        end

    end

    -- reset animation
    finished = false
    anim = ANIM_WELCOME
    cur = 0
    next = CurTime() + .3
    hudwelcome:Clear()

    -- select a greeting
    local hour = os.date( "*t" ).hour

    if hour >= 4 and hour < 12 then

        MOTD[ 1 ] = "#holohud2.greeting.morning"

    elseif hour >= 12 and hour < 18 then

        MOTD[ 1 ] = "#holohud2.greeting.afternoon"

    elseif hour >= 18 and hour <= 23 then

        MOTD[ 1 ] = "#holohud2.greeting.evening"

    else

        MOTD[ 1 ] = "#holohud2.greeting.night"

    end

end

function ELEMENT:DoWelcomeAnim()

    local curtime = CurTime()

    if next > curtime then return end

    if finished then

        anim = ANIM_NONE
        return

    end

    cur = cur + 1

    local message = MOTD[ cur ]

    if cur > 2 and cur < #MOTD then

        local message1, message2 = language.GetPhrase( message[ 1 ] ), language.GetPhrase( message[ 2 ] )

        hudwelcome:AddDeferredMessage( message1, message2, 2 )

        local duration1, duration2 = utf8.len( message1 ) * speed, utf8.len( message2 ) * speed
        next = curtime + duration1 + duration2 + 3

    else

        -- add an empty message before the last
        if cur == #MOTD then hudwelcome:AddSpacer() end

        hudwelcome:AddMessage( message )

        local duration = utf8.len( message ) * speed
        next = curtime + duration + 1

        -- elongate last message before finishing the animation
        if cur == #MOTD then

            finished = true
            next = next + 3

        end

    end

end

---
--- Startup sequence
---
local FALLBACK  = "#holohud2.startup.init_fallback"
local premessages = { "#holohud2.startup.init_0", "#holohud2.startup.init_1" }
local postmessages = { "#holohud2.startup.init_2" }
local ending = "#holohud2.startup.init_3"

local message = 1 -- current preinitialization message to show
local next_message = 0 -- time for the next preinitialization message

local await = false -- awaiting for an element's startup to finish
local next = 1 -- next element
local cur_message -- current message
local skipped = {} -- skipped elements (to be started up at the end)

function ELEMENT:InitStartup()

    panel:Close()

    for i=1, #index do

        local element = elements[ index[ i ] ]

        if not element:IsVisible() then continue end

        element:QueueStartup()

    end

    anim = ANIM_STARTUP
    next = 1
    message = 1
    next_message = CurTime() + .2
    await = false
    skipped = {}

    hudwelcome:Clear()

end

function ELEMENT:DoStartupSequence()

    local curtime = CurTime()

    if next_message > curtime then return end

    -- initial welcome messages
    if message <= #premessages then

        local text = premessages[ message ]

        hudwelcome:AddMessage( text )

        local duration = utf8.len( text ) * speed
        next_message = curtime + duration + 1

        message = message + 1

        return

    end

    -- startup HUD elements
    if next <= #index then

        local element = elements[ index[ next ] ]

        if not element:IsVisible() then

            next = next + 1
            return

        end

        local startupover = element:IsStartupOver()

        if startupover == nil then -- if the function wasn't implemented, skip

            table.insert( skipped, element )
            next = next + 1

        else

            if not await then

                cur_message = hudwelcome:AddDeferredMessage( element:GetStartupMessage() or string.format( language.GetPhrase( FALLBACK ), element.name ) )
                element:Startup()
                await = true

            elseif startupover then

                cur_message.deferred = false
                cur_message.bullet = ">"
                next = next + 1
                await = false

            end

        end

    else

        -- continue where we left off after the startup finishes
        if message <= #premessages + #postmessages then

            -- initialize all skipped elements
            for _, element in ipairs( skipped ) do

                element:Startup()

            end

            local text = postmessages[ message - #premessages ]

            hudwelcome:AddMessage( text )

            local duration = utf8.len( text ) * speed
            next_message = curtime + duration + 1

            message = message + 1

        elseif message == #premessages + #postmessages + 1 then

            -- closing message
            local text = hook_Call( "WelcomeSecretMessage" ) or ending
            local duration = utf8.len( text ) * speed

            hudwelcome:AddSpacer()
            hudwelcome:AddMessage( text )

            message = message + 1
            next_message = curtime + duration + 3.5 -- wait a bit before closing the window

        else

            anim = ANIM_NONE -- the animation is done

        end

    end

end

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    if anim == ANIM_STANDBY then

        if settings.initialspawn == MODE_WELCOME then

            self:InitWelcome()

        elseif settings.initialspawn == MODE_STARTUP then

            self:InitStartup()

        end

    elseif anim == ANIM_WELCOME then

        self:DoWelcomeAnim()

    elseif anim == ANIM_STARTUP then

        self:DoStartupSequence()

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and anim > ANIM_NONE )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudwelcome:Think()

end

---
--- Reset animation after equipping the suit
---
HOLOHUD2.hook.Add( "OnSuitEquipped", "startup", function()

    if not ELEMENT:IsVisible() then return end

    if suiton == MODE_WELCOME then

        ELEMENT:InitWelcome()

    elseif suiton == MODE_STARTUP then

        ELEMENT:InitStartup()

    end

end)

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
local preview_hudwelcome = HOLOHUD2.component.Create( "HudWelcome" )

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

    preview_hudwelcome:Think()
    preview_hudwelcome:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudwelcome:ApplySettings( settings, self.preview_fonts )

    preview_hudwelcome:Clear()
    preview_hudwelcome:AddMessage( "#holohud2.startup.preview_0" )
    preview_hudwelcome:AddMessage( "#holohud2.startup.preview_1" )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    suiton = settings.suiton

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

    hudwelcome:ApplySettings( settings, self.fonts )

    premessages = settings.startup_premessages
    postmessages = settings.startup_postmessages
    ending = settings.startup_ending

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudwelcome:InvalidateLayout()

end

---
--- Secret messages
---
local SECRET_PHRASES = {
    "#holohud2.secretphrase_00",
    "#holohud2.secretphrase_01",
    "#holohud2.secretphrase_02",
    "#holohud2.secretphrase_03",
    "#holohud2.secretphrase_04",
    "#holohud2.secretphrase_05",
    "#holohud2.secretphrase_06",
    "#holohud2.secretphrase_07",
    "#holohud2.secretphrase_08",
    "#holohud2.secretphrase_09",
    "#holohud2.secretphrase_10",
    "#holohud2.secretphrase_11",
    "#holohud2.secretphrase_12"
}

HOLOHUD2.hook.Add( "WelcomeSecretMessage", "startup", function()

    local date = os.date( "*t" )

    -- New year
    if date.month == 1 and date.day == 1 then

        return string.format( language.GetPhrase( "holohud2.holiday.new_year" ), date.year )

    end

    -- Christmas
    if date.month == 12 and date.day == 25 then

        return "#holohud2.holiday.christmas"

    end

    -- Halloween
    if date.month == 10 and date.day == 31 then

        return "#holohud2.holiday.halloween"

    end

    -- April Fools
    if date.month == 4 and date.day == 1 then

        return "#holohud2.holiday.aprilfools"

    end

    -- Weekend
    if date.wday == 1 or date.wday == 7 then

        return "#holohud2.holiday.weekend"

    end

    -- A message for the future
    if math.random( 1, 30 ) == 1 then

        if date.year >= 2030 and date.year < 2035 then

            return "#holohud2.startup.historic_0"

        elseif date.year == 2035 then

            return "#holohud2.startup.historic_1"

        elseif date.year > 2035 and date.year < 2045 then

            return string.format( language.GetPhrase( "holohud2.startup.historic_2" ), date.year )

        elseif date.year >= 2045 then

            return string.format( language.GetPhrase( "holohud2.startup.historic_3" ), date.year )

        end

    end

    -- Secret phrase
    if math.random( 1, 100 ) == 1 then

        return SECRET_PHRASES[ math.random( 1, #SECRET_PHRASES ) ]

    end

end)

HOLOHUD2.element.Register( "startup", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudwelcome  = hudwelcome
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "startup", "animation" )
HOLOHUD2.modifier.Add( "background", "startup", "background" )
HOLOHUD2.modifier.Add( "background_color", "startup", "background_color" )
HOLOHUD2.modifier.Add( "color", "startup", "messages_color" )
HOLOHUD2.modifier.Add( "text_font", "startup", { "title_font", "version_font", "messages_font" } )
HOLOHUD2.modifier.Add( "text_offset", "startup", { "title_pos", "version_pos", "messages_pos" } )
HOLOHUD2.modifier.Add( "scale", "startup", {
    "pos", "margin", "size",
    "title_pos", "title_font",
    "version_pos", "version_font",
    "separator_pos", "separator_size",
    "messages_pos", "messages_size", "messages_font", "messages_spacing", "messages_margin"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "startup", "element/startup" )

---
--- Debug commands
---
concommand.Add( "holohud2_debug_startup", function() ELEMENT:InitStartup() end)
concommand.Add( "holohud2_debug_welcome", function() ELEMENT:InitWelcome() end)
