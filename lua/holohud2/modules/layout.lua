---
--- Dynamic HUD layout.
---

HOLOHUD2.layout = {}

local debug_shapes = CreateClientConVar( "holohud2_debug_layout", 0, false, false, "Renders debug rectangles to see layout panels.", 0, 1 )
local user_scale = GetConVar( "holohud2_scale" )

local ScrW              = ScrW
local ScrH              = ScrH

local SCREEN_WIDTH      = HOLOHUD2.SCREEN_WIDTH
local SCREEN_HEIGHT     = HOLOHUD2.SCREEN_HEIGHT

local DIRECTION_UP      = 1
local DIRECTION_DOWN    = 2
local DIRECTION_LEFT    = 3
local DIRECTION_RIGHT   = 4

local DOCK = {
    TOP_LEFT     = 1,
    TOP          = 2,
    TOP_RIGHT    = 3,
    LEFT         = 4,
    CENTER       = 5,
    RIGHT        = 6,
    BOTTOM_LEFT  = 7,
    BOTTOM       = 8,
    BOTTOM_RIGHT = 9
}

local HORIZONTAL_DOCK = {
    LEFT = {
        [ DOCK.TOP_LEFT ]       = true,
        [ DOCK.LEFT ]           = true,
        [ DOCK.BOTTOM_LEFT ]    = true
    },
    CENTER = {
        [ DOCK.TOP ]    = true,
        [ DOCK.CENTER ] = true,
        [ DOCK.BOTTOM ] = true
    },
    RIGHT = {
        [ DOCK.TOP_RIGHT ]      = true,
        [ DOCK.RIGHT ]          = true,
        [ DOCK.BOTTOM_RIGHT ]   = true
    }
}

local VERTICAL_DOCK = {
    TOP = {
        [ DOCK.TOP_LEFT ]   = true,
        [ DOCK.TOP ]        = true,
        [ DOCK.TOP_RIGHT ]  = true
    },
    CENTER = {
        [ DOCK.LEFT ]   = true,
        [ DOCK.CENTER ] = true,
        [ DOCK.RIGHT ]  = true
    },
    BOTTOM = {
        [ DOCK.BOTTOM_LEFT ]    = true,
        [ DOCK.BOTTOM ]         = true,
        [ DOCK.BOTTOM_RIGHT ]   = true
    }
}

local DEBUG_COLOR1  = Color(255, 0, 255, 128)
local DEBUG_COLOR2  = Color(0, 0, 0, 168)

local scrw, scrh = ScrW(), ScrH()
local panels = {} -- registered panels
local active = {} -- visible panels
local invalid_layout = false

--- Returns the boundaries used by panels.
--- @return number w screen width
--- @return number h screen height
local function get_screen_size()

    local user_scale_value = math.Clamp( user_scale:GetFloat(), 0.01, 3 )

    if scrh > scrw then

        return SCREEN_WIDTH / user_scale_value, math.Round( SCREEN_WIDTH * ( scrh / scrw ) ) / user_scale_value

    end

    return math.Round( SCREEN_HEIGHT * ( scrw / scrh ) ) / user_scale_value, SCREEN_HEIGHT / user_scale_value

end
HOLOHUD2.layout.GetScreenSize = get_screen_size

---
--- Define PANEL structure.
---
local PANEL = {
    visible     = false,
    x           = 0,
    y           = 0,
    w           = 0,
    h           = 0,
    dock        = DOCK.TOP_LEFT,
    margin      = 0,
    direction   = DIRECTION_DOWN,
    order       = 0,
    _x          = 0, -- desired x coordinate
    _y          = 0 -- desired y coordinate
}

--- Returns the visibility of this panel.
--- @return boolean visible
function PANEL:IsVisible()

    return self.visible

end

--- Sets the visibility of the panel.
--- @param visible boolean
function PANEL:SetVisible( visible )

    if self.visible == visible then return end

    if not visible then

        active[ self.id ] = nil

    else

        active[ self.id ] = self

    end

    invalid_layout = true
    self.visible = visible

end

--- Moves the horizontal coordinate based on the current dock.
function PANEL:TranslateX()

    local w, _ = get_screen_size()

    if HORIZONTAL_DOCK.CENTER[ self.dock ] then

        self.x = ( w / 2 ) + ( self._x - self.w / 2 )

    elseif HORIZONTAL_DOCK.RIGHT[ self.dock ] then

        self.x = w - ( self._x + self.w )

    else

        self.x = self._x

    end

end

--- Moves the vertical coordinate based on the current dock.
function PANEL:TranslateY()

    local _, h = get_screen_size()

    if VERTICAL_DOCK.CENTER[ self.dock ] then

        self.y = ( h / 2 ) + ( self._y - self.h / 2 )

    elseif VERTICAL_DOCK.BOTTOM[ self.dock ] then

        self.y = h - ( self._y + self.h )

    else

        self.y = self._y

    end

end

--- Moves the position coordinates based on the current dock.
function PANEL:Translate()

    self:TranslateX()
    self:TranslateY()

end

--- Sets the horizontal offset of the panel from its dock.
--- @param x number
function PANEL:SetX( x )

    if self._x == x then return end

    self.x = x
    self._x = x
    self:TranslateX()

    if not self.visible then return end

    invalid_layout = true

end

--- Sets the vertical offset of the panel from its dock.
--- @param y number
function PANEL:SetY( y )

    if self._y == y then return end

    self.y = y
    self._y = y
    self:TranslateY()

    if not self.visible then return end

    invalid_layout = true

end

--- Sets the offset of the panel from its dock.
--- @param x number
--- @param y number
function PANEL:SetPos( x, y )

    self:SetX( x )
    self:SetY( y )

end

--- Sets the width of the panel.
--- @param w number
function PANEL:SetWidth( w )

    if self.w == w then return end

    self.w = w
    self:TranslateX()

    if not self.visible then return end

    invalid_layout = true

end

--- Sets the height of the panel.
--- @param h number
function PANEL:SetHeight( h )

    if self.h == h then return end

    self.h = h
    self:TranslateY()

    if not self.visible then return end

    invalid_layout = true

end

--- Sets the size of the panel.
--- @param w number
--- @param h number
function PANEL:SetSize( w, h )

    self:SetWidth( w )
    self:SetHeight( h )

end

--- Sets where the panel absolute origin is.
--- @param dock HOLOHUD2.DOCK
function PANEL:SetDock( dock )

    if self.dock == dock then return end

    self.dock = dock

    if not self.visible then return end

    invalid_layout = true

end

--- Sets the space kept with other panels.
--- @param margin number
function PANEL:SetMargin( margin )

    if self.margin == margin then return end

    self.margin = margin

    if not self.visible then return end

    invalid_layout = true

end

--- Changes the direction and invalidates the layout if necessary.
--- @param direction HOLOHUD2.DOCK
function PANEL:SetDirection( direction )

    if self.direction == direction then return end

    self.direction = direction

    if not self.visible then return end

    invalid_layout = true

end

--- Changes the order and invalidates the layout if necessary.
--- @param order number
function PANEL:SetOrder( order )

    if self.order == order then return end

    self.order = order

    if not self.visible then return end

    invalid_layout = true

end

--- Registers a new panel and returns it.
--- @param id string
--- @return table panel
function HOLOHUD2.layout.Register( id )

    local panel = table.Copy( PANEL )
    panel.id = id
    panels[ id ] = panel

    return panel

end

--- Returns whether the given rectangles intersect.
--- @param x1 number
--- @param y1 number
--- @param w1 number
--- @param h1 number
--- @param x2 number
--- @param y2 number
--- @param w2 number
--- @param h2 number
local function overlap( x1, y1, w1, h1, x2, y2, w2, h2 )

    return ( ( x1 >= x2 and x1 < x2 + w2 ) or ( x1 + w1 > x2 and x1 + w1 <= x2 + w2 ) ) and
           ( ( y1 >= y2 and y1 < y2 + h2 ) or ( y1 + h1 > y2 and y1 + h1 <= y2 + h2 ) )

end

--- Distributes the registered panels on the screen.
function HOLOHUD2.layout.Layout()

    if not invalid_layout then return end

    -- reset panels positions back to default
    for _, panel in pairs( active ) do

        panel:Translate()

    end

    -- sort panels by order
    local iterator, sorted = SortedPairsByMemberValue( active, "order" )
    local p = 1

    for _, parent in iterator, sorted do

        for c = p + 1, #sorted.KeyValues do

            local child = sorted.KeyValues[ c ].val

            -- if a lower ranking panel collides with a higher one, move aside according to its direction
            if overlap( child.x, child.y, child.w, child.h, parent.x, parent.y, parent.w, parent.h ) or overlap( parent.x, parent.y, parent.w, parent.h, child.x, child.y, child.w, child.h ) then

                if child.direction == DIRECTION_UP then

                    child.y = parent.y - ( child.h + parent.margin )

                elseif child.direction == DIRECTION_LEFT then

                    child.x = parent.x - ( child.w + parent.margin )

                elseif child.direction == DIRECTION_RIGHT then

                    child.x = parent.x + ( parent.w + parent.margin )

                elseif child.direction == DIRECTION_DOWN then

                    child.y = parent.y + ( parent.h + parent.margin )

                end

            end

        end

        p = p + 1

    end

    HOLOHUD2.hook.Call( "OnLayoutPerformed" )
    invalid_layout = false

end

---
--- Force panel layout after changing screen size
---
HOLOHUD2.hook.Add( "OnScaleChanged", "layout", function()

    scrw, scrh = ScrW(), ScrH()
    invalid_layout = true
    HOLOHUD2.layout.Layout()

end)

---
--- Draw debug shapes.
---
hook.Add( "PostDrawHUD", "holohud2_layout", function()

    if not debug_shapes:GetBool() then return end

    local scale = HOLOHUD2.scale.Get()

    for _, panel in pairs( panels ) do

        draw.RoundedBox( 0, panel.x * scale, panel.y * scale, panel.w * scale, panel.h * scale, DEBUG_COLOR1 )
        draw.SimpleText( panel.id, "DermaDefault", panel.x * scale + 2 * scale, panel.y * scale + scale, DEBUG_COLOR2 )

    end

end )

HOLOHUD2.DIRECTION_UP       = DIRECTION_UP
HOLOHUD2.DIRECTION_DOWN     = DIRECTION_DOWN
HOLOHUD2.DIRECTION_LEFT     = DIRECTION_LEFT
HOLOHUD2.DIRECTION_RIGHT    = DIRECTION_RIGHT

HOLOHUD2.DOCK               = DOCK
HOLOHUD2.HORIZONTAL_DOCK    = HORIZONTAL_DOCK
HOLOHUD2.VERTICAL_DOCK      = VERTICAL_DOCK
