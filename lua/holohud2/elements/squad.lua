HOLOHUD2.AddCSLuaFile( "squad/hudsquadmember.lua" )
HOLOHUD2.AddCSLuaFile( "squad/hudsquadstatus.lua" )

local NET_JOINED    = "holohud2_squad_joined"
local NET_LEFT      = "holohud2_squad_left"

if SERVER then
    
    local ai = ai
    local net = net
    local IsValid = IsValid

    -- NPC squads only work in single player
    if not game.SinglePlayer() then return end

    util.AddNetworkString( NET_JOINED )
    util.AddNetworkString( NET_LEFT )

    local SQUAD = "player_squad"

    --- Track squad members' status.
    --- WARNING: This is a bit of an expensive operation. Since we're tracking
    --- members' individual health values we have to make sure a miscount
    --- doesn't happen.
    local last_squad = {}
    hook.Add( "Tick", "holohud2_squad", function()
    
        local squad = ai.GetSquadMembers( SQUAD )

        if not squad then return end

        local index = {}
        local joined, left = {}, {}

        -- check for joining members
        for _, member in pairs( squad ) do

            index[ member ] = true

            if last_squad[ member ] then continue end

            table.insert( joined, member )
            last_squad[ member ] = true

        end

        -- check for leaving members
        for member, _ in pairs( last_squad ) do

            -- remove invalid members
            if not IsValid( member ) then
                
                last_squad[ member ] = nil
                continue

            end

            if index[ member ] then continue end

            table.insert( left, member )
            last_squad[ member ] = nil

        end

        -- NOTE: let's keep this civil and only send data when there's an actual change

        if #joined > 0 then

            net.Start( NET_JOINED )
            net.WriteTable( joined )
            net.Broadcast()

        end

        if #left > 0 then

            net.Start( NET_LEFT )
            net.WriteTable( left )
            net.Broadcast()

        end

    end)

    return

end

local game = game
local LocalPlayer = LocalPlayer
local IsVisible = HOLOHUD2.IsVisible
local hook_Call = HOLOHUD2.hook.Call

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

local visible = true

local ELEMENT = {
    name        = "#holohud2.squad",
    hide        = "CHudSquadStatus",
    helptext    = "#holohud2.squad.helptext",
    parameters  = {
        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 128 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 112, y = 44 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200 ) },
        color2                  = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },
        icon_size               = { name = "#holohud2.squad.icon_size", type = HOLOHUD2.PARAM_NUMBER, value = 32, min = 0 },
        inverted                = { name = "#holohud2.parameter.inverted", type = HOLOHUD2.PARAM_BOOL, value = false },
        fade_offset             = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 8 },
        died_color              = { name = "#holohud2.squad.member_died_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32 ), helptext = "#holohud2.squad.member_died_color.helptext" },
        
        highlight               = { name = "#holohud2.squad.highlight", type = HOLOHUD2.PARAM_BOOL, value = true, helptext = "#holohud2.squad.highlight.helptext" },
        highlight_offset        = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = -4 },
        highlight_color         = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 186, 104 ) },
        
        text                    = { name = "#holohud2.component.label", type = HOLOHUD2.PARAM_BOOL, value = false },
        text_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 4 } },
        text_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        text_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "#holohud2.SQUAD" },
        text_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },
        text_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        pile_min                = { name = "#holohud2.parameter.limit", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 1, helptext = "#holohud2.squad.pile_min.helptext" },
        icon_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 14, y = 4 } },
        spacing                 = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 15 },
        outlined                = { name = "#holohud2.squad.icon_outlined", type = HOLOHUD2.PARAM_BOOL, value = false },
        
        healthbar               = { name = "#holohud2.squad.health_bar", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_pos           = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_VECTOR, value = { x = -6, y = 7 } },
        healthbar_size          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 24 }, min_x = 1, min_y = 1 },
        healthbar_color         = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 162, 72 ), [100] = Color(72, 255, 72) }, fraction = true, gradual = false } },
        healthbar_style         = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        healthbar_growdirection = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },
        healthbar_background    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_color2        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [ 0 ] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        pile_max                = { name = "#holohud2.parameter.limit", type = HOLOHUD2.PARAM_NUMBER, value = 9, min = 1, helptext = "#holohud2.squad.pile_max.helptext" },
        pile_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 6, y = 4 } },
        pile_spacing            = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = -2 },
        pile_oddoffset          = { name = "#holohud2.squad.odd_offset", type = HOLOHUD2.PARAM_NUMBER, value = 4, helptext = "#holohud2.squad.odd_offset.helptext" },
        pile_num                = { name = "#holohud2.squad.pile_num", type = HOLOHUD2.PARAM_BOOL, value = true },
        pile_num_pos            = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 87, y = 24 } },
        pile_num_font           = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 14, weight = 1000, italic = false } },
        pile_num_rendermode     = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        pile_num_background     = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        pile_num_digits         = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 2, min = 1 },
        pile_num_align          = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        pile_outlined           = { name = "#holohud2.squad.icon_outlined", type = HOLOHUD2.PARAM_BOOL, value = true }
    },
    menu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "pos", parameters = {
                { id = "dock" },
                { id = "direction" },
                { id = "margin" },
                { id = "order" }
            } },
            { id = "size" },
            { id = "background", parameters = {
                { id = "background_color" }
            } },
            { id = "animation", parameters = {
                { id = "animation_direction" }
            } }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.squad.category.animations", parameters = {
            { name = "#holohud2.squad.fade_animation", helptext = "#holohud2.squad.fade_animation.helptext", parameters = {
                { id = "fade_offset" },
                { id = "died_color" },
            } },
            { id = "highlight", parameters = {
                { id = "highlight_offset" },
                { id = "highlight_color" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "icon_size" },
            { id = "inverted" },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" },
                { id = "text_text" },
                { id = "text_align" },
                { id = "text_on_background" }
            } }
        } },

        { category = "#holohud2.squad.category.few_members", helptext = "#holohud2.squad.category.few_members.helptext", parameters = {
            { id = "pile_min" },
            { id = "icon_pos" },
            { id = "spacing" },
            { id = "outlined" },
            { id = "healthbar", parameters = {
                { id = "healthbar_pos" },
                { id = "healthbar_size" },
                { id = "healthbar_color" },
                { id = "healthbar_style" },
                { id = "healthbar_growdirection" },
                { id = "healthbar_background", parameters = {
                    { id = "healthbar_color2" }
                } }
            } },
        } },

        { category = "#holohud2.squad.category.members_pile", helptext = "#holohud2.squad.category.members_pile.helptext", parameters = {
            { id = "pile_max" },
            { id = "pile_pos" },
            { id = "pile_spacing" },
            { id = "pile_oddoffset" },
            { id = "pile_num", parameters = {
                { id = "pile_num_pos" },
                { id = "pile_num_font" },
                { id = "pile_num_rendermode" },
                { id = "pile_num_background" },
                { id = "pile_num_digits" },
                { id = "pile_num_align" }
            } },
            { id = "pile_outlined" }
        } }
    },
    quickmenu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "color" },
            { id = "color2" }
        } },

        { category = "#holohud2.squad.category.animations", parameters = {
            { name = "#holohud2.squad.fade_animation", helptext = "#holohud2.squad.fade_animation.helptext", parameters = {
                { id = "died_color" },
            } },
            { id = "highlight", parameters = {
                { id = "highlight_color" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "icon_size" },
            { id = "inverted" },
            { id = "text", parameters = {
                { id = "text_pos" },
                { id = "text_font" }
            } }
        } },

        { category = "#holohud2.squad.category.few_members", helptext = "#holohud2.squad.category.few_members.helptext", parameters = {
            { id = "pile_min" },
            { id = "icon_pos" },
            { id = "outlined" },
            { id = "healthbar", parameters = {
                { id = "healthbar_pos" },
                { id = "healthbar_size" },
                { id = "healthbar_color" },
                { id = "healthbar_background", parameters = {
                    { id = "healthbar_color2" }
                } }
            } },
        } },

        { category = "#holohud2.squad.category.members_pile", helptext = "#holohud2.squad.category.members_pile.helptext", parameters = {
            { id = "pile_max" },
            { id = "pile_pos" },
            { id = "pile_num", parameters = {
                { id = "pile_num_pos" },
                { id = "pile_num_font" }
            } },
            { id = "pile_outlined" }
        } }
    }
}

---
--- Composition
---
local hudsquadstatus = HOLOHUD2.component.Create( "HudSquadStatus" )
local layout = HOLOHUD2.layout.Register( "squad" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawSquadStatus", x, y, LAYER_FRAME )

end

panel.PaintOverBackground = function( _, x, y )

    if hook_Call( "DrawSquadStatus", x, y, LAYER_BACKGROUND ) then return end

    hudsquadstatus:PaintBackground( x, y )

    hook_Call( "DrawOverSquadStatus", x, y, LAYER_BACKGROUND, hudsquadstatus )

end

panel.PaintOver = function( _, x, y )

    if hook_Call( "DrawSquadStatus", x, y, LAYER_FOREGROUND ) then return end

    hudsquadstatus:Paint( x, y )

    hook_Call( "DrawOverSquadStatus", x, y, LAYER_FOREGROUND, hudsquadstatus )

end

panel.PaintOverScanlines = function( _, x, y )

    if hook_Call( "DrawSquadStatus", x, y, LAYER_SCANLINES ) then return end

    hudsquadstatus:PaintScanlines( x, y )

    hook_Call( "DrawOverSquadStatus", x, y, LAYER_SCANLINES, hudsquadstatus )

end

---
--- Startup
---
local STARTUP_NONE      = -1
local STARTUP_QUEUED    = 0
local STARTUP_STANDBY   = 1
local STARTUP_ACTIVATED = 2

local startup_phase = STARTUP_NONE
local next_startup_phase = 0

function ELEMENT:QueueStartup()

    panel:Close()
    startup_phase = STARTUP_QUEUED

end

function ELEMENT:Startup()

    startup_phase = STARTUP_STANDBY
    next_startup_phase = CurTime() + 1

end

function ELEMENT:CancelStartup()

    startup_phase = STARTUP_NONE

end

function ELEMENT:IsStartupOver()

    if not game.SinglePlayer() then return end -- ignore on multiplayer since there are no squads
    return startup_phase == STARTUP_NONE

end

function ELEMENT:GetStartupMessage()

    return "#holohud2.squad.startup"

end

function ELEMENT:DoStartupSequence()

    if startup_phase == STARTUP_NONE then return end
    if startup_phase == STARTUP_QUEUED then return true end

    local curtime = CurTime()
    
    -- advance through the different phases
    if next_startup_phase < curtime then

        if startup_phase ~= STARTUP_ACTIVATED then

            startup_phase = startup_phase + 1
            next_startup_phase = curtime + 2

        else

            startup_phase = STARTUP_NONE

        end

    end

end

---
--- Logic
---
local members = {}
local localplayer
function ELEMENT:PreDraw( settings )
    
    if self:DoStartupSequence() then return end

    localplayer = localplayer or LocalPlayer()

    local trace = localplayer:GetEyeTrace()

    for member, component in pairs( members ) do
        
        if not IsValid( member ) then
            
            hudsquadstatus:RemoveMember( component, true )
            component:SetHealth( 0 )
            members[member] = nil

            continue

        end

        component:SetOutlined( ( #hudsquadstatus.members <= settings.pile_min and settings.outlined ) or ( #hudsquadstatus.members > settings.pile_min and settings.pile_outlined ) )
        component:SetHighlighted( settings.highlight and trace.Hit and trace.Entity == member )
        component:SetHealth( member:Health() / member:GetMaxHealth() )

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and not table.IsEmpty( members ) )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudsquadstatus:Think()

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )
    
    panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )
    
    if startup_phase == STARTUP_STANDBY then return end
    
    panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )
    
    if startup_phase == STARTUP_STANDBY then return end

    panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )
    
    if startup_phase == STARTUP_STANDBY then return end

    panel:PaintScanlines( x, y )

end

---
--- Preview
---
local preview_hudsquadstatus = HOLOHUD2.component.Create( "HudSquadStatus" )

local preview0 = preview_hudsquadstatus:AddMember( true )
preview0:SetHealth( 1 )
preview0:SetHighlighted( true )

preview_hudsquadstatus:AddMember():SetHealth( .75 )
preview_hudsquadstatus:AddMember():SetHealth( .5 )
preview_hudsquadstatus:AddMember():SetHealth( .25 )

function ELEMENT:PreviewInit( panel )

    local controls = vgui.Create( "Panel", panel )
    controls:Dock( BOTTOM )
    controls:DockMargin( 4, 0, 0, 4 )
    
        local add = vgui.Create( "DButton", controls )
        add:SetWide( 24 )
        add:Dock( LEFT )
        add:DockMargin( 0, 0, 4, 0 )
        add:SetText( "" )
        add:SetTooltip( "#holohud2.squad.preview.add" )
        add:SetImage( "icon16/add.png" )
        add.DoClick = function()

            local was_empty = table.IsEmpty( preview_hudsquadstatus.members )

            local member = preview_hudsquadstatus:AddMember( math.random( 1, 4 ) == 1 )
            member:SetHealth( math.Rand( 0, 1 ) )
            member:SetHighlighted( was_empty )

        end

        local remove = vgui.Create( "DButton", controls )
        remove:SetWide( 24 )
        remove:Dock( LEFT )
        remove:SetText( "" )
        remove:SetTooltip( "#holohud2.squad.preview.remove" )
        remove:SetImage( "icon16/delete.png" )
        remove.DoClick = function()

            preview_hudsquadstatus:RemoveMember( 1, true )

            timer.Simple( .56, function()
            
                if not preview_hudsquadstatus.members[ 1 ] then return end
                preview_hudsquadstatus.members[ 1 ]:SetHighlighted( true )

            end)

        end

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudsquadstatus:ApplySettings( settings, self.preview_fonts )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    local w, h = settings.size.x * scale, settings.size.y * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudsquadstatus:Think()
    preview_hudsquadstatus:PaintBackground( x, y )
    preview_hudsquadstatus:Paint( x, y )

    for _, member in ipairs( preview_hudsquadstatus.members ) do

        member:SetOutlined( ( #preview_hudsquadstatus.members <= settings.pile_min and settings.outlined ) or ( #preview_hudsquadstatus.members > settings.pile_min and settings.pile_outlined ) )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    visible = settings._visible

    if not visible then

        layout:SetVisible( false )
        return

    end

    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )
    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetPos( layout.x, layout.y )

    hudsquadstatus:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudsquadstatus:InvalidateLayout()

end

---
--- Receive newcomers.
---
net.Receive( NET_JOINED, function( len )

    if not IsVisible() or not visible then return end

    local joined = net.ReadTable()

    for _, member in pairs( joined ) do

        if not IsValid( member ) then continue end
        
        members[ member ] = hudsquadstatus:AddMember( member:HasSpawnFlags( 131072 ) )
        
    end

end)

---
--- Receive leaving members.
---
net.Receive( NET_LEFT, function( len )

    if not IsVisible() or not visible then return end

    local left = net.ReadTable()

    for _, member in pairs( left ) do

        if not IsValid( member ) then continue end

        local component = members[ member ]

        if not component then continue end
        
        hudsquadstatus:RemoveMember( component, member:Health() <= 0 )
        component:SetHealth( 0 )

        members[ member ] = nil

    end

end)

HOLOHUD2.element.Register( "squad", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel           = panel,
    hudsquadstatus  = hudsquadstatus
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "squad", "animation" )
HOLOHUD2.modifier.Add( "background", "squad", "background" )
HOLOHUD2.modifier.Add( "background_color", "squad", "background_color" )
HOLOHUD2.modifier.Add( "color", "squad", "color" )
HOLOHUD2.modifier.Add( "color2", "squad", "color2" )
HOLOHUD2.modifier.Add( "number3_font", "squad", "pile_num_font" )

---
--- Presets
---
HOLOHUD2.presets.Register( "squad", "element/squad" )