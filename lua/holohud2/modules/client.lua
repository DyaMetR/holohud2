---
--- Client settings
---

HOLOHUD2.client = {}

local modifiers     = {} -- modifier values
local settings_mods = {} -- layer of changed values
local settings      = {} -- element settings

HOLOHUD2.settings.Register( settings_mods, HOLOHUD2.SETTINGS_CLIENT_MODIFIERS )
HOLOHUD2.settings.Register( settings, HOLOHUD2.SETTINGS_CLIENT )

--- Returns the client settings.
--- @return table settings
function HOLOHUD2.client.Get()

    return settings

end

--- Returns the client modifiers values.
--- @return table modifiers
function HOLOHUD2.client.GetModifiers()

    return modifiers

end

--- Submits the given table as the client settings.
--- @param values table
function HOLOHUD2.client.Submit( values )

    table.CopyFromTo( values, settings )
    HOLOHUD2.settings.Merge()

end

--- Submits the given table as the client modifiers.
--- @param values table
function HOLOHUD2.client.SubmitModifiers( values )

    modifiers = values
    table.CopyFromTo( HOLOHUD2.modifier.Call( HOLOHUD2.element.GetDefaultValues(), modifiers ), settings_mods )
    HOLOHUD2.settings.Merge()

end
