-- SUGGESTION: add a property to allow for "looping health bar colours"

HOLOHUD2.AddCSLuaFile( "health/hudhealth.lua" )
HOLOHUD2.AddCSLuaFile( "health/hudbattery.lua" )

if SERVER then return end

local CurTime = CurTime
local LocalPlayer = LocalPlayer
local FrameTime = FrameTime
local hook_Call = HOLOHUD2.hook.Call

local SUITDEPLETED_NONE = HOLOHUD2.SUITDEPLETED_NONE
local SUITDEPLETED_HIDE = HOLOHUD2.SUITDEPLETED_HIDE

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.health",
    helptext    = "#holohud2.health.helptext",
    hide        = { "CHudHealth", "CHudBattery" },
    parameters  = {
        healthwarn                              = { name = "#holohud2.health.healthwarn", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.HEALTHWARNANIMATIONS, value = HOLOHUD2.HEALTHWARN_PULSE, helptext = "#holohud2.health.healthwarn.helptext" },
        healthwarn_threshold                    = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_NUMBER, value = 15, min = 0 },
        healthwarn_rate                         = { name = "#holohud2.parameter.rate", type = HOLOHUD2.PARAM_NUMBER, value = .8, min = 0, decimals = 1 },

        autohide                                = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay                          = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        autohide_threshold                      = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_NUMBER, value = 50, min = 0 },

        pos                                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction                               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 32 },

        size                                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 43 } },
        background                              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color                        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction                     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        health_color                            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 162, 72 ), [100] = Color(72, 255, 72) }, fraction = true, gradual = false } },
        health_color2                           = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        healthnum                               = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthnum_pos                           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 56, y = -1 } },
        healthnum_font                          = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 37, weight = 1000, italic = false } },
        healthnum_rendermode                    = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        healthnum_background                    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        healthnum_lerp                          = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        healthnum_align                         = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthnum_digits                        = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        healthbar                               = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_pos                           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 34 } },
        healthbar_size                          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 109, y = 6 }, min_x = 1, min_y = 1 },
        healthbar_style                         = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        healthbar_growdirection                 = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        healthbar_layered                       = { name = "#holohud2.component.percentage_bar.layered", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.component.percentage_bar.layered.helptext" },
        healthbar_dotline                       = { name = "#holohud2.component.percentage_bar.dot_line", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.component.percentage_bar.dot_line.helptext" },
        healthbar_dotline_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 6, y = 29 } },
        healthbar_dotline_size                  = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0 },
        healthbar_dotline_growdirection         = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        healthbar_background                    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_lerp                          = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_damage                        = { name = "#holohud2.health.damage_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_damage_color                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 128, 24, 24 ) },
        healthbar_damage_delay                  = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 0 },
        healthbar_damage_speed                  = { name = "#holohud2.parameter.speed", type = HOLOHUD2.PARAM_NUMBER, value = 1, min = 0 },

        healthicon                              = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        healthicon_pos                          = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 35, y = 9 } },
        healthicon_size                         = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 16 },
        healthicon_style                        = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.HEALTHICONS, value = HOLOHUD2.HEALTHICON_CROSS },
        healthicon_rendermode                   = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ICONRENDERMODES, value = HOLOHUD2.ICONRENDERMODE_STATIC },
        healthicon_background                   = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthicon_lerp                         = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        healthpulse                             = { name = "#holohud2.health.ecg", type = HOLOHUD2.PARAM_BOOL, value = false },
        healthpulse_pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        healthpulse_size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 48, y = 24 }, min_x = 1, min_y = 1 },
        healthpulse_style                       = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ECGANIMATIONS, value = HOLOHUD2.ECGANIMATION_GAME },
        healthpulse_brackets                    = { name = "#holohud2.health.ecg_brackets", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthpulse_brackets_margin             = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 6 },
        healthpulse_brackets_offset             = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = -3 },
        healthpulse_on_background               = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        healthtext                              = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        healthtext_pos                          = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        healthtext_font                         = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        healthtext_text                         = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#Valve_Hud_HEALTH" },
        healthtext_align                        = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        healthtext_on_background                = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        health_oversize_size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        health_oversize_numberpos               = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_oversize_progressbarpos          = { name = "#holohud2.health.healthbar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_oversize_progressbarsize         = { name = "#holohud2.health.healthbar_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        health_oversize_iconpos                 = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_oversize_pulsepos                = { name = "#holohud2.health.ecg_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_oversize_pulsesize               = { name = "#holohud2.health.ecg_size", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_oversize_textpos                 = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false },

        health_suit_oversize_size               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        health_suit_oversize_numberpos          = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_suit_oversize_progressbarpos     = { name = "#holohud2.health.healthbar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_suit_oversize_progressbarsize    = { name = "#holohud2.health.healthbar_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        health_suit_oversize_iconpos            = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_suit_oversize_pulsepos           = { name = "#holohud2.health.ecg_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        health_suit_oversize_pulsesize          = { name = "#holohud2.health.ecg_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        health_suit_oversize_textpos            = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false },

        health_suit_depleted_size               = { name = "#holohud2.health.suit_depleted.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_numberpos          = { name = "#holohud2.health.suit_depleted.number_pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_progressbarpos     = { name = "#holohud2.health.suit_depleted.healthbar_pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_progressbarsize    = { name = "#holohud2.health.suit_depleted.healthbar_size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_iconpos            = { name = "#holohud2.health.suit_depleted.icon_pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_pulsepos           = { name = "#holohud2.health.suit_depleted.ecg_pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_pulsesize          = { name = "#holohud2.health.suit_depleted.ecg_size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        health_suit_depleted_textpos            = { name = "#holohud2.health.suit_depleted.text_pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },

        suit_depleted                           = { name = "#holohud2.health.suit_depleted", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.SUITDEPLETED, value = HOLOHUD2.SUITDEPLETED_TURNOFF },
        suit_separate                           = { name = "#holohud2.parameter.standalone", type = HOLOHUD2.PARAM_BOOL, value = false },

        suit_autohide                           = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        suit_autohide_delay                     = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4 },

        suit_pos                                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        suit_dock                               = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        suit_direction                          = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        suit_margin                             = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        suit_order                              = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_NUMBER, value = 40 },

        suit_size                               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 59, y = 42 } },
        suit_background                         = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        suit_background_color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        suit_animation                          = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        suit_animation_direction                = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        suit_color                              = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 92, 163, 255 ) }, fraction = true, gradual = false } },
        suit_color2                             = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        suitnum                                 = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitnum_pos                             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 24, y = 6 } },
        suitnum_font                            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 22, weight = 1000, italic = false } },
        suitnum_rendermode                      = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        suitnum_background                      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        suitnum_lerp                            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        suitnum_align                           = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        suitnum_digits                          = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        suitbar                                 = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = false },
        suitbar_pos                             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 3, y = 5 } },
        suitbar_size                            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 24 }, min_x = 1, min_y = 1 },
        suitbar_style                           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        suitbar_growdirection                   = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },
        suitbar_layered                         = { name = "#holohud2.component.percentage_bar.layered", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.component.percentage_bar.layered.helptext" },
        suitbar_dotline                         = { name = "#holohud2.component.percentage_bar.dot_line", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.component.percentage_bar.dot_line.helptext" },
        suitbar_dotline_pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 1, y = 5 } },
        suitbar_dotline_size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0 },
        suitbar_dotline_growdirection           = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },
        suitbar_background                      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_lerp                            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        suiticon                                = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        suiticon_pos                            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 9, y = 6 } },
        suiticon_size                           = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 22 },
        suiticon_style                          = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.SUITBATTERYICONS, value = HOLOHUD2.SUITBATTERYICON_SILHOUETTE },
        suiticon_rendermode                     = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.ICONRENDERMODES, value = HOLOHUD2.ICONRENDERMODE_PROGRESS },
        suiticon_background                     = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        suiticon_lerp                           = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        suittext                                = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        suittext_pos                            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 24, y = 2 } },
        suittext_font                           = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        suittext_text                           = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#Valve_Hud_SUIT" },
        suittext_align                          = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        suittext_on_background                  = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        suit_oversize_size                      = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        suit_oversize_numberpos                 = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_oversize_progressbarpos            = { name = "#holohud2.health.suitbar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_oversize_progressbarsize           = { name = "#holohud2.health.suitbar_size", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_oversize_iconpos                   = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_oversize_textpos                   = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false },

        suit_health_oversize_numberpos          = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_health_oversize_progressbarpos     = { name = "#holohud2.health.suitbar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_health_oversize_progressbarsize    = { name = "#holohud2.health.suitbar_size", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_health_oversize_iconpos            = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        suit_health_oversize_textpos            = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { tab = "#holohud2.health.tab.health", icon = "icon16/heart.png", parameters = {
            { id = "healthwarn", parameters = {
                { id = "healthwarn_threshold" },
                { id = "healthwarn_rate" }
            } },

            { category = "#holohud2.category.panel", parameters = {
                { id = "autohide", parameters = {
                    { id = "autohide_delay" },
                    { id = "autohide_threshold" }
                } },

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
                { id = "health_color" },
                { id = "health_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "healthnum", parameters = {
                    { id = "healthnum_pos" },
                    { id = "healthnum_font" },
                    { id = "healthnum_rendermode" },
                    { id = "healthnum_background" },
                    { id = "healthnum_lerp" },
                    { id = "healthnum_align" },
                    { id = "healthnum_digits" }
                } },
                { id = "healthbar", parameters = {
                    { id = "healthbar_pos" },
                    { id = "healthbar_size" },
                    { id = "healthbar_style" },
                    { id = "healthbar_growdirection" },
                    { id = "healthbar_layered", parameters = {
                        { id = "healthbar_dotline", parameters = {
                            { id = "healthbar_dotline_pos" },
                            { id = "healthbar_dotline_size" },
                            { id = "healthbar_dotline_growdirection" }
                        } }
                    } },
                    { id = "healthbar_background" },
                    { id = "healthbar_lerp" },
                    { id = "healthbar_damage", parameters = {
                        { id = "healthbar_damage_color" },
                        { id = "healthbar_damage_delay" },
                        { id = "healthbar_damage_speed" }
                    } },
                } },
                { id = "healthicon", parameters = {
                    { id = "healthicon_pos" },
                    { id = "healthicon_size" },
                    { id = "healthicon_style" },
                    { id = "healthicon_rendermode", parameters = {
                        { id = "healthicon_background" }
                    } },
                    { id = "healthicon_lerp" }
                } },
                { id = "healthpulse", parameters = {
                    { id = "healthpulse_pos" },
                    { id = "healthpulse_size" },
                    { id = "healthpulse_style" },
                    { id = "healthpulse_brackets", parameters = {
                        { id = "healthpulse_brackets_margin" },
                        { id = "healthpulse_brackets_offset" }
                    } },
                    { id = "healthpulse_on_background" }
                } },
                { id = "healthtext", parameters = {
                    { id = "healthtext_pos" },
                    { id = "healthtext_font" },
                    { id = "healthtext_text" },
                    { id = "healthtext_align" },
                    { id = "healthtext_on_background" }
                } }
            } },

            { category = "#holohud2.dynamic_sizing", helptext = "#holohud2.dynamic_sizing.helptext", parameters = {
                { id = "health_oversize_size" },
                { id = "health_oversize_numberpos" },
                { id = "health_oversize_progressbarpos" },
                { id = "health_oversize_progressbarsize" },
                { id = "health_oversize_iconpos" },
                { id = "health_oversize_pulsepos" },
                { id = "health_oversize_pulsesize" },
                { id = "health_oversize_textpos" }
            } },

            { category = "#holohud2.health.category.suit_oversize", helptext = "#holohud2.health.category.suit_oversize.helptext", parameters = {
                { id = "health_suit_oversize_size" },
                { id = "health_suit_oversize_numberpos" },
                { id = "health_suit_oversize_progressbarpos" },
                { id = "health_suit_oversize_progressbarsize" },
                { id = "health_suit_oversize_iconpos" },
                { id = "health_suit_oversize_pulsepos" },
                { id = "health_suit_oversize_pulsesize" },
                { id = "health_suit_oversize_textpos" }
            } },

            { category = "#holohud2.health.category.suit_depleted", helptext = "#holohud2.health.category.suit_depleted.helptext", parameters = {
                { id = "health_suit_depleted_size" },
                { id = "health_suit_depleted_numberpos" },
                { id = "health_suit_depleted_progressbarpos" },
                { id = "health_suit_depleted_progressbarsize" },
                { id = "health_suit_depleted_iconpos" },
                { id = "health_suit_depleted_pulsepos" },
                { id = "health_suit_depleted_pulsesize" },
                { id = "health_suit_depleted_textpos" }
            } }
        } },

        { tab = "#holohud2.health.tab.suit", icon = "icon16/shield.png", parameters = {
            { id = "suit_depleted" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "suit_separate", parameters = {
                    { id = "suit_autohide", parameters = {
                        { id = "suit_autohide_delay" }
                    } },
                    { id = "suit_pos", parameters = {
                        { id = "suit_dock" },
                        { id = "suit_direction" },
                        { id = "suit_margin" },
                        { id = "suit_order" }
                    } },
                    { id = "suit_size" },
                    { id = "suit_background", parameters = {
                        { id = "suit_background_color" }
                    } },
                    { id = "suit_animation", parameters = {
                        { id = "suit_animation_direction" }
                    } }
                } }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "suit_color" },
                { id = "suit_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "suitnum", parameters = {
                    { id = "suitnum_pos" },
                    { id = "suitnum_font" },
                    { id = "suitnum_rendermode" },
                    { id = "suitnum_background" },
                    { id = "suitnum_lerp" },
                    { id = "suitnum_align" },
                    { id = "suitnum_digits" }
                } },
                { id = "suitbar", parameters = {
                    { id = "suitbar_pos" },
                    { id = "suitbar_size" },
                    { id = "suitbar_style" },
                    { id = "suitbar_growdirection" },
                    { id = "suitbar_layered", parameters = {
                        { id = "suitbar_dotline", parameters = {
                            { id = "suitbar_dotline_pos" },
                            { id = "suitbar_dotline_size" },
                            { id = "suitbar_dotline_growdirection" }
                        } }
                    } },
                    { id = "suitbar_background" },
                    { id = "suitbar_lerp" }
                } },
                { id = "suiticon", parameters = {
                    { id = "suiticon_pos" },
                    { id = "suiticon_size" },
                    { id = "suiticon_style" },
                    { id = "suiticon_rendermode", parameters = {
                        { id = "suiticon_background" }
                    } },
                    { id = "suiticon_lerp" }
                } },
                { id = "suittext", parameters = {
                    { id = "suittext_pos" },
                    { id = "suittext_font" },
                    { id = "suittext_text" },
                    { id = "suittext_align" },
                    { id = "suittext_on_background" }
                } }
            } },

            { category = "#holohud2.dynamic_sizing", helptext = "#holohud2.dynamic_sizing.helptext", parameters = {
                { id = "suit_oversize_size" },
                { id = "suit_oversize_numberpos" },
                { id = "suit_oversize_progressbarpos" },
                { id = "suit_oversize_progressbarsize" },
                { id = "suit_oversize_iconpos" },
                { id = "suit_oversize_textpos" }
            } },

            { category = "#holohud2.health.category.health_oversize", helptext = "#holohud2.health.category.health_oversize.helptext", parameters = {
                { id = "suit_health_oversize_numberpos" },
                { id = "suit_health_oversize_progressbarpos" },
                { id = "suit_health_oversize_progressbarsize" },
                { id = "suit_health_oversize_iconpos" },
                { id = "suit_health_oversize_textpos" }
            } }
        } }
    },
    quickmenu = {
        { tab = "#holohud2.health.tab.health", icon = "icon16/heart.png", parameters = {
            { id = "autohide" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "pos" },
                { id = "size" }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "health_color" },
                { id = "health_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "healthnum", parameters = {
                    { id = "healthnum_pos" },
                    { id = "healthnum_font" }
                } },
                { id = "healthbar", parameters = {
                    { id = "healthbar_pos" },
                    { id = "healthbar_size" }
                } },
                { id = "healthicon", parameters = {
                    { id = "healthicon_pos" },
                    { id = "healthicon_size" }
                } },
                { id = "healthpulse", parameters = {
                    { id = "healthpulse_pos" },
                    { id = "healthpulse_size" }
                } },
                { id = "healthtext", parameters = {
                    { id = "healthtext_pos" },
                    { id = "healthtext_font" }
                } }
            } }
        } },

        { tab = "#holohud2.health.tab.suit", icon = "icon16/shield.png", parameters = {
            { category = "#holohud2.category.panel", parameters = {
                { id = "suit_separate" },
                { id = "suit_autohide" },
                { id = "suit_pos" },
                { id = "suit_size" }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "suit_color" },
                { id = "suit_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "suitnum", parameters = {
                    { id = "suitnum_pos" },
                    { id = "suitnum_font" }
                } },

                { id = "suitbar", parameters = {
                    { id = "suitbar_pos" },
                    { id = "suitbar_size" }
                } },

                { id = "suiticon", parameters = {
                    { id = "suiticon_pos" },
                    { id = "suiticon_size" }
                } },

                { id = "suittext", parameters = {
                    { id = "suittext_pos" },
                    { id = "suittext_font" }
                } }
            } }
        } }
    }
}

---
--- Health
---
local hudhealth         = HOLOHUD2.component.Create( "HudHealth" )
local health_layout     = HOLOHUD2.layout.Register( "health" )
local health_panel      = HOLOHUD2.component.Create( "AnimatedPanel" )
health_panel:SetLayout( health_layout )

health_panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawHealth", x, y, self._w, self._h, LAYER_FRAME )

end

---
--- Suit battery
---
local hudbattery        = HOLOHUD2.component.Create( "HudBattery" )
local suit_layout       = HOLOHUD2.layout.Register( "suitbattery" )
local suit_panel        = HOLOHUD2.component.Create( "AnimatedPanel" )
suit_panel:SetLayout( suit_layout )

suit_panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawArmor", x, y, self._w, self._h, LAYER_FRAME )

end

suit_panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawArmor", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudbattery:PaintBackground( x, y )

    hook_Call( "DrawOverArmor", x, y, self._w, self._h, LAYER_BACKGROUND, hudbattery )

end

suit_panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawArmor", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudbattery:Paint( x, y )

    hook_Call( "DrawOverArmor", x, y, self._w, self._h, LAYER_FOREGROUND, hudbattery )

end

suit_panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawArmor", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudbattery:PaintScanlines( x, y )

    hook_Call( "DrawOverArmor", x, y, self._w, self._h, LAYER_SCANLINES, hudbattery )

end

---
--- Connect component oversize
---
hudhealth.OnOversizeTransformApplied = function( _, offset )

    hudbattery:ApplyHealthOversizeTransform( offset )

end
hudbattery.OnOversizeTransformApplied = function( _, offset )

    hudhealth:ApplySuitOversizeTransform( offset )

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

    health_panel:Close()
    hudhealth:SetValue( 0 )
    hudhealth:SetDamage( 0 )

    suit_panel:Close()
    hudbattery:SetValue( 0 )

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

    return "#holohud2.health.startup"

end

function ELEMENT:DoStartupSequence( settings, curtime )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    hudhealth:SetMaxValue( localplayer:GetMaxHealth() )
    hudbattery:SetMaxValue( localplayer:GetMaxArmor() )

    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_FILL then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            hudbattery:SetOnDepleted( settings.suit_depleted )

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    local armor = localplayer:Armor()

    if startup_phase == STARTUP_EMPTY then

        hudbattery:SetOnDepleted( armor > 0 and SUITDEPLETED_NONE or settings.suit_depleted )

    elseif startup_phase == STARTUP_FILL then

        local health = localplayer:Health()
        local anim = ( 1 - ( next_startup_phase - curtime ) / STARTUP_TIMINGS[ startup_phase ] ) * 3

        hudhealth:SetValue( math.min( math.ceil( anim * health ), health ) )
        hudbattery:SetValue( math.min( math.ceil( anim * armor ), armor ) )

    end

    hudhealth:Think()
    hudbattery:Think()

    health_panel:Think()
    health_panel:SetDeployed( true )

    health_layout:SetSize( settings.size.x + ( settings.health_oversize_size and hudhealth:GetOversizeOffset() or 0 ) + ( not settings.suit_separate and hudbattery:GetOversizeOffset() or 0 ), settings.size.y )
    health_layout:SetVisible( health_panel:IsVisible() )

    if not settings.suit_separate then return true end

    suit_panel:Think()
    suit_panel:SetDeployed( true )

    suit_layout:SetSize( settings.suit_size.x + hudbattery:GetOversizeOffset(), settings.suit_size.y )
    suit_layout:SetVisible( suit_panel:IsVisible() )

    return true

end

---
--- Logic
---
local healthtime, armortime = 0, 0
local _health, _armor = 100, 0
function ELEMENT:PreDraw( settings )

    localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()
    local is_minimized, is_inspecting, is_peeking = self:IsMinimized(), self:IsInspecting(), localplayer:KeyDown( IN_SCORE )

    -- startup sequence
    if self:DoStartupSequence( settings, curtime ) then return end

    -- health
    local health, max_health = localplayer:Health(), localplayer:GetMaxHealth()
    local armor, max_armor = localplayer:Armor(), localplayer:GetMaxArmor()

    if _health ~= health then

        healthtime = curtime + settings.autohide_delay
        _health = health

    end

    -- accelerate heart rate if we sprint
    if localplayer:OnGround() and localplayer:IsSprinting() and hudhealth.Pulse.pain < .8 then

        hudhealth.Pulse:SetPain( hudhealth.Pulse.pain + FrameTime() / 8 )

    end

    health_panel:Think()
    health_panel:SetDeployed( not is_minimized and ( is_inspecting or is_peeking or not settings.autohide or healthtime > curtime or health <= settings.autohide_threshold ) )

    if health_panel:IsVisible() then

        local w, h = 0, 0

        if armor <= 0 and settings.suit_depleted == SUITDEPLETED_HIDE and not settings.suit_separate then

            w, h = settings.health_suit_depleted_size.x, settings.health_suit_depleted_size.y
            hudhealth:SetSuitDepleted( true )

        else

            hudhealth:SetSuitDepleted( false )

        end

        health_layout:SetSize( settings.size.x + hudhealth:GetOversizeOffset() + ( not settings.suit_separate and settings.health_suit_oversize_size and hudbattery:GetOversizeOffset() or 0 ) + w, settings.size.y + h )
        health_layout:SetVisible( true )

        hudhealth:SetMaxValue( max_health )
        hudhealth:SetValue( math.max( health, 0 ) )
        hudhealth:Think()

        if not settings.suit_separate then

            hudbattery:SetMaxValue( max_armor )
            hudbattery:SetValue( armor )
            hudbattery:Think()

        end

    else

        health_layout:SetVisible( false )

    end

    -- suit battery
    if _armor ~= armor then

        if not settings.suit_separate then

            healthtime = curtime + settings.autohide_delay

        end

        armortime = curtime + settings.suit_autohide_delay
        _armor = armor

    end

    if not settings.suit_separate then return end

    suit_panel:Think()
    suit_panel:SetDeployed( not is_minimized and ( is_inspecting or is_peeking or ( armor > 0 or settings.suit_depleted ~= SUITDEPLETED_HIDE ) and ( not settings.suit_autohide or armortime > curtime ) ) )

    if suit_panel:IsVisible() then

        suit_layout:SetSize( settings.suit_size.x + ( settings.suit_oversize_size and hudbattery:GetOversizeOffset() or 0 ), settings.suit_size.y )
        suit_layout:SetVisible( true )

        hudbattery:SetMaxValue( max_armor )
        hudbattery:SetValue( armor )
        hudbattery:Think()

    else

        suit_layout:SetVisible( false )

    end

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    health_panel:PaintFrame( x, y )

    if not settings.suit_separate then return end

    suit_panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )

    health_panel:PaintBackground( x, y )

    if not settings.suit_separate then return end

    suit_panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )

    if startup_phase == STARTUP_STANDBY then return end

    health_panel:Paint( x, y )

    if not settings.suit_separate then return end

    suit_panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    if startup_phase == STARTUP_STANDBY then return end

    health_panel:PaintScanlines( x, y )

    if not settings.suit_separate then return end

    suit_panel:PaintScanlines( x, y )

end

---
--- Preview
---
local preview_hudhealth = HOLOHUD2.component.Create( "HudHealth" )
local preview_hudbattery = HOLOHUD2.component.Create( "HudBattery" )

preview_hudhealth:SetValue( 100 )
preview_hudhealth:SetMaxValue( 100 )
preview_hudbattery:SetValue( 0 )
preview_hudbattery:SetMaxValue( 100 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudhealth:ApplySettings( settings, self.preview_fonts )
    preview_hudbattery:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 130, 42 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() - 4 )

        local health = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", controls )
        health:SetIcon( "icon16/heart.png" )
        health:Dock( TOP )
        health:SetTall( 22 )
        health:SetMinMax( 0, 2147483647 )
        health:SetValue( preview_hudhealth.value )
        health:SetMaxValue( preview_hudhealth.max_value )
        health.OnValueChanged = function( _, value )

            preview_hudhealth:SetValue( value )

        end
        health.OnMaxValueChanged = function( _, value )

            preview_hudhealth:SetMaxValue( value )

        end

        local armor = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", controls )
        armor:SetIcon( "icon16/shield.png" )
        armor:Dock( TOP )
        armor:SetMinMax( 0, 2147483647 )
        armor:SetValue( preview_hudbattery.value )
        armor:SetMaxValue( preview_hudbattery.max_value )
        armor.OnValueChanged = function( _, value )

            preview_hudbattery:SetValue( value )

        end
        armor.OnMaxValueChanged = function( _, value )

            preview_hudbattery:SetMaxValue( value )

        end

        local reset = vgui.Create( "DImageButton", panel )
        reset:SetSize( 16, 16 )
        reset:SetPos( controls:GetWide() + 4, panel:GetTall() - reset:GetTall() - 5 )
        reset:SetImage( "icon16/arrow_refresh.png" )
        reset.DoClick = function()

            health:SetValue( 100 )
            health:SetMaxValue( 100 )
            armor:SetValue( 0 )
            armor:SetMaxValue( 100 )

        end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()

    local w, h = ( settings.size.x + preview_hudhealth:GetOversizeOffset() ) * scale, settings.size.y * scale
    local w2, h2 = preview_hudbattery:GetOversizeOffset(), 0

    if settings.suit_separate then

        w2, h2 = ( settings.suit_size.x + w2 ) * scale, settings.suit_size.y * scale

        if settings.suit_depleted ~= SUITDEPLETED_HIDE or preview_hudbattery.value > 0 then

            x = x - w2 / 2

        end

    else

        w = w + w2 * scale

        if settings.suit_depleted == SUITDEPLETED_HIDE and preview_hudbattery.value <= 0 then

            w = w + settings.health_suit_depleted_size.x * scale
            h = h + settings.health_suit_depleted_size.y * scale
            preview_hudhealth:SetSuitDepleted( true )

        else

            preview_hudhealth:SetSuitDepleted( false )

        end

    end

    x, y = x - w / 2, y - h / 2

    preview_hudhealth:Think()
    preview_hudbattery:Think()

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( wireframe_color )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudhealth:PaintBackground( x, y )
    preview_hudhealth:Paint( x, y )

    if settings.suit_depleted == SUITDEPLETED_HIDE and preview_hudbattery.value <= 0 then return end

    if settings.suit_separate then

        x = x + w + 4 * scale

        if settings.suit_background then

            draw.RoundedBox( 0, x, y, w2, h2, settings.suit_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w2, h2 )

    end

    preview_hudbattery:PaintBackground( x, y )
    preview_hudbattery:Paint( x, y )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        health_layout:SetVisible( false )
        suit_layout:SetVisible( false )

        return

    end

    -- health properties
    health_layout:SetPos( settings.pos.x, settings.pos.y )
    health_layout:SetSize( settings.size.x, settings.size.y )
    health_layout:SetDock( settings.dock )
    health_layout:SetMargin( settings.margin )
    health_layout:SetDirection( settings.direction )
    health_layout:SetOrder( settings.order )

    health_panel:SetAnimation( settings.animation )
    health_panel:SetAnimationDirection( settings.animation_direction )
    health_panel:SetDrawBackground( settings.background )
    health_panel:SetColor( settings.background_color )

    hudhealth:ApplySettings( settings, self.fonts )

    health_panel.PaintOverBackground = function( self, x, y )

        if not hook_Call( "DrawHealth", x, y, self._w, self._h, LAYER_BACKGROUND ) then

            hudhealth:PaintBackground( x, y )
            hook_Call( "DrawOverHealth", x, y, self._w, self._h, LAYER_BACKGROUND, hudhealth )

        end

        if settings.suit_separate then return end
        if hook_Call( "DrawArmor", x, y, suit_panel._w, suit_panel._h, LAYER_BACKGROUND ) then return end

        hudbattery:PaintBackground( x, y )
        hook_Call( "DrawOverArmor", x, y, suit_panel._w, suit_panel._h, LAYER_BACKGROUND )

    end

    health_panel.PaintOver = function( self, x, y )

        if not hook_Call( "DrawHealth", x, y, self._w, self._h, LAYER_FOREGROUND ) then

            hudhealth:Paint( x, y )
            hook_Call( "DrawOverHealth", x, y, self._w, self._h, LAYER_FOREGROUND, hudhealth )

        end

        if settings.suit_separate then return end
        if hook_Call( "DrawArmor", x, y, suit_panel._w, suit_panel._h, LAYER_FOREGROUND ) then return end

        hudbattery:Paint( x, y )
        hook_Call( "DrawOverArmor", x, y, suit_panel._w, suit_panel._h, LAYER_FOREGROUND, hudhealth )

    end

    health_panel.PaintOverScanlines = function( self, x, y )

        if not hook_Call( "DrawHealth", x, y, self._w, self._h, LAYER_SCANLINES ) then

            hudhealth:PaintScanlines( x, y )
            hook_Call( "DrawOverHealth", x, y, self._w, self._h, LAYER_SCANLINES, hudhealth )

        end

        if settings.suit_separate then return end
        if hook_Call( "DrawArmor", x, y, suit_panel._w, suit_panel._h, LAYER_SCANLINES ) then return end

        hudbattery:PaintScanlines( x, y )
        hook_Call( "DrawOverArmor", x, y, suit_panel._w, suit_panel._h, LAYER_SCANLINES )

    end

    -- suit battery properties
    suit_layout:SetPos( settings.suit_pos.x, settings.suit_pos.y )
    suit_layout:SetSize( settings.suit_size.x, settings.suit_size.y )
    suit_layout:SetDock( settings.suit_dock )
    suit_layout:SetMargin( settings.suit_margin )
    suit_layout:SetDirection( settings.suit_direction )
    suit_layout:SetOrder( settings.suit_order )

    suit_panel:SetAnimation( settings.suit_animation )
    suit_panel:SetAnimationDirection( settings.suit_animation_direction )
    suit_panel:SetDrawBackground( settings.suit_background )
    suit_panel:SetColor( settings.suit_background_color )

    hudbattery:ApplySettings( settings, self.fonts )

    if settings.suit_separate then return end

    suit_panel:SetDeployed( false )
    suit_layout:SetVisible( false )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    health_panel:InvalidateLayout()
    hudhealth:InvalidateLayout()

    suit_panel:InvalidateLayout()
    hudbattery:InvalidateLayout()

end

HOLOHUD2.element.Register( "health", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    health_panel    = health_panel,
    hudhealth       = hudhealth,
    suit_panel      = suit_panel,
    hudbattery      = hudbattery
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "autohide", "health", { "autohide", "suit_autohide" } )
HOLOHUD2.modifier.Add( "panel_animation", "health", { "animation", "suit_animation" } )
HOLOHUD2.modifier.Add( "background", "health", { "background", "suit_background" } )
HOLOHUD2.modifier.Add( "background_color", "health", { "background_color", "suit_background_color" } )
HOLOHUD2.modifier.Add( "color2", "health", { "health_color2", "suit_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "health", { "healthnum_rendermode", "suitnum_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "health", { "healthnum_background", "suitnum_background" } )
HOLOHUD2.modifier.Add( "number_font", "health", "healthnum_font" )
HOLOHUD2.modifier.Add( "number_offset", "health", "healthnum_pos" )
HOLOHUD2.modifier.Add( "number2_font", "health", "suitnum_font" )
HOLOHUD2.modifier.Add( "number2_offset", "health", "suitnum_pos" )
HOLOHUD2.modifier.Add( "text_font", "health", { "healthtext_font", "suittext_font" } )
HOLOHUD2.modifier.Add( "text_pos", "health", { "healthtext_pos", "suittext_pos" } )
HOLOHUD2.modifier.Add( "scale", "health", {
    "pos", "margin", "size",
    "healthnum_pos", "healthnum_font",
    "healthbar_pos", "healthbar_size", "healthbar_dotline_pos", "healthbar_dotline_size",
    "healthicon_pos", "healthicon_size",
    "healthpulse_pos", "healthpulse_size", "healthpulse_brackets_margin", "healthpulse_brackets_offset",
    "healthtext_pos", "healthtext_font",
    "health_suit_depleted_size", "health_suit_depleted_numberpos", "health_suit_depleted_progressbarpos", "health_suit_depleted_progressbarsize", "health_suit_depleted_iconpos", "health_suit_depleted_pulsepos", "health_suit_depleted_pulsesize", "health_suit_depleted_textpos",
    "suit_pos", "suit_margin", "suit_size",
    "suitnum_pos", "suitnum_font",
    "suitbar_pos", "suitbar_size", "suitbar_dotline_pos", "suitbar_dotline_size",
    "suiticon_pos", "suiticon_size",
    "suittext_pos", "suittext_font"
} )

---
--- Register health and suit related item icons
---
HOLOHUD2.item.Register( "item_healthkit", surface.GetTextureID( "holohud2/items/item_healthkit" ), 64, 64, nil, nil, nil, nil, function() return hudhealth.Colors:GetColor() end )
HOLOHUD2.item.Register( "item_battery", surface.GetTextureID( "holohud2/items/item_battery" ), 64, 64, nil, nil, nil, nil, function() return hudbattery.Colors:GetColor() end )
HOLOHUD2.item.Register( "item_healthvial", surface.GetTextureID( "holohud2/items/item_healthvial" ), 64, 64, nil, nil, nil, nil, function() return hudhealth.Colors:GetColor() end )
HOLOHUD2.item.Register( "item_grubnugget", "item_healthvial" )

---
--- Presets
---
HOLOHUD2.presets.Register( "health", "element/health" )
HOLOHUD2.presets.Add( "health", "Classic - Electrocardiogram", {
    size                                    = { x = 152, y = 35 },
    health_suit_oversize_size               = false,
    health_suit_oversize_progressbarsize    = false,
    health_suit_oversize_pulsesize          = false,
    health_suit_depleted_size               = { x = -5, y = 0 },
    health_suit_depleted_numberpos          = { x = -5, y = 0 },
    healthnum_pos                           = { x = 94, y = -1 },
    healthbar                               = false,
    healthpulse                             = true,
    healthpulse_style                       = 2,
    healthpulse_pos                         = { x = 4, y = 5 },
    healthpulse_size                        = { x = 79, y = 24 },
    suitnum_pos                             = { x = 53, y = 2 },
    suitbar                                 = true,
    suitbar_style                           = 5,
    suitbar_pos                             = { x = 86, y = 3 },
    suitbar_size                            = { x = 5, y = 32 },
    suiticon                                = false
} )
HOLOHUD2.presets.Add( "health", "Classic - Electrocardiogram with kevlar", {
    size                                    = { x = 147, y = 35 },
    healthnum_pos                           = { x = 89, y = -1 },
    healthbar                               = false,
    healthpulse                             = true,
    healthpulse_style                       = 2,
    healthpulse_pos                         = { x = 4, y = 5 },
    healthpulse_size                        = { x = 79, y = 24 },
    healthpulse_brackets_offset             = -3,
    health_suit_oversize_size               = false,
    health_suit_oversize_progressbarsize    = false,
    health_suit_oversize_pulsesize          = false,
    suit_depleted                           = 3,
    suit_separate                           = true,
    suit_autohide                           = false,
    suit_size                               = { x = 35, y = 35 },
    suitnum_pos                             = { x = 18, y = 24 },
    suitnum_font                            = { font = "Roboto Condensed Light", size = 12, weight = 1000, italic = false },
    suiticon_style                          = 3,
    suiticon_pos                            = { x = 7, y = 4 }
} )
HOLOHUD2.presets.Add( "health", "Classic - FPS", {
    size                        = { x = 152, y = 35 },
    health_suit_depleted_size   = { x = -69, y = 0 },
    healthnum_font              = { font = "Roboto Condensed", size = 37, weight = 0, italic = false },
    healthnum_pos               = { x = 28, y = -1 },
    healthbar                   = false,
    healthicon                  = true,
    healthicon_pos              = { x = 8, y = 10 },
    suitnum_pos                 = { x = 98, y = -1 },
    suitnum_font                = { font = "Roboto Condensed", size = 37, weight = 0, italic = false },
    suiticon_pos                = { x = 83, y = 5 },
    suiticon_size               = 26
} )
