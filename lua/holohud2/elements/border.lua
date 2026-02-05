local surface = surface
local scale_Get = HOLOHUD2.scale.Get
local GetScreenSize = HOLOHUD2.layout.GetScreenSize
local element_Get = HOLOHUD2.element.Get
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier

local RESOURCE = surface.GetTextureID( "holohud2/border" )

local ELEMENT = {
    name        = "#holohud2.border",
    helptext    = "#holohud2.border.helptext",
    visible     = false,
    parameters  = {
        style   = { name = "#holohud2.parameter.style", type = HOLOHUD2.PARAM_OPTION, options = { "#holohud2.border.style_0", "#holohud2.border.style_1" }, value = 2 },
        frame   = { name = "#holohud2.parameter.frame", type = HOLOHUD2.PARAM_BOOL, value = false },
        color   = { name = "#holohud2.parameter.color", type = HOLOHUD2.PARAM_COLOR, value = Color( 255, 255, 255, 72 ) },
        size    = { name = "#holohud2.parameter.size", type = HOLOHUD2.PARAM_NUMBER, min = 1, value = 10 },
        margin  = { name = "#holohud2.parameter.margin", type = HOLOHUD2.PARAM_NUMBER, min = 0, value = 2 }
    },
    menu = {
        { id = "style" },
        { id = "frame" },
        { id = "color" },
        { id = "size" },
        { id = "margin" }
    },
    quickmenu = {
        { id = "color" },
        { id = "margin" }
    }
}

---
--- Startup sequence
---
local startup -- is the element awaiting startup

function ELEMENT:QueueStartup()

    startup = true

end

function ELEMENT:Startup()

    startup = false

end

---
--- Paint
---
local function paint( x, y, w, h, scale, settings )

    surface.SetDrawColor( settings.color.r, settings.color.g, settings.color.b, settings.color.a )

    local size = math.ceil( settings.size * scale )
    local thickness = math.Round( size / 16 )
    local margin = math.Round( settings.margin * scale )
    local x, y, w, h = x + margin, y + margin, w - margin * 2, h - margin * 2

    if settings.frame then

        surface.DrawRect( x + size * 2, y, w - size * 4, thickness )
        surface.DrawRect( x + size * 2, y + h - thickness, w - size * 4, thickness )
        surface.DrawRect( x, y + size * 2, thickness, h - size * 4 - thickness )
        surface.DrawRect( x + w - thickness, y + size * 2, thickness, h - size * 4 - thickness )

    end

    if settings.style <= 1 then

        surface.DrawRect( x, y, size * 2, thickness )
        surface.DrawRect( x, y + thickness, thickness, size * 2 - thickness )

        surface.DrawRect( x + w - size * 2, y, size * 2, thickness )
        surface.DrawRect( x + w - thickness, y + thickness, thickness, size * 2 - thickness )

        surface.DrawRect( x, y + h - size * 2 - thickness, thickness, size * 2 )
        surface.DrawRect( x, y + h - thickness, size * 2, thickness )

        surface.DrawRect( x + w - thickness, y + h - size * 2 - thickness, thickness, size * 2 )
        surface.DrawRect( x + w - size * 2, y + h - thickness, size * 2, thickness )

    else

        surface.SetTexture( RESOURCE )

        surface.DrawRect( x + size, y, size, thickness )
        surface.DrawTexturedRect( x, y, size, size )
        surface.DrawRect( x, y + size, thickness, size )

        surface.DrawRect( x + w - size * 2, y, size, thickness )
        surface.DrawTexturedRectUV( x + w - size, y, size, size, 1, 0, 0, 1 )
        surface.DrawRect( x + w - thickness, y + size, thickness, size )

        surface.DrawRect( x, y + h - size * 2 - thickness, thickness, size )
        surface.DrawTexturedRectUV( x, y + h - size - thickness, size, size, 0, 1, 1, 0 )
        surface.DrawRect( x + size, y + h - thickness, size, thickness )

        surface.DrawRect( x + w - thickness, y + h - size * 2 - thickness, thickness, size )
        surface.DrawTexturedRectUV( x + w - size, y + h - size - thickness, size, size, 1, 1, 0, 0 )
        surface.DrawRect( x + w - size * 2, y + h - thickness, size, thickness )

    end


end

function ELEMENT:Paint( settings, x, y )

    if startup then return end

    local scale = scale_Get()
    local w, h = GetScreenSize()
    local death = element_Get( "death" )

    StartAlphaMultiplier( death:IsVisible() and death._alpha or 1 )
    paint( x, y, w * scale, h * scale, scale, settings )
    EndAlphaMultiplier()

end

---
--- Preview
---
function ELEMENT:PreviewPaint( x, y, w, h, settings )

    paint( x, y, w, h, scale_Get(), settings )

end

HOLOHUD2.element.Register( "borders", ELEMENT )

---
--- Presets
---
HOLOHUD2.presets.Register( "borders", "element/borders" )

---
--- Add common parameter to modifier
---
HOLOHUD2.modifier.Add( "color", "borders", "color" )
HOLOHUD2.modifier.Add( "scale", "borders", { "size", "margin" } )
