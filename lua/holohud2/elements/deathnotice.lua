
local NET           = "holohud2_deathnotice"

local TEAM_INVALID  = -1

local COLOR_INVALID = -1
local COLOR_FOE     = 1
local COLOR_FRIEND  = 2

if SERVER then

    util.AddNetworkString( NET )

    --- Broadcasts a death notice to all players.
    --- @param attacker Player|NPC
    --- @param inflictor Entity|Weapon
    --- @param victim Player|NPC
    local function send_death_notice( attacker, inflictor, victim )

        if not IsValid( victim ) then return end

        if IsValid( attacker ) then

            -- if killed by trigger hurt it counts as a suicide
            if attacker:GetClass() == "trigger_hurt" then attacker = victim end

            -- if killed by a vehicle, try blaming its driver
            if attacker:IsVehicle() and IsValid( attacker:GetDriver() ) then attacker = attacker:GetDriver() end

            -- convert the inflictor to the weapon the attacker is holding
            if IsValid( inflictor ) then

                if attacker == inflictor and ( inflictor:IsPlayer() or inflictor:IsNPC() ) and IsValid( inflictor:GetActiveWeapon() ) then

                    inflictor = inflictor:GetActiveWeapon()

                end

            else

                inflictor = attacker

            end
        
        else

            attacker = victim

            if not IsValid( inflictor ) then

                inflictor = victim

            end

        end

        local suicide = attacker == victim

        for _, ply in pairs( player.GetAll() ) do

            net.Start( NET )
            
            net.WriteString( HOLOHUD2.util.GetDeathNoticeEntityName( victim ) )
            net.WriteInt( victim:IsPlayer() and victim:Team() or TEAM_INVALID, 32 )
            net.WriteInt( victim:IsNPC() and ( victim:Disposition( ply ) == D_LI and COLOR_FRIEND or COLOR_FOE ) or COLOR_INVALID, 8 )

            net.WriteBool( suicide )

            if not suicide then

                if inflictor ~= victim and inflictor ~= attacker then

                    net.WriteString( inflictor:GetClass() )
                    net.WriteString( inflictor:IsWeapon() and ( inflictor.GetPrintName and inflictor:GetPrintName() or inflictor.PrintName ) or inflictor:GetClass() )

                else

                    net.WriteString( "worldspawn" )
                    net.WriteString( "worldspawn" )

                end

                net.WriteString( HOLOHUD2.util.GetDeathNoticeEntityName( attacker ) )
                net.WriteInt( attacker:IsPlayer() and attacker:Team() or TEAM_INVALID, 32 )
                net.WriteInt( attacker:IsNPC() and ( attacker:Disposition( ply ) == D_LI and COLOR_FRIEND or COLOR_FOE ) or COLOR_INVALID, 8 )

            end

            net.Send( ply )

        end

    end

    ---
    --- Send death notice of an NPC getting killed.
    ---
    hook.Add( "OnNPCKilled", "holohud2_deathnotice", function( npc, attacker, inflictor )
        
        -- avoid spamming the killfeed with map scripting related entities
        if npc:GetClass() == "npc_bullseye" or npc:GetClass() == "npc_launcher" then return end

        send_death_notice( attacker, inflictor, npc )
    
    end )

    ---
    --- Send death notice of a player getting killed.
    ---
    hook.Add( "PlayerDeath", "holohud2_deathnotice", function( ply, inflictor, attacker ) send_death_notice( attacker, inflictor, ply ) end )

    return

end

local IsVisible = HOLOHUD2.IsVisible
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local dock = 0

local ELEMENT = {
    name        = "#holohud2.deathnotice",
    helptext    = "#holohud2.deathnotice.helptext",
    parameters  = {
        delay               = { name = "#holohud2.parameter.notification_delay", type = HOLOHUD2.PARAM_NUMBER, value = 6, min = 0, helptext = "#holohud2.parameter.notification_delay.helptext" },
        queue               = { name = "#holohud2.parameter.notification_queue", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.parameter.nofitication_queue.helptext" },
        limit               = { name = "#holohud2.parameter.notification_limit", type = HOLOHUD2.PARAM_NUMBER, value = 6, helptext = "#holohud2.parameter.notification_limit.helptext" },

        pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_RIGHT },
        direction           = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin              = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order               = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 32 },

        background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color    = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },

        animation           = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_LEFT },

        padding             = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        spacing             = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        color_foe           = { name = "#holohud2.deathnotice.hostile_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 72, 64 ) },
        color_friend        = { name = "#holohud2.deathnotice.friend_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 64, 255, 92 ) },
        color_inflictor     = { name = "#holohud2.deathnotice.inflictor_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        inflictor_uppercase = { name = "#holohud2.deathnotice.inflictor_uppercase", type = HOLOHUD2.PARAM_BOOL, value = true },
        inflictor_size      = { name = "#holohud2.deathnotice.inflictor_size", type = HOLOHUD2.PARAM_NUMBER, value = 12, min = 0, helptext = "#holohud2.deathnotice.inflictor_size.helptext" }
    },
    menu = {
        { id = "delay" },
        { id = "queue" },
        { id = "limit" },

        { category = "#holohud2.category.panel", parameters = {
            { id = "pos", parameters = {
                { id = "dock" },
                { id = "direction" },
                { id = "margin" },
                { id = "order" }
            } },
            { id = "background", parameters = {
                { id  = "background_color" }
            } },
            { id = "animation", parameters = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color_foe" },
            { id = "color_friend" },
            { id = "color_inflictor" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "spacing" },
            { id = "font" },
            { id = "inflictor_uppercase" },
            { id = "inflictor_size" }
        } }
    },
    quickmenu = {
        { id = "pos" },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color_foe" },
            { id = "color_friend" },
            { id = "color_inflictor" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "spacing" },
            { id = "font" },
            { id = "inflictor_size" }
        } }
    }
}

---
--- Receive death notices
---
local startup -- is the element awaiting startup
local deathnotices  = {}
local queue = {}
local invalid_layout = false
net.Receive( NET, function( len )

    if not IsVisible() or not ELEMENT:IsVisible() or startup then return end

    local deathnotice = { time = 0, x = 0, y = 0 }

    local component = HOLOHUD2.component.Create( "DeathNotice" )

    -- victim
    local victim, victim_t, victim_col = net.ReadString(), net.ReadInt( 32 ), net.ReadInt( 8 )
    component:SetVictim( victim )
    deathnotice.victim = victim
    deathnotice.color2 = victim_t ~= TEAM_INVALID and team.GetColor( victim_t ) or victim_col
    
    if not net.ReadBool() then

        -- inflictor
        local inflictor = net.ReadString()
        local inflictor_name = net.ReadString()
        local weapon = weapons.GetStored( inflictor )
        component:SetInflictorClass( inflictor )
        component:SetInflictorName( weapon and weapon.PrintName or inflictor_name )
        deathnotice.inflictor = inflictor

        -- attacker
        local attacker, attacker_t, victim_col = net.ReadString(), net.ReadInt( 32 ), net.ReadInt( 8 )
        component:SetAttacker( attacker )
        deathnotice.attacker = attacker
        deathnotice.color1 = attacker_t ~= TEAM_INVALID and team.GetColor( attacker_t ) or victim_col

    end

    local panel = HOLOHUD2.component.Create( "AnimatedPanel" )

    panel.PaintOverFrame = function( self, x, y )

        hook_Call( "DrawDeathNotice", x, y, self._w, self._h, LAYER_FRAME )

    end

    panel.PaintOver = function( self, x, y )

        if hook_Call( "DrawDeathNotice", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

        component:Paint( x, y )

        hook_Call( "DrawOverDeathNotice", x, y, self._w, self._h, LAYER_FOREGROUND, deathnotice )

    end

    panel.PaintOverScanlines = function( self, x, y )

        if hook_Call( "DrawDeathNotice", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

        StartAlphaMultiplier( GetMinimumGlow() )
        component:Paint( x, y )
        EndAlphaMultiplier()
        
        hook_Call( "DrawOverDeathNotice", x, y, self._w, self._h, LAYER_SCANLINES, deathnotice )

    end

    deathnotice.component = component
    deathnotice.panel = panel

    table.insert( queue, deathnotice )

end)

---
--- Startup sequence
---
function ELEMENT:QueueStartup()

    table.Empty( deathnotices )
    startup = true

end

function ELEMENT:Startup()
    
    startup = false

end

---
--- Hide default death notices
---
hook.Add( "DrawDeathNotice", "holohud2_deathnotice", function()

    if not IsVisible() or not ELEMENT:IsVisible() then return end

    return false

end)

---
--- Layout
---
local layout = HOLOHUD2.layout.Register( "deathnotice" )
function ELEMENT:PerformLayout( settings )

    if not invalid_layout then return end

    local y, w, h = 0, 0, 0

    for i, notice in ipairs( deathnotices ) do

        if i > 1 then y = y + settings.margin end
        if i < #deathnotices then h = h + settings.margin end

        notice.panel:SetDrawBackground( settings.background )
        notice.panel:SetColor( settings.background_color )
        notice.panel:SetAnimation( settings.animation )
        notice.panel:SetAnimationDirection( settings.animation_direction )

        notice.component:SetPos( settings.padding + 1, settings.padding )
        notice.component:SetSize( settings.inflictor_size )
        notice.component:SetSpacing( settings.spacing )
        notice.component:SetFont( self.fonts.font )
        notice.component:SetAttackerColor( IsColor( notice.color1 ) and notice.color1 or notice.color1 == COLOR_FRIEND and settings.color_friend or settings.color_foe )
        notice.component:SetInflictorColor( settings.color_inflictor )
        notice.component:SetVictimColor( IsColor( notice.color2 ) and notice.color2 or notice.color2 == COLOR_FRIEND and settings.color_friend or settings.color_foe )
        notice.component:SetInflictorOnUppercase( settings.inflictor_uppercase )
        notice.component:PerformLayout( true )
        
        notice.y = y

        local _w, _h = notice.component:GetSize()
        _w = _w + settings.padding * 2 + 2
        _h = _h + settings.padding * 2

        notice.panel:SetSize( _w, _h )

        if _w > w then w = _w end

        h = h + _h
        y = y + _h

    end

    layout:SetSize( w, h )
    layout:SetVisible( #deathnotices > 0 )

    invalid_layout = false

end

---
--- Logic
---
function ELEMENT:PreDraw( settings )

    local curtime = CurTime()
    local localplayer = LocalPlayer()
    local alive = localplayer.Alive and localplayer:Alive()

    local i = 1
    for _, notice in ipairs( deathnotices ) do

        notice.x = layout.w * dock - notice.panel.w * dock

        notice.panel:SetPos( layout.x + notice.x, layout.y + notice.y )
        notice.panel:SetDeployed( ( not self:IsMinimized() or not alive ) and notice.time + settings.delay > curtime )
        notice.panel:Think()

        notice.component:PerformLayout()

        if not notice.panel:IsVisible() then

            table.remove( deathnotices, i )
            invalid_layout = true

            continue

        end

        i = i + 1

    end

    if #deathnotices < settings.limit then

        for i, notice in ipairs( queue ) do

            if #deathnotices >= settings.limit then break end

            notice.time = curtime
            table.insert( deathnotices, notice )
            table.remove( queue, i )
            invalid_layout = true

            if #queue > 0 then

                deathnotices[ 1 ].time = 0

            end

        end

    end

    self:PerformLayout( settings )

end

---
--- When not using the single tray option, relocate panels to the layout.
---
HOLOHUD2.hook.Add( "OnLayoutPerformed", "deathnotice", function()

    for _, notice in ipairs( deathnotices ) do
        
        notice.panel:SetPos( layout.x + notice.x, layout.y + notice.y )

    end

end )

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    for _, notice in ipairs( deathnotices ) do
        
        notice.panel:PaintFrame( x, y )

    end

end

function ELEMENT:Paint( settings, x, y )

    for _, notice in ipairs( deathnotices ) do

        notice.panel:Paint( x, y )

    end

end

function ELEMENT:PaintScanlines( settings, x, y )

    for _, notice in ipairs( deathnotices ) do

        notice.panel:PaintScanlines( x, y )

    end

end

---
--- Preview
---
local PREVIEW_PLAYER_COLOR = Color( 255, 255, 100, 255 )

local preview_deathnotice0 = HOLOHUD2.component.Create( "DeathNotice" )
preview_deathnotice0:SetAttacker( "#holohud2.deathnotice.preview.attacker" )
preview_deathnotice0:SetInflictorName( "#holohud2.deathnotice.preview.inflictor" )
preview_deathnotice0:SetVictim( "#holohud2.deathnotice.preview.victim" )

local preview_deathnotice1 = HOLOHUD2.component.Create( "DeathNotice" )
preview_deathnotice1:SetVictim( "#holohud2.deathnotice.preview.victim" )

function ELEMENT:OnPreviewChanged( settings )

    preview_deathnotice0:SetSize( settings.inflictor_size )
    preview_deathnotice0:SetSpacing( settings.spacing )
    preview_deathnotice0:SetFont( self.preview_fonts.font )
    preview_deathnotice0:SetAttackerColor( settings.color_friend )
    preview_deathnotice0:SetInflictorColor( settings.color_inflictor )
    preview_deathnotice0:SetVictimColor( settings.color_foe )
    preview_deathnotice0:SetInflictorOnUppercase( settings.inflictor_uppercase )
    preview_deathnotice0:PerformLayout( true )
    
    preview_deathnotice1:SetSize( settings.inflictor_size )
    preview_deathnotice1:SetSpacing( settings.spacing )
    preview_deathnotice1:SetFont( self.preview_fonts.font )
    preview_deathnotice1:SetInflictorColor( settings.color_inflictor )
    preview_deathnotice1:SetVictimColor( PREVIEW_PLAYER_COLOR )
    preview_deathnotice1:SetInflictorOnUppercase( settings.inflictor_uppercase )
    preview_deathnotice1:PerformLayout( true )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local wireframe_color = HOLOHUD2.WIREFRAME_COLOR
    local scale = HOLOHUD2.scale.Get()

    preview_deathnotice0:PerformLayout()
    preview_deathnotice1:PerformLayout()

    local padding = settings.padding * scale
    local u0, v0 = preview_deathnotice0.__w * scale + padding * 2, preview_deathnotice0.__h * scale + padding * 2
    local u1, v1 = preview_deathnotice1.__w * scale + padding * 2, preview_deathnotice1.__h * scale + padding * 2

    x, y = x + w / 2, y + h / 2 - ( v0 + v1 ) / 2

    if settings.background then

        draw.RoundedBox( 0, x - u0 / 2, y, u0, v0, settings.background_color )

    end

    surface.SetDrawColor( wireframe_color )
    surface.DrawOutlinedRect( x - u0 / 2, y, u0, v0 )

    preview_deathnotice0:Paint( x - u0 / 2 + padding, y + padding )

    y = y + v1 + 4 * scale
    

    if settings.background then

        draw.RoundedBox( 0, x - u1 / 2, y, u1, v1, settings.background_color )

    end

    surface.SetDrawColor( wireframe_color )
    surface.DrawOutlinedRect( x - u1 / 2, y, u1, v1 )

    preview_deathnotice1:Paint( x - u1 / 2 + padding, y + padding )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then
        
        layout:SetVisible(false)
        return
    
    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    dock = HOLOHUD2.HORIZONTAL_DOCK.LEFT[ settings.dock ] and 0 or ( HOLOHUD2.HORIZONTAL_DOCK.CENTER[ settings.dock ] and .5 ) or 1

    invalid_layout = true

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    for _, deathnotice in ipairs( deathnotices ) do

        deathnotice.panel:InvalidateLayout()
        deathnotice.component:InvalidateLayout()

    end

end

HOLOHUD2.element.Register( "deathnotice", ELEMENT )

---
--- Export components
---
ELEMENT.components = deathnotices

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "deathnotice", "animation" )
HOLOHUD2.modifier.Add( "background", "deathnotice", "background" )
HOLOHUD2.modifier.Add( "background_color", "deathnotice", "background_color" )
HOLOHUD2.modifier.Add( "color", "deathnotice", "color_inflictor" )
HOLOHUD2.modifier.Add( "text_font", "deathnotice", "font" )

---
--- Presets
---
HOLOHUD2.presets.Register( "deathnotice", "element/deathnotice" )