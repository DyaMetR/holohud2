HOLOHUD2.AddCSLuaFile( "zoom/hudelevation.lua" )
HOLOHUD2.AddCSLuaFile( "zoom/hudzoomdisplay.lua" )
HOLOHUD2.AddCSLuaFile( "zoom/hudzoom.lua" )
HOLOHUD2.AddCSLuaFile( "zoom/hudzoomdistance.lua" )

if SERVER then return end

-- FIXME: when changing resolutions it gets decentered

local LocalPlayer = LocalPlayer
local EyePos = EyePos
local EyeAngles = EyeAngles
local FrameTime = FrameTime
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local ELEMENT = {
    name        = "#holohud2.zoom",
    hide        = "CHudZoom",
    helptext    = "#holohud2.zoom.helptext",
    parameters  = {
        elevation                       = { name = "#holohud2.common.visible", type = HOLOHUD2.PARAM_BOOL, value = true },
        elevation_pos                   = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 184, y = 0 }, helptext = "#holohud2.zoom.offset.helptext" },
        elevation_size                  = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 32, y = 360 } },
        elevation_background            = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        elevation_background_color      = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        elevation_animation             = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        elevation_animation_direction   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_CENTER_VERTICAL },
        elevation_padding               = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4 },
        elevation_scale                 = { name = "#holohud2.zoom.visible_height", type = HOLOHUD2.PARAM_RANGE, value = .3, min = 0, max = 1, decimals = 1, helptext = "#holohud2.zoom.visible_height.helptext" },
        elevation_color                 = { name = "#holohud2.zoom.angles_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        elevation_color2                = { name = "#holohud2.zoom.graduation_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        elevation_gap                   = { name = "#holohud2.zoom.gap", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        elevation_font                  = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 0, italic = false } },

        zoom                            = { name = "#holohud2.common.visible", type = HOLOHUD2.PARAM_BOOL, value = true },
        zoom_pos                        = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = -180 }, helptext = "#holohud2.zoom.offset.helptext" },
        zoom_size                       = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 60, y = 20 } },
        zoom_align                      = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        zoom_background                 = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        zoom_background_color           = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        zoom_animation                  = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        zoom_animation_direction        = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },
        zoom_color                      = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        zoom_color2                     = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        zoomnum                         = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        zoomnum_pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 36, y = 2 } },
        zoomnum_font                    = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 15, weight = 1000, italic = false } },
        zoomnum_rendermode              = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        zoomnum_background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        zoomnum_align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        zoomnum_digits                  = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 1 },
        zoomunit                        = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_BOOL, value = true },
        zoomunit_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 50, y = 6 } },
        zoomunit_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 9, weight = 1000, italic = false } },
        zoomunit_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },
        zoomtext                        = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = true },
        zoomtext_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 5, y = 4 } },
        zoomtext_font                   = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 0, italic = false } },
        zoomtext_text                   = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.ZOOM" },
        zoomtext_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        zoomtext_on_background          = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        distance                        = { name = "#holohud2.common.visible", type = HOLOHUD2.PARAM_BOOL, value = true },
        distance_unit                   = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.DISTANCEUNITS, value = HOLOHUD2.DISTANCE_METRIC },
        distance_pos                    = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 149 }, helptext = "#holohud2.zoom.offset.helptext" },
        distance_size                   = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 72, y = 27 } },
        distance_align                  = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        distance_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        distance_background_color       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        distance_animation              = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        distance_animation_direction    = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },
        distance_color                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        distance_color2                 = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        distancenum                     = { name = "#holohud2.component.number", type = HOLOHUD2.PARAM_BOOL, value = true },
        distancenum_pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 10, y = 3 } },
        distancenum_font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 22, weight = 1000, italic = false } },
        distancenum_rendermode          = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        distancenum_background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        distancenum_align               = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        distancenum_digits              = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 1 },
        distanceunit                    = { name = "#holohud2.parameter.units", type = HOLOHUD2.PARAM_BOOL, value = true },
        distanceunit_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 54, y = 12 } },
        distanceunit_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 10, weight = 0, italic = false } },
        distanceunit_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        distanceunit_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },
        distancetext                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        distancetext_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        distancetext_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 10, weight = 0, italic = false } },
        distancetext_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.DISTANCE" },
        distancetext_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        distancetext_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { tab = "#holohud2.zoom.category.elevation", icon = "icon16/text_columns.png", parameters = {
            { id = "elevation" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "elevation_pos" },
                { id = "elevation_size" },
                { id = "elevation_background", parameters = {
                    { id = "elevation_background_color" }
                } },
                { id = "elevation_animation", parameters = {
                    { id = "elevation_animation_direction" }
                } }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "elevation_color" },
                { id = "elevation_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "elevation_font" },
                { id = "elevation_padding" },
                { id = "elevation_scale" },
                { id = "elevation_gap" }
            } }
        } },
        { tab = "#holohud2.zoom.category.zoom", icon = "icon16/zoom.png", parameters = {
            { id = "zoom" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "zoom_pos" },
                { id = "zoom_size" },
                { id = "zoom_align" },
                { id = "zoom_background", parameters = {
                    { id = "zoom_background_color" }
                } },
                { id = "zoom_animation", parameters = {
                    { id = "zoom_animation_direction" }
                } }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "zoom_color" },
                { id = "zoom_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "zoomnum", parameters = {
                    { id = "zoomnum_pos" },
                    { id = "zoomnum_font" },
                    { id = "zoomnum_rendermode" },
                    { id = "zoomnum_background" },
                    { id = "zoomnum_align" },
                    { id = "zoomnum_digits" }
                } },
                { id = "zoomunit", parameters = {
                    { id = "zoomunit_pos" },
                    { id = "zoomunit_font" },
                    { id = "zoomunit_on_background" }
                } },
                { id = "zoomtext", parameters = {
                    { id = "zoomtext_pos" },
                    { id = "zoomtext_font" },
                    { id = "zoomtext_text" },
                    { id = "zoomtext_align" },
                    { id = "zoomtext_on_background" }
                } }
            } }
        } },
        { tab = "#holohud2.zoom.category.distance", icon = "icon16/map.png", parameters = {
            { id = "distance" },
            { id = "distance_unit" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "distance_pos" },
                { id = "distance_size" },
                { id = "distance_align" },
                { id = "distance_background", parameters = {
                    { id = "distance_background_color" }
                } },
                { id = "distance_animation", parameters = {
                    { id = "distance_animation_direction" }
                } }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "distance_color" },
                { id = "distance_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "distancenum", parameters = {
                    { id = "distancenum_pos" },
                    { id = "distancenum_font" },
                    { id = "distancenum_rendermode" },
                    { id = "distancenum_background" },
                    { id = "distancenum_align" },
                    { id = "distancenum_digits" }
                } },
                { id = "distanceunit", parameters = {
                    { id = "distanceunit_pos" },
                    { id = "distanceunit_font" },
                    { id = "distanceunit_align" },
                    { id = "distanceunit_on_background" }
                } },
                { id = "distancetext", parameters = {
                    { id = "distancetext_pos" },
                    { id = "distancetext_font" },
                    { id = "distancetext_text" },
                    { id = "distancetext_align" },
                    { id = "distancetext_on_background" }
                } }
            } }
        } }
    },
    quickmenu = {
        { tab = "#holohud2.zoom.category.elevation", icon = "icon16/text_columns.png", parameters = {
            { id = "elevation" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "elevation_pos" },
                { id = "elevation_size" }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "elevation_color" },
                { id = "elevation_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "elevation_font" },
                { id = "elevation_padding" },
                { id = "elevation_gap" }
            } }
        } },
        { tab = "#holohud2.zoom.category.zoom", icon = "icon16/zoom.png", parameters = {
            { id = "zoom" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "zoom_pos" },
                { id = "zoom_size" },
                { id = "zoom_align" }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "zoom_color" },
                { id = "zoom_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "zoomnum", parameters = {
                    { id = "zoomnum_pos" },
                    { id = "zoomnum_font" }
                } },
                { id = "zoomunit", parameters = {
                    { id = "zoomunit_pos" },
                    { id = "zoomunit_font" }
                } },
                { id = "zoomtext", parameters = {
                    { id = "zoomtext_pos" },
                    { id = "zoomtext_font" }
                } }
            } }
        } },
        { tab = "#holohud2.zoom.category.distance", icon = "icon16/map.png", parameters = {
            { id = "distance" },
            { id = "distance_unit" },

            { category = "#holohud2.category.panel", parameters = {
                { id = "distance_pos" },
                { id = "distance_size" },
                { id = "distance_align" }
            } },

            { category = "#holohud2.category.coloring", parameters = {
                { id = "distance_color" },
                { id = "distance_color2" }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "distancenum", parameters = {
                    { id = "distancenum_pos" },
                    { id = "distancenum_font" }
                } },
                { id = "distanceunit", parameters = {
                    { id = "distanceunit_pos" },
                    { id = "distanceunit_font" }
                } },
                { id = "distancetext", parameters = {
                    { id = "distancetext_pos" },
                    { id = "distancetext_font" }
                } }
            } }
        } }
    }
}

local INF_GLYPH     = "∞"
local MAX_ZOOM      = 3
local ZOOM_SPEED    = 4

---
--- Left elevation compass
---
local hudelevation_left = HOLOHUD2.component.Create( "HudElevation" )
hudelevation_left:SetInverted( true )

local elevation_panel_left = HOLOHUD2.component.Create( "AnimatedPanel" )

elevation_panel_left.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawElevationCompass_Left", x, y, self._w, self._h, LAYER_FRAME )

end

elevation_panel_left.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Left", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudelevation_left:PaintBackground( x, y )

    hook_Call( "DrawOverElevationCompass_Left", x, y, self._w, self._h, LAYER_BACKGROUND, hudelevation_left )

end

elevation_panel_left.PaintOver = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Left", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudelevation_left:Paint( x, y )

    hook_Call( "DrawOverElevationCompass_Left", x, y, self._w, self._h, LAYER_FOREGROUND, hudelevation_left )

end

elevation_panel_left.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Left", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudelevation_left:PaintScanlines( x, y )

    hook_Call( "DrawOverElevationCompass_Left", x, y, self._w, self._h, LAYER_SCANLINES, hudelevation_left )

end

---
--- Right elevation compass
---
local hudelevation_right = HOLOHUD2.component.Create( "HudElevation" )
local elevation_panel_right = HOLOHUD2.component.Create( "AnimatedPanel" )

elevation_panel_right.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawElevationCompass_Right", x, y, self._w, self._h, LAYER_FRAME )

end

elevation_panel_right.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Right", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudelevation_right:PaintBackground( x, y )

    hook_Call( "DrawOverElevationCompass_Right", x, y, self._w, self._h, LAYER_BACKGROUND, hudelevation_right )

end

elevation_panel_right.PaintOver = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Right", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudelevation_right:Paint( x, y )

    hook_Call( "DrawOverElevationCompass_Right", x, y, self._w, self._h, LAYER_FOREGROUND, hudelevation_right )

end

elevation_panel_right.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawElevationCompass_Right", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudelevation_right:PaintScanlines( x, y )

    hook_Call( "DrawOverElevationCompass_Right", x, y, self._w, self._h, LAYER_SCANLINES, hudelevation_right )

end

---
--- Zoom
---
local hudzoom = HOLOHUD2.component.Create( "HudZoom" )
local zoom_panel = HOLOHUD2.component.Create( "AnimatedPanel" )

zoom_panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawZoomMags", x, y, self._w, self._h, LAYER_FRAME )

end

zoom_panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawZoomMags", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudzoom:PaintBackground( x, y )

    hook_Call( "DrawOverZoomMags", x, y, self._w, self._h, LAYER_BACKGROUND, hudzoom )

end

zoom_panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawZoomMags", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudzoom:Paint( x, y )

    hook_Call( "DrawOverZoomMags", x, y, self._w, self._h, LAYER_FOREGROUND, hudzoom )

end

zoom_panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawZoomMags", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudzoom:PaintScanlines( x, y )

    hook_Call( "DrawOverZoomMags", x, y, self._w, self._h, LAYER_SCANLINES, hudzoom )

end

---
--- Distance
---
local hudzoomdistance = HOLOHUD2.component.Create( "HudZoomDistance" )
local distance_panel = HOLOHUD2.component.Create( "AnimatedPanel" )

distance_panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawZoomDistance", x, y, self._w, self._h, LAYER_FRAME )

end

distance_panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawZoomDistance", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudzoomdistance:PaintBackground( x, y )

    hook_Call( "DrawOverZoomDistance", x, y, self._w, self._h, LAYER_BACKGROUND, hudzoomdistance )

end

distance_panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawZoomDistance", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudzoomdistance:Paint( x, y )

    hook_Call( "DrawOverZoomDistance", x, y, self._w, self._h, LAYER_FOREGROUND, hudzoomdistance )

end

distance_panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawZoomDistance", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudzoomdistance:PaintScanlines( x, y )

    hook_Call( "DrawOverZoomDistance", x, y, self._w, self._h, LAYER_SCANLINES, hudzoomdistance )

end

---
--- Startup sequence
---
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    elevation_panel_left:Close()
    elevation_panel_right:Close()
    zoom_panel:Close()
    distance_panel:Close()
    startup = true

end

function ELEMENT:Startup()

    startup = false

end

---
--- Logic
---
local localplayer
local conversion = 1
local animation = 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    localplayer = localplayer or LocalPlayer()
    local frametime = FrameTime()
    local minimized = self:IsMinimized()

    local angle = EyeAngles().p
    hudelevation_left:SetAngle( angle )
    hudelevation_right:SetAngle( angle )

    local trace = localplayer:GetEyeTrace()
    hudzoomdistance:SetValue( trace.Hit and math.floor( conversion * EyePos():Distance( trace.HitPos ) ) or INF_GLYPH )

    local can_zoom = hook_Call( "CanZoom" )
    if can_zoom == nil then can_zoom = localplayer:GetCanZoom() end

    local zoomed = can_zoom and localplayer:KeyDown( IN_ZOOM )
    hudzoom:SetValue( math.max( math.Round( MAX_ZOOM * animation ), 1 ) )

    if zoomed then

        animation = math.min( animation + frametime * ZOOM_SPEED, 1 )

    else

        animation = math.max( animation - frametime * ZOOM_SPEED, 0 )

    end

    elevation_panel_left:SetDeployed( not minimized and zoomed )
    elevation_panel_left:Think()

    if elevation_panel_left:IsVisible() then

        hudelevation_left:Think()

    end

    elevation_panel_right:SetDeployed( not minimized and zoomed )
    elevation_panel_right:Think()

    if elevation_panel_right:IsVisible() then

        hudelevation_right:Think()

    end

    zoom_panel:SetDeployed( not minimized and zoomed )
    zoom_panel:Think()

    if zoom_panel:IsVisible() then

        hudzoom:Think()

    end

    distance_panel:SetDeployed( not minimized and zoomed )
    distance_panel:Think()

    if distance_panel:IsVisible() then

        hudzoomdistance:Think()

    end

end

---
--- Paint
---
local ZOOM_OVERLAY  = surface.GetTextureID( "vgui/zoom" )

function ELEMENT:PaintFrame( settings, x, y )

    elevation_panel_left:PaintFrame( x, y )
    elevation_panel_right:PaintFrame( x, y )
    zoom_panel:PaintFrame( x, y )
    distance_panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )

    elevation_panel_left:PaintBackground( x, y )
    elevation_panel_right:PaintBackground( x, y )
    zoom_panel:PaintBackground( x, y )
    distance_panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )

    elevation_panel_left:Paint( x, y )
    elevation_panel_right:Paint( x, y )
    zoom_panel:Paint( x, y )
    distance_panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    elevation_panel_left:PaintScanlines( x, y )
    elevation_panel_right:PaintScanlines( x, y )
    zoom_panel:PaintScanlines( x, y )
    distance_panel:PaintScanlines( x, y )

end

function ELEMENT:PaintOver( settings )

    local w, h = math.ceil( ScrW() / 2 ), math.ceil( ScrH() / 2 )
    surface.SetTexture( ZOOM_OVERLAY )
    surface.SetDrawColor( color_white.r, color_white.g, color_white.b, color_white.a * animation )
    surface.DrawTexturedRectUV( w, 0, w, h, 0, 0, 1, 1 )
    surface.DrawTexturedRectUV( 0, 0, w, h, 1, 0, 0, 1 )
    surface.DrawTexturedRectUV( 0, h, w, h, 1, 1, 0, 0 )
    surface.DrawTexturedRectUV( w, h, w, h, 0, 1, 1, 0 )

end

---
--- Preview
---
local PREVIEW_ELEVATION = 1
local PREVIEW_ZOOM      = 2
local PREVIEW_DISTANCE  = 3

local preview = PREVIEW_ELEVATION
local preview_elevation = HOLOHUD2.component.Create( "HudElevation" )
local preview_zoom = HOLOHUD2.component.Create( "HudZoom" )
local preview_distance = HOLOHUD2.component.Create( "HudZoomDistance" )

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:SetTall( 46 )
    controls:Dock( BOTTOM )
    controls:DockMargin( 4, 0, 0, 2 )

        local angle = vgui.Create( "DNumSlider", controls )
        angle:SetPos( 2, -6 )
        angle:SetWide( 158 )
        angle:SetText( "#holohud2.zoom.preview.angle" )
        angle:SetMinMax( -180, 180 )
        angle:SetDecimals( 0 )
        angle.OnValueChanged = function( _, value )

            preview_elevation:SetAngle( value )

        end

        local zoom = vgui.Create( "DNumSlider", controls )
        zoom:SetPos( 2, -6 )
        zoom:SetWide( 162 )
        zoom:SetText( "#holohud2.zoom" )
        zoom:SetMinMax( 0, 3 )
        zoom:SetDecimals( 0 )
        zoom.OnValueChanged = function( _, value )

            preview_zoom:SetValue( math.Round( value ) )

        end
        zoom:SetValue( 3 )

        local distance = vgui.Create( "DNumSlider", controls )
        distance:SetPos( 2, -6 )
        distance:SetWide( 154 )
        distance:SetText( "#holohud2.zoom.preview.distance_short" )
        distance:SetMinMax( 0, 9999 )
        distance:SetDecimals( 0 )
        distance.OnValueChanged = function( _, value )

            preview_distance:SetValue( math.Round( value ) )

        end

        local reset = vgui.Create( "DImageButton", controls )
        reset:SetPos( 140, 2 )
        reset:SetSize( 16, 16 )
        reset:SetImage( "icon16/arrow_refresh.png" )
        reset.DoClick = function()

            angle:SetValue( 0 )
            zoom:SetValue( 0 )
            distance:SetValue( 0 )

        end

        local combobox = vgui.Create( "DComboBox", controls )
        combobox:SetY( 22 )
        combobox:SetWide( 156 )
        combobox:SetSortItems( false )
        combobox:AddChoice( "#holohud2.zoom.preview.elevation", PREVIEW_ELEVATION )
        combobox:AddChoice( "#holohud2.zoom.preview.zoom", PREVIEW_ZOOM )
        combobox:AddChoice( "#holohud2.zoom.preview.distance", PREVIEW_DISTANCE )
        combobox.OnSelect = function( _, i )

            preview = i

            angle:SetVisible( i == PREVIEW_ELEVATION )
            zoom:SetVisible( i == PREVIEW_ZOOM )
            distance:SetVisible( i == PREVIEW_DISTANCE )

        end
        combobox:ChooseOptionID( PREVIEW_ELEVATION )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_elevation:ApplySettings( settings, self.preview_fonts )
    preview_zoom:ApplySettings( settings, self.preview_fonts )
    preview_distance:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    if preview == PREVIEW_ELEVATION then

        local w, h = settings.elevation_size.x * scale, settings.elevation_size.y * scale

        x, y = x - w / 2, y - h / 2

        if settings.elevation_background then

            draw.RoundedBox( 0, x, y, w, h, settings.elevation_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_elevation:Think()
        preview_elevation:PaintBackground( x, y )
        preview_elevation:Paint( x, y )

    elseif preview == PREVIEW_ZOOM then

        local w, h = settings.zoom_size.x * scale, settings.zoom_size.y * scale

        x, y = x - w / 2, y - h / 2

        if settings.zoom_background then

            draw.RoundedBox( 0, x, y, w, h, settings.zoom_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_zoom:Think()
        preview_zoom:PaintBackground( x, y )
        preview_zoom:Paint( x, y )

    elseif preview == PREVIEW_DISTANCE then

        local w, h = settings.distance_size.x * scale, settings.distance_size.y * scale

        x, y = x - w / 2, y - h / 2

        if settings.distance_background then

            draw.RoundedBox( 0, x, y, w, h, settings.distance_background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_distance:Think()
        preview_distance:PaintBackground( x, y )
        preview_distance:Paint( x, y )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    local w, h = HOLOHUD2.layout.GetScreenSize()
    local scale = w / HOLOHUD2.SCREEN_WIDTH
    local x, y = math.ceil( w / 2 ), math.ceil( h / 2 )

    -- apply settings to compasses
    for _, compass in ipairs( { { elevation_panel_left, hudelevation_left }, { elevation_panel_right, hudelevation_right } } ) do

        local panel, component = unpack( compass )

        panel:SetPos( panel.x, y - settings.elevation_size.y / 2 + settings.elevation_pos.y )
        panel:SetSize( settings.elevation_size.x, settings.elevation_size.y )
        panel:SetDrawBackground( settings.elevation_background )
        panel:SetColor( settings.elevation_background_color )
        panel:SetAnimation( settings.elevation_animation )
        panel:SetAnimationDirection( settings.elevation_animation_direction )

        component:ApplySettings( settings, self.fonts )

    end

    elevation_panel_left:SetPos( x - settings.elevation_size.x - settings.elevation_pos.x * scale, elevation_panel_left.y )
    elevation_panel_right:SetPos( x + settings.elevation_pos.x * scale, elevation_panel_right.y )

    -- apply settings to zoom panel
    zoom_panel:SetPos( x + settings.zoom_pos.x - ( settings.zoom_align == TEXT_ALIGN_RIGHT and settings.zoom_size.x or ( settings.zoom_align == TEXT_ALIGN_CENTER and settings.zoom_size.x / 2 ) or 0 ), y + settings.zoom_pos.y )
    zoom_panel:SetSize( settings.zoom_size.x, settings.zoom_size.y )
    zoom_panel:SetDrawBackground( settings.zoom_background )
    zoom_panel:SetColor( settings.zoom_background_color )
    zoom_panel:SetAnimation( settings.zoom_animation )
    zoom_panel:SetAnimationDirection( settings.zoom_animation_direction )
    hudzoom:ApplySettings( settings, self.fonts )

    -- apply settings to distance panel
    distance_panel:SetPos( x + settings.distance_pos.x - ( settings.distance_align == TEXT_ALIGN_RIGHT and settings.distance_size.x or ( settings.distance_align == TEXT_ALIGN_CENTER and settings.distance_size.x / 2 ) or 0 ), y + settings.distance_pos.y )
    distance_panel:SetSize( settings.distance_size.x, settings.distance_size.y )
    distance_panel:SetDrawBackground( settings.distance_background )
    distance_panel:SetColor( settings.distance_background_color )
    distance_panel:SetAnimation( settings.distance_animation )
    distance_panel:SetAnimationDirection( settings.distance_animation_direction )
    hudzoomdistance:ApplySettings( settings, self.fonts )

    -- calculate distance conversion factor
    conversion = settings.distance_unit == HOLOHUD2.DISTANCE_METRIC and HOLOHUD2.HU_TO_M or ( settings.distance_unit == HOLOHUD2.DISTANCE_IMPERIAL and HOLOHUD2.HU_TO_FT ) or 1

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    elevation_panel_left:InvalidateLayout()
    hudelevation_left:InvalidateLayout()

    elevation_panel_right:InvalidateLayout()
    hudelevation_right:InvalidateLayout()

    zoom_panel:InvalidateLayout()
    hudzoom:InvalidateLayout()

    distance_panel:InvalidateLayout()
    hudzoomdistance:InvalidateLayout()

end

HOLOHUD2.element.Register( "zoom", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    elevation_panel_left    = elevation_panel_left,
    hudelevation_left       = hudelevation_left,
    elevation_panel_right   = elevation_panel_right,
    hudelevation_right      = hudelevation_right,
    zoom_panel              = zoom_panel,
    hudzoom                 = hudzoom,
    distance_panel          = distance_panel,
    hudzoomdistance         = hudzoomdistance
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "zoom", { "elevation_animation", "zoom_animation", "distance_animation" } )
HOLOHUD2.modifier.Add( "background", "zoom", { "elevation_background", "zoom_background", "distance_background" } )
HOLOHUD2.modifier.Add( "background_color", "zoom", { "elevation_background_color", "zoom_background_color", "distance_background_color" } )
HOLOHUD2.modifier.Add( "color", "zoom", { "elevation_color", "zoom_color", "distance_color" } )
HOLOHUD2.modifier.Add( "color2", "zoom", { "elevation_color2", "zoom_color2", "distance_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "zoom", { "zoomnum_rendermode", "distancenum_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "zoom", { "zoomnum_background", "distancenum_background" } )
HOLOHUD2.modifier.Add( "number_font", "zoom", "distancenum_font" )
HOLOHUD2.modifier.Add( "number_offset", "zoom", "distancenum_pos" )
HOLOHUD2.modifier.Add( "number3_font", "zoom", { "elevation_font", "zoomnum_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "zoom", { "elevation_pos", "zoomnum_pos" } )
HOLOHUD2.modifier.Add( "text_font", "zoom", { "zoomtext_font", "distancetext_font", "distanceunit_font" } )
HOLOHUD2.modifier.Add( "text_offset", "zoom", { "zoomtext_pos", "distancetext_pos", "distanceunit_pos" } )
HOLOHUD2.modifier.Add( "scale", "zoom", {
    "elevation_pos", "elevation_size", "elevation_padding", "elevation_gap", "elevation_font",
    "zoom_pos", "zoom_size", "zoomnum_pos", "zoomnum_font", "zoomunit_pos", "zoomunit_font", "zoomtext_pos", "zoomtext_font",
    "distance_pos", "distance_size", "distancenum_pos", "distancenum_font", "distanceunit_pos", "distanceunit_font", "distancetext_pos", "distancetext_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "zoom", "element/zoom" )
