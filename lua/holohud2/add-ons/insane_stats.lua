---
--- Insane Stats
--- https://steamcommunity.com/sharedfiles/filedetails/?id=2980423627
---

if not InsaneStats then return end

HOLOHUD2.AddCSLuaFile( "insane_stats/coins.lua" )
HOLOHUD2.AddCSLuaFile( "insane_stats/experience.lua" )

if SERVER then return end

local math = math
local LocalPlayer = LocalPlayer
local CurTime = CurTime

---
--- Coin counter
---
local ELEMENT_COINS = {
    name        = "#holohud2.insane_stats_coins",
    helptext    = "#holohud2.insane_stats_coins.helptext",
    parameters  = {
        autohide                    = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay              = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 4 },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 186 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 128 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 83, y = 22 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        num                         = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        num_pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 20, y = 2 } },
        num_font                    = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 18, weight = 1000, italic = false } },
        num_rendermode              = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        num_background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        num_lerp                    = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        num_align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        num_digits                  = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 7, min = 1 },

        icon                        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 6 } },
        icon_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 12 },
        icon_tier_color             = { name = "Use tier colour", type = HOLOHUD2.PARAM_BOOL, value = true },
        icon_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        text                        = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        text_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "COINS" },
        text_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        oversize_size               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        oversize_numberpos          = { name = "#holohud2.parameter.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        oversize_iconpos            = { name = "#holohud2.parameter.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        oversize_textpos            = { name = "#holohud2.parameter.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "autohide", parameters = {
            { id = "autohide_delay" }
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
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" },
                { id = "num_rendermode" },
                { id = "num_background" },
                { id = "num_lerp" },
                { id = "num_align" },
                { id = "num_digits" }
            } },
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" },
                { id = "icon_tier_color" },
                { id = "icon_on_background" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" },
                { id = "text_text" },
                { id = "text_align" },
                { id = "text_on_background" }
            } }
        } },

        { category = "#holohud2.dynamic_sizing", parameters = {
            { id = "oversize_size" },
            { id = "oversize_numberpos" },
            { id = "oversize_iconpos" },
            { id = "oversize_textpos" }
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
            { id = "num", parameters = {
                { id = "num_pos" },
                { id = "num_font" }
            } },
            { id = "icon", parameters = {
                { id = "icon_pos" },
                { id = "icon_size" }
            } },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } }
    }
}

-- Composition
local hudcoins = HOLOHUD2.component.Create( "InsaneStats_HudCoins" )
local layout = HOLOHUD2.layout.Register( "insanestats_coins" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverBackground = function( _, x, y ) hudcoins:PaintBackground( x, y ) end
panel.PaintOver = function( _, x, y ) hudcoins:Paint( x, y ) end
panel.PaintOverScanlines = function( _, x, y ) hudcoins:PaintScanlines( x, y ) end

-- Startup
local startup -- is the element awaiting startup

function ELEMENT_COINS:QueueStartup()

    panel:Close()
    startup = true

end

function ELEMENT_COINS:Startup() startup = false end

-- Logic
local time = 0
local last_coins = 0
function ELEMENT_COINS:PreDraw( settings )

    if startup then return end

    local localplayer = LocalPlayer()
    local curtime = CurTime()
    local coins = localplayer:InsaneStats_GetCoins()

    if last_coins ~= coins then

        hudcoins:SetLastCoinTier( localplayer:InsaneStats_GetLastCoinTier() )
        hudcoins:SetValue( math.floor( coins ) )
        time = curtime + settings.autohide_delay
        last_coins = coins

    end

    -- mimick Insane Stats' behaviour
    if localplayer:KeyDown( IN_WALK ) then

        time = curtime + 1

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or InsaneStats:GetConVarValue( "coins_enabled" ) and ( not settings.autohide or time > curtime ) ) )

    layout:SetSize( settings.size.x + ( settings.oversize_size and hudcoins:GetOversizeOffset() or 0 ), settings.size.y )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudcoins:Think()

end

-- Paint
function ELEMENT_COINS:PaintFrame( settings, x, y ) panel:PaintFrame( x, y ) end
function ELEMENT_COINS:Paint( settings, x, y ) panel:Paint( x, y ) end
function ELEMENT_COINS:PaintBackground( settings, x, y ) panel:PaintBackground( x, y ) end
function ELEMENT_COINS:PaintScanlines( settings, x, y ) panel:PaintScanlines( x, y ) end

-- Preview
local preview_hudcoins = HOLOHUD2.component.Create( "InsaneStats_HudCoins" )

function ELEMENT_COINS:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()
    local w, h = settings.size.x * scale + ( settings.oversize_size and preview_hudcoins:GetOversizeOffset() or 0 ), settings.size.y * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    preview_hudcoins:Think()
    preview_hudcoins:PaintBackground( x, y )
    preview_hudcoins:Paint( x, y )

end

function ELEMENT_COINS:OnPreviewChanged( settings )

    preview_hudcoins:ApplySettings( settings, self.preview_fonts )

    local localplayer = LocalPlayer()
    preview_hudcoins:SetValue( math.floor( localplayer:InsaneStats_GetCoins() ) )
    preview_hudcoins:SetLastCoinTier( localplayer:InsaneStats_GetLastCoinTier() )

end

-- Apply settings
function ELEMENT_COINS:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetDirection( settings.direction )
    layout:SetMargin( settings.margin )
    layout:SetOrder( settings.order )

    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )

    hudcoins:ApplySettings( settings, self.fonts )

end

--- Screen size changed
function ELEMENT_COINS:OnScreenSizeChanged()

    panel:PerformLayout( true )
    hudcoins:InvalidateLayout()

end


HOLOHUD2.element.Register( "insanestats_coins", ELEMENT_COINS )

-- Add common parameters to modifiers
HOLOHUD2.modifier.Add( "panel_animation", "insanestats_coins", "animation" )
HOLOHUD2.modifier.Add( "background", "insanestats_coins", "background" )
HOLOHUD2.modifier.Add( "background_color", "insanestats_coins", "background_color" )
HOLOHUD2.modifier.Add( "color", "insanestats_coins", "color" )
HOLOHUD2.modifier.Add( "color2", "insanestats_coins", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "insanestats_coins", "num_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "insanestats_coins", "num_background" )
HOLOHUD2.modifier.Add( "number2_font", "insanestats_coins", "num_font" )
HOLOHUD2.modifier.Add( "number2_offset", "insanestats_coins", "num_pos" )
HOLOHUD2.modifier.Add( "text_font", "insanestats_coins", "text_font" )
HOLOHUD2.modifier.Add( "text_offset", "insanestats_coins", "text_pos" )

-- Presets
HOLOHUD2.presets.Register( "insanestats_coins", "element/insanestats_coins" )

---
--- Experience bar
---
local ELEMENT_EXPERIENCE = {
    name        = "#holohud2.insane_stats_exp",
    helptext    = "#holohud2.insane_stats_exp.helptext",
    parameters  = {
        autohide                    = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = false },
        autohide_delay              = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 32 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 156, y = 30 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 172, 255, 172 ) },
        color2                      = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        nums                        = { name = "##holohud2.insane_stats_exp.numbers", type = HOLOHUD2.PARAM_BOOL, value = true },
        nums_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 152, y = 2 } },
        nums_spacing                = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        nums_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },

        num                         = { name = "#holohud2.insane_stats_exp.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        num_font                    = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false } },
        num_rendermode              = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        num_background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        num_lerp                    = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        num_align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        num_digits                  = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        separator                   = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_offset            = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 3 },
        separator_is_rect           = { name = "#holohud2.parameter.separator_is_rect", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_size              = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 1, y = 9 } },
        separator_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },

        num2                        = { name = "#holohud2.insane_stats_exp.next_exp", type = HOLOHUD2.PARAM_BOOL, value = true },
        num2_offset                 = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        num2_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        num2_rendermode             = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        num2_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_NONE },
        num2_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        num2_digits                 = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        progressbar                 = { name = "#holohud2.insane_stats_exp.bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        progressbar_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 20 } },
        progressbar_size            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 151, y = 6 }, min_x = 1, min_y = 1 },
        progressbar_style           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        progressbar_growdirection   = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        progressbar_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        progressbar_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        level                       = { name = "#holohud2.insane_stats_exp.level", type = HOLOHUD2.PARAM_BOOL, value = true },
        level_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        level_font                  = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false } },
        level_align                 = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        level_on_background         = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "autohide", parameters = {
            { id = "autohide_delay" }
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
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "nums", parameters = {
                { id = "nums_pos" },
                { id = "nums_spacing" },
                { id = "nums_align" },

                { id = "num", parameters = {
                    { id = "num_font" },
                    { id = "num_rendermode" },
                    { id = "num_background" },
                    { id = "num_lerp" },
                    { id = "num_align" },
                    { id = "num_digits" }
                } },

                { id = "separator", parameters = {
                    { id = "separator_offset" },
                    { id = "separator_is_rect" },
                    { id = "separator_size" },
                    { id = "separator_font" }
                } },

                { id = "num2", parameters = {
                    { id = "num2_offset" },
                    { id = "num2_font" },
                    { id = "num2_rendermode" },
                    { id = "num2_background" },
                    { id = "num2_lerp" },
                    { id = "num2_align" },
                    { id = "num2_digits" }
                } },
            } },

            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" },
                { id = "progressbar_style" },
                { id = "progressbar_growdirection" },
                { id = "progressbar_background" },
                { id = "progressbar_lerp" }
            } },

            { id = "level", parameters = {
                { id = "level_pos" },
                { id = "level_font" },
                { id = "level_align" },
                { id = "level_on_background" }
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
            { id = "nums", parameters = {
                { id = "nums_pos" },

                { id = "num", parameters = {
                    { id = "num_font" }
                } },

                { id = "separator", parameters = {
                    { id = "separator_offset" }
                } },

                { id = "num2", parameters = {
                    { id = "num2_offset" },
                    { id = "num2_font" }
                } },
            } },

            { id = "progressbar", parameters = {
                { id = "progressbar_pos" },
                { id = "progressbar_size" }
            } },

            { id = "level", parameters = {
                { id = "level_pos" },
                { id = "level_font" }
            } }
        } }
    }
}

-- Composition
local hudexperience = HOLOHUD2.component.Create( "InsaneStats_HudExperience" )
local layout = HOLOHUD2.layout.Register( "insanestats_experience" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverBackground = function( _, x, y ) hudexperience:PaintBackground( x, y ) end
panel.PaintOver = function( _, x, y ) hudexperience:Paint( x, y ) end
panel.PaintOverScanlines = function( _, x, y ) hudexperience:PaintScanlines( x, y ) end

-- Startup
local startup -- is the element awaiting startup

function ELEMENT_EXPERIENCE:QueueStartup()

    panel:Close()
    startup = true

end

function ELEMENT_EXPERIENCE:Startup() startup = false end

-- Logic
local time = 0
local last_exp = 0
function ELEMENT_EXPERIENCE:PreDraw( settings )

    if startup then return end

    local localplayer = LocalPlayer()
    local curtime = CurTime()
    local data = InsaneStats:GetXPInfo()

    if last_exp ~= data.current then

        time = curtime + settings.autohide_delay
        last_exp = data.current

    end

    -- mimick Insane Stats' behaviour
    if localplayer:KeyDown( IN_WALK ) then

        time = curtime + 1

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and ( self:IsInspecting() or localplayer:KeyDown( IN_SCORE ) or InsaneStats:GetConVarValue( "xp_enabled" ) and ( not settings.autohide or time > curtime ) ) )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudexperience:SetLevel( data.level )
    hudexperience:SetExperience( data.current )
    hudexperience:SetMaxExperience( data.required )
    hudexperience:Think()

end

-- Paint
function ELEMENT_EXPERIENCE:PaintFrame( settings, x, y ) panel:PaintFrame( x, y ) end
function ELEMENT_EXPERIENCE:Paint( settings, x, y ) panel:Paint( x, y ) end
function ELEMENT_EXPERIENCE:PaintBackground( settings, x, y ) panel:PaintBackground( x, y ) end
function ELEMENT_EXPERIENCE:PaintScanlines( settings, x, y ) panel:PaintScanlines( x, y ) end

-- Preview
local preview_hudexperience = HOLOHUD2.component.Create( "InsaneStats_HudExperience" )

function ELEMENT_EXPERIENCE:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()
    local w, h = settings.size.x * scale, settings.size.y * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    preview_hudexperience:Think()
    preview_hudexperience:PaintBackground( x, y )
    preview_hudexperience:Paint( x, y )

end

function ELEMENT_EXPERIENCE:OnPreviewChanged( settings )

    preview_hudexperience:ApplySettings( settings, self.preview_fonts )

    local localplayer = LocalPlayer()
    local level = localplayer:InsaneStats_GetLevel()
    local previous_exp = math.floor( InsaneStats:GetConVarValue( "hud_xp_cumulative" ) and 0 or InsaneStats:GetXPRequiredToLevel( level ) )

    preview_hudexperience:SetLevel( level )
    preview_hudexperience:SetExperience( localplayer:InsaneStats_GetXP() - previous_exp )
    preview_hudexperience:SetMaxExperience( localplayer:InsaneStats_GetXPToNextLevel() - previous_exp )

end

-- Apply settings
function ELEMENT_EXPERIENCE:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetDirection( settings.direction )
    layout:SetMargin( settings.margin )
    layout:SetOrder( settings.order )

    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )

    hudexperience:ApplySettings( settings, self.fonts )

end

--- Screen size changed
function ELEMENT_EXPERIENCE:OnScreenSizeChanged()

    panel:PerformLayout( true )
    hudexperience:InvalidateLayout()

end

HOLOHUD2.element.Register( "insanestats_experience", ELEMENT_EXPERIENCE )

-- Add common parameters to modifiers
HOLOHUD2.modifier.Add( "panel_animation", "insanestats_experience", "animation" )
HOLOHUD2.modifier.Add( "background", "insanestats_experience", "background" )
HOLOHUD2.modifier.Add( "background_color", "insanestats_experience", "background_color" )
HOLOHUD2.modifier.Add( "color", "insanestats_experience", "color" )
HOLOHUD2.modifier.Add( "color2", "insanestats_experience", "color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "insanestats_experience", "num_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "insanestats_experience", "num_background" )
HOLOHUD2.modifier.Add( "number_font", "insanestats_experience", { "num_font", "num2_font" } )
HOLOHUD2.modifier.Add( "number_offset", "insanestats_experience", { "nums_pos", "separator_offset", "num2_offset" } )
HOLOHUD2.modifier.Add( "text_font", "insanestats_experience", "level_font" )
HOLOHUD2.modifier.Add( "text_offset", "insanestats_experience", "level_pos" )

-- Presets
HOLOHUD2.presets.Register( "insanestats_experience", "element/insanestats_experience" )
