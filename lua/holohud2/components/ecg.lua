local math = math
local CurTime = CurTime
local FrameTime = FrameTime
local surface = surface
local render = render
local scale_Get = HOLOHUD2.scale.Get

local HEARTBEAT_CENTER      = 11 / 16
local HEARTBEAT_SHAPE       = {

    { x = 0, y = 0 },
    { x = 2 / 32, y = -2 / 32 },
    { x = 4 / 32, y = 0 },
    
    { x = 9 / 32, y = -22 / 32 },
    { x = 15 / 32, y = 10 / 32 },
    { x = 20 / 32, y = 0 },

    { x = 22 / 32, y = -2 / 32 },
    { x = 24 / 32, y = 0 },
    { x = 56 / 32, y = 0 },

}
local HEARTBEAT_FLATLINE    = {

    { x = 0, y = 0 },
    { x = 1, y = 0 }

}
local PAIN_TIME, PAIN_SCALE = 16, 6

local ECGANIMATIONS = {}

local animations = {}

local COMPONENT = {
    visible         = true,
    invalid_layout  = false,
    x               = 0,
    y               = 0,
    w               = 0,
    h               = 0,
    animation       = 1,
    color           = color_white,
    speed           = 1.84,
    value           = -1,
    pain            = 0,
    _last_pain      = 0,
    _x              = 0,
    _y              = 0,
    _w              = 0,
    _h              = 0,
    _shape          = {},
    _cache          = {}
}

--- Adds an animation
--- @param name string
--- @param func function
--- @return number
local function register( name, func )

    table.insert( ECGANIMATIONS, name )
    return table.insert( animations, func )

end
HOLOHUD2.component.RegisterECGAnimation = register

function COMPONENT:InvalidateLayout()

    self.invalid_layout = true

end

function COMPONENT:Init()

    self._last_pain = CurTime()

end

function COMPONENT:Add( pos )

    if #self._shape <= 0 then return end
    if #self._cache >= 128 then
        
        table.remove( self._cache, 1 )

    end

    table.insert( self._cache, { pos = pos, shape = self._shape } )

end

function COMPONENT:PerformLayout( force )

    if not force and ( not self.visible or not self.invalid_layout ) then return end
    
    local shape = {}

    local w, h, margin = 1, 1, 1
    local animation = animations[ self.animation ]
    if animation then w, h, margin = animation( self ) end

    if h <= 0 then

        shape = HEARTBEAT_FLATLINE

    else

        for i=1, #HEARTBEAT_SHAPE do

            local point = HEARTBEAT_SHAPE[ i ]
            local x, y = point.x, point.y

            if i >= 4 then

                local diff = x - HEARTBEAT_SHAPE[ i - 1 ].x

                if i <= 6 then

                    diff = diff * w
                    y = y * h

                elseif i == #HEARTBEAT_SHAPE then

                    diff = diff * margin

                end

                x = shape[ i - 1 ].x + diff

            end

            shape[ i ] = { x = x, y = y }

        end

    end

    self._shape = shape

    local scale = scale_Get()
    self._x, self._y = math.Round( self.x * scale ), math.Round( self.y * scale )
    self._w, self._h = math.Round( self.w * scale ), math.Round( self.h * scale )
    
    self.invalid_layout = false
    return true

end

function COMPONENT:SetVisible( visible )

    if self.visible == visible then return end

    self.visible = visible
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetAnimation( animation )

    if self.animation == animation then return end

    self.animation = animation
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetPos( x, y )

    if self.x == x and self.y == y then return end

    self.x = x
    self.y = y

    return true

end

function COMPONENT:SetSize( w, h )

    w = math.max( w, 1 )
    h = math.max( h, 1 )

    if self.w == w and self.h == h then return end

    self.w = w
    self.h = h

    return true

end

function COMPONENT:SetSpeed( speed )

    self.speed = speed

end

function COMPONENT:SetColor( color )

    self.color = color

end

function COMPONENT:SetValue( value )

    value = math.Clamp(value, 0, 1)

    if self.value == value then return end

    if value == 0 then

        self:SetPain( 0 )

    else

        if value < self.value then
            
            self:SetPain( math.min( self.pain + ( self.value - value ) * PAIN_SCALE, 1 ) )
            
        end

    end
    
    self.value = value
    self:InvalidateLayout()

    return true

end

function COMPONENT:SetPain( pain )

    if self.pain == pain then return end

    self.pain = pain
    self:InvalidateLayout()

    return true

end

function COMPONENT:Think()

    if not self.visible then return end

    self:PerformLayout()

    local frametime = FrameTime()
    local curtime = CurTime()
    local delta = frametime * self.speed * self._h

    if #self._cache <= 0 then

        self:Add( delta )

    else

        for i, heartbeat in ipairs(self._cache) do

            local u = heartbeat.shape[ #heartbeat.shape ].x * self._h

            -- add a beat if there's space for it
            if i >= #self._cache and heartbeat.pos >= u then
                
                self:Add( delta )
            
            end
            
            -- remove beats out of bounds
            if heartbeat.pos >= self._w + u then

                local next = self._cache[ i + 1 ]
                next.pos = next.pos + delta
                table.remove( self._cache, i )

            end

            heartbeat.pos = heartbeat.pos + delta

        end

    end

    self:SetPain( math.max( self.pain - ( curtime - self._last_pain ) / PAIN_TIME, 0 ) )
    self._last_pain = curtime

end

function COMPONENT:Paint( x, y )

    if not self.visible then return end

    x, y = x + self._x, y + self._y
    local w, h = self._w, self._h

    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()

    render.SetStencilEnable( true )
    render.SetStencilReferenceValue( 1 )
    render.SetStencilCompareFunction( STENCIL_NEVER )
    render.SetStencilFailOperation( STENCIL_REPLACE )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawRect( x, y, w, h )

    render.SetStencilCompareFunction( STENCIL_EQUAL )
    render.SetStencilFailOperation( STENCIL_KEEP )

    surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )

    local y = y + HEARTBEAT_CENTER * h

    for i=1, #self._cache do

        local heartbeat = self._cache[ i ]
        local x = x + w - heartbeat.pos

        for j=2, #heartbeat.shape do

            local cur = heartbeat.shape[ j ]
            local prev = heartbeat.shape[ j - 1 ]
            local x0, y0, x1, y1 = math.Round( prev.x * h ), math.Round( prev.y * h ), math.Round( cur.x * h ), math.Round( cur.y * h )
            surface.DrawLine( x + x0, y + y0, x + x1, y + y1 )

        end

    end

    render.SetStencilEnable( false )

end

HOLOHUD2.component.Register( "Electrocardiogram", COMPONENT )

local ECGANIMATION_GAME = register(
    "#holohud2.option.ecg_0",
    function(self)

        if self.value <= 0 then return 1, 0, 1 end

        return 1, .2 + .8 * math.Clamp( self.value, 0, 1 ), 1

    end
)
local ECGANIMATION_REACTIVE = register(
    "#holohud2.option.ecg_1",
    function(self)

        if self.value <= 0 then return 1, 0, 1 end

        local pain = .1 + .9 * math.max( 1 - self.pain, 0 )
        return pain, .2 + .8 * math.Clamp( self.value, 0, 1 ), pain

    end
)
local ECGANIMATION_REALISTIC = register(
    "#holohud2.option.ecg_2",
    function(self)

        if self.value <= 0 then return 1, 0, 1 end

        local pain = .1 + .9 * math.max( 1 - self.pain, 0 ) * ( .4 + .6 * math.Clamp( math.abs( .5 - self.value ) * 2, 0, 1 ) )
        return pain, .6 + .4 * math.Clamp( self.value * 2, 0, 1 ), pain

    end
)
local ECGANIMATION_ACCELERATIVE = register(
    "#holohud2.option.ecg_3",
    function(self)

        if self.value <= 0 then return 1, 0, 1 end

        local pain = .1 + .9 * math.Clamp( self.value, 0, 1 )
        return pain, 1, pain

    end
)

HOLOHUD2.ECGANIMATION_GAME          = ECGANIMATION_GAME
HOLOHUD2.ECGANIMATION_REACTIVE      = ECGANIMATION_REACTIVE
HOLOHUD2.ECGANIMATION_REALISTIC     = ECGANIMATION_REALISTIC
HOLOHUD2.ECGANIMATION_ACCELERATIVE  = ECGANIMATION_ACCELERATIVE
HOLOHUD2.ECGANIMATIONS              = ECGANIMATIONS