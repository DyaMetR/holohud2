local math = math
local render = render
local surface = surface
local FrameTime = FrameTime
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier
local BlurRect = HOLOHUD2.render.BlurRect

local GROWDIRECTION_DOWN                = HOLOHUD2.GROWDIRECTION_DOWN
local GROWDIRECTION_CENTER_HORIZONTAL   = HOLOHUD2.GROWDIRECTION_CENTER_HORIZONTAL
local GROWDIRECTION_CENTER_VERTICAL     = HOLOHUD2.GROWDIRECTION_CENTER_VERTICAL
local GROWDIRECTION_LEFT                = HOLOHUD2.GROWDIRECTION_LEFT
local GROWDIRECTION_RIGHT               = HOLOHUD2.GROWDIRECTION_RIGHT
local GROWDIRECTION_UP                  = HOLOHUD2.GROWDIRECTION_UP

local BaseClass = HOLOHUD2.component.Get( "Panel" )

local pp = GetConVar( "holohud2_r_pp" )
local offset = HOLOHUD2.offset

local PANELANIMATIONS = {}
local animations = {}

local COMPONENT = {
    originx         = 0, -- scissoring operations offset, used when drawing on a non-HUD surface (derma)
    originy         = 0,
    animation       = 0,
    direction       = GROWDIRECTION_DOWN,
    deploy_time     = .18,
    retract_time    = .46,
    deployed        = false,
    progress        = 0,
    _visible        = false,
    _u0             = 0,
    _v0             = 0,
    _u1             = 0,
    _v1             = 0
}

--- Registers an animation for panels to use.
--- @param name string
--- @param funcs table
---     - set_size
---     - pre_draw
---     - post_draw
---     - paint
local function register( name, funcs )

    funcs = funcs or {}

    funcs.name = name
    table.insert(PANELANIMATIONS, name)

    return table.insert(animations, funcs)

end
HOLOHUD2.component.RegisterPanelAnimation = register

--- Returns a registered panel animation
--- @param animation PANELANIMATION
--- @return table data
function HOLOHUD2.component.GetPanelAnimation( animation )

    return animations[ animation ]

end

function COMPONENT:Think()

    if not BaseClass.Think( self ) and ( ( self.deployed and self.progress >= 1 ) or ( not self.deployed and self.progress <= 0 ) ) then return end

    local frametime = FrameTime()

    if self.deployed then

        self.progress = math.min( self.progress + frametime / self.deploy_time, 1 )

    else

        self.progress = math.max( self.progress - frametime / self.retract_time, 0 )

    end

    local animation = animations[ self.animation ]

    if not animation or not animation.set_size then

        self._u0 = 0
        self._v0 = 0
        self._u1 = self._w
        self._v1 = self._h
        self._visible = self.deployed

    else

        local x, y, w, h, visible = animation.set_size( self._w, self._h, self.progress, self.direction )
        self._u0 = x
        self._v0 = y
        self._u1 = w
        self._v1 = h
        self._visible = visible

    end

end

function COMPONENT:SetOrigin( x, y )

    self.originx = x
    self.originy = y

end

function COMPONENT:SetPos( x, y )

    if not BaseClass.SetPos( self, x, y ) then return end
    if self._visible then return end

    self._x0, self._y0, self._x1, self._y1 = self.x, self.y, self.w, self.h

    local scale = HOLOHUD2.scale.Get()
    self._x = math.Round( self._x0 * scale )
    self._y = math.Round( self._y0 * scale )
    self._w = math.Round( ( self._x0 + self._x1 ) * scale ) - self._x
    self._h = math.Round( ( self._y0 + self._y1 ) * scale ) - self._y

    return true

end

function COMPONENT:SetAnimation( animation )

    self.animation = animation

end

function COMPONENT:SetAnimationDirection( direction )

    self.direction = direction

end

function COMPONENT:SetDeployTime( deploy_time )

    self.deploy_time = deploy_time

end

function COMPONENT:SetRetractTime( retract_time )

    self.retract_time = retract_time

end

function COMPONENT:SetDeployed( deployed )

    self.deployed = deployed

end

function COMPONENT:Close()

    self.deployed = false
    self.progress = 0
    self:Think()

end

function COMPONENT:IsVisible()

    return self.deployed or self._visible

end

function COMPONENT:IsDeployed()

    return self.deployed

end

function COMPONENT:PaintFrame( x, y )

    if not self._visible then return end

    local progress = self.progress
    local animation = animations[ self.animation ]
    local x, y = x + self._x, y + self._y

    render.SetScissorRect( self.originx + x + self._u0, self.originy + y + self._v0, self.originx + x + self._u1, self.originy + y + self._v1, true )

    local w, h = self._w, self._h

    if animation and animation.pre_draw then animation.pre_draw( x, y, w, h, progress ) end

    if self.background then

        if self.blur then

            BlurRect( x, y, w, h )

        end

        surface.SetDrawColor( self.color.r, self.color.g, self.color.b, self.color.a )
        surface.DrawRect( x, y, w, h )

    end

    self:PaintOverFrame( x, y )

    if animation then

        if pp:GetBool() and animation.paint then animation.paint( x, y, w, h, progress ) end
        if animation.post_draw then animation.post_draw( x, y, w, h, progress ) end

    end

    render.SetScissorRect( 0, 0, 0, 0, false )

end

function COMPONENT:PaintBackground( x, y )

    if not self._visible then return end

    local progress = self.progress
    local animation = animations[ self.animation ]
    local x, y = x + self._x, y + self._y

    render.SetScissorRect( self.originx + x + self._u0, self.originy + y + self._v0, self.originx + x + self._u1, self.originy + y + self._v1, true )

    local w, h = self._w, self._h

    if animation and animation.pre_draw then animation.pre_draw( x, y, w, h, progress ) end

    self:PaintOverBackground( x + offset.x * .3, y + offset.y * .3 )

    if animation and animation.post_draw then animation.post_draw( x, y, w, h, progress ) end

    render.SetScissorRect( 0, 0, 0, 0, false )

end

function COMPONENT:Paint( x, y )

    if not self._visible then return end

    local progress = self.progress
    local animation = animations[self.animation]
    x, y = x + self._x, y + self._y

    render.SetScissorRect( self.originx + x + self._u0, self.originy + y + self._v0, self.originx + x + self._u1, self.originy + y + self._v1, true )

    local w, h = self._w, self._h

    if animation and animation.pre_draw then animation.pre_draw( x, y, w, h, progress ) end

    self:PaintOver( x + offset.x * .3, y + offset.y * .3 )

    if animation then

        if not pp:GetBool() and animation.paint then animation.paint( x, y, w, h, progress ) end
        if animation.post_draw then animation.post_draw( x, y, w, h, progress ) end

    end

    render.SetScissorRect( 0, 0, 0, 0, false )
end

function COMPONENT:PaintScanlines( x, y )

    if not self._visible then return end

    local progress = self.progress
    local animation = animations[ self.animation ]
    x, y = x + self._x, y + self._y

    render.SetScissorRect( self.originx + x + self._u0, self.originy + y + self._v0, self.originx + x + self._u1, self.originy + y + self._v1, true )

    local w, h = self._w, self._h

    if animation and animation.pre_draw then animation.pre_draw( x, y, w, h, progress ) end

    self:PaintOverScanlines( x + offset.x * .3, y + offset.y * .3 )

    if animation and animation.post_draw then animation.post_draw( x, y, w, h, progress ) end

    render.SetScissorRect( 0, 0, 0, 0, false )

end

HOLOHUD2.component.Register( "AnimatedPanel", COMPONENT, "Panel" )

HOLOHUD2.PANELANIMATION_NONE        = register("#holohud2.option.animatedpanel_0")
HOLOHUD2.PANELANIMATION_DRAWER      = register(
    "#holohud2.option.animatedpanel_1",
    {
        set_size = function( w, h, progress, direction )

            if progress <= 0 then return 0, 0, 0, 0, false end
            if progress >= 1 then return 0, 0, w, h, true end

            local x0, y0, x1, y1 = 0, 0, w, h
            local u, v = math.floor( w * progress ), math.floor( h * progress )

            if direction == GROWDIRECTION_RIGHT then

                x1 = u

            elseif direction == GROWDIRECTION_CENTER_HORIZONTAL then

                local center, size = math.Round( w / 2 ), math.Round( u / 2 )
                x0 = center - size
                x1 = center + size

            elseif direction == GROWDIRECTION_LEFT then

                x0 = w - u

            elseif direction == GROWDIRECTION_DOWN then

                y1 = v

            elseif direction == GROWDIRECTION_CENTER_VERTICAL then

                local center, size = math.Round( h / 2 ), math.Round( v / 2 )
                y0 = center - size
                y1 = center + size

            elseif direction == GROWDIRECTION_UP then

                y0 = h - v

            end

            return x0, y0, x1, y1, true

        end
    }
)
HOLOHUD2.PANELANIMATION_FLASH       = register(
    "#holohud2.option.animatedpanel_2",
    {
        set_size = animations[ HOLOHUD2.PANELANIMATION_DRAWER ].set_size,
        paint = function( x, y, w, h, progress, direction )

            surface.SetDrawColor( 255, 255, 255, 255 * ( 1 - progress ) )
            surface.DrawRect( x, y, w, h )

        end
    }
)
HOLOHUD2.PANELANIMATION_FADE        = register(
    "#holohud2.option.animatedpanel_3",
    {
        set_size = function( w, h, progress ) return 0, 0, w, h, progress > 0 end,
        pre_draw = function( _, _, _, _, progress ) StartAlphaMultiplier( progress ) end,
        post_draw = function( _, _, _, _, progress ) EndAlphaMultiplier( progress ) end
    }
)

HOLOHUD2.PANELANIMATIONS = PANELANIMATIONS
