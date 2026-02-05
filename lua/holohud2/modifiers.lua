--- Changes the font's properties.
--- @param value table
--- @param mod table
--- @return table
local function font_props( self, value, mod )

    local italic = value.italic

    if mod.italic ~= nil then

        italic = mod.italic

    end

    return { font = mod.font, size = value.size + ( mod.size or 0 ), weight = mod.weight or value.weight, italic = italic }

end

--- Applies an offset.
--- @param value table
--- @param mod table
--- @return table
local function offset( self, value, mod )

    if isnumber( value ) then

        return value + mod.y

    end

    return { x = value.x + mod.x, y = value.y + mod.y }

end

HOLOHUD2.modifier.Register( "color" )
HOLOHUD2.modifier.Register( "number_font", font_props )
HOLOHUD2.modifier.Register( "number_offset", offset )
HOLOHUD2.modifier.Register( "number2_font", font_props )
HOLOHUD2.modifier.Register( "number2_offset", offset )
HOLOHUD2.modifier.Register( "number3_font", font_props )
HOLOHUD2.modifier.Register( "number3_offset", offset )
HOLOHUD2.modifier.Register( "text_font", font_props )
HOLOHUD2.modifier.Register( "text_offset", offset )
HOLOHUD2.modifier.Register( "text2_font", font_props )
HOLOHUD2.modifier.Register( "text2_offset", offset )
HOLOHUD2.modifier.Register( "number_rendermode" )
HOLOHUD2.modifier.Register( "number_background" )
HOLOHUD2.modifier.Register( "background" )
HOLOHUD2.modifier.Register( "background_color" )
HOLOHUD2.modifier.Register( "panel_animation" )
HOLOHUD2.modifier.Register( "autohide" )

--- Replaces all secondary colours with a single one.
--- @param self table unused
--- @param value number
--- @param mod table
--- @return table|nil
HOLOHUD2.modifier.Register( "color2", function( self, value, mod )

    if IsColor( value ) then

        return mod

    end

    return { colors = { [ 0 ] = mod }, fraction = true, gradual = false }

end)

--- Rescale all sizes.
--- @param self table unused
--- @param value number|table
--- @param mod number
--- @return number
HOLOHUD2.modifier.Register( "scale", function( self, value, mod )

    mod = math.Clamp( mod, .01, 3 )

    if istable( value ) then

        local copy = table.Copy(value)

        if value.font then

            copy.size = copy.size * mod

        elseif value.x and value.y then

            copy.x = value.x * mod
            copy.y = value.y * mod

        end

        return copy

    end

    return value * mod

end)
