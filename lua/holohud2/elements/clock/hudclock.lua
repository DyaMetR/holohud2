local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local GetMinimumGlow = HOLOHUD2.render.GetMinimumGlow

local BaseClass = HOLOHUD2.component.Get( "Clock" )

local COMPONENT = {
    twelve_hours        = false,
    am_background       = true,
    pm_background       = true,
    date_format         = "%x",
    date_on_background  = false,
    text_on_background  = false,
    time                = 0,
    _am                 = false
}

function COMPONENT:Init()

    BaseClass.Init( self )

    self.Date = HOLOHUD2.component.Create( "Text" )

    local am = HOLOHUD2.component.Create( "Text" )
    am:SetText( "#holohud2.common.AM" )
    self.AM = am

    local pm = HOLOHUD2.component.Create( "Text" )
    pm:SetText( "#holohud2.common.PM" )
    self.PM = pm

    self.Text = HOLOHUD2.component.Create( "Text" )

end

function COMPONENT:InvalidateLayout()

    self.Hours:InvalidateLayout()
    self.Minutes:InvalidateLayout()
    self.Seconds:InvalidateLayout()
    self.Separator:InvalidateLayout()
    self.Separator2:InvalidateLayout()
    self.Date:InvalidateLayout()
    self.AM:InvalidateLayout()
    self.PM:InvalidateLayout()
    self.Text:InvalidateLayout()

end

function COMPONENT:SetColor( color )

    BaseClass.SetColor( self, color )

    if not self.date_on_background then self.Date:SetColor( color ) end

    ( self._am and self.AM or self.PM ):SetColor( color )

end

function COMPONENT:SetColor2( color2 )

    BaseClass.SetColor2( self, color2 )

    if self.date_on_background then self.Date:SetColor( color2 ) end

    ( self._am and self.PM or self.AM ):SetColor( color2 )

end

function COMPONENT:SetTwelveHours( twelvehours )

    if self.twelvehours == twelvehours then return end

    self.AM:SetVisible( twelvehours )
    self.PM:SetVisible( twelvehours )

    self.twelvehours = twelvehours

    return true

end

function COMPONENT:SetDrawDateOnBackground( on_background )

    self.date_on_background = on_background

end

function COMPONENT:SetDrawTextOnBackground( on_background )

    self.text_on_background = on_background

end

function COMPONENT:SetDrawAMBackground( background )

    self.am_background = background

end

function COMPONENT:SetDrawPMBackground( background )

    self.pm_background = background

end

function COMPONENT:SetDateFormat( date_format )

    if self.date_format == date_format then return end

    self.date_format = date_format

    self:SetTime( self.time )

    return true

end

function COMPONENT:SetTime( time )

    time = math.ceil( time ) -- NOTE: we don't need floating point precision (we can also save some frames with this)

    if self.time == time then return end

    local date = os.date( "*t", time )

    -- AM or PM?
    local am = date.hour <= 12
    self.AM:SetColor( am and self.color or self.color2 )
    self.PM:SetColor( not am and self.color or self.color2 )
    self._am = am

    -- set date
    self.Date:SetText( HOLOHUD2.util.DateFormat( self.date_format, time ) )

    -- set time
    self.Hours:SetValue( self.twelvehours and ( date.hour - math.floor( ( date.hour - 1 ) / 12 ) * 12 ) or date.hour )
    self.Minutes:SetValue( date.min )
    self.Seconds:SetValue( date.sec )

    self.time = time

    return true

end

function COMPONENT:Think()

    BaseClass.Think( self )

    self.Date:PerformLayout()
    self.AM:PerformLayout()
    self.PM:PerformLayout()

end

function COMPONENT:PaintBackground( x, y )

    BaseClass.PaintBackground( self, x, y )

    if self.date_on_background then self.Date:Paint( x, y ) end
    if self.text_on_background then self.Text:Paint( x, y ) end
    if not self.twelvehours then return end

    if self._am then

        if not self.pm_background then return end

        self.PM:Paint( x, y )

    else

        if not self.am_background then return end

        self.AM:Paint( x, y )

    end

end

function COMPONENT:Paint( x, y )

    BaseClass.Paint( self, x, y )

    if not self.date_on_background then self.Date:Paint( x, y ) end
    if not self.text_on_background then self.Text:Paint( x, y ) end
    if not self.twelvehours then return end

    if self._am then

        self.AM:Paint( x, y )

    else

        self.PM:Paint( x, y )

    end

end

function COMPONENT:PaintScanlines( x, y )

    StartAlphaMultiplier( GetMinimumGlow() )
    self:Paint( x, y )
    EndAlphaMultiplier()

end

function COMPONENT:ApplySettings( settings, fonts )

    self:SetColor( settings.color )
    self:SetColor2( settings.color2 )
    self:SetBlinking( settings.blinking )
    self:SetTwelveHours( settings.twelvehours )

    local am = self.AM
    am:SetFont( fonts.am_font )
    self:SetDrawAMBackground( settings.am_background )

    local pm = self.PM
    pm:SetFont( fonts.pm_font )
    self:SetDrawPMBackground( settings.pm_background )

    local hour = self.Hours
    hour:SetVisible( settings.hour )
    hour:SetFont( fonts.hour_font )
    hour:SetRenderMode( settings.hour_rendermode )
    hour:SetBackground( settings.hour_background )
    hour:SetAlign( settings.hour_align )

    local separator = self.Separator
    separator:SetVisible( settings.hour_separator )
    separator:SetFont( fonts.hour_separator_font )
    self:SetDrawSeparatorBackground( settings.hour_separator_background )

    local minutes = self.Minutes
    minutes:SetVisible( settings.minutes )
    minutes:SetFont( fonts.minutes_font )
    minutes:SetRenderMode( settings.minutes_rendermode )
    minutes:SetBackground( settings.minutes_background )
    minutes:SetAlign( settings.minutes_align )

    local separator2 = self.Separator2
    separator2:SetVisible( settings.minutes_separator )
    separator2:SetFont( fonts.minutes_separator_font )

    local seconds = self.Seconds
    seconds:SetVisible( settings.seconds )
    seconds:SetFont( fonts.seconds_font )
    seconds:SetRenderMode( settings.seconds_rendermode )
    seconds:SetBackground( settings.seconds_background )
    seconds:SetAlign( settings.seconds_align )

    local date = self.Date
    date:SetVisible( settings.date )
    date:SetPos( settings.date_pos.x, settings.date_pos.y )
    date:SetFont( fonts.date_font )
    date:SetAlign( settings.date_align )
    self:SetDrawDateOnBackground( settings.date_on_background )
    self:SetDateFormat( HOLOHUD2.util.ParseDateFormat( settings.date_format ) )
    date:InvalidateLayout()

    local text = self.Text
    text:SetVisible( settings.text )
    text:SetText( settings.text_text )
    text:SetPos( settings.text_pos.x, settings.text_pos.y )
    text:SetFont( fonts.text_font )
    text:SetAlign( settings.text_align )
    text:SetColor( settings.text_on_background and settings.color2 or settings.color )
    self:SetDrawTextOnBackground( settings.text_on_background )
    text:InvalidateLayout()

    am:PerformLayout( true )
    pm:PerformLayout( true )
    hour:PerformLayout( true )
    separator:PerformLayout( true )
    minutes:PerformLayout( true )
    separator2:PerformLayout( true )
    seconds:PerformLayout( true )

    local am_w, pm_w = am.__w, pm.__w
    local hour_w, separator_w = 0, 0
    local minutes_w, separator2_w = 0, 0
    local seconds_w = 0
    local spacings = 0

    if settings.hour then

        hour_w = hour.__w
        spacings = spacings + 1

        if settings.hour_separator then

            separator_w = separator.__w
            spacings = spacings + 1

        end

    end

    if settings.minutes then

        minutes_w = minutes.__w
        spacings = spacings + 1

        if settings.minutes_separator then

            separator2_w = separator2.__w
            spacings = spacings + 1

        end

    end

    if settings.seconds then

        seconds_w = seconds.__w

    end

    local w = hour_w + separator_w + minutes_w + separator2_w + seconds_w + settings.spacing * spacings

    if settings.twelvehours then

        w = w + math.max( am_w, pm_w )

    end

    local x, y = settings.origin.x, settings.origin.y

    if settings.align == TEXT_ALIGN_CENTER then

        x = x - w / 2

    elseif settings.align == TEXT_ALIGN_RIGHT then

        x = x - w

    end


    hour:SetPos( x + settings.hour_offset.x, y + settings.hour_offset.y )

    x = x + hour_w + settings.spacing
    separator:SetPos( x + settings.hour_separator_offset.x, y + settings.hour_separator_offset.y )

    x = x + separator_w + settings.spacing
    minutes:SetPos( x + settings.minutes_offset.x, y + settings.minutes_offset.y )

    x = x + minutes_w + settings.spacing
    separator2:SetPos( x + settings.minutes_separator_offset.x, y + settings.minutes_separator_offset.y )

    x = x + separator2_w + settings.spacing
    seconds:SetPos( x + settings.seconds_offset.x, y + settings.seconds_offset.y )

    x = x + seconds_w + settings.spacing
    am:SetPos( x + settings.am_offset.x, y + settings.am_offset.y )
    pm:SetPos( x + settings.pm_offset.x, y + settings.pm_offset.y )

end

HOLOHUD2.component.Register( "HudClock", COMPONENT, "Clock" )
