
HOLOHUD2.settings = {}

local refresh   = false -- should the settings refresh on next tick

local layers    = {} -- registered layers of values
local settings  = {} -- resulting settings from merging all layers

--- Registers a settings layer.
--- @param values table
--- @param priority number|nil
function HOLOHUD2.settings.Register( values, priority )

    local layer = { values = values }
    local i = table.insert( layers, layer )
    layer.priority = priority or i

end

--- Merges all registered settings layers.
function HOLOHUD2.settings.Merge()

    refresh = true

end

--- Returns the merged settings.
--- @param id string|nil element identifier
--- @return table settings
function HOLOHUD2.settings.Get( id )

    if id then

        return settings[ id ]

    end

    return settings

end

---
--- Merging is expensive, so queue it in case we signal multiple layers to merge at once.
---
hook.Add( "PreDrawHUD", "holohud2_settings", function()

    if not refresh then return end

    settings = {}

    for i, layer in SortedPairsByMemberValue( layers, "priority" ) do

        for element, values in pairs( layer.values ) do

            if not settings[ element ] then settings[ element ] = {} end

            for parameter, value in pairs( values ) do

                if istable( value ) then value = table.Copy( value ) end

                settings[ element ][ parameter ] = value

            end

        end

    end

    HOLOHUD2.hook.Call( "OnSettingsChanged", settings )

    refresh = false

end)

---
--- Settings layers
---
HOLOHUD2.SETTINGS_DEFAULT               = 0
HOLOHUD2.SETTINGS_LUA_DEFAULT           = 1
HOLOHUD2.SETTINGS_SERVER_DEFAULT        = 2
HOLOHUD2.SETTINGS_CLIENT_MODIFIERS      = 3
HOLOHUD2.SETTINGS_CLIENT                = 4
HOLOHUD2.SETTINGS_LUA                   = 5
HOLOHUD2.SETTINGS_SERVER                = 6
