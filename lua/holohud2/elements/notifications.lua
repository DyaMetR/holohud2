local CurTime = CurTime
local hook_Call = HOLOHUD2.hook.Call
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow
local IsVisible = HOLOHUD2.IsVisible

local LAYER_FRAME       = HOLOHUD2.LAYER_FRAME
local LAYER_BACKGROUND  = HOLOHUD2.LAYER_BACKGROUND
local LAYER_FOREGROUND  = HOLOHUD2.LAYER_FOREGROUND
local LAYER_SCANLINES   = HOLOHUD2.LAYER_SCANLINES

-- cache parameters for notifications
local visible = true
local generic_color, generic_color2, generic_bullet
local error_color, error_color2, error_bullet
local undo_color, undo_color2, undo_bullet
local hint_color, hint_color2, hint_bullet
local cleanup_color, cleanup_color2, cleanup_bullet

local ELEMENT = {
    name        = "#holohud2.notifications",
    helptext    = "#holohud2.notifications.helptext",
    visible     = false,
    parameters  = {
        pos                 = { name = "#holohud2.parameter.pos", type = HOLOHUD2.PARAM_VECTOR, value = { x = 12, y = 68 } },
        dock                = { name = "#holohud2.parameter.dock", type = HOLOHUD2.PARAM_DOCK, value = HOLOHUD2.DOCK.BOTTOM_RIGHT },
        direction           = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_DIRECTION, value = HOLOHUD2.DIRECTION_LEFT },
        margin              = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 4, min = 0 },
        order               = { name = "#holohud2.parameter.order", type = HOLOHUD2.PARAM_NUMBER, value = 144 },

        size                = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_VECTOR, value = { x = 214, y = 90 } },
        background          = { name = "#holohud2.parameter.background", type = HOLOHUD2.PARAM_BOOL, value = true },
        background_color    = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 0, 0, 0, 94 ) },
        animation           = { name = "#holohud2.parameter.animation", type = HOLOHUD2.PARAM_OPTION, options = HOLOHUD2.PANELANIMATIONS, value = HOLOHUD2.PANELANIMATION_FLASH },
        animation_direction = { name = "#holohud2.parameter.direction", type = HOLOHUD2.PARAM_GROWDIRECTION, value = HOLOHUD2.GROWDIRECTION_UP },

        padding             = { name = "#holohud2.parameter.padding", type = HOLOHUD2.PARAM_NUMBER, value = 4 },
        content_margin      = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, value = 8 },
        font                = { name = "#holohud2.parameter.font", type = HOLOHUD2.PARAM_FONT, value = { font = "Roboto Light", size = 12, weight = 1000 } },
        spacing             = { name = "#holohud2.parameter.spacing", type = HOLOHUD2.PARAM_NUMBER, value = 2 },

        generic_color       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        generic_bullet      = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_STRING, value = ">" },
        generic_color2      = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 32, 164, 255 ) },

        error_color         = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        error_bullet        = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_STRING, value = "!" },
        error_color2        = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 48, 32 ) },

        undo_color          = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        undo_bullet         = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_STRING, value = "<" },
        undo_color2         = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 32, 164, 255 ) },

        hint_color          = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        hint_bullet         = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_STRING, value = "?" },
        hint_color2         = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 32, 164, 255 ) },

        cleanup_color       = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255 ) },
        cleanup_bullet      = { name = "#holohud2.component.icon", type = HOLOHUD2.PARAM_STRING, value = "X" },
        cleanup_color2      = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 32, 164, 255 ) }
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

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "content_margin" },
            { id = "font" },
            { id = "spacing" }
        } },

        { category = "#holohud2.notifications", parameters = {
            { name = "Generic", parameters = {
                { id = "generic_color" },
                { id = "generic_bullet", parameters = {
                    { id = "generic_color2" }
                } }
            } },
            { name = "Error", parameters = {
                { id = "error_color" },
                { id = "error_bullet", parameters = {
                    { id = "error_color2" }
                } }
            } },
            { name = "Undo", parameters = {
                { id = "undo_color" },
                { id = "undo_bullet", parameters = {
                    { id = "undo_color2" }
                } }
            } },
            { name = "Hint", parameters = {
                { id = "hint_color" },
                { id = "hint_bullet", parameters = {
                    { id = "hint_color2" }
                } }
            } },
            { name = "Cleanup", parameters = {
                { id = "cleanup_color" },
                { id = "cleanup_bullet", parameters = {
                    { id = "cleanup_color2" }
                } }
            } }
        } }
    },
    quickmenu = {
        { category = "#holohud2.category.panel", parameters = {
            { id = "pos" },
            { id = "size" }
        } },

        { category = "#holohud2.category.composition", parameters = {
            { id = "padding" },
            { id = "font" }
        } },

        { category = "#holohud2.notifications", parameters = {
            { name = "Generic", parameters = {
                { id = "generic_color" },
                { id = "generic_bullet", parameters = {
                    { id = "generic_color2" }
                } }
            } },
            { name = "Error", parameters = {
                { id = "error_color" },
                { id = "error_bullet", parameters = {
                    { id = "error_color2" }
                } }
            } },
            { name = "Undo", parameters = {
                { id = "undo_color" },
                { id = "undo_bullet", parameters = {
                    { id = "undo_color2" }
                } }
            } },
            { name = "Hint", parameters = {
                { id = "hint_color" },
                { id = "hint_bullet", parameters = {
                    { id = "hint_color2" }
                } }
            } },
            { name = "Cleanup", parameters = {
                { id = "cleanup_color" },
                { id = "cleanup_bullet", parameters = {
                    { id = "cleanup_color2" }
                } }
            } }
        } }
    }
}

---
--- Composition
---
local console   = HOLOHUD2.component.Create( "MessageLog" )
local layout    = HOLOHUD2.layout.Register( "notifications" )
local panel     = HOLOHUD2.component.Create( "AnimatedPanel" )
panel:SetLayout( layout )

panel.PaintOverFrame = function( self, x, y )

    hook_Call( "DrawNotifications", x, y, self._w, self._h, LAYER_FRAME )

end

panel.PaintOverBackground = function( self, x, y )

    hook_Call( "DrawNotifications", x, y, self._w, self._h, LAYER_BACKGROUND )

end

panel.PaintOver = function( self, x, y )

    if hook_Call( "DrawNotifications", x, y, self._w, self._h, LAYER_FOREGROUND ) then return end

    console:Paint( x, y )

    hook_Call( "DrawOverNotifications", x, y, self._w, self._h, LAYER_FOREGROUND, console )

end

panel.PaintOverScanlines = function( self, x, y )

    if hook_Call( "DrawNotifications", x, y, self._w, self._h, LAYER_SCANLINES ) then return end

    StartAlphaMultiplier( GetMinimumGlow() )
    console:Paint( x, y )
    EndAlphaMultiplier()

    hook_Call( "DrawOverNotifications", x, y, self._w, self._h, LAYER_SCANLINES, console )

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
local time = 0
function ELEMENT:PreDraw( settings )

    if startup then return end

    console:Think()

    local padding = settings.padding * 2
    local w, h = console:GetContentSize()
    layout:SetSize( math.min( w, settings.size.x ) + padding, math.min( h, settings.size.y ) + padding )

    panel:Think()
    panel:SetDeployed( not self:IsMinimized() and time > CurTime() )
    layout:SetVisible( panel:IsVisible() )

    if panel:IsVisible() then return end

    console:Purge()

end

---
--- Override legacy notifications
---
HOLOHUD2.notification_AddLegacy = HOLOHUD2.notification_AddLegacy or notification.AddLegacy
notification.AddLegacy = function( text, notify, duration )

    if not IsVisible() or not visible then

        HOLOHUD2.notification_AddLegacy( text, notify, duration )
        return

    end

    if startup then return end

    local color, color2, bullet

    if notify == NOTIFY_GENERIC then

        color, color2, bullet = generic_color, generic_color2, generic_bullet

    elseif notify == NOTIFY_ERROR then

        color, color2, bullet = error_color, error_color2, error_bullet

    elseif notify == NOTIFY_UNDO then

        color, color2, bullet = undo_color, undo_color2, undo_bullet

    elseif notify == NOTIFY_HINT then

        color, color2, bullet = hint_color, hint_color2, hint_bullet

    elseif notify == NOTIFY_CLEANUP then

        color, color2, bullet = cleanup_color, cleanup_color2, cleanup_bullet

    end

    console:AddMessage( text, color, color2, bullet )
    time = math.max( time, CurTime() + duration + 1 )

end

---
--- Paint
---
function ELEMENT:PaintFrame( settings, x, y )

    panel:PaintFrame( x, y )

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
local preview_messagelog = HOLOHUD2.component.Create( "MessageLog" )

function ELEMENT:OnPreviewChanged( settings )

    preview_messagelog:SetPos( settings.padding, settings.padding )
    preview_messagelog:SetSize( settings.size.x - settings.padding * 2, settings.size.y - settings.padding * 2 )
    preview_messagelog:SetMargin( settings.content_margin )
    preview_messagelog:SetSpacing( settings.spacing )
    preview_messagelog:SetFont( self.preview_fonts.font )

    preview_messagelog:Purge()
    preview_messagelog:AddMessage( "#holohud2.notifications.preview.generic", settings.generic_color, settings.generic_color2, settings.generic_bullet )
    preview_messagelog:AddMessage( "#holohud2.notifications.preview.error", settings.error_color, settings.error_color2, settings.error_bullet )
    preview_messagelog:AddMessage( "#holohud2.notifications.preview.hint", settings.hint_color, settings.hint_color2, settings.hint_bullet )
    preview_messagelog:AddMessage( "#holohud2.notifications.preview.undo", settings.undo_color, settings.undo_color2, settings.undo_bullet )
    preview_messagelog:AddMessage( "#holohud2.notifications.preview.cleanup", settings.cleanup_color, settings.cleanup_color2, settings.cleanup_bullet )

end

function ELEMENT:PreviewPaint( x, y, w, h, settings )

    x, y = x + w / 2, y + h / 2

    local scale = HOLOHUD2.scale.Get()


    local padding = settings.padding * 2
    local cnt_w, cnt_h = preview_messagelog:GetContentSize()
    w, h = ( math.min( cnt_w, settings.size.x ) + padding ) * scale, ( math.min( cnt_h, settings.size.y ) + padding ) * scale

    x, y = x - w / 2, y - h / 2

    if settings.background then

        draw.RoundedBox( 0, x, y, w, h, settings.background_color )

    end

    surface.SetDrawColor( HOLOHUD2.WIREFRAME_COLOR )
    surface.DrawOutlinedRect( x, y, w, h )

    preview_messagelog:Think()
    preview_messagelog:Paint( x, y )

end

---
--- Apply settings
---
function ELEMENT:OnSettingsChanged( settings )

    visible = settings._visible

    if not settings._visible then

        layout:SetVisible( false )
        return

    end

    generic_color, generic_color2, generic_bullet = settings.generic_color, settings.generic_color2, settings.generic_bullet
    error_color, error_color2, error_bullet = settings.error_color, settings.error_color2, settings.error_bullet
    undo_color, undo_color2, undo_bullet = settings.undo_color, settings.undo_color2, settings.undo_bullet
    hint_color, hint_color2, hint_bullet = settings.hint_color, settings.hint_color2, settings.hint_bullet
    cleanup_color, cleanup_color2, cleanup_bullet = settings.cleanup_color, settings.cleanup_color2, settings.cleanup_bullet

    layout:SetPos( settings.pos.x, settings.pos.y )
    layout:SetDock( settings.dock )
    layout:SetMargin( settings.margin )
    layout:SetDirection( settings.direction )
    layout:SetOrder( settings.order )

    panel:SetAnimation( settings.animation )
    panel:SetAnimationDirection( settings.animation_direction )
    panel:SetDrawBackground( settings.background )
    panel:SetColor( settings.background_color )

    console:SetPos( settings.padding, settings.padding )
    console:SetSize( settings.size.x - settings.padding * 2, settings.size.y - settings.padding * 2 )
    console:SetMargin( settings.content_margin )
    console:SetSpacing( settings.spacing )
    console:SetFont( self.fonts.font )

end

---
--- Screen size changed
---
function ELEMENT:OnScreenSizeChanged()

    panel:InvalidateLayout()
    console:InvalidateLayout()

end

HOLOHUD2.element.Register( "quicknotifs", ELEMENT ) -- NOTE: this implementation was not the planned one -- in case we make a radical new one we're changing its name to avoid configuration conflicts

---
--- Export components
---
ELEMENT.components = {
    panel       = panel,
    console     = console
}

---
--- Add common parameters to modifiers
---
HOLOHUD2.modifier.Add( "background", "quicknotifs", "background" )
HOLOHUD2.modifier.Add( "background_color", "quicknotifs", "background_color" )
HOLOHUD2.modifier.Add( "color", "quicknotifs", { "generic_color", "error_color", "hint_color", "cleanup_color", "undo_color" } )
HOLOHUD2.modifier.Add( "text_font", "quicknotifs", "font" )

---
--- Presets
---
HOLOHUD2.presets.Register( "quicknotifs", "element/quicknotifs" )
