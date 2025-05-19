HOLOHUD2.AddCSLuaFile( "ammo/hudammo.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudammo1.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudammo2.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudclip.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudclip1.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudclip2.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudfiremode.lua" )
HOLOHUD2.AddCSLuaFile( "ammo/hudquicknades.lua" )

if SERVER then return end

-- SUGGESTION: tray with remaining reserve ammunition of all vanilla (?) types

local IsValid = IsValid
local CurTime = CurTime
local LocalPlayer = LocalPlayer
local hook_Call = HOLOHUD2.hook.Call
local GetWeapon = HOLOHUD2.util.GetWeapon
local GetPrimaryAmmo = HOLOHUD2.util.GetPrimaryAmmo
local GetSecondaryAmmo = HOLOHUD2.util.GetSecondaryAmmo
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local clip2_size, clip2_animation, clip2_animation_direction, clip2_background, clip2_background_color = { x = 0, y = 0 }, 0, 0, true, color_black
local ammo2_size, ammo2_animation, ammo2_animation_direction, ammo2_background, ammo2_background_color = { x = 0, y = 0 }, 0, 0, true, color_black

local ELEMENT = {
    name        = "#holohud2.ammo",
    helptext    = "#holohud2.ammo.helptext",
    hide        = { "CHudAmmo", "CHudSecondaryAmmo" },
    parameters  = {
        autohide                                = { name = "#holohud2.parameter.autohide", type = HOLOHUD2.PARAM_BOOL, value = true },
        autohide_delay                          = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        autohide_threshold                      = { name = "#holohud2.parameter.threshold", type = HOLOHUD2.PARAM_RANGE, value = 0, min = 0, max = 100, helptext = "#holohud2.ammo.autohide_threshold.helptext" },
        
        firemode                                = { name = "#holohud2.ammo.firemode", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.ammo.firemode.helptext" },
        firemode_pos                            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 73, y = 3 } },
        firemode_size                           = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 6 },
        firemode_separate                       = { name = "#holohud2.parameter.standalone", type = HOLOHUD2.PARAM_BOOL, value = false },
        firemode_separate_pos                   = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 62 } },
        firemode_separate_dock                  = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        firemode_separate_direction             = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT },
        firemode_separate_margin                = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 4 },
        firemode_separate_order                 = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 20 },
        firemode_separate_padding               = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 3 } },
        firemode_separate_background            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        firemode_separate_background_color      = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        firemode_separate_animation             = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        firemode_separate_animation_direction   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },
    
        quicknades                              = { name = "#holohud2.ammo.quicknades", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.quicknades.helptext" },
        quicknades_ammotype                     = { name = "#holohud2.ammo.quicknades_ammotype", type = HOLOHUD2.PARAM_OPTION, value = 10, options = game.GetAmmoTypes() },
        quicknades_pos                          = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        quicknades_icon_alt                     = { name = "#holohud2.ammo.quicknades_icon_alt", type = HOLOHUD2.PARAM_BOOL, value = false },
        quicknades_icon_size                    = { name = "#holohud2.ammo.quicknades_icon_size", type = HOLOHUD2.PARAM_NUMBER, value = 11, min = 0 },
        quicknades_num_offset                   = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        quicknades_num_font                     = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 18, weight = 1000, italic = false } },
        quicknades_num_rendermode               = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        quicknades_num_background               = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        quicknades_num_align                    = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        quicknades_num_digits                   = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 1 },
        quicknades_separate                     = { name = "#holohud2.parameter.standalone", type = HOLOHUD2.PARAM_BOOL, value = false },
        quicknades_separate_pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        quicknades_separate_dock                = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        quicknades_separate_direction           = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        quicknades_separate_margin              = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        quicknades_separate_order               = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 256 },
        quicknades_separate_padding             = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 3 } },
        quicknades_separate_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        quicknades_separate_background_color    = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        quicknades_separate_animation           = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        quicknades_separate_animation_direction = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP }
    },
    menu = {
        { id = "autohide", parameters = {
            { id = "autohide_delay" },
            { id = "autohide_threshold" }
        } },
        { id = "firemode", parameters = {
            { id = "firemode_pos" },
            { id = "firemode_size" },
            { id = "firemode_separate", parameters = {
                { id = "firemode_separate_pos", parameters = {
                    { id = "firemode_separate_dock" },
                    { id = "firemode_separate_direction" },
                    { id = "firemode_separate_margin" },
                    { id = "firemode_separate_order" }
                } },
                { id = "firemode_separate_padding" },
                { id = "firemode_separate_background", parameters = {
                    { id = "firemode_separate_background_color" }
                } },
                { id = "firemode_separate_animation", parameters = {
                    { id = "firemode_separate_animation_direction" }
                } }
            } }
        } },
        { id = "quicknades", parameters = {
            { id = "quicknades_ammotype" },
            { id = "quicknades_pos" },
            { id = "quicknades_icon_alt" },
            { id = "quicknades_icon_size" },
            { name = "#holohud2.component.number", parameters = {
                { id = "quicknades_num_offset" },
                { id = "quicknades_num_font" },
                { id = "quicknades_num_rendermode" },
                { id = "quicknades_num_background" },
                { id = "quicknades_num_align" },
                { id = "quicknades_num_digits" }
            } },
            { id = "quicknades_separate", parameters = {
                { id = "quicknades_separate_pos", parameters = {
                    { id = "quicknades_separate_dock" },
                    { id = "quicknades_separate_direction" },
                    { id = "quicknades_separate_margin" },
                    { id = "quicknades_separate_order" },
                } },
                { id = "quicknades_separate_padding" },
                { id = "quicknades_separate_background", parameters = {
                    { id = "quicknades_separate_background_color" }
                } },
                { id = "quicknades_separate_animation", parameters = {
                    { id = "quicknades_separate_animation_direction" }
                } }
            } }
        } }
    },
    quickmenu = {
        { id = "autohide" },
        { id = "firemode", parameters = {
            { id = "firemode_pos" },
            { id = "firemode_size" },
            { id = "firemode_separate", parameters = {
                { id = "firemode_separate_pos" },
                { id = "firemode_separate_padding" }
            } }
        } },
        { id = "quicknades", parameters = {
            { id = "quicknades_ammotype" },
            { id = "quicknades_pos" },
            { id = "quicknades_icon_alt" },
            { id = "quicknades_icon_size" },
            { name = "#holohud2.component.number", parameters = {
                { id = "quicknades_num_offset" },
                { id = "quicknades_num_font" }
            } },
            { id = "quicknades_separate", parameters = {
                { id = "quicknades_separate_pos" },
                { id = "quicknades_separate_padding" }
            } }
        } }
    }
}

function ELEMENT:DefineClip( id, tab, label, order, copy, firemode )

    local parameters = {
        [ id .. "_always" ]                 = { name = "#holohud2.ammo.always", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.always.helptext" },
        
        [ id .. "_pos" ]                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        [ id .. "_dock" ]                   = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        [ id .. "_direction" ]              = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT },
        [ id .. "_margin" ]                 = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        [ id .. "_order" ]                  = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_NUMBER, value = order },
        
        [ id .. "_size" ]                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 46 } },
        [ id .. "_background" ]             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_background_color" ]       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        [ id .. "_animation" ]              = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        [ id .. "_animation_direction" ]    = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },
        
        [ id .. "_color" ]                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color(255, 60, 50), [100] = Color(255, 186, 92) }, fraction = true, gradual = false } },
        [ id .. "_color2" ]                 = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color(255, 255, 255, 12) }, fraction = true, gradual = false } },
        
        [ id .. "num" ]                     = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "num_pos" ]                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = -1 } },
        [ id .. "num_font" ]                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 37, weight = 1000, italic = false } },
        [ id .. "num_rendermode" ]          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        [ id .. "num_background" ]          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        [ id .. "num_lerp" ]                = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "num_align" ]               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        [ id .. "num_digits" ]              = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },
        
        [ id .. "separator" ]               = { name = "#holohud2.component.separator", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "separator_pos" ]           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 60, y = 8 } },
        [ id .. "separator_is_rect" ]       = { name = "#holohud2.parameter.separator_is_rect", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "separator_size" ]          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 1, y = 18 } },
        [ id .. "separator_font" ]          = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 22, weight = 1000, italic = false } },
        
        [ id .. "num2" ]                    = { name = "#holohud2.ammo.num2", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "num2_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 65, y = 6 } },
        [ id .. "num2_font" ]               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 22, weight = 1000, italic = false } },
        [ id .. "num2_rendermode" ]         = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        [ id .. "num2_background" ]         = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        [ id .. "num2_lerp" ]               = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "num2_align" ]              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        [ id .. "num2_digits" ]             = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 1 },
        [ id .. "num2_clips" ]              = { name = "#holohud2.ammo.clips", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.clips.helptext" },

        [ id .. "bar" ]                     = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "bar_pos" ]                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 34 } },
        [ id .. "bar_size" ]                = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 6 }, min_x = 1, min_y = 1 },
        [ id .. "bar_style" ]               = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        [ id .. "bar_growdirection" ]       = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        [ id .. "bar_background" ]          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "bar_smooth" ]              = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        [ id .. "tray" ]                    = { name = "#holohud2.ammo.tray", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "tray_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 3, y = 32 } },
        [ id .. "tray_size" ]               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 110, y = 12 }, min_x = 1, min_y = 1 },
        [ id .. "tray_direction" ]          = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },
        
        [ id .. "icon" ]                    = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "icon_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 84, y = 5 } },
        [ id .. "icon_size" ]               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 14, min = 0 },
        [ id .. "icon_angle" ]              = { name = "#holohud2.parameter.rotation", type = HOLOHUD2.PARAM_RANGE, value = 0, min = 0, max = 360 },
        [ id .. "icon_align" ]              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },

        [ id .. "text" ]                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "text_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        [ id .. "text_font" ]               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        [ id .. "text_text" ]               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = label },
        [ id .. "text_align" ]              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        [ id .. "text_on_background" ]      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        [ id .. "_oversize_size" ]          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_numberpos" ]     = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_ammobarpos" ]    = { name = "#holohud2.dynamic_sizing.percentage_bar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_ammobarsize" ]   = { name = "#holohud2.dynamic_sizing.percentage_bar_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_traypos" ]       = { name = "#holohud2.ammo.tray_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_traysize" ]      = { name = "#holohud2.ammo.tray_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_iconpos" ]       = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_textpos" ]       = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false }
    }

    local menu = { icon = "icon16/gun.png", parameters = {
        { category = "#holohud2.category.panel", parameters = {
            { id = id .. "_always" },
            { id = id .. "_pos", parameters = {
                { id = id .. "_dock" },
                { id = id .. "_direction" },
                { id = id .. "_margin" },
                { id = id .. "_order" }
            } },
            { id = id .. "_size" },
            { id = id .. "_background", parameters = {
                { id = id .. "_background_color" }
            } },
            { id = id .. "_animation", parameters = {
                { id = id .. "_animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = id .. "_color" },
            { id = id .. "_color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = id .. "num", parameters = {
                { id = id .. "num_pos" },
                { id = id .. "num_font" },
                { id = id .. "num_rendermode" },
                { id = id .. "num_background" },
                { id = id .. "num_lerp" },
                { id = id .. "num_align" },
                { id = id .. "num_digits" }
            } },

            { id = id .. "separator", parameters = {
                { id = id .. "separator_pos" },
                { id = id .. "separator_is_rect", parameters = {
                    { id = id .. "separator_size" },
                    { id = id .. "separator_font" }
                } }
            } },

            { id = id .. "num2", parameters = {
                { id = id .. "num2_pos" },
                { id = id .. "num2_font" },
                { id = id .. "num2_rendermode" },
                { id = id .. "num2_background" },
                { id = id .. "num2_lerp" },
                { id = id .. "num2_align" },
                { id = id .. "num2_digits" },
                { id = id .. "num2_clips" }
            } },

            { id = id .. "bar", parameters = {
                { id = id .. "bar_pos" },
                { id = id .. "bar_size" },
                { id = id .. "bar_style" },
                { id = id .. "bar_growdirection" },
                { id = id .. "bar_background" },
                { id = id .. "bar_smooth" }
            } },

            { id = id .. "tray", parameters = {
                { id = id .. "tray_pos" },
                { id = id .. "tray_size" },
                { id = id .. "tray_direction" }
            } },

            { id = id .. "icon", parameters = {
                { id = id .. "icon_pos" },
                { id = id .. "icon_size" },
                { id = id .. "icon_angle" }
            } },

            { id = id .. "text", parameters = {
                { id = id .. "text_pos" },
                { id = id .. "text_font" },
                { id = id .. "text_text" },
                { id = id .. "text_align" },
                { id = id .. "text_on_background" }
            } }
        } },

        { category = "#holohud2.dynamic_sizing", helptext = "#holohud2.dynamic_sizing.helptext", parameters = {
            { id = id .. "_oversize_size" },
            { id = id .. "_oversize_numberpos" },
            { id = id .. "_oversize_ammobarpos" },
            { id = id .. "_oversize_ammobarsize" },
            { id = id .. "_oversize_traypos" },
            { id = id .. "_oversize_traysize" },
            { id = id .. "_oversize_iconpos" },
            { id = id .. "_oversize_textpos" }
        } }
    } }

    local quickmenu = { icon = "icon16/gun.png", parameters = {
        { category = "#holohud2.category.panel", parameters = {
            { id = id .. "_pos" },
            { id = id .. "_size" }
        } },
        
        { category = "#holohud2.category.coloring", parameters = {
            { id = id .. "_color" },
            { id = id .. "_color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = id .. "num", parameters = {
                { id = id .. "num_pos" },
                { id = id .. "num_font" }
            } },
            { id = id .. "separator", parameters = {
                { id = id .. "separator_pos" }
            } },
            { id = id .. "num2", parameters = {
                { id = id .. "num2_pos" },
                { id = id .. "num2_font" }
            } },
            { id = id .. "bar", parameters = {
                { id = id .. "bar_pos" },
                { id = id .. "bar_size" }
            } },
            { id = id .. "tray", parameters = {
                { id = id .. "tray_pos" },
                { id = id .. "tray_size" }
            } },
            { id = id .. "icon", parameters = {
                { id = id .. "icon_pos" },
                { id = id .. "icon_size" }
            } },
            { id = id .. "text", parameters = {
                { id = id .. "text_pos" },
                { id = id .. "text_font" }
            } }
        } }
    } }

    if copy then

        parameters[ id .. "_copy" ] = { name = "#holohud2.ammo.clip1_copy", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.clip1_copy.helptext" }
        table.insert( menu.parameters, 1, { id = id .. "_copy" } )
        table.insert( quickmenu.parameters, 1, { id = id .. "_copy" } )

    end

    if firemode then
        
        parameters[ id .. "_oversize_firemodepos" ] = { name = "#holohud2.ammo.firemode_pos", type = HOLOHUD2.PARAM_BOOL, value = true }
        table.insert( menu.parameters[ 4 ].parameters, { id = id .. "_oversize_firemodepos" } )

        parameters[ id .. "_oversize_grenadespos" ] = { name = "#holohud2.ammo.quicknades_pos", type = HOLOHUD2.PARAM_BOOL, value = false }
        table.insert( menu.parameters[ 4 ].parameters, { id = id .. "_oversize_grenadespos" } )

    end
    
    self:ParseParameters( parameters )
    self:AddMenuTab( tab, menu )
    self:AddQuickTab( tab, quickmenu )

end

function ELEMENT:DefineReserve( id, tab, label, order, copy )

    local parameters = {
        [ id .. "_separate" ]               = { name = "#holohud2.parameter.standalone", type = HOLOHUD2.PARAM_BOOL, value = false },

        [ id .. "_always" ]                 = { name = "#holohud2.ammo.always", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.always.helptext" },
        
        [ id .. "_pos" ]                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 }, helptext = "#holohud2.ammo.reserve_pos.helptext" },
        [ id .. "_dock" ]                   = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        [ id .. "_direction" ]              = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT },
        [ id .. "_margin" ]                 = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        [ id .. "_order" ]                  = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_NUMBER, value = order },

        [ id .. "_size" ]                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 63, y = 46 } },
        [ id .. "_background" ]             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_background_color" ]       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        [ id .. "_animation" ]              = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        [ id .. "_animation_direction" ]    = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        [ id .. "_color" ]                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color(255, 60, 50), [100] = Color(255, 186, 92) }, fraction = true, gradual = false } },
        [ id .. "_color2" ]                 = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color(255, 255, 255, 12) }, fraction = true, gradual = false } },

        [ id .. "num" ]                     = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "num_pos" ]                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = -1 } },
        [ id .. "num_font" ]                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 37, weight = 1000, italic = false } },
        [ id .. "num_rendermode" ]          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        [ id .. "num_background" ]          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        [ id .. "num_lerp" ]                = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "num_align" ]               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        [ id .. "num_digits" ]              = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },
        [ id .. "num_clips" ]               = { name = "#holohud2.ammo.clips", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.clips.helptext" },

        [ id .. "bar" ]                     = { name = "#holohud2.component.percentage_bar", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "bar_pos" ]                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 34 } },
        [ id .. "bar_size" ]                = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 60, y = 6 }, min_x = 1, min_y = 1 },
        [ id .. "bar_style" ]               = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        [ id .. "bar_growdirection" ]       = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        [ id .. "bar_background" ]          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "bar_smooth" ]              = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },

        [ id .. "tray" ]                    = { name = "#holohud2.ammo.tray", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "tray_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 2, y = 32 } },
        [ id .. "tray_size" ]               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 59, y = 12 }, min_x = 1, min_y = 1 },
        [ id .. "tray_direction" ]          = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_RIGHT },

        [ id .. "icon" ]                    = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "icon_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 84, y = 5 } },
        [ id .. "icon_size" ]               = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 14, min = 0 },
        [ id .. "icon_angle" ]              = { name = "#holohud2.parameter.rotation", type = HOLOHUD2.PARAM_RANGE, value = 0, min = 0, max = 360 },
        [ id .. "icon_align" ]              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },

        [ id .. "text" ]                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "text_pos" ]                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        [ id .. "text_font" ]               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        [ id .. "text_text" ]               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = label },
        [ id .. "text_align" ]              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        [ id .. "text_on_background" ]      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        [ id .. "_oversize_size" ]          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_numberpos" ]     = { name = "#holohud2.dynamic_sizing.number_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_ammobarpos" ]    = { name = "#holohud2.dynamic_sizing.percentage_bar_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_ammobarsize" ]   = { name = "#holohud2.dynamic_sizing.percentage_bar_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_traypos" ]       = { name = "#holohud2.ammo.tray_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_traysize" ]      = { name = "#holohud2.ammo.tray_size", type = HOLOHUD2.PARAM_BOOL, value = true },
        [ id .. "_oversize_iconpos" ]       = { name = "#holohud2.dynamic_sizing.icon_pos", type = HOLOHUD2.PARAM_BOOL, value = false },
        [ id .. "_oversize_textpos" ]       = { name = "#holohud2.dynamic_sizing.label_pos", type = HOLOHUD2.PARAM_BOOL, value = false }
    }

    local menu = { icon = "icon16/basket.png", parameters = {
        { id = id .. "_separate" },

        { category = "#holohud2.category.panel", parameters = {
            { id = id .. "_always" },
            { id = id .. "_pos", parameters = {
                { id = id .. "_dock" },
                { id = id .. "_direction" },
                { id = id .. "_margin" },
                { id = id .. "_order" }
            } },
            { id = id .. "_size" },
            { id = id .. "_background", parameters = {
                { id = id .. "_background_color" }
            } },
            { id = id .. "_animation", parameters = {
                { id = id .. "_animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = id .. "_color" },
            { id = id .. "_color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = id .. "num", parameters = {
                { id = id .. "num_pos" },
                { id = id .. "num_font" },
                { id = id .. "num_rendermode" },
                { id = id .. "num_background" },
                { id = id .. "num_lerp" },
                { id = id .. "num_align" },
                { id = id .. "num_digits" },
                { id = id .. "num_clips" }
            } },
            { id = id .. "bar", parameters = {
                { id = id .. "bar_pos" },
                { id = id .. "bar_size" },
                { id = id .. "bar_style" },
                { id = id .. "bar_growdirection" },
                { id = id .. "bar_background" },
                { id = id .. "bar_smooth" }
            } },
            { id = id .. "tray", parameters = {
                { id = id .. "tray_pos" },
                { id = id .. "tray_size" },
                { id = id .. "tray_direction" }
            } },
            { id = id .. "icon", parameters = {
                { id = id .. "icon_pos" },
                { id = id .. "icon_size" },
                { id = id .. "icon_angle" },
                { id = id .. "icon_align" }
            } },
            { id = id .. "text", parameters = {
                { id = id .. "text_pos" },
                { id = id .. "text_font" },
                { id = id .. "text_text" },
                { id = id .. "text_align" },
                { id = id .. "text_on_background" }
            } }
        } },
        { category = "#holohud2.dynamic_sizing", helptext = "#holohud2.dynamic_sizing.helptext", parameters = {
            { id = id .. "_oversize_size" },
            { id = id .. "_oversize_numberpos" },
            { id = id .. "_oversize_ammobarpos" },
            { id = id .. "_oversize_ammobarsize" },
            { id = id .. "_oversize_traypos" },
            { id = id .. "_oversize_traysize" },
            { id = id .. "_oversize_iconpos" },
            { id = id .. "_oversize_textpos" }
        } }
    } }

    local quickmenu = { icon = "icon16/basket.png", parameters = {
        { id = id .. "_separate" },

        { category = "#holohud2.category.panel", parameters = {
            { id = id .. "_always" },
            { id = id .. "_pos" },
            { id = id .. "_size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = id .. "_color" },
            { id = id .. "_color2" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = id .. "num", parameters = {
                { id = id .. "num_pos" },
                { id = id .. "num_font" }
            } },
            { id = id .. "bar", parameters = {
                { id = id .. "bar_pos" },
                { id = id .. "bar_size" }
            } },
            { id = id .. "tray", parameters = {
                { id = id .. "tray_pos" },
                { id = id .. "tray_size" }
            } },
            { id = id .. "icon", parameters = {
                { id = id .. "icon_pos" },
                { id = id .. "icon_size" }
            } },
            { id = id .. "text", parameters = {
                { id = id .. "text_pos" },
                { id = id .. "text_font" }
            } }
        } }
    } }

    if copy then

        parameters[ id .. "_copy" ] = { name = "#holohud2.ammo.ammo1_copy", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.ammo.ammo1_copy.helptext" }
        table.insert( menu.parameters, 1, { id = id .. "_copy" } )
        table.insert( quickmenu.parameters, 1, { id = id .. "_copy" } )

    end

    self:ParseParameters( parameters )
    self:AddMenuTab( tab, menu )
    self:AddQuickTab( tab, quickmenu )

end

function ELEMENT:Init()

    self:DefineClip( "clip1", "#holohud2.ammo.tab.clip1", "#Valve_Hud_AMMO", 16, false, true )
    self:DefineReserve( "ammo1", "#holohud2.ammo.tab.ammo1", "#Valve_Hud_AMMO", 32 )
    self:DefineClip( "clip2", "#holohud2.ammo.tab.clip2", "#Valve_Hud_AMMO_ALT", 48, true )
    self:DefineReserve( "ammo2", "#holohud2.ammo.tab.ammo2", "#Valve_Hud_AMMO_ALT", 64, true )

end

---
--- Primary clip
---
local hudclip1      = HOLOHUD2.component.Create( "HudClip1" )
local clip1_layout  = HOLOHUD2.layout.Register( "clip1" )
local clip1_panel   = HOLOHUD2.component.Create( "AnimatedPanel" )
clip1_panel:SetLayout( clip1_layout )

clip1_panel.PaintOverFrame = function( self, x, y )
    
    hook_Call( "DrawClip1", x, y, self.w, self.h, LAYER_FRAME )

end

local has_clip1 -- determines whether clip2_panel shows hudclip1 or hudammo1

---
--- Fire mode
---
local hudfiremode = HOLOHUD2.component.Create( "HudFireMode" )
local firemode_layout = HOLOHUD2.layout.Register( "firemode" )
local firemode_panel = HOLOHUD2.component.Create( "AnimatedPanel" )
firemode_panel:SetLayout( firemode_layout )

firemode_panel.PaintOver = function( self, x, y )

    hudfiremode:Paint( x, y )

end

firemode_panel.PaintOverScanlines = function( self, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    hudfiremode:Paint( x, y )
    EndAlphaMultiplier()

end

---
--- Quick grenades
---
local hudquicknades = HOLOHUD2.component.Create( "HudQuickNades" )
local quicknades_layout = HOLOHUD2.layout.Register( "quicknades" )
local quicknades_panel = HOLOHUD2.component.Create( "AnimatedPanel" )
quicknades_panel:SetLayout( quicknades_layout )

quicknades_panel.PaintOverBackground = function( self, x, y )

    hudquicknades:PaintBackground( x, y )

end

quicknades_panel.PaintOver = function( self, x, y )

    hudquicknades:Paint( x, y )

end

quicknades_panel.PaintOverScanlines = function( self, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    hudquicknades:Paint( x, y )
    EndAlphaMultiplier()

end

---
--- Primary reserve
---
local hudammo1      = HOLOHUD2.component.Create( "HudAmmo1" )
local ammo1_layout  = HOLOHUD2.layout.Register( "ammo1" )
local ammo1_panel   = HOLOHUD2.component.Create( "AnimatedPanel" )
ammo1_panel:SetLayout( ammo1_layout )

ammo1_panel.PaintOverFrame = function( self, x, y )
    
    hook_Call( "DrawAmmo1", x, y, self.w, self.h, LAYER_FRAME )

end

ammo1_panel.PaintOverBackground = function( self, x, y )
    
    if hook_Call( "DrawAmmo1", x, y, self.w, self.h, LAYER_BACKGROUND ) then return end

    hudammo1:PaintBackground( x, y )

    hook_Call( "DrawOverAmmo1", x, y, self.w, self.h, LAYER_BACKGROUND, hudammo1 )

end

ammo1_panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawAmmo1", x, y, self.w, self.h, LAYER_FOREGROUND ) then return end

    hudammo1:Paint( x, y )

    hook_Call( "DrawOverAmmo1", x, y, self.w, self.h, LAYER_FOREGROUND, hudammo1 )

end

ammo1_panel.PaintOverScanlines = function( self, x, y )
    
    if hook_Call( "DrawAmmo1", x, y, self.w, self.h, LAYER_SCANLINES ) then return end

    hudammo1:PaintScanlines( x, y )

    hook_Call( "DrawOverAmmo1", x, y, self.w, self.h, LAYER_SCANLINES, hudammo1 )

end

---
--- Secondary clip
---
local hudclip2      = HOLOHUD2.component.Create( "HudClip2" )
local clip2_layout  = HOLOHUD2.layout.Register( "clip2" )
local clip2_panel   = HOLOHUD2.component.Create( "AnimatedPanel" )
clip2_panel:SetLayout( clip2_layout )

clip2_panel.PaintOverFrame = function( self, x, y )
    
    hook_Call( "DrawClip2", x, y, self.w, self.h, LAYER_FRAME )

end

local has_clip2 -- determines whether clip2_panel shows hudclip2 or hudammo2

---
--- Secondary reserve
---
local hudammo2      = HOLOHUD2.component.Create( "HudAmmo2" )
local ammo2_layout  = HOLOHUD2.layout.Register( "ammo2" )
local ammo2_panel   = HOLOHUD2.component.Create( "AnimatedPanel" )
ammo2_panel:SetLayout( ammo2_layout )

ammo2_panel.PaintOverFrame = function( self, x, y )
    
    hook_Call( "DrawAmmo2", x, y, self.w, self.h, LAYER_FRAME )

end

ammo2_panel.PaintOverBackground = function( self, x, y )
    
    if hook_Call( "DrawAmmo2", x, y, self.w, self.h, LAYER_BACKGROUND ) then return end

    hudammo2:PaintBackground( x, y )

    hook_Call( "DrawOverAmmo2", x, y, self.w, self.h, LAYER_BACKGROUND, hudammo2 )

end

ammo2_panel.PaintOver = function( self, x, y )
    
    if hook_Call( "DrawAmmo2", x, y, self.w, self.h, LAYER_FOREGROUND ) then return end

    hudammo2:Paint( x, y )

    hook_Call( "DrawOverAmmo2", x, y, self.w, self.h, LAYER_FOREGROUND, hudammo2 )

end

ammo2_panel.PaintOverScanlines = function( self, x, y )
    
    if hook_Call( "DrawAmmo2", x, y, self.w, self.h, LAYER_SCANLINES ) then return end

    hudammo2:PaintScanlines( x, y )

    hook_Call( "DrawOverAmmo2", x, y, self.w, self.h, LAYER_SCANLINES, hudammo2 )

end

---
--- Startup
---
local _weapon = NULL -- last weapon used in PreDraw

local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_EMPTY     = 2
local STARTUP_FILL      = 3

local STARTUP_TIMINGS   = { 1, 1, 2 }

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    clip1_panel:Close()
    hudclip1:SetAmmoType( 1 )
    hudclip1:SetAmmo( 0 )
    hudclip1:SetAmmo2( 0 )
    hudclip1:SetMaxAmmo( 0 )

    ammo1_panel:Close()
    hudammo1:SetAmmo( 0 )

    clip2_panel:Close()
    ammo2_panel:Close()

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

    return "#holohud2.ammo.startup"

end

function ELEMENT:DoStartupSequence( settings, curtime )

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local clip1, max_clip1, ammo1, max_ammo1, primary, weapon = GetPrimaryAmmo()

    has_clip1 = primary <= 0 or clip1 ~= -1 -- default to clip weapon indicator
    _weapon = weapon -- avoid weapon change event from triggering after initialization

    -- advance through the different phases
    if next_startup_phase < curtime then
        
        if startup_phase ~= STARTUP_FILL then
            
            startup_phase = startup_phase + 1
            next_startup_phase = curtime + STARTUP_TIMINGS[ startup_phase ]

        else

            startup_phase = STARTUP_NONE -- finish startup sequence

        end

    end

    if startup_phase == STARTUP_FILL then

        local primary = math.max( primary, 1 )
        local anim = ( 1 - ( next_startup_phase - curtime ) / STARTUP_TIMINGS[ startup_phase ] ) * 3

        hudclip1:SetAmmoType( primary )
        hudclip1:SetAmmo( math.max( math.min( math.ceil( anim * clip1 ), clip1 ), 0 ) )
        hudclip1:SetAmmo2( math.min( math.ceil( anim * ammo1 ), ammo1 ) )
        hudclip1:SetMaxAmmo( max_clip1 )

        hudammo1:SetAmmoType( primary )
        hudammo1:SetAmmo( math.min( math.ceil( anim * ammo1 ), ammo1 ) )
        hudammo1:SetMaxAmmo( max_ammo1 )

    end

    if has_clip1 then

        clip1_layout:SetSize( settings.clip1_size.x + hudclip1:GetOversizeOffset(), settings.clip1_size.y )
        clip1_panel:SetDeployed( true )
        ammo1_panel:SetDeployed( settings.ammo1_separate )

    else

        clip1_layout:SetSize( settings.ammo1_size.x + hudammo1:GetOversizeOffset(), settings.ammo1_size.y )
        clip1_panel:SetDeployed( not settings.ammo1_separate )
        ammo1_panel:SetDeployed( settings.ammo1_separate )

    end

    hudclip1:Think()
    clip1_panel:Think()
    clip1_layout:SetVisible( clip1_panel:IsVisible() )

    hudammo1:Think()
    ammo1_panel:Think()
    ammo1_layout:SetVisible( ammo1_panel:IsVisible() )

    return true

end

---
--- Logic
---
local localplayer -- reference set in PreDraw
local ammotime = 0
local _clip1, _clip2, _ammo1, _ammo2 = 0, 0, 0, 0
local _grenades, _firemode = 0
function ELEMENT:PreDraw( settings )
    
    localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()

    -- startup sequence
    if self:DoStartupSequence( settings, curtime ) then return end

    local minimized = self:IsMinimized()
    local visible = self:IsInspecting() or ammotime > curtime
    local weapon = GetWeapon()

    -- tick all panels early to apply previous transforms before showing up
    clip1_panel:Think()
    ammo1_panel:Think()
    clip2_panel:Think()
    ammo2_panel:Think()

    -- primary ammo
    local clip1, max_clip1, ammo1, max_ammo1, primary = GetPrimaryAmmo()

    if primary > 0 then

        local clips1, max_clips1 = math.ceil( ammo1 / math.max( max_clip1, 1 ) ), math.ceil( max_ammo1 / math.max( max_clip1, 1 ) )
        has_clip1 = clip1 ~= -1

        ammo1_panel:SetSize( settings.ammo1_size.x + hudammo1:GetOversizeOffset(), settings.ammo1_size.y )

        -- clip
        if clip1 ~= _clip1 then
            
            ammotime = curtime + settings.autohide_delay
            visible = true -- HACK: this prevents the indicator from flashing when the startup sequence finishes
            _clip1 = clip1

        end

        if has_clip1 or settings.ammo1_separate then

            clip1_layout:SetSize( settings.clip1_size.x + hudclip1:GetOversizeOffset(), settings.clip1_size.y )

        else

            clip1_layout:SetSize( settings.ammo1_size.x + hudammo1:GetOversizeOffset(), settings.ammo1_size.y )

        end
        
        if has_clip1 then
            
            clip1_panel:SetDeployed( not minimized and ( settings.clip1_always or not settings.autohide or visible ) )
            ammo1_panel:SetDeployed( not minimized and ( settings.ammo1_separate and ( settings.ammo1_always or not settings.autohide or visible ) ) )

        else

            clip1_panel:SetDeployed( not minimized and ( not settings.ammo1_separate and ( settings.clip1_always or not settings.autohide or visible ) ) )
            ammo1_panel:SetDeployed( not minimized and ( settings.ammo1_separate and ( settings.ammo1_always or not settings.autohide or visible ) ) )

        end

        hudclip1:SetMaxAmmo( max_clip1 )
        hudclip1:SetAmmo( clip1 )
        hudclip1:SetAmmo2( settings.clip1num2_clips and clips1 or ammo1 )
        hudclip1:SetAmmoType( primary )

        -- reserve
        if ammo1 ~= _ammo1 then
            
            ammotime = curtime + settings.autohide_delay
            _ammo1 = ammo1

        end

        hudammo1:SetMaxAmmo( settings.ammo1num_clips and max_clips1 or max_ammo1 )
        hudammo1:SetAmmo( settings.ammo1num_clips and clips1 or ammo1 )
        hudammo1:SetAmmoType( primary )

    else

        clip1_panel:SetDeployed( false )
        ammo1_panel:SetDeployed( false )

    end

    -- secondary ammo
    local clip2, max_clip2, ammo2, max_ammo2, secondary = GetSecondaryAmmo()
    local quicknades = settings.quicknades and secondary == settings.quicknades_ammotype

    if secondary > 0 then
        
        local clips2, max_clips2 = math.ceil( ammo2 / math.max( max_clip2, 1 ) ), math.ceil( max_ammo2 / math.max( max_clip2, 1 ) )
        has_clip2 = clip2 ~= -1

        local clip2_size, ammo2_size = settings.clip2_size, settings.ammo2_size
        local clip2num2_clips, ammo2num_clips = settings.clip2num2_clips, settings.ammo2num_clips

        if settings.clip2_copy then

            clip2_size, clip2num2_clips = settings.clip1_size, settings.clip1num2_clips

        end

        if settings.ammo2_copy then

            ammo2_size, ammo2num_clips = settings.ammo1_size, settings.ammo1num_clips

        end

        ammo2_panel:SetSize( ammo2_size.x + hudammo2:GetOversizeOffset(), ammo2_size.y )

        if has_clip2 or settings.ammo2_separate then

            clip2_layout:SetSize( clip2_size.x + hudclip2:GetOversizeOffset(), clip2_size.y )

        else

            clip2_layout:SetSize( ammo2_size.x + hudammo2:GetOversizeOffset(), ammo2_size.y )

        end

        if has_clip2 then
            
            clip2_panel:SetDeployed( not minimized and ( settings.clip2_always or not settings.autohide or visible ) and not quicknades )
            ammo2_panel:SetDeployed( not minimized and ( settings.ammo2_separate and ( settings.ammo2_always or not settings.autohide or visible ) ) and not quicknades )

        else
            
            clip2_panel:SetDeployed( not minimized and ( not settings.ammo2_separate and ( settings.clip2_always or not settings.autohide or visible ) ) and not quicknades )
            ammo2_panel:SetDeployed( not minimized and ( settings.ammo2_separate and ( settings.ammo2_always or not settings.autohide or visible ) ) and not quicknades )
            
        end

        -- clip
        if clip2 ~= _clip2 then
            
            ammotime = curtime + settings.autohide_delay
            _clip2 = clip2

        end

        hudclip2:SetMaxAmmo( max_clip2 )
        hudclip2:SetAmmo( clip2 )
        hudclip2:SetAmmo2( clip2num2_clips and clips2 or ammo2 )
        hudclip2:SetAmmoType( secondary )

        -- reserve
        if ammo2 ~= _ammo2 then
            
            ammotime = curtime + settings.autohide_delay
            _ammo2 = ammo2

        end

        hudammo2:SetMaxAmmo( ammo2num_clips and max_clips2 or max_ammo2 )
        hudammo2:SetAmmo( ammo2num_clips and clips2 or ammo2 )
        hudammo2:SetAmmoType( secondary )

    else

        clip2_panel:SetDeployed( false )
        ammo2_panel:SetDeployed( false )

    end

    -- weapon changed
    if weapon ~= _weapon then

        if primary > 0 then

            hudclip1:OnWeaponChanged()
            hudammo1:OnWeaponChanged()
        
        end

        if secondary > 0 then
            
            hudclip2:OnWeaponChanged()
            hudammo2:OnWeaponChanged()

        end

        ammotime = curtime + settings.autohide_delay
        _weapon = weapon

    end

    -- show ammo if we're trying to reload or shoot an empty weapon
    if localplayer:KeyDown( IN_RELOAD ) or
       ( localplayer:KeyDown( IN_ATTACK ) and primary > 0 and ( ( clip1 == -1 and ammo1 <= 0 ) or clip1 == 0 ) ) or
       ( localplayer:KeyDown( IN_ATTACK2 ) and secondary > 0 and ( ( clip2 == -1 and ammo2 <= 0 ) or clip2 == 0 ) ) then
        
        ammotime = curtime + settings.autohide_delay

    end

    -- primary clip
    local clip1 = clip1_panel:IsVisible()
    clip1_layout:SetVisible( clip1 )
    if clip1 then
        
        if settings.ammo1_separate or has_clip1 then

            clip1_layout:SetPos( settings.clip1_pos.x, settings.clip1_pos.y )
            clip1_layout:SetMargin( settings.ammo1_margin )
            clip1_layout:SetOrder( settings.clip1_order )
            clip1_panel:SetAnimation( settings.clip1_animation )
            clip1_panel:SetAnimationDirection( settings.clip1_animation_direction )
            clip1_panel:SetDrawBackground( settings.clip1_background )
            clip1_panel:SetColor( settings.clip1_background_color )

            hudclip1:Think()
        
        else

            clip1_layout:SetPos( settings.ammo1_pos.x, settings.ammo1_pos.y )
            clip1_layout:SetMargin( settings.ammo1_margin )
            clip1_layout:SetOrder( settings.ammo1_order )
            clip1_panel:SetAnimation( settings.ammo1_animation )
            clip1_panel:SetAnimationDirection( settings.ammo1_animation_direction )
            clip1_panel:SetDrawBackground( settings.ammo1_background )
            clip1_panel:SetColor( settings.ammo1_background_color )

            hudammo1:Think()

        end
    
    end

    -- primary reserve
    local ammo1 = ammo1_panel:IsVisible()
    ammo1_layout:SetVisible( ammo1 )
    if ammo1 then hudammo1:Think() end

    -- secondary clip
    local clip2 = clip2_panel:IsVisible()
    clip2_layout:SetVisible( clip2 )
    if clip2 then
        
        if settings.ammo2_separate or has_clip2 then
            
            clip2_layout:SetPos( settings.clip2_pos.x, settings.clip2_pos.y )
            clip2_layout:SetMargin( settings.clip2_margin )
            clip2_layout:SetDirection( settings.clip2_direction )
            clip2_layout:SetOrder( settings.clip2_order )
            clip2_panel:SetAnimation( clip2_animation )
            clip2_panel:SetAnimationDirection( clip2_animation_direction )
            clip2_panel:SetDrawBackground( clip2_background )
            clip2_panel:SetColor( clip2_background_color )

            hudclip2:Think()
        
        else

            clip2_layout:SetPos( settings.ammo2_pos.x, settings.ammo2_pos.y )
            clip2_layout:SetMargin( settings.ammo2_margin )
            clip2_layout:SetDirection( settings.ammo2_direction )
            clip2_layout:SetOrder( settings.ammo2_order )
            clip2_panel:SetAnimation( ammo2_animation )
            clip2_panel:SetAnimationDirection( ammo2_animation_direction )
            clip2_panel:SetDrawBackground( ammo2_background )
            clip2_panel:SetColor( ammo2_background_color )

            hudammo2:Think()

        end
    
    end

    -- secondary reserve
    local ammo2 = ammo2_panel:IsVisible()
    ammo2_layout:SetVisible( ammo2 )
    if ammo2 then hudammo2:Think() end

    -- fire mode
    local firemode

    if IsValid( weapon ) then

        firemode = hook_Call( "GetWeaponFiremode", weapon )

        if _firemode ~= firemode then

            ammotime = curtime + settings.autohide_delay
            _firemode = firemode

        end

    end

    hudfiremode:SetFireMode( settings.firemode and firemode )
    hudfiremode:PerformLayout()

    if settings.firemode_separate then
        
        firemode_panel:Think()
        firemode_panel:SetDeployed( settings.firemode and firemode and clip1_panel.deployed )
        firemode_layout:SetVisible( firemode_panel:IsVisible() )

    else

        if settings.clip1_oversize_firemodepos then

            hudfiremode:SetPos( settings.firemode_pos.x + hudclip1:GetOversizeOffset(), settings.firemode_pos.y )

        end

        firemode_panel:SetDeployed( false )

    end
        
    -- quick nades
    local grenades = localplayer:GetAmmoCount( settings.quicknades_ammotype )
    hudquicknades:SetAmount( grenades )
    hudquicknades:Think()

    if settings.quicknades and grenades ~= _grenades and ( has_clip1 or settings.quicknades_separate ) then
        
        ammotime = curtime + settings.autohide_delay
        _grenades = grenades

    end

    if settings.quicknades_separate then

        if has_clip1 then
            
            hudquicknades:SetColor( hudclip1.Colors:GetColor() )
            hudquicknades:SetColor2( hudclip1.Colors2:GetColor() )

        else

            hudquicknades:SetColor( hudammo1.Colors:GetColor() )
            hudquicknades:SetColor2( hudammo1.Colors2:GetColor() )

        end
        
        quicknades_panel:Think()
        quicknades_panel:SetDeployed( settings.quicknades and settings.quicknades_separate and clip1_panel.deployed and primary ~= settings.quicknades_ammotype )
        quicknades_layout:SetSize( hudquicknades.__w + settings.quicknades_separate_padding.x * 2, hudquicknades.__h + settings.quicknades_separate_padding.y * 2 )
        quicknades_layout:SetVisible( quicknades_panel:IsVisible() )

    end

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )
    
    clip1_panel:PaintFrame( x, y )
    ammo1_panel:PaintFrame( x, y )
    clip2_panel:PaintFrame( x, y )
    ammo2_panel:PaintFrame( x, y )

    if settings.firemode_separate then firemode_panel:PaintFrame( x, y ) return end
    if settings.quicknades_separate then quicknades_panel:PaintFrame( x, y ) return end

end

function ELEMENT:PaintBackground( settings, x, y )

    clip1_panel:PaintBackground( x, y )
    ammo1_panel:PaintBackground( x, y )
    clip2_panel:PaintBackground( x, y )
    ammo2_panel:PaintBackground( x, y )

    if settings.firemode_separate then firemode_panel:PaintBackground( x, y ) return end
    if settings.quicknades_separate then quicknades_panel:PaintBackground( x, y ) return end

end

function ELEMENT:Paint( settings, x, y )

    if startup_phase == STARTUP_STANDBY then return end

    clip1_panel:Paint( x, y )
    ammo1_panel:Paint( x, y )
    clip2_panel:Paint( x, y )
    ammo2_panel:Paint( x, y )

    if settings.firemode_separate then firemode_panel:Paint( x, y ) return end
    if settings.quicknades_separate then quicknades_panel:Paint( x, y ) return end
    
end

function ELEMENT:PaintScanlines( settings, x, y )

    if startup_phase == STARTUP_STANDBY then return end

    clip1_panel:PaintScanlines( x, y )
    ammo1_panel:PaintScanlines( x, y )
    clip2_panel:PaintScanlines( x, y )
    ammo2_panel:PaintScanlines( x, y )

    if settings.firemode_separate then firemode_panel:PaintScanlines( x, y ) return end
    if settings.quicknades_separate then quicknades_panel:PaintScanlines( x, y ) return end
    
end

---
--- Preview
---
local PREVIEW_AMMOTYPES = {
    [ -1 ] = 1, [ 3 ] = 2, [ 5 ] = 3, [ 4 ] = 4, [ 9 ] = 5,
    [ 1 ] = 6, [ 2 ] = 7, [ 7 ] = 8, [ 6 ] = 9, [ 8 ] = 10,
    [ 10 ] = 11, [ 11 ] = 12
}
local PREVIEW_DEFAULTS = {
    { 1, 30, 30, 120 }, { 8, 3, 3, 0 }, { 9, 1, 1, 2 }, { 9, 3, 3, 0 }
}

local preview_option = 1
local preview_hudclip1 = HOLOHUD2.component.Create( "HudClip1" )
local preview_hudammo1 = HOLOHUD2.component.Create( "HudAmmo1" )
local preview_hudclip2 = HOLOHUD2.component.Create( "HudClip2" )
local preview_hudammo2 = HOLOHUD2.component.Create( "HudAmmo2" )
local preview_hudfiremode = HOLOHUD2.component.Create( "HudFireMode" )
local preview_hudquicknades = HOLOHUD2.component.Create( "HudQuickNades" )
local preview_options = { preview_hudclip1, preview_hudammo1, preview_hudclip2, preview_hudammo2 }

preview_hudfiremode:SetFireMode( HOLOHUD2.FIREMODE_AUTO )

for i, component in pairs( preview_options ) do

    local defaults = PREVIEW_DEFAULTS[ i ]

    component:SetAmmoType( defaults[ 1 ] )
    component:SetAmmo( defaults[ 2 ] )
    component:SetMaxAmmo( defaults[ 3 ] )
    component:SetAmmo2( defaults[ 4 ] )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudclip1:ApplySettings( settings, self.preview_fonts )
    preview_hudammo1:ApplySettings( settings, self.preview_fonts )
    preview_hudclip2:ApplySettings( settings, self.preview_fonts )
    preview_hudammo2:ApplySettings( settings, self.preview_fonts )
    preview_hudfiremode:SetColor( preview_hudclip1.Colors:GetColor() )
    preview_hudfiremode:ApplySettings( settings )
    preview_hudquicknades:SetColor( preview_hudclip1.Colors:GetColor() )
    preview_hudquicknades:SetColor2( preview_hudclip1.Colors2:GetColor() )
    preview_hudquicknades:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:Dock( BOTTOM )
    controls:SetTall( 80 )

        local ammotype = vgui.Create( "DComboBox", controls )
        ammotype:SetPos( 4, 4 )
        ammotype:SetWide( 156 )
        ammotype:SetSortItems( false )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_0", -1 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_1", 3 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_2", 5 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_3", 4 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_4", 9 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_5", 1 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_6", 2 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_7", 7 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_8", 6 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_9", 8 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_10", 10 )
        ammotype:AddChoice( "#holohud2.ammo.preview.ammotype_11", 11 )
        ammotype:ChooseOptionID( PREVIEW_AMMOTYPES[ preview_options[ preview_option ].ammotype ] or 1 )
        ammotype.OnSelect = function( _, _, _, ammotype )

            preview_options[ preview_option ]:SetAmmoType( ammotype )

        end

        local value = vgui.Create( "DNumberWang", controls )
        value:SetPos( 4, 30 )
        value:SetWide( 48 )
        value:SetMax( 999 )
        value:SetTooltip( "#holohud2.ammo.preview.ammo" )
        value.OnValueChanged = function( _, value )

            preview_options[ preview_option ]:SetAmmo( value )

        end

        local separator = vgui.Create( "DLabel", controls )
        separator:SetPos( value:GetX() + value:GetWide() + 2, 30 )
        separator:SetText( "/" )

        local max_value = vgui.Create( "DNumberWang", controls )
        max_value:SetPos( separator:GetX() + 6, 30 )
        max_value:SetWide( 48 )
        max_value:SetMax( 999 )
        max_value:SetTooltip( "#holohud2.ammo.preview.max" )
        max_value.OnValueChanged = function( _, value )

            preview_options[ preview_option ]:SetMaxAmmo( value )

        end

        local value2 = vgui.Create( "DNumberWang", controls )
        value2:SetPos( max_value:GetX() + max_value:GetWide() + 4, 30 )
        value2:SetWide( 48 )
        value2:SetMax( 9999 )
        value2:SetTooltip( "#holohud2.ammo.preview.reserve" )
        value2.OnValueChanged = function( _, value )

            preview_options[ preview_option ]:SetAmmo2( value )

        end

        local options = vgui.Create( "DComboBox", controls )
        options:SetPos( 4, 54 )
        options:SetWide( 156 )
        options:SetSortItems( false )
        options:AddChoice( "#holohud2.ammo.tab.clip1", 1 )
        options:AddChoice( "#holohud2.ammo.tab.ammo1", 2 )
        options:AddChoice( "#holohud2.ammo.tab.clip2", 3 )
        options:AddChoice( "#holohud2.ammo.tab.ammo2", 4 )
        options.OnSelect = function( _, i )

            preview_option = i

            local component = preview_options[ preview_option ]
            ammotype:ChooseOptionID( PREVIEW_AMMOTYPES[ component.ammotype or -1 ] or 1 )
            value:SetValue( component.ammo )
            max_value:SetValue( component.max_ammo )
            value2:SetValue( component.ammo2 )
            value2:SetVisible( i % 2 ~= 0 )

        end
        options:ChooseOptionID( preview_option )

        local reset = vgui.Create( "DImageButton", controls )
        reset:SetSize( 16, 16 )
        reset:SetImage( "icon16/arrow_refresh.png" )
        reset:SetPos( 166, 58 )
        reset.DoClick = function()

            local defaults = PREVIEW_DEFAULTS[ preview_option ]

            ammotype:ChooseOptionID( PREVIEW_AMMOTYPES[ defaults[ 1 ] ] )
            value:SetValue( defaults[ 2 ] )
            max_value:SetValue( defaults[ 3 ] )
            value2:SetValue( defaults[ 4 ] )

        end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()

    if preview_option == 1 then

        local w, h = ( settings.clip1_size.x + preview_hudclip1:GetOversizeOffset() ) * scale, settings.clip1_size.y * scale

        x, y = x - w / 2, y - h / 2

        preview_hudclip1:Think()

        if settings.clip1_background then

            draw.RoundedBox( 0, x, y, w, h, settings.clip1_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_hudclip1:PaintBackground( x, y )
        preview_hudclip1:Paint( x, y )

        if settings.firemode and not settings.firemode_separate then
            
            preview_hudfiremode:PerformLayout()
            preview_hudfiremode:Paint( x, y )

        end

        if settings.quicknades and not settings.quicknades_separate then
            
            preview_hudquicknades:Think()
            preview_hudquicknades:PaintBackground( x, y )
            preview_hudquicknades:Paint( x, y )

        end
    
    elseif preview_option == 2 then

        local w, h = ( settings.ammo1_size.x + preview_hudammo1:GetOversizeOffset() ) * scale, settings.ammo1_size.y * scale

        x, y = x - w / 2, y - h / 2

        preview_hudammo1:Think()

        if settings.ammo1_background then

            draw.RoundedBox( 0, x, y, w, h, settings.ammo1_background_color )
            
        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_hudammo1:PaintBackground( x, y )
        preview_hudammo1:Paint( x, y )

    elseif preview_option == 3 then

        local clip2_size, clip2_background, clip2_background_color = settings.clip2_size, settings.clip2_background, settings.clip2_background_color

        if settings.clip2_copy then

            clip2_size, clip2_background, clip2_background_color = settings.clip1_size, settings.clip1_background, settings.clip1_background_color

        end

        local w, h = ( clip2_size.x + preview_hudclip2:GetOversizeOffset() ) * scale, clip2_size.y * scale

        x, y = x - w / 2, y - h / 2

        preview_hudclip2:Think()

        if clip2_background then

            draw.RoundedBox( 0, x, y, w, h, clip2_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_hudclip2:PaintBackground( x, y )
        preview_hudclip2:Paint( x, y )
    
    elseif preview_option == 4 then

        local ammo2_size, ammo2_background, ammo2_background_color = settings.ammo2_size, settings.ammo2_background, settings.ammo2_background_color

        if settings.ammo2_copy then

            ammo2_size, ammo2_background, ammo2_background_color = settings.ammo1_size, settings.ammo1_background, settings.ammo1_background_color

        end

        local w, h = ( ammo2_size.x + preview_hudammo2:GetOversizeOffset() ) * scale, ammo2_size.y * scale

        x, y = x - w / 2, y - h / 2

        preview_hudammo2:Think()

        if ammo2_background then

            draw.RoundedBox( 0, x, y, w, h, ammo2_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )
        
        preview_hudammo2:PaintBackground( x, y )
        preview_hudammo2:Paint( x, y )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged(settings)

    if not settings._visible then

        clip1_layout:SetVisible( false )
        ammo1_layout:SetVisible( false )
        clip2_layout:SetVisible( false )
        ammo2_layout:SetVisible( false )
        firemode_layout:SetVisible( false )

        return

    end

    -- primary clip
    clip1_layout:SetPos( settings.clip1_pos.x, settings.clip1_pos.y )
    clip1_layout:SetDock( settings.clip1_dock )
    clip1_layout:SetMargin( settings.clip1_margin )
    clip1_layout:SetDirection( settings.clip1_direction )
    clip1_layout:SetOrder( settings.clip1_order )

    clip1_panel:SetAnimation( settings.clip1_animation )
    clip1_panel:SetAnimationDirection( settings.clip1_animation_direction )
    clip1_panel:SetDrawBackground( settings.clip1_background )
    clip1_panel:SetColor( settings.clip1_background_color )

    hudclip1:ApplySettings( settings, self.fonts )

    clip1_panel.PaintOverBackground = function( self, x, y )

        if not settings.ammo1_separate and not has_clip1 then

            hudammo1:PaintBackground( x, y )
            return

        end

        if hook_Call( "DrawClip1", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

        hudclip1:PaintBackground( x, y )

        if not settings.quicknades_separate then
            
            hudquicknades:PaintBackground( x, y )

        end

        hook_Call( "DrawOverClip1", x, y, self._w, self._h, LAYER_BACKGROUND, hudclip1 )

    end

    clip1_panel.PaintOver = function(self, x, y)

        if not settings.ammo1_separate and not has_clip1 then

            hudammo1:Paint( x, y )
            return

        end

        if hook_Call( "DrawClip1", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

        hudclip1:Paint( x, y )

        if not settings.firemode_separate then hudfiremode:Paint( x, y ) end
        if not settings.quicknades_separate then hudquicknades:Paint( x, y ) end

        hook_Call( "DrawOverClip1", x, y, self._w, self._h, LAYER_FOREGROUND, hudclip1 )

    end

    clip1_panel.PaintOverScanlines = function(self, x, y)
        
        if not settings.ammo1_separate and not has_clip1 then

            hudammo1:PaintScanlines( x, y )
            return

        end

        if hook_Call( "DrawClip1", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

        hudclip1:PaintScanlines( x, y )

        StartAlphaMultiplier( hudclip1.Blur:GetAmount() )

        if not settings.firemode_separate then hudfiremode:Paint( x, y ) end
        if not settings.quicknades_separate then hudquicknades:Paint( x, y ) end

        EndAlphaMultiplier()

        hook_Call( "DrawOverClip1", x, y, self._w, self._h, LAYER_SCANLINES, hudclip1 )

    end

    -- primary reserve
    ammo1_layout:SetPos( settings.ammo1_pos.x, settings.ammo1_pos.y )
    ammo1_layout:SetSize( settings.ammo1_size.x, settings.ammo1_size.y )
    ammo1_layout:SetDock( settings.ammo1_dock )
    ammo1_layout:SetMargin( settings.ammo1_margin )
    ammo1_layout:SetDirection( settings.ammo1_direction )
    ammo1_layout:SetOrder( settings.ammo1_order )

    ammo1_panel:SetAnimation( settings.ammo1_animation )
    ammo1_panel:SetAnimationDirection( settings.ammo1_animation_direction )
    ammo1_panel:SetDrawBackground( settings.ammo1_background )
    ammo1_panel:SetColor( settings.ammo1_background_color )

    hudammo1:ApplySettings( settings, self.fonts )

    -- secondary clip
    clip2_animation = settings.clip2_animation
    clip2_animation_direction = settings.clip2_animation_direction
    clip2_background = settings.clip2_background
    clip2_background_color = settings.clip2_background_color

    if settings.clip2_copy then

        clip2_animation = settings.clip1_animation
        clip2_animation_direction = settings.clip1_animation_direction
        clip2_background = settings.clip1_background
        clip2_background_color = settings.clip1_background_color

    end

    clip2_layout:SetPos( settings.clip2_pos.x, settings.clip2_pos.y )
    clip2_layout:SetDock( settings.clip2_dock )
    clip2_layout:SetMargin( settings.clip2_margin )
    clip2_layout:SetDirection( settings.clip2_direction )
    clip2_layout:SetOrder( settings.clip2_order )
    
    clip2_panel:SetAnimation( clip2_animation )
    clip2_panel:SetAnimationDirection( clip2_animation_direction )
    clip2_panel:SetDrawBackground( clip2_background )
    clip2_panel:SetColor( clip2_background_color )

    hudclip2:ApplySettings( settings, self.fonts )

    clip2_panel.PaintOverBackground = function( self, x, y )

        if not settings.ammo2_separate and not has_clip2 then

            hudammo2:PaintBackground( x, y )
            return

        end

        if hook_Call( "DrawClip2", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

        hudclip2:PaintBackground( x, y )

        hook_Call( "DrawOverClip2", x, y, self._w, self._h, LAYER_BACKGROUND, hudclip2 )

    end

    clip2_panel.PaintOver = function( self, x, y )

        if not settings.ammo2_separate and not has_clip2 then

            hudammo2:Paint( x, y )
            return

        end

        if hook_Call( "DrawClip2", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

        hudclip2:Paint( x, y )

        hook_Call( "DrawOverClip2", x, y, self._w, self._h, LAYER_FOREGROUND, hudclip2 )

    end

    clip2_panel.PaintOverScanlines = function( self, x, y )
        
        if not settings.ammo2_separate and not has_clip2 then

            hudammo2:PaintScanlines( x, y )
            return

        end

        if hook_Call( "DrawClip2", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

        hudclip2:PaintScanlines( x, y )

        hook_Call( "DrawOverClip2", x, y, self._w, self._h, LAYER_SCANLINES, hudclip2 )

    end

    -- secondary reserve
    ammo2_size = settings.ammo2_size
    ammo2_animation = settings.ammo2_animation
    ammo2_animation_direction = settings.ammo2_animation_direction
    ammo2_background = settings.ammo2_background
    ammo2_background_color = settings.ammo2_background_color

    if settings.ammo2_copy then

        ammo2_size = settings.ammo1_size
        ammo2_animation = settings.ammo1_animation
        ammo2_animation_direction = settings.ammo1_animation_direction
        ammo2_background = settings.ammo1_background
        ammo2_background_color = settings.ammo1_background_color

    end

    ammo2_layout:SetPos( settings.ammo2_pos.x, settings.ammo2_pos.y )
    ammo2_layout:SetSize( ammo2_size.x, ammo2_size.y )
    ammo2_layout:SetDock( settings.ammo2_dock )
    ammo2_layout:SetMargin( settings.ammo2_margin )
    ammo2_layout:SetDirection( settings.ammo2_direction )
    ammo2_layout:SetOrder( settings.ammo2_order )

    ammo2_panel:SetAnimation( ammo2_animation )
    ammo2_panel:SetAnimationDirection( ammo2_animation_direction )
    ammo2_panel:SetDrawBackground( ammo2_background )
    ammo2_panel:SetColor( ammo2_background_color )

    hudammo2:ApplySettings( settings, self.fonts )

    hudfiremode:SetVisible( settings.firemode )
    hudfiremode:SetColor( hudclip1.Colors:GetColor() )
    hudfiremode:ApplySettings( settings )

    if settings.firemode_separate then
        
        hudfiremode:PerformLayout( true )

        firemode_layout:SetPos( settings.firemode_separate_pos.x, settings.firemode_separate_pos.y )
        firemode_layout:SetSize( ( 64 / 16 * settings.firemode_size ) + settings.firemode_separate_padding.x * 2, settings.firemode_size + settings.firemode_separate_padding.y * 2 )
        firemode_layout:SetDock( settings.firemode_separate_dock )
        firemode_layout:SetMargin( settings.firemode_separate_margin )
        firemode_layout:SetDirection( settings.firemode_separate_direction )
        firemode_layout:SetOrder( settings.firemode_separate_order )
    
        firemode_panel:SetDrawBackground( settings.firemode_separate_background )
        firemode_panel:SetColor( settings.firemode_separate_background_color )
        firemode_panel:SetAnimation( settings.firemode_separate_animation )
        firemode_panel:SetAnimationDirection( settings.firemode_separate_animation_direction )

    else

        firemode_layout:SetVisible( false )

    end

    hudquicknades:ApplySettings( settings, self.fonts )

    if settings.quicknades_separate then
        
        quicknades_layout:SetPos( settings.quicknades_separate_pos.x, settings.quicknades_separate_pos.y )
        quicknades_layout:SetDock( settings.quicknades_separate_dock )
        quicknades_layout:SetMargin( settings.quicknades_separate_margin )
        quicknades_layout:SetDirection( settings.quicknades_separate_direction )
        quicknades_layout:SetOrder( settings.quicknades_separate_order )

        quicknades_panel:SetDrawBackground( settings.quicknades_separate_background )
        quicknades_panel:SetColor( settings.quicknades_separate_background_color )
        quicknades_panel:SetAnimation( settings.quicknades_separate_animation )
        quicknades_panel:SetAnimationDirection( settings.quicknades_separate_animation_direction )

    else

        hudquicknades:SetColor( hudclip1.Colors:GetColor() )
        hudquicknades:SetColor2( hudclip1.Colors2:GetColor() )
        quicknades_layout:SetVisible( false )

    end

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    for _, panel in ipairs( { clip1_panel, ammo1_panel, clip2_panel, ammo2_panel, firemode_panel } ) do

        panel:InvalidateLayout()

    end

    for _, component in ipairs( { hudclip1, hudammo1, hudclip2, hudammo2, hudfiremode } ) do

        component:InvalidateLayout()

    end

end

HOLOHUD2.element.Register( "ammo", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    clip1_panel     = clip1_panel,
    hudclip1        = hudclip1,
    ammo1_panel     = ammo1_panel,
    hudammo1        = hudammo1,
    clip2_panel     = clip2_panel,
    hudclip2        = hudclip2,
    ammo2_panel     = ammo2_panel,
    hudammo2        = hudammo2,
    hudfiremode     = hudfiremode,
    hudquicknades   = hudquicknades
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "autohide", "ammo", "autohide" )
HOLOHUD2.modifier.Add( "panel_animation", "ammo", { "clip1_animation", "ammo1_animation", "clip2_animation", "ammo2_animation", "firemode_separate_animation", "quicknades_separate_animation" } )
HOLOHUD2.modifier.Add( "background", "ammo", { "clip1_background", "ammo1_background", "clip2_background", "ammo2_background", "firemode_separate_background", "quicknades_separate_background" } )
HOLOHUD2.modifier.Add( "background_color", "ammo", { "clip1_background_color", "ammo1_background_color", "clip2_background_color", "ammo2_background_color", "firemode_separate_background_color", "quicknades_separate_background_color" } )
HOLOHUD2.modifier.Add( "color2", "ammo", { "clip1_color2", "ammo1_color2", "clip2_color2", "ammo2_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "ammo", { "clip1num_rendermode", "clip1num2_rendermode", "ammo1num_rendermode", "clip2num_rendermode", "clip2num2_rendermode", "ammo2num_rendermode", "quicknades_num_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "ammo", { "clip1num_background", "clip1num2_background", "ammo1num_background", "clip2num_background", "clip2num2_background", "ammo2num_background", "quicknades_num_background" } )
HOLOHUD2.modifier.Add( "number_font", "ammo", { "clip1num_font", "ammo1num_font", "clip2num_font", "ammo2num_font" })
HOLOHUD2.modifier.Add( "number_offset", "ammo", { "clip1num_pos", "ammo1num_pos", "clip2num_pos", "ammo2num_pos" } )
HOLOHUD2.modifier.Add( "number2_font", "ammo", { "clip1num2_font", "clip2num2_font" } )
HOLOHUD2.modifier.Add( "number2_offset", "ammo", { "clip1num2_pos", "clip2num2_pos" } )
HOLOHUD2.modifier.Add( "number3_font", "ammo", "quicknades_num_font" )
HOLOHUD2.modifier.Add( "number3_offset", "ammo", "quicknades_num_offset" )
HOLOHUD2.modifier.Add( "text_font", "ammo", { "clip1text_font", "ammo1text_font", "clip2text_font", "ammo2text_font" } )
HOLOHUD2.modifier.Add( "text_offset", "ammo", { "clip1text_pos", "ammo1text_pos", "clip2text_pos", "ammo2text_pos" } )

---
--- Presets
---
HOLOHUD2.presets.Register( "ammo", "element/ammo" )
HOLOHUD2.presets.Add( "ammo", "Alternate - Separate widgets", {
    firemode_separate = true,
    arc9_thermometer_size = { x = 60, y = 3 },
    arc9_thermometer_separate = true
} )
HOLOHUD2.presets.Add( "ammo", "Classic - Compact", {
    arc9_jammed_font = { font = "Roboto Light", size = 14, weight = 1000, italic = false },
    arc9_thermometer = false,
    firemode = false,

    clip1_size = { x = 76, y = 52 },
    clip1num_pos = { x = 18, y = -1 },
    clip1num2_pos = { x = 25, y = 29 },
    clip1tray_pos = { x = 3, y = 3 },
    clip1tray_size = { x = 12, y = 50 },
    clip1tray_direction = 2,

    ammo1_size = { x = 76, y = 35 },
    ammo1num_pos = { x = 18, y = -1 },
    ammo1tray_pos = { x = 3, y = 3 },
    ammo1tray_size = { x = 12, y = 32 },
    ammo1tray_direction = 2,
    
    clip2_size = { x = 76, y = 52 },
    clip2num_pos = { x = 18, y = -1 },
    clip2num2_pos = { x = 25, y = 29 },
    clip2tray_pos = { x = 3, y = 3 },
    clip2tray_size = { x = 12, y = 50 },
    clip2tray_direction = 2,

    ammo2_size = { x = 19, y = 52 },
    ammo2num = false,
    ammo2tray_size = { x = 12, y = 50 },
    ammo2tray_pos = { x = 3, y = 3 },
    ammo2tray_direction = 2,
} )
HOLOHUD2.presets.Add( "ammo", "Classic - Minimalistic", {
    arc9_jammed_font = { font = "Roboto Light", size = 14, weight = 1000, italic = false },
    arc9_jammed_vertical = true,
    arc9_thermometer = false,
    firemode = false,

    clip1_color = {
        fraction = true,
        gradual = false,
        colors = {
            [0] = { r = 255, b = 50, a = 255, g = 60 },
            [99] = { r = 255, b = 92, a = 255, g = 186, },
            [100] = { r = 170, b = 70, a = 255, g = 150, },
        },
    },
    clip1_size = { x = 16, y = 114 },
    clip1num = false,
    clip1num2 = false,
    clip1tray_pos = { x = 2, y = 2 },
    clip1tray_size = { x = 12, y = 112 },
    clip1tray_direction = 2,

    ammo1_separate = true,
    ammo1_always = true,
    ammo1num_pos = { x = 17, y = 0 },
    ammo1num_font = { font = "Roboto Light", size = 24, weight = 1000, italic = false },
    ammo1num_digits = 2,
    ammo1num_clips = true,
    ammo1tray = false,
    ammo1_size = { x = 46, y = 24},
    ammo1icon = true,
    ammo1icon_pos = { x = 9, y = 12 },
    ammo1icon_size = 4,
    ammo1icon_angle = 297,
    
    clip2_copy = true,

    ammo2_separate = true,
    ammo2_copy = true,
    ammo2_always = true,
    ammo2_pos = { x = 12, y = 39 }
} )