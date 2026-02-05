local CurTime = CurTime
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow

local singletray        = false
local dock_x, dock_y    = 0, 0
local dir_x, dir_y      = 0, 0
local inverted          = false

local ELEMENT = {
    name        = "#holohud2.hazards",
    helptext    = "#holohud2.hazards.helptext",
    parameters  = {
        singletray          = { name = "#holohud2.hazards.single_tray", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.hazards.single_tray.helptext" },
        verticaltray        = { name = "#holohud2.hazards.vertical_tray", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.hazards.vertical_tray.helptext" },
        delay               = { name = "#holohud2.parameter.delay", type = HOLOHUD2.PARAM_NUMBER, value = 8, min = 0 },

        pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction           = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin              = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order               = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 64 },

        size                = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 24, min = 0 },
        padding             = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color    = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation           = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color               = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        damage              = { name = "#holohud2.hazards.damage_effect", type = HOLOHUD2.PARAM_BOOL, value = true },
        damage_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 42, 42 ) },
        damage_time         = { name = "#holohud2.parameter.duration", type = HOLOHUD2.PARAM_NUMBER, value = 1, min = 0, decimals = 1, helptext = "#holohud2.hazards.duration.helptext" },
        blinking            = { name = "#holohud2.hazards.blinking", type = HOLOHUD2.PARAM_BOOL, value = true },
        blink_amount        = { name = "#holohud2.hazards.blinking_amount", type = HOLOHUD2.PARAM_RANGE, value = .4, min = 0, max = 1, decimals = 1 },
        blink_rate          = { name = "#holohud2.hazards.blinking_rate", type = HOLOHUD2.PARAM_NUMBER, value = .6, min = 0, decimals = 1 }
    },
    menu = {
        { id = "singletray" },
        { id = "verticaltray" },
        { id = "delay" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos", parameters = {
                { id = "dock" },
                { id = "direction" },
                { id = "margin" },
                { id = "order" }
            } },
            { id = "size" },
            { id = "padding" },
            { id = "background", parameters = {
                { id = "background_color" }
            } },
            { id = "animation", parameters = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.hazards.category.icons", parameters = {
            { id = "color" },
            { id = "damage", parameters = {
                { id = "damage_color" },
                { id = "damage_time" }
            } },
            { id = "blinking", parameters = {
                { id = "blink_amount" },
                { id = "blink_rate" }
            } }
        } }
    },
    quickmenu = {
        { id = "singletray" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" },
            { id = "padding" }
        } },

        { category = "#holohud2.hazards.category.icons", parameters = {
            { id = "color" },
            { id = "damage", parameters = {
                { id = "damage_color" }
            } },
            { id = "blinking", parameters = {
                { id = "blink_amount" }
            } }
        } }
    }
}

---
--- Active hazard icons
---
local hazards = {}

---
--- Composition
---
local layout    = HOLOHUD2.layout.Register( "hazards" )
local tray      = HOLOHUD2.component.Create( "AnimatedPanel" )
tray:SetLayout( layout )

tray.PaintOver = function( self, x, y )

    x, y = x + self._w * dock_x, y + self._h * dock_y

    for _, hazard in ipairs( hazards ) do

        hazard.component:Paint( x, y )

    end

end

---
--- Layout
---
local invalid_layout = false

function ELEMENT:InvalidateLayout()

    invalid_layout = true

end

function ELEMENT:PerformLayout( settings )

    if not invalid_layout then return end

    local size = settings.size + settings.padding * 2
    local margin = size + ( not singletray and settings.margin or 0 )
    local x, y = margin * math.min( dir_x, 0 ), margin * math.min( dir_y, 0 ) -- if inverted, start shifted

    for i, hazard in ipairs( hazards ) do

        -- apply component settings
        local component = hazard.component
        component:SetSize( settings.size )
        component:SetDamageColor( settings.damage_color )
        component:SetBlinkRate( settings.blink_rate )

        -- apply special settings during startup
        if hazard.preview then

            component:SetColor( Color( settings.color.r * .8, settings.color.g * .8, settings.color.b * .8, settings.color.a * .8 ) )
            component:SetBlinkAmount( 0 )

        else

            component:SetColor( settings.color )
            component:SetBlinkAmount( settings.blinking and settings.blink_amount or 0 )

        end

        if inverted then i = #hazards - i + 1 end -- if inverted, revert order

        -- position icons
        if singletray then

            local center = margin / 2 - settings.size / 2
            component:SetPos( x + center + margin * ( i - 1 ) * dir_x, y + center + margin * ( i - 1 ) * dir_y )
            component:SetVisible( true )

        else

            -- apply panel settings
            local panel = hazard.panel
            panel:SetSize( size, size )
            panel:SetDrawBackground( settings.background )
            panel:SetColor( settings.background_color )
            panel:SetAnimation( settings.animation )
            panel:SetAnimationDirection( settings.animation_direction )

            component:SetPos( size / 2 - settings.size / 2, size / 2 - settings.size / 2 ) -- center icon in panel

            hazard.x = x + margin * ( i - 1 ) * dir_x
            hazard.y = y + margin * ( i - 1 ) * dir_y

        end

    end

    local length = margin * math.max( #hazards, 1 ) -- total length of the layout
    layout:SetSize( settings.verticaltray and size or length, settings.verticaltray and length or size )

    invalid_layout = false

end

function ELEMENT:AddHazard( dmgtype, time )

    local hazard = {
        dmgtype = dmgtype,
        time    = CurTime() + time
    }

    local component = HOLOHUD2.component.Create( "Hazard" )
    component:SetVisible( not singletray ) -- if using a single tray, make icons visible once laid out
    component:SetHazard( dmgtype )
    hazard.component = component

    -- if not using a single tray, create a panel for each icon
    if not singletray then

        local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
        hazard.panel = panel

        panel.PaintOver = function( self, x, y )

            component:Paint( x, y )

        end

        hazard.x, hazard.y = 0, 0 -- panel relative position in layout

    end

    table.insert( hazards, hazard )
    self:InvalidateLayout()

    return hazard

end

---
--- Startup sequence
---
local STARTUP_TIME = 4
local STARTUP_HAZARDS = { DMG_BURN, DMG_SHOCK, DMG_DROWN, DMG_PARALYZE, DMG_POISON, DMG_RADIATION, DMG_ACID, DMG_NERVEGAS, DMG_BLAST, DMG_DISSOLVE }

local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_ACTIVE    = 1

local startup_phase = STARTUP_NONE
local startup_time = 0

function ELEMENT:QueueStartup()

    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    for _, dmgtype in ipairs( STARTUP_HAZARDS ) do

        self:AddHazard( dmgtype, STARTUP_TIME ).preview = true

    end

    startup_phase = STARTUP_ACTIVE
    startup_time = CurTime() + STARTUP_TIME

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:IsStartupOver()

    if startup_phase == STARTUP_ACTIVE and startup_time < CurTime() then

        startup_phase = STARTUP_NONE

    end

    return startup_phase == STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.hazards.startup"

end

---
--- Queue received hazards
---
local queue = {}
local queue_count = 0
HOLOHUD2.hook.Add( "OnTakeDamage", "hazards", function( _, dmgtype, _ )

    if startup_phase ~= STARTUP_NONE then return end

    table.Merge( queue, HOLOHUD2.hazard.Read( dmgtype ) )
    queue_count = table.Count( queue )

end )

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    local curtime = CurTime()

    -- tick existing hazards
    if #hazards > 0 then

        local next = 1
        for i=1, #hazards do

            local hazard = hazards[ next ]

            -- we're trying to add this same hazard again
            if queue[ hazard.dmgtype ] then

                if settings.damage then

                    hazard.component:Damage()

                end

                hazard.time = curtime + settings.delay
                queue[ hazard.dmgtype ] = nil

            end

            -- tick component
            hazard.component:Think()

            -- fade away expired hazards
            if singletray then

                hazard.component:SetFading( hazard.time <= curtime )

                -- if it hasn't faded, don't remove yet
                if not hazard.component:IsFaded() then

                    next = next + 1
                    continue

                end

            else

                hazard.panel:Think()
                hazard.panel:SetDeployed( not self:IsMinimized() and hazard.time > curtime )

                -- if the panel hasn't closed, don't remove yet
                if hazard.panel:IsVisible() then

                    next = next + 1
                    continue

                end

            end

            table.remove( hazards, next )
            self:InvalidateLayout()

        end

    end

    -- add new hazards from queue
    if queue_count > 0 then

        for dmgtype, _ in pairs( queue ) do

            local hazard = self:AddHazard( dmgtype, settings.delay )

            if settings.damage then

                hazard.component:Damage()

            end

            queue[ dmgtype ] = nil
            queue_count = table.Count( queue )

        end

    end

    -- tick single tray
    if singletray then

        tray:Think()
        tray:SetDeployed( not self:IsMinimized() and #hazards > 0 )

    end

    layout:SetVisible( not self:IsMinimized() and #hazards > 0 )

    self:PerformLayout( settings )

end

---
--- Reposition panels when not using the single tray option.
---
HOLOHUD2.hook.Add( "OnLayoutPerformed", "hazards", function()

    if singletray then return end

    for _, hazard in ipairs( hazards ) do

        hazard.panel:SetPos( layout.x + hazard.x, layout.y + hazard.y )

    end

end)

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    if singletray then

        tray:PaintFrame( x, y )
        return

    end

    for _, hazard in ipairs( hazards ) do

        hazard.panel:PaintFrame( x, y )

    end

end

function ELEMENT:Paint( settings, x, y )

    if singletray then

        tray:Paint( x, y )
        return

    end

    for _, hazard in ipairs( hazards ) do

        hazard.panel:Paint( x, y )

    end

end

function ELEMENT:PaintScanlines( settings, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    self:Paint( settings, x, y )
    EndAlphaMultiplier()

end

---
--- Preview
---
local PREVIEW_HAZARDS = {
    { DMG_BURN, DMG_SHOCK, DMG_ACID, DMG_POISON, DMG_RADIATION },
    { DMG_DROWN, DMG_PARALYZE, DMG_NERVEGAS, DMG_BLAST, DMG_DISSOLVE }
}

local preview_icons = 2
local preview_damage = 0
local preview_hazards = {}

for _, hazard in ipairs( PREVIEW_HAZARDS[ 1 ] ) do

    local component = HOLOHUD2.component.Create( "Hazard" )
    component:SetHazard( hazard )

    table.insert( preview_hazards, component )

end

function ELEMENT:OnPreviewChanged( settings )

    for _, hazard in ipairs( preview_hazards ) do

        hazard:SetSize( settings.size )
        hazard:SetColor( settings.color )
        hazard:SetDamageColor( settings.damage_color )
        hazard:SetDamageTime( settings.damage_time )
        hazard:SetBlinkAmount( settings.blinking and settings.blink_amount or 0 )
        hazard:SetBlinkRate( settings.blink_rate )

    end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local curtime = CurTime()
    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()
    local marginx, marginy = 1, 0

    if settings.verticaltray then

        marginx, marginy = 0, 1

    end

    local margin = settings.singletray and 0 or settings.margin * scale
    local padding = settings.padding * scale
    local size = settings.size * scale
    local backgroundsize = size + padding * 2
    local trayw, trayh = backgroundsize + marginx * ( backgroundsize + margin ) * ( #preview_hazards - 1 ), backgroundsize + marginy * ( backgroundsize + margin ) * ( #preview_hazards - 1 )

    x, y = x + w / 2 - trayw / 2, y + h / 2 - trayh / 2

    if settings.singletray then

        if settings.background then draw.RoundedBox( 0, x, y, trayw, trayh, settings.background_color ) end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, trayw, trayh )

    end

    for i, hazard in ipairs( preview_hazards ) do

        local x, y = x + marginx * ( backgroundsize + margin ) * ( i - 1 ), y + marginy * ( backgroundsize + margin ) * ( i - 1 )

        if not settings.singletray then

            if settings.background then draw.RoundedBox( 0, x, y, backgroundsize, backgroundsize, settings.background_color ) end

            surface.SetDrawColor( wireframe_color )
            surface.DrawOutlinedRect( x, y, backgroundsize, backgroundsize )

        end

        if settings.damage and preview_damage < curtime then

            hazard:Damage()

        end

        hazard:Think()
        hazard:Paint( x + backgroundsize / 2 - size / 2, y + backgroundsize / 2 - size / 2 )

    end

    if preview_damage < curtime then

        preview_icons = preview_icons == 1 and 2 or 1

        for i, hazard in ipairs( preview_hazards ) do

            hazard:SetHazard( PREVIEW_HAZARDS[ preview_icons ][ i ] )

        end

        preview_damage = curtime + 3

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    singletray = settings.singletray

    layout:SetOrder( settings.order )
    layout:SetDirection( settings.direction )
    layout:SetDock( settings.dock )
    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetMargin( settings.margin )

    tray:SetDrawBackground( settings.background )
    tray:SetColor( settings.background_color )
    tray:SetAnimation( settings.animation )
    tray:SetAnimationDirection( settings.animation_direction )

    if settings.verticaltray then

        dock_x, dir_x = 0, 0

        if settings.dock > HOLOHUD2.DOCK.TOP_RIGHT then

            dock_y = 1
            dir_y = singletray and -1 or 1
        else

            dock_y = 0
            dir_y = 1

        end

        inverted = settings.dock >= HOLOHUD2.DOCK.BOTTOM_LEFT

    else

        dock_y, dir_y = 0, 0

        if settings.dock == HOLOHUD2.DOCK.TOP_RIGHT and settings.dock == HOLOHUD2.DOCK.RIGHT or settings.dock == HOLOHUD2.DOCK.BOTTOM_RIGHT then

            dock_x = 1
            dir_x = singletray and -1 or 1

        else

            dock_x = 0
            dir_x = 1

        end

        inverted = settings.dock ~= HOLOHUD2.DOCK.TOP_LEFT and settings.dock ~= HOLOHUD2.DOCK.LEFT and settings.dock ~= HOLOHUD2.DOCK.BOTTOM_LEFT

    end

    table.Empty( hazards )

    self:InvalidateLayout()

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    tray:InvalidateLayout()

    for _, hazard in ipairs( hazards ) do

        hazard.component:InvalidateLayout()

        if not hazard.panel then continue end

        hazard.panel:InvalidateLayout()

    end

end

HOLOHUD2.element.Register( "hazards", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    tray        = tray,
    hazards     = hazards
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "hazards", "animation" )
HOLOHUD2.modifier.Add( "background", "hazards", "background" )
HOLOHUD2.modifier.Add( "background_color", "hazards", "background_color" )
HOLOHUD2.modifier.Add( "color", "hazards", "color" )
HOLOHUD2.modifier.Add( "scale", "hazards", { "pos", "margin", "size", "padding" } )

---
--- Presets
---
HOLOHUD2.presets.Register( "hazards", "element/hazards" )
