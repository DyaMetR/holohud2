HOLOHUD2.AddCSLuaFile( "resourcehistory/hudweaponpickup.lua" )
HOLOHUD2.AddCSLuaFile( "resourcehistory/hudammopickup.lua" )

if SERVER then return end

local IsValid = IsValid
local CurTime = CurTime
local scale_Get = HOLOHUD2.scale.Get
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow
local hook_Call = HOLOHUD2.hook.Call

local DOCK_CENTER = HOLOHUD2.HORIZONTAL_DOCK.CENTER
local DOCK_RIGHT = HOLOHUD2.HORIZONTAL_DOCK.RIGHT

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND

local weapon_pickup_sound = true

local ELEMENT = {
    name = "#holohud2.resourcehistory",
    helptext = "#holohud2.resourcehistory.helptext",
    parameters = {
        delay                       = { name = "#holohud2.parameter.notification_delay", type = HOLOHUD2.PARAM_NUMBER, value = 5, min = 0, helptext = "#holohud2.parameter.notification_delay.helptext" },
        limit                       = { name = "#holohud2.parameter.notification_limit", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0, helptext = "#holohud2.parameter.notification_limit.helptext" },
        queue                       = { name = "#holohud2.parameter.notification_queue", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.parameter.notification_queue.helptext" },

        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 140 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_RIGHT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 72 },

        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },

        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_LEFT },

        weapon_sound                = { name = "#holohud2.parameter.sound", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.resourcehistory.sound" },
        weapon_size                 = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 144, y = 72 } },

        weapon_name                 = { name = "#holohud2.resourcehistory.weapon_name", type = HOLOHUD2.PARAM_BOOL, value = true },
        weapon_name_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 56 } },
        weapon_name_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 0, italic = false } },
        weapon_name_color           = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200 ) },
        weapon_name_align           = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        weapon_name_animated        = { name = "#holohud2.parameter.animated", type = HOLOHUD2.PARAM_BOOL, value = true },

        weapon_icon                 = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        weapon_icon_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 72, y = 36 } },
        weapon_icon_size            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 140 },
        weapon_icon_color           = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },

        weapon_label                = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = true },
        weapon_label_pos            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        weapon_label_font           = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 10, weight = 1000, italic = false } },
        weapon_label_color          = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 24 ) },
        weapon_label_text           = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.WEAPON_ACQUIRED" },
        weapon_label_align          = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        weapon_label_animated       = { name = "#holohud2.parameter.animated", type = HOLOHUD2.PARAM_BOOL, value = true },

        ammo_mode                   = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.AMMOPICKUPMODES, value = HOLOHUD2.AMMOPICKUPMODE_NAMEFALLBACK },
        ammo_padding                = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 0 },
        ammo_spacing                = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 5 },
        ammo_color                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 186, 92 ) },
        ammo_color2                 = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        ammo_icon_size              = { name = "#holohud2.resourcehistory.icon_size", type = HOLOHUD2.PARAM_NUMBER, value = 8, min = 0 },
        ammo_fallback_font          = { name = "#holohud2.resourcehistory.fallback_font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 1000, italic = false } },

        ammo_amount_offset          = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 0 } },
        ammo_amount_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 20, weight = 1000, italic = false } },
        ammo_amount_rendermode      = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        ammo_amount_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        ammo_amount_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },
        ammo_amount_align           = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        ammo_amount_digits          = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },

        ammo_name_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 12, weight = 0, italic = false } },
        ammo_name_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.AMMOPICKUPNAMEPOS, value = HOLOHUD2.AMMOPICKUPNAMEPOS_UNDER },
        ammo_name_color             = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        ammo_name_align             = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        ammo_name_spacing           = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = -3 },
        ammo_name_animated          = { name = "#holohud2.parameter.animated", type = HOLOHUD2.PARAM_BOOL, value = true },

        item_delay                  = { name = "#holohud2.parameter.notification_delay", type = HOLOHUD2.PARAM_NUMBER, value = 5, min = 0, helptext = "#holohud2.parameter.notification_delay.helptext" },
        item_limit                  = { name = "#holohud2.parameter.notification_limit", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0, helptext = "#holohud2.parameter.notification_limit.helptext" },
        item_queue                  = { name = "#holohud2.parameter.notification_queue", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.parameter.notification_queue.helptext" },

        item_pos                    = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        item_background             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        item_background_color       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        item_animation              = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        item_animation_direction    = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_RIGHT },
        item_dock                   = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        item_direction              = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        item_margin                 = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        item_order                  = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_NUMBER, value = 72 },

        item_padding                = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        item_color                  = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200 ) },
        item_size                   = { name = "#holohud2.resourcehistory.icon_size", type = HOLOHUD2.PARAM_NUMBER, value = 24, min = 0 },
        item_font                   = { name = "#holohud2.resourcehistory.item_name_font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 14, weight = 1000, italic = false }, helptext = "#holohud2.resourcehistory.item_name_font.helptext" }
    },
    menu = {
        { tab = "#holohud2.resourcehistory.tab.weapons", icon = "icon16/gun.png", parameters = {
            { id = "delay" },
            { id = "limit" },
            { id = "queue" },

            { category = "#holohud2.resourcehistory.category.panels", parameters = {
                { id = "pos", parameters = {
                    { id = "dock" },
                    { id = "direction" },
                    { id = "margin" },
                    { id = "order" }
                } },
                { id = "background", parameters = {
                    { id = "background_color" }
                } },
                { id = "animation", parameters = {
                    { id = "animation_direction" }
                } }
            } },

            { category = "#holohud2.resourcehistory.category.weapon_pickup", parameters = {
                { id = "weapon_sound" },
                { id = "weapon_size" },
                { id = "weapon_name", parameters = {
                    { id = "weapon_name_pos" },
                    { id = "weapon_name_font" },
                    { id = "weapon_name_color" },
                    { id = "weapon_name_align" },
                    { id = "weapon_name_animated" }
                } },
                { id = "weapon_icon", parameters = {
                    { id = "weapon_icon_pos" },
                    { id = "weapon_icon_size" },
                    { id = "weapon_icon_color" }
                } },
                { id = "weapon_label", parameters = {
                    { id = "weapon_label_pos" },
                    { id = "weapon_label_font" },
                    { id = "weapon_label_color" },
                    { id = "weapon_label_text" },
                    { id = "weapon_label_align" },
                    { id = "weapon_label_animated" }
                } }
            } },

            { category = "#holohud2.resourcehistory.category.ammo_pickup", parameters = {
                { id = "ammo_mode" },
                { id = "ammo_padding" },
                { id = "ammo_spacing" },
                { id = "ammo_color" },
                { id = "ammo_color2" },
                { id = "ammo_icon_size" },
                { id = "ammo_fallback_font" },
                { name = "#holohud2.parameter.amount", parameters = {
                    { id = "ammo_amount_offset" },
                    { id = "ammo_amount_font" },
                    { id = "ammo_amount_rendermode" },
                    { id = "ammo_amount_background" },
                    { id = "ammo_amount_lerp" },
                    { id = "ammo_amount_align" },
                    { id = "ammo_amount_digits" }
                } },
                { name = "#holohud2.resourcehistory.ammo_name", helptext = "#holohud2.resourcehistory.ammo_name.helptext", parameters = {
                    { id = "ammo_name_font" },
                    { id = "ammo_name_pos" },
                    { id = "ammo_name_color" },
                    { id = "ammo_name_align" },
                    { id = "ammo_name_spacing" },
                    { id = "ammo_name_animated" }
                } }
            } }
        } },
        { tab = "#holohud2.resourcehistory.tab.items", icon = "icon16/bricks.png", parameters = {
            { id = "item_delay" },
            { id = "item_limit" },
            { id = "item_queue" },

            { category = "#holohud2.resourcehistory.category.panels", parameters = {
                { id = "item_pos", parameters = {
                    { id = "item_dock" },
                    { id = "item_direction" },
                    { id = "item_margin" },
                    { id = "item_order" }
                } },
                { id = "item_background", parameters = {
                    { id = "item_background_color" }
                } },
                { id = "item_animation", parameters = {
                    { id = "item_animation_direction" }
                } }
            } },

            { category = "#holohud2.category.composition", parameters = {
                { id = "item_padding" },
                { id = "item_color" },
                { id = "item_size" },
                { id = "item_font" }
            } }
        } }
    },
    quickmenu = {
        { tab = "#holohud2.resourcehistory.tab.weapons", icon = "icon16/gun.png", parameters = {
            { id = "pos" },

            { category = "#holohud2.resourcehistory.category.weapon_pickup", parameters = {
                { id = "weapon_size" },
                { id = "weapon_name", parameters = {
                    { id = "weapon_name_pos" },
                    { id = "weapon_name_font" },
                    { id = "weapon_name_color" }
                } },
                { id = "weapon_icon", parameters = {
                    { id = "weapon_icon_pos" },
                    { id = "weapon_icon_size" },
                    { id = "weapon_icon_color" }
                } },
                { id = "weapon_label", parameters = {
                    { id = "weapon_label_pos" },
                    { id = "weapon_label_font" },
                    { id = "weapon_label_color" }
                } }
            } },

            { category = "#holohud2.resourcehistory.category.ammo_pickup", parameters = {
                { id = "ammo_mode" },
                { id = "ammo_padding" },
                { id = "ammo_color" },
                { id = "ammo_color2" },
                { id = "ammo_icon_size" },
                { id = "ammo_fallback_font" },
                { name = "#holohud2.parameter.amount", parameters = {
                    { id = "ammo_amount_offset" },
                    { id = "ammo_amount_font" }
                } },
                { name = "#holohud2.resourcehistory.ammo_name", helptext = "#holohud2.resourcehistory.ammo_name.helptext", parameters = {
                    { id = "ammo_name_font" },
                    { id = "ammo_name_color" }
                } }
            } }
        } },
        { tab = "#holohud2.resourcehistory.tab.items", icon = "icon16/bricks.png", parameters = {
            { id = "item_pos" },

            { category = "#holohud2.category.composition", parameters = {
                { id = "item_padding" },
                { id = "item_color" },
                { id = "item_size" },
                { id = "item_font" }
            } }
        } }
    }
}

---
--- Queue pickup notifications received
---
local startup -- is the element awaiting startup
local weapon_queue = {}
local item_queue = {}

hook.Add( "HUDWeaponPickedUp", "holohud2_resourcehistory", function( weapon )

    if not HOLOHUD2.IsVisible() or not ELEMENT:IsVisible() or startup then return end

    table.insert( weapon_queue, { weapon = weapon } )

    if not weapon_pickup_sound then return end

    surface.PlaySound( "physics/metal/weapon_impact_soft" .. math.random( 1, 3 ) .. ".wav" )

end)

hook.Add( "HUDAmmoPickedUp", "holohud2_resourcehistory", function( ammo, amount )

    if not HOLOHUD2.IsVisible() or not ELEMENT:IsVisible() or startup then return end

    table.insert( weapon_queue, { ammo = game.GetAmmoID( ammo ), amount = amount } )

end)

hook.Add( "HUDItemPickedUp", "holohud2_resourcehistory", function( item )

    if not HOLOHUD2.IsVisible() or not ELEMENT:IsVisible() or startup then return end

    table.insert( item_queue, item )

end)

---
--- Weaponry related pickups
---
local weapon_history        = {}
local weapon_layout         = HOLOHUD2.layout.Register( "pickup_weapon" )
local weapon_layout_invalid = false
function ELEMENT:PerformWeaponLayout( settings )

    if not weapon_layout_invalid then return end

    -- order panels and calculate total size
    local w, h = 0, 0
    for i, pickup in ipairs( weapon_history ) do

        pickup.panel:SetDrawBackground( settings.background )
        pickup.panel:SetColor( settings.background_color )
        pickup.panel:SetAnimation( settings.animation )
        pickup.panel:SetAnimationDirection( settings.animation_direction )
        pickup.panel:InvalidateLayout()

        -- ammo pickup
        if pickup.ammo then

            pickup.y = h

            pickup.component:ApplySettings( settings, self.fonts )
            pickup.component:InvalidateLayout()

            local _w, _h = pickup.component:GetSize()
            pickup.panel:SetSize( _w + settings.ammo_padding * 4, _h + settings.ammo_padding * 2 )

            w, h = math.max( w, pickup.panel.w ), h + pickup.panel.h

            if i < #weapon_history then h = h + settings.margin end

            continue

        end

        -- weapon pickup
        pickup.y = h
        pickup.panel:SetSize( settings.weapon_size.x, settings.weapon_size.y )
        pickup.component:ApplySettings( settings, self.fonts )
        pickup.component:InvalidateLayout()

        w, h = math.max( w, pickup.panel.w ), h + pickup.panel.h

        if i < #weapon_history then h = h + settings.margin end

    end

    -- align pickup notifications according to dock
    for _, pickup in ipairs( weapon_history ) do

        if DOCK_RIGHT[ settings.dock ] then

            pickup.x = w - pickup.panel.w

        elseif DOCK_CENTER[ settings.dock ] then

            pickup.x = ( w - pickup.panel.w ) / 2

        end

    end

    weapon_layout:SetDock( settings.dock )
    weapon_layout:SetDirection( settings.direction )
    weapon_layout:SetMargin( settings.margin )
    weapon_layout:SetOrder( settings.order )
    weapon_layout:SetPos( settings.pos.x, settings.pos.y )
    weapon_layout:SetSize( w, h )

    weapon_layout_invalid = false

end

---
--- Item related pickups
---
local item_history          = {}
local item_layout           = HOLOHUD2.layout.Register( "pickup_item" )
local item_layout_invalid   = false
function ELEMENT:PerformItemLayout( settings )

    if not item_layout_invalid then return end

    -- order panels and calculate total size
    local size = settings.item_size + settings.item_padding * 2
    local w, h = 0, 0
    for i, item in ipairs( item_history ) do

        item.panel:SetDrawBackground( settings.item_background )
        item.panel:SetColor( settings.item_background_color )
        item.panel:SetAnimation( settings.item_animation )
        item.panel:SetAnimationDirection( settings.item_animation_direction )
        item.panel:InvalidateLayout()

        if item.is_icon then

            item.component:SetSize( settings.item_size )
            item.component:PerformLayout()

            local w, h = item.component:GetSize()
            item.component:SetPos( size / 2 - w / 2, size / 2 - h / 2 )

            if not item.component:IsUsingItemColor() then

                item.component:SetColor( settings.item_color )

            end

            item.panel:SetSize( size, size )

        else

            item.component:SetPos( settings.item_padding, settings.item_padding )
            item.component:SetFont( self.fonts.item_font )
            item.component:SetColor( settings.item_color )
            item.component:PerformLayout()
            item.panel:SetSize( item.component.__w + settings.item_padding * 2, item.component.__h + settings.item_padding * 2 )

        end

        item.y = h
        w, h = math.max( w, item.panel.w ), h + item.panel.h

        if i < #item_history then h = h + settings.item_margin end

    end

    -- align pickup notifications according to dock
    for _, item in ipairs( item_history ) do

        if DOCK_RIGHT[ settings.dock ] then

            item.x = w - item.panel.w

        elseif DOCK_CENTER[ settings.dock ] then

            item.x = ( w - item.panel.w ) / 2

        end

    end

    item_layout:SetDock( settings.item_dock )
    item_layout:SetDirection( settings.item_direction )
    item_layout:SetMargin( settings.item_margin )
    item_layout:SetOrder( settings.item_order )
    item_layout:SetPos( settings.item_pos.x, settings.item_pos.y )
    item_layout:SetSize( w, h )

    item_layout_invalid = false

end

---
--- Startup sequence
---
function ELEMENT:QueueStartup()

    table.Empty( weapon_history )
    table.Empty( item_history )
    startup = true

end

function ELEMENT:Startup()

    startup = false

end

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    if startup then return end

    local curtime = CurTime()

    -- tick weapon pickups
    for i, pickup in ipairs( weapon_history ) do

        pickup.component:Think()

        pickup.panel:Think()
        pickup.panel:SetPos( weapon_layout.x + pickup.x, weapon_layout.y + pickup.y )
        pickup.panel:SetDeployed( not self:IsMinimized() and ( ( settings.queue or ( #weapon_history + #weapon_queue ) <= settings.limit or i ~= 1 ) and ( not pickup.weapon or IsValid( pickup.weapon ) ) and ( curtime < pickup.time + settings.delay ) ) )

        if pickup.panel:IsVisible() then continue end

        table.remove( weapon_history, i )
        weapon_layout_invalid = true

    end

    -- tick item pickups
    for i, item in ipairs( item_history ) do

        item.component:PerformLayout()

        item.panel:Think()
        item.panel:SetPos( item_layout.x + item.x, item_layout.y + item.y )
        item.panel:SetDeployed( not self:IsMinimized() and ( ( settings.item_queue or ( #item_history + #item_queue ) <= settings.item_limit or i ~= 1 ) and ( curtime < item.time + settings.delay ) ) )

        if item.panel:IsVisible() then continue end

        table.remove(item_history, i)
        item_layout_invalid = true

    end

     -- add new weapon/ammo from queue
     for i, pickup in ipairs( weapon_queue ) do

        if pickup.ammo then

            local ignore = false

            -- find existing ammo pickup and add the amount there
            for _, existing in ipairs( weapon_history ) do

                if existing.ammo ~= pickup.ammo then continue end

                existing.component:SetAmount( existing.component.amount + pickup.amount )
                existing.time = curtime

                ignore = true

                break
            end

            if ignore then

                table.remove( weapon_queue, i )
                continue

            end

            if #weapon_history >= settings.limit then continue end

            local component = HOLOHUD2.component.Create( "HudAmmoPickup" )
            component:SetAmmoType( pickup.ammo )
            component:SetAmount( pickup.amount )

            local panel = HOLOHUD2.component.Create( "AnimatedPanel" )

            panel.PaintOverFrame = function( self, x, y )

                hook_Call( "DrawAmmoPickup", x, y, self._w, self._h, LAYER_FRAME, pickup.ammo, pickup.amount )

            end

            panel.PaintOverBackground = function( self, x, y )

                if hook_Call( "DrawAmmoPickup", x, y, self._w, self._h, LAYER_BACKGROUND, pickup.ammo, pickup.amount ) then return end

                component:PaintBackground( x, y )

            end

            panel.PaintOver = function( self, x, y )

                if hook_Call( "DrawAmmoPickup", x, y, self._w, self._h, LAYER_FOREGROUND, pickup.ammo, pickup.amount ) then return end

                component:Paint(x, y )

            end

            table.insert( weapon_history, { panel = panel, component = component, ammo = pickup.ammo, x = 0, y = 0, time = curtime } )
            weapon_layout_invalid = true
            table.remove( weapon_queue, i )

            continue

        end

        if #weapon_history >= settings.limit then continue end

        table.remove( weapon_queue, i )

        if not IsValid( pickup.weapon ) then continue end

        local component = HOLOHUD2.component.Create( "HudWeaponPickup" )
        component:SetWeapon( pickup.weapon )

        local panel = HOLOHUD2.component.Create( "AnimatedPanel" )

        panel.PaintOverFrame = function( self, x, y )

            if hook_Call( "DrawWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_FRAME ) then return end

            component:PaintFrame( x, y )

            hook_Call( "DrawOverWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_FRAME, component )

        end

        panel.PaintOverBackground = function( self, x, y )

            if hook_Call( "DrawWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_BACKGROUND ) then return end

            component:PaintBackground( x, y )

            hook_Call( "DrawOverWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_BACKGROUND, component )

        end

        panel.PaintOver = function( self, x, y )

            if hook_Call( "DrawWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_FOREGROUND ) then return end

            component:Paint( x, y )

            hook_Call( "DrawOverWeaponPickup", x, y, self._w, self._h, pickup.weapon, LAYER_FOREGROUND, component )

        end

        table.insert( weapon_history, { panel = panel, component = component, weapon = pickup.weapon, x = 0, y = 0, time = curtime } )
        weapon_layout_invalid = true

    end

    weapon_layout:SetVisible( #weapon_history > 0 )

    -- add new items from queue
    for _, item in ipairs( item_queue ) do

        local is_icon = false
        local component

        if HOLOHUD2.item.Has( item ) then

            component = HOLOHUD2.component.Create( "ItemPickup" )
            component:SetItem( item )
            is_icon = true

        else

            component = HOLOHUD2.component.Create( "Text" )
            component:SetText( language.GetPhrase( item ) )

        end

        local panel = HOLOHUD2.component.Create( "AnimatedPanel" )

        panel.PaintOverFrame = function( self, x, y )

            hook_Call( "DrawItemPickup", x, y, self._w, self._h, item, LAYER_FRAME )

        end

        panel.PaintOverBackground = function( self, x, y )

            hook_Call( "DrawItemPickup", x, y, self._w, self._h, item, LAYER_BACKGROUND )

        end

        panel.PaintOver = function( self, x, y )

            if hook_Call( "DrawItemPickup", x, y, self._w, self._h, item, LAYER_FOREGROUND ) then return end

            component:Paint( x, y )

            hook_Call( "DrawOverItemPickup", x, y, self._w, self._h, item, component )

        end

        if #item_history >= settings.item_limit then continue end

        table.insert( item_history, { panel = panel, component = component, time = curtime, x = 0, y = 0, is_icon = is_icon } )
        table.remove( item_queue, 1 )

        item_layout_invalid = true

    end

    item_layout:SetVisible( #item_history > 0 )

    self:PerformItemLayout( settings )
    self:PerformWeaponLayout( settings )

end

---
--- Locate panels relative to the layout panel.
---
HOLOHUD2.hook.Add( "OnLayoutPerformed", "pickup", function()

    for _, pickup in ipairs( weapon_history ) do

        pickup.panel:SetPos( weapon_layout.x + pickup.x, weapon_layout.y + pickup.y )

    end

    for _, item in ipairs( item_history ) do

        item.panel:SetPos( item_layout.x + item.x, item_layout.y + item.y )

    end

end )

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    for _, pickup in ipairs( weapon_history ) do

        pickup.panel:PaintFrame( x, y )

    end

    for _, item in ipairs( item_history ) do

        item.panel:PaintFrame( x, y )

    end

end

function ELEMENT:PaintBackground( settings, x, y )

    for _, pickup in ipairs( weapon_history ) do

        pickup.panel:PaintBackground( x, y )

    end

end

function ELEMENT:Paint( settings, x, y )

    for _, pickup in ipairs( weapon_history ) do

        pickup.panel:Paint( x, y )

    end

    for _, item in ipairs( item_history ) do

        item.panel:Paint( x, y )

    end

end

function ELEMENT:PaintScanlines(settings, x, y)

    StartAlphaMultiplier( GetMinimumGlow() )
    self:Paint( settings, x, y )
    EndAlphaMultiplier()

end

---
--- Preview
---
local PREVIEW_WEAPON, PREVIEW_AMMO, PREVIEW_ITEM = 1, 2, 3
local PREVIEW_ITEMNAME = "#Item_Name"

local preview = PREVIEW_WEAPON
local preview_weapon = HOLOHUD2.component.Create( "HudWeaponPickup" )
local preview_ammo = HOLOHUD2.component.Create( "HudAmmoPickup" )
local preview_item = HOLOHUD2.component.Create( "ItemPickup" )

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:Dock( BOTTOM )
    controls:DockMargin( 4, 4, 4, 4 )

        local combobox = vgui.Create( "DComboBox", controls )
        combobox:SetWide( 156 )
        combobox:SetSortItems( false )
        combobox.OnSelect = function( _, i )

            preview = i

        end

        combobox:AddChoice( "#holohud2.resourcehistory.preview.weapon" )
        combobox:AddChoice( "#holohud2.resourcehistory.preview.ammo" )
        combobox:AddChoice( "#holohud2.resourcehistory.preview.items" )

        combobox:ChooseOptionID( PREVIEW_WEAPON )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_weapon:ApplySettings( settings, self.preview_fonts )
    preview_ammo:ApplySettings( settings, self.preview_fonts )
    preview_item:SetSize( settings.item_size )
    preview_item:SetItem( math.random( 0, 1 ) == 0 and "item_healthkit" or "item_battery" )
    preview_item:SetColor( settings.item_color )

    local weapon = LocalPlayer():GetActiveWeapon()
    local ammo = IsValid( weapon ) and weapon:GetPrimaryAmmoType() or 1

    if ammo <= 0 then ammo = 1 end

    preview_weapon:SetWeapon( weapon )
    preview_ammo:SetAmmoType( ammo )
    preview_ammo:SetAmount( game.GetAmmoMax( ammo ) )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = scale_Get()
    x, y = x + w / 2, y + h / 2

    if preview == PREVIEW_WEAPON then

        local w, h = settings.weapon_size.x * scale, settings.weapon_size.y * scale
        local x, y = x - w / 2, y - h / 2

        if settings.background then

            draw.RoundedBox( 0, x, y, w, h, settings.background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_weapon:Think()
        preview_weapon:PaintFrame( x, y )
        preview_weapon:PaintBackground( x, y )
        preview_weapon:Paint( x, y )

    elseif preview == PREVIEW_AMMO then

        local w, h = ( preview_ammo.__w + settings.ammo_padding * 4 ) * scale, ( preview_ammo.__h + settings.ammo_padding * 2 ) * scale
        local x, y = x - w / 2, y - h / 2

        if settings.background then

            draw.RoundedBox( 0, x, y, w, h, settings.background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, w, h )

        preview_ammo:Think()
        preview_ammo:PaintBackground( x, y )
        preview_ammo:Paint( x, y )

    else

        surface.SetFont( self.preview_fonts.item_font )
        surface.SetTextColor( settings.item_color )
        local textw, texth = surface.GetTextSize( PREVIEW_ITEMNAME )
        local padding = settings.item_padding * scale
        local size = settings.item_size * scale
        local margin = 4 * scale
        local backgroundsize = settings.item_size * scale + padding * 2
        local w, h = math.max( backgroundsize, textw ), backgroundsize + texth + margin

        x, y = x - w / 2, y - h / 2

        if settings.background then

            draw.RoundedBox( 0, x, y, backgroundsize, backgroundsize, settings.background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, backgroundsize, backgroundsize )

        preview_item:PerformLayout()
        preview_item:Paint( x + backgroundsize / 2 - size / 2, y + backgroundsize / 2 - size / 2 )

        y = y + backgroundsize + margin

        if settings.background then

            draw.RoundedBox( 0, x, y, textw + padding * 2, texth + padding * 2, settings.background_color )

        end

        surface.SetDrawColor( wireframe_color )
        surface.DrawOutlinedRect( x, y, textw + padding * 2, texth + padding * 2 )

        surface.SetTextPos( x + padding, y + padding )
        surface.DrawText( PREVIEW_ITEMNAME )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged(settings)

    weapon_pickup_sound = settings.weapon_sound

    if not settings._visible then

        table.Empty( weapon_history )
        table.Empty( weapon_queue )
        table.Empty( item_history )
        table.Empty( item_queue )
        return

    end

    item_layout_invalid = true
    weapon_layout_invalid = true

end

---
--- Hide default pickup history
---
hook.Add( "HUDDrawPickupHistory", "holohud2_resourcehistory", function()

    if not HOLOHUD2.IsVisible() or not ELEMENT:IsVisible() then return end

    return false

end)

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    item_layout_invalid = true
    weapon_layout_invalid = true

end

HOLOHUD2.element.Register( "resourcehistory", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    weapons     = weapon_history,
    items       = item_history
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "resourcehistory", { "animation", "item_animation" } )
HOLOHUD2.modifier.Add( "background", "resourcehistory", { "background", "item_background" } )
HOLOHUD2.modifier.Add( "background_color", "resourcehistory", { "background_color", "item_background_color" } )
HOLOHUD2.modifier.Add( "color", "resourcehistory", { "weapon_name_color", "weapon_icon_color", "item_color", "ammo_name_color" } )
HOLOHUD2.modifier.Add( "color2", "resourcehistory", { "weapon_label_color", "ammo_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "resourcehistory", "ammo_amount_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "resourcehistory", "ammo_amount_background" )
HOLOHUD2.modifier.Add( "number3_offset", "resourcehistory", "ammo_amount_offset" )
HOLOHUD2.modifier.Add( "number3_font", "resourcehistory", "ammo_amount_font" )
HOLOHUD2.modifier.Add( "text_font", "resourcehistory", { "item_font", "weapon_label_font", "weapon_name_font" } )
HOLOHUD2.modifier.Add( "scale", "resourcehistory", {
    "pos", "margin",
    "weapon_size",
    "weapon_name_pos", "weapon_name_font",
    "weapon_icon_pos", "weapon_icon_size",
    "weapon_label_pos", "weapon_label_font",
    "ammo_padding", "ammo_spacing",
    "ammo_icon_size", "ammo_fallback_font",
    "ammo_amount_offset", "ammo_amount_font",
    "ammo_name_font", "ammo_name_pos", "ammo_name_spacing",
    "item_pos", "item_margin", "item_padding", "item_size", "item_font"
} )

---
--- Presets
---
HOLOHUD2.presets.Register( "resourcehistory", "element/resourcehistory" )
