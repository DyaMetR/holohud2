local math = math
local render = render
local surface = surface
local Lerp = Lerp
local FrameTime = FrameTime
local scale_Get = HOLOHUD2.scale.Get
local BlurRect = HOLOHUD2.render.BlurRect

local offset = HOLOHUD2.offset

local lerp = CreateClientConVar( "holohud2_draw_smoothpaneltransforms", 1, true, false, "Makes panels use linear interpolation to change position or size.", 0, 1 )

local COMPONENT = {
    visible         = true,
    invalid_layout  = false,
    layout          = nil,
    x               = 0,
    y               = 0,
    w               = 0,
    h               = 0,
    color           = color_black,
    background      = true,
    blur            = true,
    lerp            = true,
    _x              = 0,
    _y              = 0,
    _w              = 0,
    _h              = 0,
    _x0             = 0,
    _y0             = 0,
    _x1             = 0,
    _y1             = 0
}

function COMPONENT:InvalidateLayout()

    self.invalid_layout = true

end

function COMPONENT:PerformLayout( force )

    if not self.invalid_layout and not force then return end

    local scale = scale_Get()
    self._x, self._y = math.Round( self.x * scale ), math.Round( self.y * scale )
    self._w, self._h = math.Round( self.w * scale ), math.Round( self.h * scale )

    self.invalid_layout = false
    return true

end

local LERP_TIME = 12
function COMPONENT:Think()

    if not self.visible then return end

    if self.layout then

        self:SetSize( self.layout.w, self.layout.h )
        self:SetPos( self.layout.x, self.layout.y )

    end

    if lerp:GetBool() then

        -- if self._x0 ~= self.x and self._y0 ~= self.y and self._x1 ~= self.w and self._y1 ~= self.h then return end -- NOTE: ???

        if self._x0 == self.x and self._y0 == self.y and self._x1 == self.w and self._y1 == self.h then return true end

        local scale = scale_Get()
        local speed = self.lerp and ( FrameTime() * LERP_TIME ) or 1
        self._x0 = Lerp( speed, self._x0, self.x )
        self._y0 = Lerp( speed, self._y0, self.y )
        self._x1 = Lerp( speed, self._x1, self.w )
        self._y1 = Lerp( speed, self._y1, self.h )

        self._x = math.Round( self._x0 * scale )
        self._y = math.Round( self._y0 * scale )
        self._w = math.Round( ( self._x0 + self._x1 ) * scale ) - self._x
        self._h = math.Round( ( self._y0 + self._y1 ) * scale ) - self._y

        return true

    end

    self:PerformLayout()

    return true

end

function COMPONENT:SetVisible( visible )

    if self.visible == visible then return end

    self.visible = visible
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

function COMPONENT:SetColor( color )

    self.color = color

end

function COMPONENT:SetBlurred( blurred )

    self.blur = blurred

end

function COMPONENT:SetSmoothenTransforms( lerp )

    self.lerp = lerp

end

function COMPONENT:SetLayout( layout )

    self:SetPos( layout.x, layout.y )
    self:SetSize( layout.w, layout.h )

    self._x = 0
    self._y = 0

    self.layout = layout

end

function COMPONENT:SetDrawBackground( background )

    self.background = background

end

function COMPONENT:PaintFrame( x, y )

    if not self.visible then return end

    local x, y, w, h = x + self._x, y + self._y, self._w, self._h

    if self.background then

        if self.blur then

            BlurRect( x, y, w, h )

        end

        surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
        surface.DrawRect( x, y, w, h )

    end

    self:PaintOverFrame( x, y, w, h )

end

function COMPONENT:PaintBackground( x, y )

    if not self.visible then return end

    local x, y = x + self._x, y + self._y

    render.SetScissorRect( x, y, x + self._w, y + self._h, true )
    self:PaintOverBackground( x + offset.x * .3, y + offset.y * .3 )
    render.SetScissorRect( 0, 0, 0, 0, false )

end

function COMPONENT:Paint( x, y )

    if not self.visible then return end

    x, y = x + self._x, y + self._y

    render.SetScissorRect( x, y, x + self._w, y + self._h, true )
    self:PaintOver( x + offset.x * .3, y + offset.y * .3 )
    render.SetScissorRect( 0, 0, 0, 0, false )

end

function COMPONENT:PaintScanlines( x, y )

    if not self.visible then return end

    x, y = x + self._x, y + self._y

    render.SetScissorRect( x, y, x + self._w, y + self._h, true )
    self:PaintOverScanlines( x + offset.x * .3, y + offset.y * .3 )
    render.SetScissorRect( 0, 0, 0, 0, false )

end

function COMPONENT:PaintOverFrame( x, y, w, h ) end
function COMPONENT:PaintOverBackground( x, y ) end
function COMPONENT:PaintOver( x, y ) end
function COMPONENT:PaintOverScanlines( x, y ) end

HOLOHUD2.component.Register( "Panel", COMPONENT )
