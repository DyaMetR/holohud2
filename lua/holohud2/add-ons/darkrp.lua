---
--- DarkRP
--- https://steamcommunity.com/sharedfiles/filedetails/?id=248302805
---

HOLOHUD2.AddCSLuaFile( "darkrp/hudjob.lua" )
HOLOHUD2.AddCSLuaFile( "darkrp/hudagenda.lua" )

if SERVER then return end

if not DarkRP then return end

local LocalPlayer = LocalPlayer
local IsEnabled = HOLOHUD2.IsEnabled
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow

local element_health    = HOLOHUD2.element.Get( "health" )
local element_money     = HOLOHUD2.element.Get( "money" )
local element_hunger    = HOLOHUD2.element.Get( "hunger" )

---
--- Default health indicator
---
--[[
HOLOHUD2.gamemode.SetElementDefaults( "health", {
    size                                    = { x = 114, y = 35 },
    healthnum_pos                           = { x = 62, y = -1 },
    healthnum_font                          = { font = "Roboto Condensed", size = 37, weight = 0, italic = false },
    healthbar                               = false,
    healthpulse                             = true,
    healthpulse_style                       = HOLOHUD2.ECGANIMATION_REALISTIC,
    healthpulse_pos                         = { x = 4, y = 5 },
    healthpulse_size                        = { x = 52, y = 24 },
    healthpulse_brackets_offset             = -3,
    health_suit_oversize_size               = false,
    health_suit_oversize_progressbarsize    = false,
    health_suit_oversize_pulsesize          = false,
    suit_depleted                           = 3,
    suit_separate                           = true,
    suit_autohide                           = false,
    suit_size                               = { x = 35, y = 35 },
    suitnum_pos                             = { x = 19, y = 24 },
    suitnum_font                            = { font = "Roboto Condensed Light", size = 12, weight = 1000, italic = false },
    suiticon_style                          = HOLOHUD2.SUITBATTERYICON_KEVLAR,
    suiticon_pos                            = { x = 7, y = 4 }
    } )]]

---
--- Follow DarkRP's death notice visibility
---
hook.Add("PostGamemodeLoaded", "holohud2_darkrp", function()
    if GAMEMODE.Config.showdeaths then return end
    HOLOHUD2.gamemode.SetParameterOverride( "deathnotice", "_visible", false )
end)

---
--- Radar
---
HOLOHUD2.hook.Add( "VisibleOnRadar", "darkrp", function( ent )

    if not ent:IsPlayer() then return end

    local localplayer = LocalPlayer()

    if not localplayer:getAgendaTable() or not ent:getAgendaTable() or localplayer:getAgendaTable() ~= ent:getAgendaTable() then return end

    return true

end)

HOLOHUD2.gamemode.SetParameterOverride( "radar", "insight", true )
HOLOHUD2.gamemode.SetParameterOverride( "radar", "insight_fov", 60 )

---
--- HungerMod
---
if not DarkRP.disabledDefaults.modules.hungermod then

    HOLOHUD2.hook.Add( "ShouldDrawHunger", "darkrp_hungermod", function()

        return true

    end )

    HOLOHUD2.hook.Add( "GetHunger", "darkrp_hungermod", function()

        return LocalPlayer():getDarkRPVar( "Energy" )

    end)

end

---
--- Money
---
HOLOHUD2.hook.Add( "ShouldDrawMoney", "darkrp", function()

    return true

end)

HOLOHUD2.hook.Add( "GetMoney", "darkrp", function()

    return LocalPlayer():getDarkRPVar( "money" )

end)

--[[HOLOHUD2.gamemode.SetElementDefaults( "money", {
    dock            = HOLOHUD2.DOCK.BOTTOM_LEFT,
    size            = { x = 114, y = 22 },
    number_digits   = 10,
    margin          = 0,
    order           = 50
    } )]]

---
--- Job
---
local ELEMENT = {
    name        = "#holohud2.darkrp.job",
    helptext    = "#holohud2.darkrp.job.helptext",
    parameters  = {
        pos                         = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 12 } },
        dock                        = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_LEFT },
        direction                   = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_UP },
        margin                      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                       = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 52 },

        size                        = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 114, y = 27 } },
        background                  = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color            = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation                   = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction         = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        job_color                   = { name = "#holohud2.darkrp.job_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 200, 200, 200 ) },
        salary_color                = { name = "#holohud2.darkrp.salary_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 96, 255, 72 ) },
        salary_color2               = { name = "#holohud2.parameter.background_color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 12 ) },

        job                         = { name = "#holohud2.darkrp.job", type = HOLOHUD2.PARAM_BOOL, value = true },
        job_pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        job_font                    = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 13, weight = 1000, italic = false } },
        job_align                   = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },

        currency                    = { name = "#holohud2.money.currency", type = HOLOHUD2.PARAM_BOOL, value = true },
        currency_pos                = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 16 } },
        currency_font               = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        currency_text               = { name = "#holohud2.parameter.text", type = HOLOHUD2.PARAM_STRING, value = "+$" },
        currency_align              = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_LEFT },

        number                      = { name = "#holohud2.darkrp.salary", type = HOLOHUD2.PARAM_BOOL, value = true },
        number_pos                  = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 16, y = 16 } },
        number_font                 = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },
        number_rendermode           = { name = "#holohud2.parameter.rendermode", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERRENDERMODES, value = HOLOHUD2.NUMBERRENDERMODE_STATIC },
        number_background           = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.NUMBERBACKGROUNDS, value = HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE },
        number_align                = { name = "#holohud2.parameter.align", type = HOLOHUD2.PARAM_TEXTALIGN, value = TEXT_ALIGN_RIGHT },
        number_digits               = { name = "#holohud2.parameter.digits", type = HOLOHUD2.PARAM_NUMBER, min = 1, value = 3 },

        gunlicense                  = { name = "#holohud2.darkrp.gunlicense", type = HOLOHUD2.PARAM_BOOL, value = true },
        gunlicense_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 96, y = 2 } },
        gunlicense_size             = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 16 },
        gunlicense_alpha            = { name = "#holohud2.parameter.opacity", type = HOLOHUD2.PARAM_RANGE, min = 0, max = 255, value = 70 }
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
            { id = "job_color" },
            { id = "salary_color", parameters = {
                { id = "salary_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "job", parameters = {
                { id = "job_pos" },
                { id = "job_font" },
                { id = "job_align" }
            } },
            { id = "currency", parameters = {
                { id = "currency_pos" },
                { id = "currency_font" },
                { id = "currency_text" },
                { id = "currency_align" }
            } },
            { id = "number", parameters = {
                { id = "number_pos"  },
                { id = "number_font" },
                { id = "number_rendermode" },
                { id = "number_background" },
                { id = "number_align" },
                { id = "number_digits" }
            } },
            { id = "gunlicense", parameters = {
                { id = "gunlicense_pos" },
                { id = "gunlicense_size" },
                { id = "gunlicense_alpha" }
            } }
        } }
    },
    quickmenu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "job_color" },
            { id = "salary_color", parameters = {
                { id = "salary_color2" }
            } }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "job", parameters = {
                { id = "job_pos" },
                { id = "job_font" }
            } },
            { id = "currency", parameters = {
                { id = "currency_pos" },
                { id = "currency_font" }
            } },
            { id = "number", parameters = {
                { id = "number_pos"  },
                { id = "number_font" }
            } },
            { id = "gunlicense", parameters = {
                { id = "gunlicense_pos" },
                { id = "gunlicense_size" }
            } }
        } }
    }
}

--- Composition
local hudjob = HOLOHUD2.component.Create( "DarkRP_HudJob" )
local layout = HOLOHUD2.layout.Register( "darkrp_job" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverBackground = function( _, x, y ) hudjob:PaintBackground( x, y ) end
panel.PaintOver = function( _, x, y ) hudjob:Paint( x, y ) end

--- Startup
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    panel:Close()
    startup = true

end
function ELEMENT:Startup() startup = false end

--- Logic
function ELEMENT:PreDraw( settings )

    if startup then return end

    panel:Think()
    panel:SetDeployed( true )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    local localplayer = LocalPlayer()

    hudjob:SetJob( localplayer:getDarkRPVar( "job" ) )
    hudjob:SetSalary( localplayer:getDarkRPVar( "salary" ) )
    hudjob:SetGunLicense( localplayer:getDarkRPVar( "HasGunlicense" ) )
    hudjob:Think()

end

--- Paint
function ELEMENT:PaintFrame( settings, x, y ) panel:PaintFrame( x, y ) end
function ELEMENT:PaintBackground( settings, x, y ) panel:PaintBackground( x, y ) end
function ELEMENT:Paint( settings, x, y ) panel:Paint( x, y ) end
function ELEMENT:PaintScanlines( settings, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    panel:Paint( x, y )
    EndAlphaMultiplier()

end

--- Preview
local preview_hudjob = HOLOHUD2.component.Create( "DarkRP_HudJob" )
preview_hudjob:SetJob( "Your job title here" )
preview_hudjob:SetSalary( 45 )
preview_hudjob:SetGunLicense( true )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()
    local w, h = settings.size.x * scale, settings.size.y * scale
    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    preview_hudjob:Think()
    preview_hudjob:PaintBackground( x, y )
    preview_hudjob:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudjob:ApplySettings( settings, self.preview_fonts )

end

--- Apply settings
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetDirection( settings.direction )
    layout:SetMargin( settings.margin )
    layout:SetOrder( settings.order )

    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )

    hudjob:ApplySettings( settings, self.fonts )

end

--- Screen size changed
function ELEMENT:OnScreenSizeChanged()

    panel:PerformLayout( true )
    hudjob:InvalidateLayout()

end

local element_job = HOLOHUD2.element.Register( "darkrp_job", ELEMENT )

--- Add common parameters to modifiers
HOLOHUD2.modifier.Add( "panel_animation", "darkrp_job", "animation" )
HOLOHUD2.modifier.Add( "background", "darkrp_job", "background" )
HOLOHUD2.modifier.Add( "background_color", "darkrp_job", "background_color" )
HOLOHUD2.modifier.Add( "color", "darkrp_job", "job_color" )
HOLOHUD2.modifier.Add( "color2", "darkrp_job", "salary_color2" )
HOLOHUD2.modifier.Add( "number_rendermode", "darkrp_job", "number_rendermode" )
HOLOHUD2.modifier.Add( "number_background", "darkrp_job", "number_background" )
HOLOHUD2.modifier.Add( "number2_font", "darkrp_job", { "currency_font", "number_font" } )
HOLOHUD2.modifier.Add( "number2_offset", "darkrp_job", { "currency_pos", "number_pos" } )
HOLOHUD2.modifier.Add( "text_font", "darkrp_job", "job_font" )
HOLOHUD2.modifier.Add( "text_offset", "darkrp_job", "job_pos" )

--- Presets
HOLOHUD2.presets.Register( "darkrp_job", "element/darkrp_job" )

---
--- Agenda
---
local ELEMENT = {
    name        = "Agenda",
    helptext    = "Displays your current agenda to follow.",
    parameters  = {
        pos                     = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 156, y = 12 } },
        dock                    = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.TOP_LEFT },
        direction               = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_DOWN },
        margin                  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order                   = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_ORDER, value = 144 },

        size                    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 172, y = 74 } },
        background              = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation               = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction     = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_DOWN },

        tint                    = { name = "Tint", type = HOLOHUD2.PARAM_COLOR, value = Color( 96, 124, 200 ) },
        color                   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },

        title                   = { name = "Title", type = HOLOHUD2.PARAM_BOOL, value = true },
        title_pos               = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 2 } },
        title_font              = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000, italic = false } },

        separator               = { name = "Separator", type = HOLOHUD2.PARAM_BOOL, value = true },
        separator_pos           = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 16 } },
        separator_size          = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 164, y = 1 } },

        agenda_pos              = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 4, y = 18 } },
        agenda_font             = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Condensed Light", size = 13, weight = 0, italic = false } }
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
            { id = "background" },
            { id = "background_color" },
            { id = "animation" },
            { id = "animation_direction" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "tint" },
            { id = "color" }
        } },

        { category = "#holohud2.category.header", parameters = {
            { id = "title", parameters = {
                { id = "title_pos" },
                { id = "title_font" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_size" }
            } }
        } },

        { category = "Agenda", parameters = {
            { id = "agenda_pos" },
            { id = "agenda_font" }
        } }
    },
    quickmenu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.coloring", parameters = {
            { id = "tint" },
            { id = "color" }
        } },

        { category = "#holohud2.category.header", parameters = {
            { id = "title", parameters = {
                { id = "title_pos" },
                { id = "title_font" }
            } },
            { id = "separator", parameters = {
                { id = "separator_pos" },
                { id = "separator_size" }
            } }
        } },

        { category = "Agenda", parameters = {
            { id = "agenda_pos" },
            { id = "agenda_font" }
        } }
    }
}

--- Composition
local hudagenda = HOLOHUD2.component.Create( "DarkRP_HudAgenda" )
local layout = HOLOHUD2.layout.Register( "darkrp_agenda" )
local panel = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )
panel.PaintOver = function( _, x, y ) hudagenda:Paint( x, y ) end

--- Startup
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    panel:Close()
    startup = true

end
function ELEMENT:Startup() startup = false end

--- Logic
local agenda_text
function ELEMENT:PreDraw( settings )

    if startup then return end

    local localplayer = LocalPlayer()
    local agenda = localplayer:getAgendaTable()

    panel:Think()
    panel:SetDeployed( agenda )
    layout:SetVisible( panel:IsVisible() )

    if not panel:IsVisible() then return end

    hudagenda:Think()

    agenda_text = agenda_text or DarkRP.textWrap( ( localplayer:getDarkRPVar( "agenda" ) or "" ):gsub( "//", "\n" ):gsub( "\\n", "\n" ), self.fonts.agenda_font, panel._w - hudagenda.Contents._x * 2 )

    hudagenda:SetTitle( agenda.Title )
    hudagenda:SetAgenda( agenda_text )

end

--- Paint
function ELEMENT:PaintFrame( settings, x, y ) panel:PaintFrame( x, y ) end
function ELEMENT:Paint( settings, x, y ) panel:Paint( x, y ) end
function ELEMENT:PaintScanlines( settings, x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    panel:Paint( x, y )
    EndAlphaMultiplier()

end


--- Preview
local preview_hudagenda = HOLOHUD2.component.Create( "DarkRP_HudAgenda" )
preview_hudagenda:SetTitle( "Sample agenda" )

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()
    local w, h = settings.size.x * scale, settings.size.y * scale
    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    preview_hudagenda:Think()
    preview_hudagenda:Paint( x, y )

end

function ELEMENT:OnPreviewChanged( settings )

    preview_hudagenda:ApplySettings( settings, self.preview_fonts )
    preview_hudagenda:SetAgenda( DarkRP.textWrap( ( "This is the body of your job agenda. Here, you will visualize what your group should be working towards as indicated by your boss." ):gsub( "//", "\n" ):gsub( "\\n", "\n" ), self.preview_fonts.agenda_font, ( settings.size.x - settings.agenda_pos.x * 2 ) * HOLOHUD2.scale.Get() ) )

end

--- Apply settings
function ELEMENT:OnSettingsChanged( settings )

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetSize( settings.size.x, settings.size.y )
    layout:SetDock( settings.dock )
    layout:SetDirection( settings.direction )
    layout:SetMargin( settings.margin )
    layout:SetOrder( settings.order )

    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )
    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )

    hudagenda:ApplySettings( settings, self.fonts )
    agenda_text = DarkRP.textWrap( ( LocalPlayer():getDarkRPVar( "agenda" ) or "" ):gsub( "//", "\n" ):gsub( "\\n", "\n" ), self.fonts.agenda_font, ( settings.size.x - settings.agenda_pos.x * 2 ) * HOLOHUD2.scale.Get() )

end

--- Screen size changed
function ELEMENT:OnScreenSizeChanged()

    panel:PerformLayout( true )
    hudagenda:InvalidateLayout()

end

local element_agenda = HOLOHUD2.element.Register( "darkrp_agenda", ELEMENT )

--- Add common parameters to modifiers
HOLOHUD2.modifier.Add( "panel_animation", "darkrp_agenda", "animation" )
HOLOHUD2.modifier.Add( "background", "darkrp_agenda", "background" )
HOLOHUD2.modifier.Add( "background_color", "darkrp_agenda", "background_color" )
HOLOHUD2.modifier.Add( "color", "darkrp_agenda", "job_color" )
HOLOHUD2.modifier.Add( "text_offset", "darkrp_agenda", "title_pos" )
HOLOHUD2.modifier.Add( "text_font", "darkrp_agenda", "title_font" )
HOLOHUD2.modifier.Add( "text2_offset", "darkrp_agenda", "agenda_pos" )
HOLOHUD2.modifier.Add( "text2_font", "darkrp_agenda", "agenda_font" )

--- Presets
HOLOHUD2.presets.Register( "darkrp_agenda", "element/darkrp_agenda" )

--- Update agenda
hook.Add( "DarkRPVarChanged", "holohud2_darkrp", function( ply, var, _, new )

    if ply ~= LocalPlayer() then return end
    if var ~= "agenda" or not new then return end

    agenda_text = DarkRP.textWrap( new:gsub( "//", "\n" ):gsub( "\\n", "\n" ), element_agenda.fonts.agenda_font, panel._w - hudagenda.Contents._x * 2 )

end)

---
--- Hide DarkRP HUD
---
hook.Add( "HUDShouldDraw", "holohud2_darkrp", function( name )

    if not IsEnabled() then return end

    if name == "DarkRP_Hungermod" and element_hunger:IsVisible() then

        return false

    end

    if name == "DarkRP_LocalPlayerHUD" and ( element_health:IsVisible() or element_money:IsVisible() or element_job:IsVisible() ) then

        return false

    end

    if name == "DarkRP_Agenda" and element_agenda:IsVisible() then

        return false

    end

end)
