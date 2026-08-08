local math = math
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier

local RES_POWER         = { surface.GetTextureID("holohud2/auxpower/auxpower"), 64, 64, 0, 0, 41, 64 }
local RES_SPRINT        = { surface.GetTextureID("holohud2/auxpower/sprint"), 64, 64, 0, 0, 64, 57 }
local RES_OXYGEN        = { surface.GetTextureID("holohud2/auxpower/oxygen"), 64, 64, 0, 0, 64, 64 }
local RES_FLASHLIGHT    = { surface.GetTextureID("holohud2/auxpower/flashlight"), 64, 32, 0, 0, 64, 17 }

local COMPONENT = {
    invalid_layout          = false,
    icon_background         = true,
    sprint_background       = true,
    oxygen_background       = true,
    flashlight_background   = true,
    icontray                = false,
    icontray_x              = 0,
    icontray_y              = 0,
    icontray_direction      = HOLOHUD2.DIRECTION_RIGHT,
    icontray_margin         = 0,
    critical_value          = 10,
    value                   = 0,
    max_value               = 100,
    sprint                  = false,
    oxygen                  = false,
    flashlight              = false,
    hide_flashlight         = false,
    text_on_background      = false,
    _decreasing             = false,
    _flashing               = false,
    _flashlight             = true
}

function COMPONENT:Init()

    self.Colors = HOLOHUD2.component.Create( "ColorRanges" )
    self.Colors2 = HOLOHUD2.component.Create( "ColorRanges" )
    local color, color2 = self.Colors:GetColor(), self.Colors2:GetColor()

    local number = HOLOHUD2.component.Create( "Number" )
    number:SetColor( color )
    number:SetColor2( color2 )
    self.Number = number

    local icon = HOLOHUD2.component.Create( "Icon" )
    icon:SetTexture( RES_POWER )
    self.Icon = icon

    local sprint = HOLOHUD2.component.Create( "Icon" )
    sprint:SetTexture( RES_SPRINT )
    self.Sprint = sprint

    local oxygen = HOLOHUD2.component.Create( "Icon" )
    oxygen:SetTexture( RES_OXYGEN )
    self.Oxygen = oxygen

    local flashlight = HOLOHUD2.component.Create( "Icon" )
    flashlight:SetTexture( RES_FLASHLIGHT )
    self.Flashlight = flashlight

    local graph = HOLOHUD2.component.Create( "Graph" )
    graph:SetColor( color )
    graph:SetInverted( true )
    self.Graph = graph

    local graphgauge = HOLOHUD2.component.Create( "Gauge" )
    graphgauge:SetColor( color2 )
    graphgauge:SetDrawLabels( false )
    graphgauge:SetDirection( HOLOHUD2.DIRECTION_RIGHT )
    self.GraphGauge = graphgauge

    local progressbarbackground = HOLOHUD2.component.Create( "Bar" )
    progressbarbackground:SetColor( color2 )
    self.ProgressBarBackground = progressbarbackground

    local progressbar = HOLOHUD2.component.Create( "ProgressBar" )
    progressbar:SetColor( color )
    self.ProgressBar = progressbar

    local gauge = HOLOHUD2.component.Create( "Gauge" )
    gauge:SetColor( color2 )
    gauge:SetLabel1( 0 )
    gauge:SetLabel2( 100 )
    gauge:SetLabel3( 50 )
    self.Gauge = gauge

    local text = HOLOHUD2.component.Create( "Text" )
    text:SetColor( color )
    self.Text = text

    self.Blur = HOLOHUD2.component.Create( "Blur" )

    self.Icons = { sprint, oxygen, flashlight }

end

function COMPONENT:InvalidateComponents()

    self.Number:InvalidateLayout()
    self.Icon:InvalidateLayout()
    self.Sprint:InvalidateLayout()
    self.Oxygen:InvalidateLayout()
    self.Flashlight:InvalidateLayout()
    self.Graph:InvalidateLayout()
    self.GraphGauge:InvalidateLayout()
    self.ProgressBarBackground:InvalidateLayout()
    self.ProgressBar:InvalidateLayout()
    self.Gauge:InvalidateLayout()
    self.Text:InvalidateLayout()

end

function COMPONENT:InvalidateLayout()

    self.invalid_layout = true

end

function COMPONENT:PerformLayout()

    if not self.invalid_layout then return end

    local color, color2 = self.Colors:GetColor(), self.Colors2:GetColor()

    -- count active actions
    local actions, total = 0, 3
    if self.sprint then actions = actions + 1 end
    if self.oxygen then actions = actions + 1 end
    if not self.hide_flashlight then

        total = total + 1
        if self.flashlight then actions = actions + 1 end

    end

    self.Graph:SetValue( actions / total )

    -- layout icon tray
    if self.icontray then

        self.Sprint:SetVisible( self.sprint )
        self.Sprint:SetColor( color )
        self.Oxygen:SetVisible( self.oxygen )
        self.Oxygen:SetColor( color )
        self.Flashlight:SetVisible( not self.hide_flashlight and self.flashlight )
        self.Flashlight:SetColor( color )

        local x, y = self.icontray_x, self.icontray_y
        local dir_x = ( self.icontray_direction == HOLOHUD2.DIRECTION_RIGHT and 1 ) or ( self.icontray_direction == HOLOHUD2.DIRECTION_LEFT and -1 ) or 0
        local dir_y = ( self.icontray_direction == HOLOHUD2.DIRECTION_BOTTOM and 1 ) or ( self.icontray_direction == HOLOHUD2.DIRECTION_TOP and -1 ) or 0
        local margin = self.icontray_margin

        for _, icon in ipairs( self.Icons ) do

            if not icon.visible then continue end

            local w, h = math.floor( icon.size * ( icon.u1 - icon.u0 ) / ( icon.v1 - icon.v0 ) ), icon.size
            icon:SetPos( x - w / 2, y - h / 2 )
            x, y = x + ( w + margin ) * dir_x, y + ( h + margin ) * dir_y

        end

        self.invalid_layout = false

        return

    end

    self.Sprint:SetColor( self.sprint and color or color2 )
    self.Oxygen:SetColor( self.oxygen and color or color2 )
    self.Flashlight:SetColor( self.flashlight and color or color2 )
    self.Flashlight:SetVisible( self._flashlight and not self.hide_flashlight )
    self.invalid_layout = false

end

function COMPONENT:SetDrawIconBackground( background )

    self.icon_background = background

end

function COMPONENT:SetDrawSprintBackground( background )

    self.sprint_background = background

end

function COMPONENT:SetDrawOxygenBackground( background )

    self.oxygen_background = background

end

function COMPONENT:SetDrawFlashlightBackground( background )

    self.flashlight_background = background

end

function COMPONENT:SetDrawTextOnBackground( on_background )

    self.text_on_background = on_background
    self.Text:SetColor( on_background and self.Colors2:GetColor() or self.Colors:GetColor() )

end

function COMPONENT:SetIconTray( icontray )

    if self.icontray == icontray then return end

    self.icontray = icontray

    self:InvalidateLayout()

end

function COMPONENT:SetIconTrayPos( x, y )

    if self.icontray_x == x and self.icontray_y == y then return end

    self.icontray_x = x
    self.icontray_y = y

    self:InvalidateLayout()

end

function COMPONENT:SetIconTrayDirection( icontray_direction )

    if self.icontray_direction == icontray_direction then return end

    self.icontray_direction = icontray_direction

    self:InvalidateLayout()

end

function COMPONENT:SetIconTrayMargin( icontray_margin )

    if self.icontray_margin == icontray_margin then return end

    self.icontray_margin = icontray_margin

    self:InvalidateLayout()

end

function COMPONENT:SetCriticalValue( value )

    self.critical_value = value

end

function COMPONENT:SetMaxValue( max_value )

    if self.max_value == max_value then return end

    self.Colors:SetValue( self.value / max_value )
    self.Colors2:SetValue( self.value / max_value )
    self.ProgressBar:SetValue( self.value / max_value )

    self.max_value = max_value

end

function COMPONENT:SetValue( value )

    if self.value == value then return end

    if ( self.value > value ) ~= self._decreasing then

        self._decreasing = self.value > value

        if self._decreasing then

            self.Blur:Activate()

        end

    end

    self.Colors:SetValue( value / self.max_value )
    self.Colors2:SetValue( value / self.max_value )
    self.Number:SetValue( value )
    self.ProgressBar:SetValue( value / self.max_value )

    self.value = value
end

function COMPONENT:SetSprinting( sprint )

    if self.sprint == sprint then return end

    self.sprint = sprint

    self:InvalidateLayout()

end

function COMPONENT:SetUnderwater( oxygen )

    if self.oxygen == oxygen then return end

    self.oxygen = oxygen

    self:InvalidateLayout()

end

function COMPONENT:SetFlashlightOn( flashlight )

    if self.flashlight == flashlight then return end

    self.flashlight = flashlight

    self:InvalidateLayout()

end

function COMPONENT:SetDrawFlashlight( flashlight )

    if self.hide_flashlight == not flashlight then return end

    self.hide_flashlight = flashlight

    self:InvalidateLayout()

end

function COMPONENT:Think( settings )

    self.Blur:Think()
    self.Colors:Think()
    self.Colors2:Think()
    self.Number:PerformLayout()
    self.Icon:PerformLayout()
    self.Sprint:PerformLayout()
    self.Oxygen:PerformLayout()
    self.Flashlight:PerformLayout()
    self.Graph:Think()
    self.GraphGauge:PerformLayout()
    self.ProgressBarBackground:PerformLayout()
    self.ProgressBar:Think()
    self.Gauge:PerformLayout()
    self.Text:PerformLayout()

    self:PerformLayout( settings )

    self._flashing = self.value == -1 or ( self.value < self.critical_value and CurTime() % .5 > .25 )
    self.Icon:SetColor( self._flashing and self.Colors2:GetColor() or self.Colors:GetColor() )

end

function COMPONENT:PaintBackground( x, y )

    if self._flashing and self.icon_background then self.Icon:Paint( x, y ) end
    if not self.sprint then self.Sprint:Paint( x, y ) end
    if not self.oxygen then self.Oxygen:Paint( x, y ) end
    if not self.flashlight then self.Flashlight:Paint( x, y ) end

    self.Number:PaintBackground( x, y )
    self.GraphGauge:Paint( x, y )
    self.ProgressBarBackground:Paint( x, y )
    self.Gauge:Paint( x, y )

    if self.text_on_background then self.Text:Paint( x, y ) end

end

function COMPONENT:Paint( x, y )

    if not self._flashing then self.Icon:Paint( x, y ) end
    if self.sprint then self.Sprint:Paint( x, y ) end
    if self.oxygen then self.Oxygen:Paint( x, y ) end
    if self.flashlight then self.Flashlight:Paint( x, y ) end

    self.Number:Paint( x, y )
    self.Graph:Paint( x, y )
    self.ProgressBar:Paint( x, y )

    if not self.text_on_background then self.Text:Paint( x, y ) end
end

function COMPONENT:PaintScanlines( x, y )

    StartAlphaMultiplier( self.Blur:GetAmount() )
    self:Paint( x, y )
    EndAlphaMultiplier()

end

function COMPONENT:ApplySettings( settings, fonts )

    self.Colors:SetColors( settings.color )
    self.Colors2:SetColors( settings.color2 )

    local icon = self.Icon
    icon:SetVisible( settings.icon )
    icon:SetPos( settings.icon_pos.x, settings.icon_pos.y )
    icon:SetSize( settings.icon_size )
    self:SetDrawIconBackground( settings.icon_background )

    local number = self.Number
    number:SetVisible( settings.number )
    number:SetPos( settings.number_pos.x, settings.number_pos.y )
    number:SetFont( fonts.number_font )
    number:SetRenderMode( settings.number_rendermode )
    number:SetBackground( settings.number_background )
    number:SetAlign( settings.number_align )

    local graph = self.Graph
    graph:SetVisible( settings.graph )
    graph:SetPos( settings.graph_pos.x, settings.graph_pos.y )
    graph:SetSize( settings.graph_size.x, settings.graph_size.y )
    graph:SetInverted( settings.graph_inverted )

    local graphgauge = self.GraphGauge
    graphgauge:SetVisible( settings.graph and settings.graph_guide )
    graphgauge:SetPos( settings.graph_pos.x + ( settings.graph_inverted and settings.graph_size.x or -3 ), settings.graph_pos.y - 1 )
    graphgauge:SetSize( 2, settings.graph_size.y + 2 )
    graphgauge:SetDirection( settings.graph_inverted and HOLOHUD2.DIRECTION_RIGHT or HOLOHUD2.DIRECTION_LEFT )

    local progressbarbackground = self.ProgressBarBackground
    progressbarbackground:SetVisible( settings.powerbar )
    progressbarbackground:SetPos( settings.powerbar_pos.x, settings.powerbar_pos.y )
    progressbarbackground:SetSize( settings.powerbar_size.x, settings.powerbar_size.y )
    progressbarbackground:SetStyle( settings.powerbar_style )

    local progressbar = self.ProgressBar
    progressbar:SetVisible( settings.powerbar )
    progressbar:SetGrowDirection( settings.powerbar_growdirection )
    progressbar:Copy( progressbarbackground )

    local gauge = self.Gauge
    gauge:SetVisible( settings.powerbar and settings.powerbar_guide )

    if settings.powerbar_growdirection == HOLOHUD2.GROWDIRECTION_RIGHT or settings.powerbar_growdirection == HOLOHUD2.GROWDIRECTION_LEFT or HOLOHUD2.GROWDIRECTION_CENTERHORIZONTAL then

        gauge:SetDirection( settings.powerbar_guide_inverted and HOLOHUD2.DIRECTION_UP or HOLOHUD2.DIRECTION_DOWN )
        gauge:SetPos( self.ProgressBar.x, self.ProgressBar.y + ( settings.powerbar_guide_inverted and self.ProgressBar.h or -self.Gauge.h ) )
        gauge:SetSize( self.ProgressBar.w, 2)

    else

        gauge:SetDirection( settings.powerbar_guide_inverted and HOLOHUD2.DIRECTION_RIGHT or HOLOHUD2.DIRECTION_LEFT )
        gauge:SetPos( self.ProgressBar.x + ( settings.powerbar_guide_inverted and self.ProgressBar.w or -self.Gauge.w ), self.ProgressBar.y )
        gauge:SetSize( 2, self.ProgressBar.h )

    end

    if settings.powerbar_growdirection == HOLOHUD2.GROWDIRECTION_LEFT or settings.powerbar_growdirection == HOLOHUD2.GROWDIRECTION_DOWN then

        gauge:SetLabel1( 100 )
        gauge:SetLabel2( 0 )

    else

        gauge:SetLabel1( 0 )
        gauge:SetLabel2( 100 )

    end
    gauge:SetLabel3( 50 )

    self:SetIconTray( settings.icontray )
    self:SetIconTrayPos( settings.icontray_pos.x, settings.icontray_pos.y )
    self:SetIconTrayDirection( settings.icontray_direction )
    self:SetIconTrayMargin( settings.icontray_margin )

    local sprint = self.Sprint
    sprint:SetVisible( settings.sprint )
    sprint:SetSize( settings.sprint_size )
    sprint:SetPos( settings.sprint_pos.x, settings.sprint_pos.y )

    local oxygen = self.Oxygen
    oxygen:SetVisible( settings.oxygen )
    oxygen:SetSize( settings.oxygen_size )
    oxygen:SetPos( settings.oxygen_pos.x, settings.oxygen_pos.y )

    local flashlight = self.Flashlight
    flashlight:SetVisible( settings.flashlight )
    flashlight:SetSize( settings.flashlight_size )
    flashlight:SetPos( settings.flashlight_pos.x, settings.flashlight_pos.y )
    self._flashlight = settings.flashlight

    local text = self.Text
    text:SetVisible( settings.text )
    text:SetPos( settings.text_pos.x, settings.text_pos.y )
    text:SetFont( fonts.text_font )
    text:SetAlign( settings.text_align )
    text:SetText( settings.text_text )
    self:SetDrawTextOnBackground( settings.text_on_background )

    self:InvalidateLayout()

end

HOLOHUD2.component.Register( "HudSuitPower", COMPONENT )
