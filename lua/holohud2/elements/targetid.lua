HOLOHUD2.AddCSLuaFile( "targetid/hudtargetid.lua" )

if SERVER then return end

local LocalPlayer = LocalPlayer
local hook_Call = HOLOHUD2.hook.Call

local visible   = true
local entityid  = false

local ELEMENT = {
    name        = "#holohud2.targetid",
    helptext    = "#holohud2.targetid.helptext",
    parameters  = {
        entityid                = { name = "#holohud2.parameter.entityid", type = HOLOHUD2.PARAM_BOOL, value = false, helptext = "#holohud2.entityid.helptext" },

        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 0, y = 72 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.CENTER },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 16 },

        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_CENTER_HORIZONTAL },

        padding                 = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        name                    = { name = "#holohud2.targetid.name", type = HOLOHUD2.PARAM_BOOL, value = true },
        name_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        name_offset             = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        name_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        name_color              = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        name_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = false },

        team                    = { name = "#holohud2.targetid.team", type = HOLOHUD2.PARAM_BOOL, value = false },
        team_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.TARGETID_POS, value = HOLOHUD2.TARGETID_BOTTOM },
        team_margin             = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        team_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        team_offset             = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        team_teamcolor          = { name = "#holohud2.targetid.team_color", type = HOLOHUD2.PARAM_BOOL, value = false },
        team_color              = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 48 ) },
        team_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 10, weight = 1000, italic = false } },
        team_on_background      = { name = "#holohud2.parameter.on_background", type = HOLOHUD2.PARAM_BOOL, value = true },

        health_color            = { name = "#holohud2.targetid.health", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [25] = Color( 255, 64, 48 ), [50] = Color( 255, 162, 72 ), [100] = Color(72, 255, 72) }, fraction = true, gradual = false } },
        health_color2           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },
        suit_color              = { name = "#holohud2.targetid.suit", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 92, 163, 255 ) }, fraction = true, gradual = false } },
        suit_color2             = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_COLORRANGES, value = { colors = { [0] = Color( 255, 255, 255, 12 ) }, fraction = true, gradual = false } },

        progressbars            = { name = "#holohud2.targetid.percentage_bars", type = HOLOHUD2.PARAM_BOOL, value = false },
        progressbars_pos        = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.TARGETID_POS, value = HOLOHUD2.TARGETID_BOTTOM },
        progressbars_margin     = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        progressbars_spacing    = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        healthbar               = { name = "#holohud2.targetid.health", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_size          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 72, y = 6 }, min_x = 1, min_y = 1 },
        healthbar_growdirection = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthbar_style         = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_TEXTURED },
        healthbar_background    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_lerp          = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_layered       = { name = "#holohud2.percentage_bar.layered", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_dotline       = { name = "#holohud2.percentage_bar.dot_line", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthbar_dotline_size  = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 4 },
        suitbar                 = { name = "#holohud2.targetid.suit", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.TARGETID_POS, value = HOLOHUD2.TARGETID_BOTTOM },
        suitbar_size            = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 72, y = 6 }, min_x = 1, min_y = 1 },
        suitbar_growdirection   = { name = "#holohud2.parameter.grow_direction", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        suitbar_style           = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PROGRESSBARSTYLES, value = HOLOHUD2.PROGRESSBAR_DOT },
        suitbar_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_layered         = { name = "#holohud2.percentage_bar.layered", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_dotline         = { name = "#holohud2.percentage_bar.dot_line", type = HOLOHUD2.PARAM_BOOL, value = true },
        suitbar_dotline_size    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 4 },

        numbers                 = { name = "#holohud2.targetid.numbers", type = HOLOHUD2.PARAM_BOOL, value = true },
        numbers_anchor          = { name = "#holohud2.parameter.anchor", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.TARGETID_ANCHORS, value = HOLOHUD2.TARGETID_ANCHOR_NAME },
        numbers_pos             = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.TARGETID_POS, value = HOLOHUD2.TARGETID_BOTTOM },
        numbers_margin          = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 1 },
        numbers_align           = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_CENTER },
        numbers_offset          = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        numbers_spacing         = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 4 },
        healthnum               = { name = "#holohud2.targetid.health", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthicon              = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        healthicon_size         = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 8 },
        healthicon_style        = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.HEALTHICONS, value = HOLOHUD2.HEALTHICON_CROSS },
        healthicon_spacing      = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 2 },
        healthnum_offset        = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        healthnum_font          = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 13, weight = 1000, italic = false } },
        healthnum_rendermode    = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        healthnum_background    = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        healthnum_align         = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        healthnum_digits        = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },
        healthnum_lerp          = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false },

        suitnum                 = { name = "#holohud2.targetid.suit", type = HOLOHUD2.PARAM_BOOL, value = true },
        suiticon                = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_BOOL, value = true },
        suiticon_size           = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, value = 10 },
        suiticon_style          = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.SUITBATTERYICONS, value = HOLOHUD2.SUITBATTERYICON_SILHOUETTE },
        suiticon_spacing        = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 3 },
        suitnum_offset          = { name = "#holohud2.parameter.offset", type = HOLOHUD2.PARAM_NUMBER, value = 0 },
        suitnum_font            = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 13, weight = 1000, italic = false } },
        suitnum_rendermode      = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        suitnum_background      = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        suitnum_align           = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        suitnum_digits          = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, value = 3, min = 1 },
        suitnum_lerp            = { name = "#holohud2.parameter.lerp", type = HOLOHUD2.PARAM_BOOL, value = false }
    },
    menu = {
        { id = "entityid" },

        { category = "#holohud2.category.panel", parameters = {
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

        { category = "#holohud2.category.coloring", parameters = {
            { id = "name_color" },
            { id = "team_teamcolor", parameters = {
                { id = "team_color" }
            } },
            { id = "health_color", parameters = {
                { id = "health_color2" }
            } },
            { id = "suit_color", parameters = {
                { id = "suit_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "name", parameters = {
                { id = "name_align" },
                { id = "name_offset" },
                { id = "name_font" },
                { id = "name_on_background" }
            } },
            { id = "team", parameters = {
                { id = "team_pos" },
                { id = "team_margin" },
                { id = "team_align" },
                { id = "team_offset" },
                { id = "team_font" },
                { id = "team_on_background" }
            } },
            { id = "progressbars", parameters = {
                { id = "progressbars_pos" },
                { id = "progressbars_margin" },
                { id = "progressbars_spacing" },
                { id = "healthbar", parameters = {
                    { id = "healthbar_size" },
                    { id = "healthbar_growdirection" },
                    { id = "healthbar_style" },
                    { id = "healthbar_background" },
                    { id = "healthbar_lerp" },
                    { id = "healthbar_layered", parameters = {
                        { id = "healthbar_dotline", parameters = {
                            { id = "healthbar_dotline_size" }
                        } }
                    } }
                } },
                { id = "suitbar", parameters = {
                    { id = "suitbar_pos" },
                    { id = "suitbar_size" },
                    { id = "suitbar_growdirection" },
                    { id = "suitbar_style" },
                    { id = "suitbar_background" },
                    { id = "suitbar_lerp" },
                    { id = "suitbar_layered", parameters = {
                        { id = "suitbar_dotline", parameters = {
                            { id = "suitbar_dotline_size" }
                        } }
                    } }
                } }
            } },
            { id = "numbers", parameters = {
                { id = "numbers_anchor", parameters = {
                    { id = "numbers_pos" },
                    { id = "numbers_align" }
                } },
                { id = "numbers_margin" },
                { id = "numbers_offset" },
                { id = "numbers_spacing" },
                { id = "healthnum", parameters = {
                    { id = "healthnum_offset" },
                    { id = "healthnum_font" },
                    { id = "healthnum_rendermode" },
                    { id = "healthnum_background" },
                    { id = "healthnum_align" },
                    { id = "healthnum_digits" },
                    { id = "healthnum_lerp" },
                    { id = "healthicon", parameters = {
                        { id = "healthicon_size" },
                        { id = "healthicon_style" },
                        { id = "healthicon_spacing" }
                    } }
                } },
                { id = "suitnum", parameters = {
                    { id = "suitnum_offset" },
                    { id = "suitnum_font" },
                    { id = "suitnum_rendermode" },
                    { id = "suitnum_background" },
                    { id = "suitnum_align" },
                    { id = "suitnum_digits" },
                    { id = "suitnum_lerp" },
                    { id = "suiticon", parameters = {
                        { id = "suiticon_size" },
                        { id = "suiticon_style" },
                        { id = "suiticon_spacing" }
                    } }
                } }
            } }
        } }
    },
    quickmenu = {
        { id = "entityid" },
        { id = "pos"  },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "name_color" },
            { id = "team_teamcolor", parameters = {
                { id = "team_color" }
            } },
            { id = "health_color", parameters = {
                { id = "health_color2" }
            } },
            { id = "suit_color", parameters = {
                { id = "suit_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "name", parameters = {
                { id = "name_align" },
                { id = "name_offset" },
                { id = "name_font" }
            } },
            { id = "team", parameters = {
                { id = "team_pos" },
                { id = "team_align" },
                { id = "team_offset" },
                { id = "team_font" }
            } },
            { id = "progressbars", parameters = {
                { id = "progressbars_pos" },
                { id = "healthbar", parameters = {
                    { id = "healthbar_size" }
                } },
                { id = "suitbar", parameters = {
                    { id = "suitbar_pos" },
                    { id = "suitbar_size" }
                } },
            } },
            { id = "numbers", parameters = {
                { id = "numbers_anchor" },
                { id = "numbers_pos" },
                { id = "numbers_offset" },
                { id = "healthnum", parameters = {
                    { id = "healthnum_offset" },
                    { id = "healthnum_font" },
                    { id = "healthicon", parameters = {
                        { id = "healthicon_size" }
                    } }
                } },
                { id = "suitnum", parameters = {
                    { id = "suitnum_offset" },
                    { id = "suitnum_font" },
                    { id = "suiticon", parameters = {
                        { id = "suiticon_size" }
                    } }
                } }
            } }
        } }
    }
}

local TIME  = .7

---
--- Override Object Information element.
---
HOLOHUD2.hook.Add( "ShouldShowEntityID", "targetid", function( target )

    if entityid then return end
    if not target:IsPlayer() then return end

    return false

end)

---
--- Override TargetID.
---
hook.Add( "HUDDrawTargetID", "holohud2_targetid", function()

    if not HOLOHUD2.IsVisible() then return end
    if visible then return false end

end)

---
--- Composition
---
local hudtargetid   = HOLOHUD2.component.Create( "HudTargetID" )
local layout        = HOLOHUD2.layout.Register( "targetid" )
local panel         = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawTargetID", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    if hook_Call( "DrawTargetID", x, y, self._w, self._h, LAYER_BACKGROUND ) then return end

    hudtargetid:PaintBackground( x, y )

    hook_Call( "DrawOverTargetID", x, y, self._w, self._h, LAYER_BACKGROUND, hudtargetid )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawTargetID", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    hudtargetid:Paint( x, y )

    hook_Call( "DrawOverTargetID", x, y, self._w, self._h, LAYER_FOREGROUND, hudtargetid )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawTargetID", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    hudtargetid:PaintScanlines( x, y )

    hook_Call( "DrawOverTargetID", x, y, self._w, self._h, LAYER_SCANLINES, hudtargetid )

end

---
--- Startup sequence
---
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    panel:Close()
    startup = true

end

function ELEMENT:Startup()

    startup = false

end

---
--- Logic
---
local localplayer
local _target = NULL
local time = 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    localplayer = localplayer or LocalPlayer()
    local curtime = CurTime()

    if time > curtime then

        if IsValid( _target ) then

            hudtargetid:SetName( _target:Name() )
            hudtargetid:SetTeam( team.GetName( _target:Team() ) )

            hudtargetid:SetMaxHealth( _target:GetMaxHealth() )
            hudtargetid:SetMaxArmor( _target:GetMaxArmor() )

            -- expire panel if target dies
            if not _target:Alive() then

                time = 0

            end

        end

        hudtargetid:SetHealth( IsValid( _target ) and math.max( _target:Health(), 0 ) or 0 )
        hudtargetid:SetArmor( IsValid( _target ) and math.max( _target:Armor(), 0 ) or 0 )

        hudtargetid:Think()

        local w, h = hudtargetid:GetSize()
        layout:SetSize( w + settings.padding * 2 + 4, h + settings.padding * 2 )

    end

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and time > curtime )
    layout:SetVisible( panel:IsVisible() )

    local result = localplayer:GetEyeTrace()

    if not result.Hit then return end

    local target = result.Entity

    if not (IsValid( target ) and target:IsPlayer()) or hook_Call( "ShouldShowTargetID", target, result ) == false then return end

    if target == _target then

        time = curtime + TIME
        return

    end

    hudtargetid._health = hudtargetid.health
    hudtargetid._armor = hudtargetid.armor

    _target = target

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    panel:PaintFrame( x, y )

end

function ELEMENT:PaintBackground( settings, x, y )

    panel:PaintBackground( x, y )

end

function ELEMENT:Paint( settings, x, y )

    panel:Paint( x, y )

end

function ELEMENT:PaintScanlines( settings, x, y )

    panel:PaintScanlines( x, y )

end

---
--- Preview
---
local preview_hudtargetid = HOLOHUD2.component.Create( "HudTargetID" )
local preview_init = false

preview_hudtargetid:SetHealth( 100 )
preview_hudtargetid:SetMaxHealth( 100 )
preview_hudtargetid:SetArmor( 0 )
preview_hudtargetid:SetMaxArmor( 100 )

function ELEMENT:OnPreviewChanged( settings )

    preview_hudtargetid:ApplySettings( settings, self.preview_fonts )

    if settings.team_teamcolor then

        preview_hudtargetid.Team:SetColor( team.GetColor( TEAM_UNASSIGNED ) )

    end

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    local scale = HOLOHUD2.scale.Get()

    x, y = x + w / 2, y + h / 2

    local w, h = ( preview_hudtargetid.__w + settings.padding * 3 ) * scale, ( preview_hudtargetid.__h + settings.padding * 2 ) * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_hudtargetid:Think()
    preview_hudtargetid:PaintBackground( x, y )
    preview_hudtargetid:Paint( x, y )

end

function ELEMENT:PreviewInit( panel )

    if not preview_init then

        preview_hudtargetid:SetName( LocalPlayer():Name() )
        preview_hudtargetid:SetTeam( team.GetName( LocalPlayer():Team() ) )
        preview_init = true

    end

    local controls = vgui.Create( "Panel", panel )
    controls:SetSize( 172, 90 )
    controls:SetPos( 4, panel:GetTall() - controls:GetTall() - 4 )

    local name = vgui.Create( "DTextEntry", controls )
    name:Dock( TOP )
    name:DockMargin( 0, 0, 0, 4 )
    name:SetValue( preview_hudtargetid.name )
    name.OnChange = function( _ )

        preview_hudtargetid:SetName( name:GetValue() )

    end

    local teamname = vgui.Create( "DTextEntry", controls )
    teamname:Dock( TOP )
    teamname:DockMargin( 0, 0, 0, 4 )
    teamname:SetValue( preview_hudtargetid.team )
    teamname.OnChange = function( _ )

        preview_hudtargetid:SetTeam( teamname:GetValue() )

    end

    local health = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", controls )
    health:Dock( TOP )
    health:SetTall( 22 )
    health:SetIcon( "icon16/heart.png" )
    health:SetValue( preview_hudtargetid.health )
    health:SetMaxValue( preview_hudtargetid.max_health )
    health.OnValueChanged = function( _, value )

        preview_hudtargetid:SetHealth( value )

    end
    health.OnMaxValueChanged = function( _, value )

        preview_hudtargetid:SetMaxHealth( value )

    end

    local armor = vgui.Create( "HOLOHUD2_DPreviewProperty_NumberWang", controls )
    armor:Dock( TOP )
    armor:SetIcon( "icon16/shield.png" )
    armor:SetValue( preview_hudtargetid.armor )
    armor:SetMaxValue( preview_hudtargetid.max_armor )
    armor.OnValueChanged = function( _, value )

        preview_hudtargetid:SetArmor( value )

    end
    armor.OnMaxValueChanged = function( _, value )

        preview_hudtargetid:SetMaxArmor( value )

    end

    local reset = vgui.Create( "DImageButton", panel )
    reset:SetSize( 16, 16 )
    reset:SetPos( 134, panel:GetTall() - reset:GetTall() - 5 )
    reset:SetImage( "icon16/arrow_refresh.png" )
    reset.DoClick = function()

        name:SetValue( LocalPlayer():Name() )
        teamname:SetValue( team.GetName( LocalPlayer():Team() ) )
        preview_hudtargetid:SetName( name:GetValue() )
        preview_hudtargetid:SetTeam( teamname:GetValue() )
        health:SetValue( 100 )
        health:SetMaxValue( 100 )
        armor:SetValue( 0 )
        armor:SetMaxValue( 100 )

    end

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    visible = settings._visible
    entityid = settings.entityid

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )

    hudtargetid:ApplySettings( settings, self.fonts )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    hudtargetid:InvalidateLayout()

end

HOLOHUD2.element.Register( "targetid", ELEMENT )

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    hudtargetid = hudtargetid
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "panel_animation", "targetid", "animation" )
HOLOHUD2.modifier.Add( "background", "targetid", "background" )
HOLOHUD2.modifier.Add( "background_color", "targetid", "background_color" )
HOLOHUD2.modifier.Add( "color", "targetid", "name_color" )
HOLOHUD2.modifier.Add( "color2", "targetid", { "team_color", "health_color2", "suit_color2" } )
HOLOHUD2.modifier.Add( "number_rendermode", "targetid", { "healthnum_rendermode", "suitnum_rendermode" } )
HOLOHUD2.modifier.Add( "number_background", "targetid", { "healthnum_background", "suitnum_background" } )
HOLOHUD2.modifier.Add( "number3_font", "targetid", { "healthnum_font", "suitnum_font" } )
HOLOHUD2.modifier.Add( "number3_offset", "targetid", { "healthnum_pos", "suitnum_pos" } )
HOLOHUD2.modifier.Add( "text_font", "targetid", "name_font" )
HOLOHUD2.modifier.Add( "text_offset", "targetid", "name_pos" )
HOLOHUD2.modifier.Add( "text2_font", "targetid", "team_font" )
HOLOHUD2.modifier.Add( "text2_offset", "targetid", "team_pos" )

---
--- Presets
---
HOLOHUD2.presets.Register( "targetid", "element/targetid" )
