local math = math
local surface = surface
local scale_Get = HOLOHUD2.scale.Get
local language_GetPhrase = language.GetPhrase

local COMPASS_SCROLL        = 1
local COMPASS_FADESCROLL    = 2
local COMPASS_DISK          = 3

local GRADUATION_NONE       = 1
local GRADUATION_SIMPLE     = 2
local GRADUATION_NUMERIC    = 3

local MAX_PRECISION         = .001

local precision = CreateClientConVar( "holohud2_draw_compassprecision", 1, true, false, "How precise is the compass." )

local COMPONENT = {
    visible                     = true,
    invalid_layout              = false,
    invalid_yaw_layout          = false,
    mode                        = COMPASS_SCROLL,
    eightwind                   = true,
    threesixty                  = false,
    x                           = 0,
    y                           = 0,
    w                           = 0,
    h                           = 0,
    size                        = 1,
    color                       = color_white,
    color2                      = color_white,
    font                        = "default",
    on_background               = false,
    graduation                  = GRADUATION_SIMPLE,
    graduationsegments          = 2,
    graduationsize              = 8,
    graduationfont              = "default",
    graduation_on_background    = true,
    axis                        = false,
    axiscolor1                  = color_white,
    axiscolor2                  = color_white,
    axisfont                    = "default",
    offset                      = 1,
    yaw                         = 0,
    inverted                    = false,
    _x                          = 0,
    _y                          = 0,
    _w                          = 0,
    _h                          = 0,
    _bearings                   = {}, -- information on all bearings
    _compass                    = {}, -- bearings shown on the compass
    _center                     = 0, -- center element of the compass
    _range                      = 0, -- how many degrees are there between bearings
    _margin                     = 0 -- how far away is each compass bearing from each other (in non disk forms)
}

local BEARINGS = {
    [0]     = "holohud2.common.north",
    [45]    = "holohud2.common.northwest",
    [90]    = "holohud2.common.west",
    [135]   = "holohud2.common.southwest",
    [180]   = "holohud2.common.south",
    [225]   = "holohud2.common.southeast",
    [270]   = "holohud2.common.east",
    [315]   = "holohud2.common.northeast"
}

local BEARING_AXIS = {
    [0]     = { "X-", true },
    [90]    = { "Y-", false },
    [180]   = { "X+", true },
    [270]   = { "Y+", false }
}

function COMPONENT:InvalidateLayout()

    self.invalid_layout = true
    self:InvalidateYawLayout()

end

function COMPONENT:PerformLayout( force )

    if not force and not ( self.visible and self.invalid_layout ) then return end

    -- scale dimensions
    local scale = scale_Get()
    self._x, self._y = math.Round( ( self.x + self.w / 2 ) * scale ), math.Round( ( self.y + self.h / 2 ) * scale )
    self._w, self._h = math.Round( self.w * scale ), math.Round( self.h * scale )

    -- calculate shared values
    local color = self.on_background and self.color2 or self.color
    local gradcolor = self.graduation_on_background and self.color2 or self.color
    local segw, segh = math.max( math.Round( scale ), 1 ), math.Round( self.graduationsize * scale )

    -- build bearings properties
    local points = self.eightwind and 8 or 4
    local cardinal_degrees = math.Round( 360 / points )
    local total = points + points * ( self.graduation ~= GRADUATION_NONE and self.graduationsegments or 0 ) -- cardinal points + in-between bearings
    local range = math.Round( 360 / total )
    local bearings = {}

    for i=1, total do

        local angle = range * ( i - 1 )

        if self.inverted then angle = 360 - angle end

        -- build cardinal point
        if angle % cardinal_degrees == 0 then

            -- get letter
            local bearing = angle + math.Round( self.offset ) * 90
            bearing = language_GetPhrase( BEARINGS[ bearing - math.floor( bearing / 360 ) * 360 ] or angle )

            -- build draw data
            surface.SetFont( self.font )
            local w, h = surface.GetTextSize( bearing )
            local data = { text = bearing, font = self.font, color = color, x = math.Round( -w / 2 ), y = math.Round( -h / 2 ), on_background = self.on_background, paint = self._PaintTextBearing }

            -- add in the axis
            local axis = BEARING_AXIS[angle]
            if self.axis and axis then

                surface.SetFont(self.axisfont)
                data.axis = { text = axis[ 1 ], font = self.axisfont, x = math.Round( -surface.GetTextSize( axis[ 1 ] ) / 2 ), y = h / 2 - scale * 2, color = axis[ 2 ] and self.axiscolor1 or self.axiscolor2 }

            end

            table.insert( bearings, data )
            continue

        end

        if self.graduation == GRADUATION_NONE then continue end

        -- build graduation
        local data = { color = gradcolor, on_background = self.graduation_on_background }
        if self.graduation == GRADUATION_SIMPLE then

            data.paint = self._PaintRectBearing
            data.x, data.y = math.Round( -segw / 2 ), math.Round( -segh / 2 )
            data.w, data.h = segw, segh

        else

            data.paint = self._PaintTextBearing
            data.text = angle
            data.font = self.axisfont

            local w, h = surface.GetTextSize(angle)
            data.x, data.y = math.Round( -w / 2 ), math.Round( -h / 2 )

        end

        table.insert(bearings, data)

    end

    self._bearings = bearings
    self._range = range

    -- layout compass
    local compass = {}
    for i=1, math.Round(total * self.size) do

        compass[i] = { bearing = 1, x = 0, alpha = 1 }

    end

    self._compass = compass

    self._center = math.Round(#compass / 2)
    self._margin = self._w / math.Round(total * self.size) -- get how far away each bearing is

    self.invalid_layout = false
    return true

end

function COMPONENT:InvalidateYawLayout()

    self.invalid_yaw_layout = true

end

function COMPONENT:PerformYawLayout( force )

    if not force and not ( self.visible and self.invalid_yaw_layout ) then return end

    local yaw = self.yaw + 180 -- compensate yaw

    if self.inverted then yaw = 360 - yaw end

    local relative = math.floor( yaw / self._range ) -- get the closest bearing to where we're looking at
    local offset = ( yaw / self._range ) - math.floor( yaw / self._range ) -- get the relative position of the compass

    for i, point in ipairs( self._compass ) do

        point.alpha = 1 -- reset alpha

        -- calculate the bearing to draw
        local bearing = relative + i + 1 - self._center
        bearing = bearing - math.floor( ( bearing - 1 ) / #self._bearings ) * #self._bearings
        point.bearing = bearing

        -- calculate the relative position on the compass
        local pos = i - self._center - offset
        if self.mode == COMPASS_DISK then

            local radiants = math.sin( pos / #self._compass * math.pi )
            point.alpha = 1 - math.abs( radiants ) ^ 2
            point.x = radiants * self._w / 2

        else

            if self.mode == COMPASS_FADESCROLL then point.alpha = 1 - ( math.abs( pos ) / self._center ) ^ 2 end
            point.x = self._margin * pos

        end

    end

    self.invalid_yaw_layout = false
    return true

end

function COMPONENT:Think()

    self:PerformLayout()
    self:PerformYawLayout()

end

function COMPONENT:SetVisible( visible )

    if self.visible == visible then return end

    self.visible = visible
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetInverted( inverted )

    if self.inverted == inverted then return end

    self.inverted = inverted
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetMode( mode )

    if self.mode == mode then return end

    self.mode = mode
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetEightWind( eightwind )

    if self.eightwind == eightwind then return end

    self.eightwind = eightwind
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetThreeSixty( threesixty )

    if self.threesixty == threesixty then return end

    self.threesixty = threesixty
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetPos( x, y )

    if self.x == x and self.y == y then return end

    self.x = x
    self.y = y
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetSize( w, h )

    if self.w == w and self.h == h then return end

    self.w = w
    self.h = h
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetCompassSize( size )

    if self.size == size then return end

    self.size = size
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetColor( color )

    if self.color == color then return end

    self.color = color
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetColor2( color2 )

    if self.color2 == color2 then return end

    self.color2 = color2
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetFont( font )

    if self.font == font then return end

    self.font = font
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetDrawOnBackground( on_background )

    if self.on_background == on_background then return end

    self.on_background = on_background
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetGraduation( graduation )

    if self.graduation == graduation then return end

    self.graduation = graduation
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetGraduationSegments( segments )

    if self.graduationsegments == segments then return end

    self.graduationsegments = segments
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetGraduationSize( size )

    if self.graduationsize == size then return end

    self.graduationsize = size
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetGraduationFont( font )

    if self.graduationfont == font then return end

    self.graduationfont = font
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetDrawGraduationOnBackground( on_background )

    if self.graduation_on_background == on_background then return end

    self.graduation_on_background = on_background
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetDrawAxis( axis )

    if self.axis == axis then return end

    self.axis = axis
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetAxisColor1( color1 )

    if self.axiscolor1 == color1 then return end

    self.axiscolor1 = color1
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetAxisColor2( color2 )

    if self.axiscolor2 == color2 then return end

    self.axiscolor2 = color2
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetAxisFont( font )

    if self.axisfont == font then return end

    self.axisfont = font
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetOffset( offset )

    if self.offset == offset then return end

    self.offset = offset
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetYaw( yaw )

    local precision = math.max( 45 * ( 1 - precision:GetFloat() ), MAX_PRECISION )
    yaw = math.floor( yaw / precision ) * precision -- reduce amount of yaw layout calls

    if self.yaw == yaw then return end

    self.yaw = yaw
    self:InvalidateYawLayout()

    return true

end

function COMPONENT._PaintTextBearing( self, bearing, x, y, alpha )

    surface.SetFont( bearing.font )
    surface.SetTextColor( bearing.color.r, bearing.color.g, bearing.color.b, bearing.color.a * alpha )
    surface.SetTextPos( x + bearing.x, y + bearing.y )
    surface.DrawText( bearing.text )

end

function COMPONENT._PaintRectBearing( self, bearing, x, y, alpha )

    surface.SetDrawColor( bearing.color.r, bearing.color.g, bearing.color.b, bearing.color.a * alpha )
    surface.DrawRect( x + bearing.x, y + bearing.y, bearing.w, bearing.h )

end

function COMPONENT:Paint( x, y )

    if not self.visible then return end

    x, y = x + self._x, y + self._y

    for i = 1, #self._compass do

        local point = self._compass[ i ]
        local bearing = self._bearings[ point.bearing ]

        if bearing.on_background then continue end

        bearing.paint( self, bearing, x + point.x, y, point.alpha )

    end

end

function COMPONENT:PaintBackground( x, y )

    if not self.visible then return end

    x, y = x + self._x, y + self._y

    for i = 1, #self._compass do

        local point = self._compass[ i ]
        local bearing = self._bearings[ point.bearing ]
        local axis = bearing.axis

        if axis then

            surface.SetFont( axis.font )
            surface.SetTextColor( axis.color.r, axis.color.g, axis.color.b, axis.color.a * point.alpha )
            surface.SetTextPos( x + axis.x + point.x, y + axis.y )
            surface.DrawText( axis.text )

        end

        if not bearing.on_background then continue end

        bearing.paint( self, bearing, x + point.x, y, point.alpha )

    end
end

HOLOHUD2.component.Register( "Compass", COMPONENT )
