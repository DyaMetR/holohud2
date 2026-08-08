
local surface = surface

local BOTTOM    = surface.GetTextureID( "holohud2/arc9/thermometer0" )
local TIP0      = surface.GetTextureID( "holohud2/arc9/thermometer1" )
local TIP1      = surface.GetTextureID( "holohud2/arc9/thermometer1b" )

local COMPONENT = {
    invalid_layout  = false,
    visible         = true,
    color           = color_white,
    vertical        = false,
    x               = 0,
    y               = 0,
    w               = 0,
    h               = 0,
    _x              = 0,
    _y              = 0,
    _w              = 0,
    _h              = 0,
    _tip_x          = 0,
    _tip_y          = 0,
    _tip_size       = 0,
    _tip_texture    = TIP0,
    _bottom_x       = 0,
    _bottom_y       = 0,
    _bottom_size    = 0,
    __w             = 0,
    __h             = 0
}

function COMPONENT:InvalidateLayout()

    self.invalid_layout = true

end

function COMPONENT:PerformLayout( force )

    if ( not self.visible or not self.invalid_layout ) and not force then return end

    local scale = HOLOHUD2.scale.Get()
    self._x, self._y = math.Round( self.x * scale ), math.Round( self.y * scale )
    self._w, self._h = math.Round( self.w * scale ), math.Round( self.h * scale )

    if self.vertical then

        self._x = self._x + self._w * .5

        self._tip_size = self._w
        self._tip_x = self._x
        self._tip_y = self._y - self._tip_size
        self._tip_texture = TIP1

        self._bottom_size = self._w * 2
        self._bottom_x = self._x - self._w * .5
        self._bottom_y = self._y + self._h

        self.__w = self.w * 2
        self.__h = self.h + self.w * 3

    else

        self._bottom_size = self._h * 2
        self._x = self._x + self._bottom_size
        self._y = self._y + self._h * .5

        self._tip_size = self._h
        self._tip_x = self._x + self._w
        self._tip_y = self._y
        self._tip_texture = TIP0

        self._bottom_x = self._x - self._bottom_size
        self._bottom_y = self._y - self._h * .5

        self.__w = self.w + self.h * 3
        self.__h = self.h * 2

    end

    self.invalid_layout = false

end

function COMPONENT:Copy( parent )

    self:SetPos( parent.x, parent.y )
    self:SetSize( parent.w, parent.h )
    self:SetVertical( parent.vertical )

end

function COMPONENT:SetVisible( visible )

    if self.visible == visible then return end

    self.visible = visible
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetColor( color )

    self.color = color

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

function COMPONENT:SetVertical( vertical )

    if self.vertical == vertical then return end

    self.vertical = vertical
    self:InvalidateLayout()

    return true

end

function COMPONENT:Paint( x, y )

    if not self.visible then return end

    surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
    surface.DrawRect( x + self._x, y + self._y, self._w, self._h )

    surface.SetTexture( BOTTOM )
    surface.DrawTexturedRect( x + self._bottom_x, y + self._bottom_y, self._bottom_size, self._bottom_size )

    surface.SetTexture( self._tip_texture )
    surface.DrawTexturedRect( x + self._tip_x, y + self._tip_y, self._tip_size, self._tip_size )

end

HOLOHUD2.component.Register( "ARC9_Thermometer", COMPONENT )
