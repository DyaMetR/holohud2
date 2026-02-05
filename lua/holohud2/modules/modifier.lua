---
--- Modifiers are functions used to apply a consistent modification
--- to a group of parameters. This is used in the general options
--- panel to change multiple similar parameters at once.
---
--- Each function will be called with two parameters: the original value
--- and the modifier value to apply to said value.
---

HOLOHUD2.modifier = {}

local modifiers = {}

---
--- Define MODIFIER structure.
---
local MODIFIER = {}

---
--- Adds one or multiple parameters of an element to this modifier.
--- @param element string
--- @param parameters string|table
---
function MODIFIER:Add( element, parameters )

    if not self.parameters[ element ] then self.parameters[ element ] = {} end

    if istable( parameters ) then

        table.Add( self.parameters[ element ], parameters )

    else

        table.insert( self.parameters[ element ], parameters )

    end

end

--- Returns a list of the modified values from the given settings table.
--- @param settings table
--- @param value any modifier value
--- @param id string|nil element identifier
--- @return any result
function MODIFIER:Call( settings, value, id )

    local values = {}

    if id then

        local element = settings[ id ]

        if not element then return values end

        local parameters = self.parameters[ id ]

        if not parameters then return values end

        for _, parameter in pairs( parameters ) do

            local dest = element[ parameter ]

            if not dest then continue end

            local result = self:Apply( dest, value )

            if result == nil then continue end

            values[ parameter ] = result

        end

        return values

    end

    for id, parameters in pairs( self.parameters ) do

        local element = settings[ id ]

        if not element then continue end

        values[ id ] = {}

        for _, parameter in pairs( parameters ) do

            local dest = element[ parameter ]

            if not dest then continue end

            local result = self:Apply( dest, value )

            if result == nil then continue end

            values[ id ][ parameter ] = result

        end

    end

    return values

end

--- Applies the modification to a value, returning the modified value.
--- @param destination any destination value
--- @param value any modifier value
--- @return any
function MODIFIER:Apply( destination, value )

    if istable( destination ) then

        return table.Copy( value )

    end

    return value

end

--- Registers a modifier.
--- @param id string
--- @param func function|nil
--- @return table modifier
function HOLOHUD2.modifier.Register( id, func )

    local modifier = table.Copy( MODIFIER )
    modifier.parameters = {}

    if func then

        modifier.Apply = func

    end

    modifiers[ id ] = modifier

    return modifier

end

--- Adds parameters to a modifier.
--- @param id string modifier identifier
--- @param element string
--- @param params string|table
function HOLOHUD2.modifier.Add( id, element, params )

    if not modifiers[ id ] then return end

    modifiers[ id ]:Add( element, params )

end

--- Calls a modifier's (or all of them) function(s) on a settings table.
--- @param id string|table modifier identifier (or settings table)
--- @param settings table|any table of settings to modify (or the modification value/s)
--- @param value any|table|string|nil modifier value(s) (or element to modify)
--- @param element string|nil whether we should only modify a specific element's parameters and which (if a modifier is specified)
--- @return table result table of modified values
function HOLOHUD2.modifier.Call( id, settings, value, element )

    if istable( id ) then

        local values = {}

        for mid, modifier in pairs( modifiers ) do

            if settings[ mid ] == nil then continue end

            table.Merge( values, modifier:Call( id, settings[ mid ], value ) )

        end

        return values

    end

    return modifiers[ id ]:Call( settings, value, element )

end

--- Returns a registered modifier.
--- @param id string
--- @return table modifier
function HOLOHUD2.modifier.Get( id )

    return modifiers[ id ]

end

--- Returns all registered modifiers.
--- @return table modifiers
function HOLOHUD2.modifier.All()

    return modifiers

end
