if CLIENT then

    local FONT_FALLBACK = { font = "Tahoma", size = 12, weight = 500, italic = false }

    ---
    --- Default parameter types
    ---
    HOLOHUD2.PARAM_NONE             = "none"
    HOLOHUD2.PARAM_BOOL             = "bool"
    HOLOHUD2.PARAM_NUMBER           = "number"
    HOLOHUD2.PARAM_STRING           = "string"
    HOLOHUD2.PARAM_COLOR            = "color"
    HOLOHUD2.PARAM_VECTOR           = "vector"
    HOLOHUD2.PARAM_OPTION           = "option"
    HOLOHUD2.PARAM_FONT             = "font"
    HOLOHUD2.PARAM_RANGE            = "range"
    HOLOHUD2.PARAM_COLORRANGES      = "color_ranges"
    HOLOHUD2.PARAM_DOCK             = "dock"
    HOLOHUD2.PARAM_DIRECTION        = "direction"
    HOLOHUD2.PARAM_GROWDIRECTION    = "grow_direction"
    HOLOHUD2.PARAM_TEXTALIGN        = "text_align"
    HOLOHUD2.PARAM_ORDER            = "order"
    HOLOHUD2.PARAM_STRINGTABLE      = "string_table"

    ---
    --- Order parameters
    ---
    local order = {}

    --- Extension function for the element module.
    --- Returns the registered order type parameters.
    --- @return table
    function HOLOHUD2.element.GetOrderParameters()

        return order

    end

    ---
    --- Implement parameter types
    ---
    HOLOHUD2.hook.Add( "OnParameterDefined", "holohud2", function( element, parameter )

        if parameter.type == HOLOHUD2.PARAM_FONT then
            
            if not element.fonts then
                
                element.fonts = {}
                element.preview_fonts = {}
            
            end

            local fontname = string.format( "holohud2_%s_%s", element.id, parameter.id )
            local previewname = string.format( "holohud2_preview_%s_%s", element.id, parameter.id )

            parameter.fontname = fontname
            parameter.previewfont = previewname

            element.fonts[ parameter.id ] = fontname
            element.preview_fonts[ parameter.id ] = previewname

        elseif parameter.type == HOLOHUD2.PARAM_ORDER then

            if not order[ element.id ] then order[ element.id ] = {} end
            order[ element.id ][ parameter.id ] = true

        end

    end)

    --- Extension function for the fonts module.
    --- Registers all fonts from the provided settings.
    --- @param settings table
    function HOLOHUD2.font.Fetch( settings )

        for _, element in pairs( HOLOHUD2.element.All() ) do

            if not element.fonts then continue end

            for parameter, name in pairs( element.fonts ) do
                
                HOLOHUD2.font.Register( name, settings[ element.id ][ parameter ] )
                
                if HOLOHUD2.font.Get( name ) then continue end -- NOTE: this makes sure we have a fallback font so errors don't pop up!

                HOLOHUD2.font.Register( element.preview_fonts[ parameter ], FONT_FALLBACK )

            end

        end

        HOLOHUD2.font.Generate()

    end

end

---
--- Default elements
---
HOLOHUD2.AddCSLuaFile( "elements/border.lua" )
HOLOHUD2.AddSharedFile( "elements/health.lua" )
HOLOHUD2.AddSharedFile( "elements/ammo.lua" )
HOLOHUD2.AddSharedFile( "elements/suitpower.lua" )
HOLOHUD2.AddCSLuaFile( "elements/damageindicator.lua" )
HOLOHUD2.AddSharedFile( "elements/death.lua" )
HOLOHUD2.AddCSLuaFile( "elements/hazards.lua" )
HOLOHUD2.AddSharedFile( "elements/weaponselection.lua" )
HOLOHUD2.AddSharedFile( "elements/resourcehistory.lua" )
HOLOHUD2.AddSharedFile( "elements/deathnotice.lua" )
HOLOHUD2.AddSharedFile( "elements/quickinfo.lua" )
HOLOHUD2.AddSharedFile( "elements/radar.lua" )
HOLOHUD2.AddSharedFile( "elements/compass.lua" )
HOLOHUD2.AddSharedFile( "elements/clock.lua" )
HOLOHUD2.AddSharedFile( "elements/squad.lua" )
HOLOHUD2.AddSharedFile( "elements/zoom.lua" )
HOLOHUD2.AddSharedFile( "elements/targetid.lua" )
HOLOHUD2.AddSharedFile( "elements/npcid.lua" )
HOLOHUD2.AddSharedFile( "elements/entityid.lua" )
HOLOHUD2.AddSharedFile( "elements/fps.lua" )
HOLOHUD2.AddSharedFile( "elements/ping.lua" )
HOLOHUD2.AddSharedFile( "elements/propcount.lua" )
HOLOHUD2.AddSharedFile( "elements/playercount.lua" )
HOLOHUD2.AddSharedFile( "elements/speedometer.lua" )
HOLOHUD2.AddSharedFile( "elements/startup.lua" )
HOLOHUD2.AddCSLuaFile( "elements/notifications.lua" )

HOLOHUD2.AddCSLuaFile( "elements/extension/hudtimer.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudmeter.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudmoney.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudshields.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudcounter.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudstims.lua" )
HOLOHUD2.AddCSLuaFile( "elements/extension/hudkillstreaks.lua" )

HOLOHUD2.AddCSLuaFile( "elements/timer.lua" )
HOLOHUD2.AddCSLuaFile( "elements/flashlight.lua" )
HOLOHUD2.AddCSLuaFile( "elements/stamina.lua" )
HOLOHUD2.AddCSLuaFile( "elements/oxygen.lua" )
HOLOHUD2.AddCSLuaFile( "elements/money.lua" )
HOLOHUD2.AddCSLuaFile( "elements/hunger.lua" )
HOLOHUD2.AddCSLuaFile( "elements/shields.lua" )
HOLOHUD2.AddCSLuaFile( "elements/stims.lua" )
HOLOHUD2.AddCSLuaFile( "elements/killstreak.lua" )