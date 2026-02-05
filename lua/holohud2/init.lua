---
--- Modules
---
HOLOHUD2.AddSharedFile( "modules/system.lua" )
HOLOHUD2.AddCSLuaFile( "modules/ammo.lua" )
HOLOHUD2.AddCSLuaFile( "modules/bind_press.lua" )
HOLOHUD2.AddCSLuaFile( "modules/component.lua" )
HOLOHUD2.AddCSLuaFile( "modules/credits.lua" )
HOLOHUD2.AddSharedFile( "modules/damage.lua" )
HOLOHUD2.AddCSLuaFile( "modules/font.lua" )
HOLOHUD2.AddCSLuaFile( "modules/hazard.lua" )
HOLOHUD2.AddSharedFile( "modules/hook.lua" )
HOLOHUD2.AddCSLuaFile( "modules/item.lua" )
HOLOHUD2.AddCSLuaFile( "modules/killicon.lua" )
HOLOHUD2.AddCSLuaFile( "modules/modifier.lua" )
HOLOHUD2.AddCSLuaFile( "modules/presets.lua" )
HOLOHUD2.AddCSLuaFile( "modules/render.lua" )
HOLOHUD2.AddCSLuaFile( "modules/scale.lua" )
HOLOHUD2.AddCSLuaFile( "modules/layout.lua" ) -- requires: scale
HOLOHUD2.AddSharedFile( "modules/util.lua" )
HOLOHUD2.AddCSLuaFile( "modules/persistence.lua" ) -- requires: util
HOLOHUD2.AddCSLuaFile( "modules/vgui.lua" )
HOLOHUD2.AddCSLuaFile( "modules/weapon.lua" )
HOLOHUD2.AddCSLuaFile( "modules/element.lua" ) -- requires: hook
HOLOHUD2.AddCSLuaFile( "modules/settings.lua" ) -- requires: hook
HOLOHUD2.AddCSLuaFile( "modules/client.lua" ) -- requires: settings
HOLOHUD2.AddSharedFile( "modules/server.lua" ) -- requires: settings
HOLOHUD2.AddCSLuaFile( "modules/gamemode.lua" ) -- requires: settings

---
--- Pre initialization
---
if CLIENT then

    local LocalPlayer = LocalPlayer
    local hook_Call = HOLOHUD2.hook.Call

    HOLOHUD2.WIREFRAME_COLOR = Color( 255, 0, 0, 144 )

    local enabled       = CreateClientConVar( "holohud2", 1, true, false, "Should the HUD render.", 0, 1 )
    local nosuit        = CreateClientConVar( "holohud2_nosuit", 0, true, false, "Should the HUD render without needing to have the suit equipped.", 0, 1 )
    local drawhud       = GetConVar( "cl_drawhud" )

    local localplayer
    local suit_equipped     = true
    local was_suit_equipped = true
    local visible           = true

    --- Returns whether the HUD is enabled by the user.
    --- @return boolean enabled
    function HOLOHUD2.IsEnabled()

        return enabled:GetBool()

    end

    --- Returns whether the HUD should render.
    --- @return boolean visible
    function HOLOHUD2.IsVisible()

        local override = hook_Call( "ShouldDrawHUD" )

        if override ~= nil then return override end

        return visible

    end

    --- Updates the status of the suit equipped on the player.
    function HOLOHUD2.Precache()

        visible = drawhud:GetBool() and enabled:GetBool()

        if not visible then return end

        visible = visible and ( suit_equipped or nosuit:GetBool() )

        -- notify if the suit is equipped
        if suit_equipped ~= was_suit_equipped then

            if not was_suit_equipped then

                hook_Call( "OnSuitEquipped" )

            end

            was_suit_equipped = suit_equipped

        end

        -- update the suit status
        localplayer = localplayer or LocalPlayer()

        if not localplayer:Alive() or localplayer:Health() <= 0 then return end

        suit_equipped = localplayer:IsSuitEquipped()

    end

    --- Global HUD offset.
    HOLOHUD2.offset = { x = 0, y = 0 }

end

---
--- Non-module includes
---
HOLOHUD2.AddCSLuaFile( "credits.lua" )
HOLOHUD2.AddCSLuaFile( "sway.lua" )
HOLOHUD2.AddCSLuaFile( "ammotypes.lua" )
HOLOHUD2.AddCSLuaFile( "weapons.lua" )
HOLOHUD2.AddCSLuaFile( "hazards.lua" )
HOLOHUD2.AddCSLuaFile( "killicons.lua" )
HOLOHUD2.AddCSLuaFile( "render.lua" )
HOLOHUD2.AddSharedFile( "components.lua" )
HOLOHUD2.AddCSLuaFile( "modifiers.lua" )
HOLOHUD2.AddSharedFile( "elements.lua" )
HOLOHUD2.AddCSLuaFile( "inspect.lua" )
HOLOHUD2.AddSharedFile( "vgui.lua" )
HOLOHUD2.AddCSLuaFile( "options.lua" )
HOLOHUD2.AddCSLuaFile( "menu.lua" )
HOLOHUD2.AddCSLuaFile( "toolmenu.lua" )

---
--- Load third-party add-ons
---
local function load_addons()

    HOLOHUD2.system.Log( HOLOHUD2.LOG_WARN, "Reading third-party add-ons..." )

    for _, addon in ipairs( file.Find( "holohud2/add-ons/*.lua", "LUA" ) ) do

        HOLOHUD2.AddSharedFile( "holohud2/add-ons/" .. addon )
        HOLOHUD2.system.Log( HOLOHUD2.LOG_INFO, "Found " .. addon )

    end

end
hook.Add( "OnGamemodeLoaded", "holohud2_addons", load_addons )
if GAMEMODE then load_addons() end

---
--- Initialization
---
if SERVER then return end

local IsValid = IsValid
local LocalPlayer = LocalPlayer

local IsEnabled = HOLOHUD2.IsEnabled
local IsVisible = HOLOHUD2.IsVisible
local Precache = HOLOHUD2.Precache

local Layout = HOLOHUD2.layout.Layout
local hook_Call = HOLOHUD2.hook.Call

local ComputeBlur = HOLOHUD2.render.ComputeBlur
local ComputeHUD = HOLOHUD2.render.ComputeHUD

local RenderHUDBackground = HOLOHUD2.render.RenderHUDBackground
local RenderHUD = HOLOHUD2.render.RenderHUD

local offset = HOLOHUD2.offset

local predraw = {} -- elements to call predraw on
local chud = {} -- CHud elements to hide
local on_overlay = false
local settings = {}
local init = false

---
--- Run HUD logic
---
hook.Add( "PreDrawHUD", "holohud2", function()

    if not init then return end

    Precache()

    if not IsVisible() then return end

    on_overlay = hook_Call( "ShouldDrawOnOverlay" )

    if not hook_Call( "PreDrawHUD", settings ) then

        for i=1, #predraw do

            local element = predraw[ i ]

            element:PreDraw( settings[ element.id ] )

        end

    end

    Layout()
    ComputeBlur()
    ComputeHUD( settings, on_overlay )

    offset.x, offset.y = 0, 0
    hook_Call( "CalcOffset", offset )

end)

---
--- Draw HUD Background
---
hook.Add( "HUDPaintBackground", "holohud2", function()

    if on_overlay then return end
    if not IsVisible() then return end
    if not init then return end

    RenderHUDBackground( settings )

end)

---
--- Draw HUD
---
hook.Add( "HUDPaint", "holohud2", function()

    if on_overlay then return end
    if not IsVisible() then return end
    if not init then return end

    RenderHUD( settings, false )

end)

---
--- Draw HUD on overlay
---
hook.Add( "DrawOverlay", "holohud2", function()

    if not on_overlay then return end
    if not IsVisible() then return end
    if not init then return end

    RenderHUDBackground( settings )
    RenderHUD( settings, true )

end)

local localplayer
HOLOHUD2.hook.Add( "ShouldDrawOnOverlay", "holohud2", function()

    localplayer = localplayer or LocalPlayer()

    if not localplayer.GetActiveWeapon then return end

    local weapon = localplayer:GetActiveWeapon()

    if not IsValid( weapon ) or weapon:GetClass() ~= "gmod_camera" then return end

    return true

end)

---
--- Hide default HUD elements
---
hook.Add( "HUDShouldDraw", "holohud2", function( name )

    if not IsEnabled() then return end
    if not init then return false end
    if not chud[ name ] then return end

    return false

end)

---
--- Resize HUD when the screen size changes.
---
HOLOHUD2.hook.Add( "OnScaleChanged", "holohud2", function()

    HOLOHUD2.font.Generate()
    HOLOHUD2.render.RefreshScreenTextures()
    HOLOHUD2.element.OnScreenSizeChanged()

end)

---
--- Rebuild HUD when settings change.
---
HOLOHUD2.hook.Add( "OnSettingsChanged", "holohud2", function( data )

    local elements = HOLOHUD2.element.All()
    predraw = {}
    chud = {}
    settings = data
    HOLOHUD2.font.Fetch( settings )

    for id, parameters in pairs( settings ) do

        local element = elements[ id ]

        if not element then continue end -- skip removed elements

        -- apply new settings
        element:OnSettingsChanged( parameters )

        -- rebuild visibility function
        element.IsVisible = function() return parameters._visible end

        if not parameters._visible then continue end

        table.insert( predraw, element )

        -- get CHud elements to hide
        for _, name in ipairs( element.hide ) do

            chud[ name ] = true

        end

    end

end)

---
--- Refresh HUD elements when language changes.
---
cvars.AddChangeCallback( "gmod_language", function() HOLOHUD2.element.OnScreenSizeChanged() end)

---
--- Initialize
---
local function initialize()

    timer.Simple( .16, HOLOHUD2.render.RefreshScreenTextures )

    HOLOHUD2.settings.Register( HOLOHUD2.element.GetDefaultValues(), HOLOHUD2.SETTINGS_DEFAULT )

    local settings, modifiers = HOLOHUD2.persistence.ReadTemp()
    HOLOHUD2.client.SubmitModifiers( modifiers )
    HOLOHUD2.client.Submit( settings )

    HOLOHUD2.settings.Merge()

    hook_Call( "OnInitialized" )
    init = true

end
hook.Add( "PostGamemodeLoaded", "holohud2", initialize )
if GAMEMODE then initialize() end
