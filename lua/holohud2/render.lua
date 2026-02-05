---
--- In memoriam to <CODE BLUE>
---

local render = render
local cam = cam
local surface = surface
local ScrW = ScrW
local ScrH = ScrH
local scale_Get = HOLOHUD2.scale.Get
local hook_Call = HOLOHUD2.hook.Call
local StartAlphaMultiplier = HOLOHUD2.render.StartAlphaMultiplier
local EndAlphaMultiplier = HOLOHUD2.render.EndAlphaMultiplier

local SCREEN_HEIGHT = HOLOHUD2.SCREEN_HEIGHT

local offset        = HOLOHUD2.offset

local QUALITY3D_INSANE      = 5
local QUALITY3D_HIGH        = 4
local QUALITY3D_MEDIUM      = 3
local QUALITY3D_LOW         = 2
local QUALITY3D_MINIMUM     = 1
local QUALITY3D_NONE        = 0

local GLOWING_SCANLINES     = 3
local GLOWING_SCANLINED     = 2
local GLOWING_SIMPLE        = 1
local GLOWING_NONE          = 0

local RT_FRAME, MAT_FRAME
local RT_SCANLINES, MAT_SCANLINES
local RT_GLOWING, MAT_GLOWING
local RT_SCANLINED, MAT_SCANLINED
local RT_ABERRATION, MAT_ABERRATION
local RT_COMPOSITE, MAT_COMPOSITE

local DEBUG_OVERLAY         = Material( "holohud2/debugoverlay.png" )

local GLOW_SPREAD           = .4
local COLOR_CLR, COLOR_ABR  = Vector( 1, 1, 1 ), { Vector( 0, 0, 1 ), Vector( 0, 1, 0 ), Vector( 1, 0, 0 ) } -- color vectors used for the chromatic aberration

local MOD_ABERRATION        = { "aberration_r", "aberration_g", "aberration_b" }

local elements = {}
local rt_ready = false -- are render targets generated
local rt_w, rt_h = 0, 0 -- render target size
local glow_spread = 0 -- calculated spread for the current screen size
local polygons = {} -- 3D visor effect polygons
local computed = false

---
--- Register the convars that will control the post processing.
---
local r_3d              = CreateClientConVar( "holohud2_r_3d", QUALITY3D_HIGH, true, false, "Enables the 3D visor effect. (0 = disabled, 1 = minimum quality, 2 = low quality, 3 = medium quality, 4 = high quality, 5 = insane quality)", 0, 5 )
local r_3dmargin        = CreateClientConVar( "holohud2_r_3dmargin", .1, true, false, "How much space does the 3D effect keep with the top and bottom of the screen. Setting it to 0 disables the 3D effect.", .01, 1 )
local r_scanlines       = CreateClientConVar( "holohud2_r_scanlines", GLOWING_SCANLINED, true, false, "Determines the quality of the glowing effect. (0 = disabled, 1 = simple glow, 2 = scanlined glow, 3 = fully scanlined)", GLOWING_NONE, GLOWING_SCANLINES)
local r_scanlinesmul    = CreateClientConVar( "holohud2_r_scanlinesmul", 6, true, false, "Determines the intensity of the glowing effect.", 0 )
local r_scanlinespasses = CreateClientConVar( "holohud2_r_scanlinespasses", 2, true, false, "Amount of passes of the glow blurrying.", 0 )
local r_scanlinesglow   = CreateClientConVar( "holohud2_r_scanlinesglow", .4, true, false, "Intensity of the scanlines background glow.", 0, 1 )
local r_scanlinesdist   = CreateClientConVar( "holohud2_r_scanlinesdist", 1, true, false, "Distance between scanlines.", 1 )
local r_aberration      = CreateClientConVar( "holohud2_r_aberration", 1, true, false, "Enables the chromatic aberration effect.", 0, 1 )
local r_aberrationdist  = CreateClientConVar( "holohud2_r_aberrationdist", 1, true, false, "Distance kept between chromatic aberration color layers.", 1 )
local debug             = CreateClientConVar( "holohud2_debug_3d", 0, false )
local r_pp              = GetConVar( "holohud2_r_pp" )

-- post processing modifier
local pp = {
    abs_alpha       = 1,
    alpha           = 1,
    aberration_dist = 1,
    aberration_r    = 1,
    aberration_g    = 1,
    aberration_b    = 1
}

--- Calls the given draw function on all elements.
--- @param func string
--- @param hook string
--- @param settings table
--- @param x number
--- @param y number
--- @param on_overlay boolean
local function draw_elements( func, hook, settings, x, y, on_overlay )

    if hook_Call( hook, settings, x, y, on_overlay ) then return end

    for i=1, #elements do

        local element = elements[ i ]

        if ( on_overlay and not element.on_overlay ) then continue end

        element[ func ]( element, settings[ element.id ], x, y )

    end

end

-- Generates the scanlines overlay.
local function generate_scanlines()

    local dist = math.max( r_scanlinesdist:GetInt(), 1 )

    render.PushRenderTarget( RT_SCANLINES )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()

    surface.SetDrawColor( color_black )

    for i = 1, math.ceil( rt_h / 2 ) / dist do

        surface.DrawRect( 0, ( i - 1 ) * 2 * dist, rt_w, dist )

    end

    cam.End2D()
    render.PopRenderTarget()

    hook_Call( "RefreshScanlinesTexture", rt_w, rt_h )

end

--- Generates the polygons required for the 3D effect.
local function generate_3d_shape()

    polygons = {}

    -- NOTE: instead of a meaningless slider I prefer to give users preset qualities
    local quality = r_3d:GetInt()
    local div = 10 -- default to the previous maximum quality

    if quality == QUALITY3D_INSANE then

        div = 8

    elseif quality == QUALITY3D_HIGH then

        div = 12

    elseif quality == QUALITY3D_MEDIUM then

        div = 16

    elseif quality == QUALITY3D_LOW then

        div = 24

    elseif quality == QUALITY3D_MINIMUM then

        div = 48

    end

    local polycount     = rt_w / div
    local angle         = 180 / polycount
    local size, margin  = rt_w / polycount, rt_h * r_3dmargin:GetFloat()

    for i=0, polycount do

        local x0, y0 = size * i, margin * math.sin( math.rad( angle * i ) ) / 2
        local x1, y1 = size * ( i + 1 ), margin * math.sin( math.rad( angle * ( i + 1 ) ) ) / 2

        polygons[ i + 1 ] = {
            { x = x0, y = y0, u = x0 / rt_w, v = 0 },
            { x = x1, y = y1, u = x1 / rt_w, v = 0 },
            { x = x1, y = rt_h - y1, u = x1 / rt_w, v = 1 },
            { x = x0, y = rt_h - y0, u = x0 / rt_w, v = 1 }
        }

    end

end

--- Generates the render targets for the current screen size.
local function generate_render_targets()

    rt_w, rt_h = ScrW(), ScrH()
    glow_spread = GLOW_SPREAD * rt_h / SCREEN_HEIGHT

    RT_FRAME        = GetRenderTarget( "holohud2/rendertarget/frame_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_FRAME       = CreateMaterial( "holohud2/rendertarget/frame", "UnlitGeneric", {
        [ "$translucent" ]  = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_FRAME:SetTexture( "$basetexture", RT_FRAME )

    RT_SCANLINES    = GetRenderTarget( "holohud2/rendertarget/scanlines_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_SCANLINES   = CreateMaterial( "holohud2/rendertarget/scanlines", "UnlitGeneric", {
        [ "$translucent" ]  = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_SCANLINES:SetTexture( "$basetexture", RT_SCANLINES )

    RT_GLOWING      = GetRenderTarget( "holohud2/rendertarget/glowing_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_GLOWING     = CreateMaterial( "holohud2/rendertarget/glowing", "UnlitGeneric", {
        [ "$additive" ]     = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_GLOWING:SetTexture( "$basetexture", RT_GLOWING )

    RT_SCANLINED      = GetRenderTarget( "holohud2/rendertarget/scanlined_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_SCANLINED     = CreateMaterial( "holohud2/rendertarget/scanlined", "UnlitGeneric", {
        [ "$additive" ]     = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_SCANLINED:SetTexture( "$basetexture", RT_SCANLINED )

    RT_ABERRATION   = GetRenderTarget( "holohud2/rendertarget/aberration_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_ABERRATION  = CreateMaterial( "holohud2/rendertarget/aberration", "UnlitGeneric", {
        [ "$additive" ]     = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_ABERRATION:SetTexture( "$basetexture", RT_ABERRATION )

    RT_COMPOSITE    = GetRenderTarget( "holohud2/rendertarget/composite_" .. rt_w .. "_" .. rt_h, rt_w, rt_h )
    MAT_COMPOSITE   = CreateMaterial( "holohud2/rendertarget/composite", "UnlitGeneric", {
        [ "$additive" ]     = "1",
        [ "$nolod" ]        = "1"
    } )
    MAT_COMPOSITE:SetTexture( "$basetexture", RT_COMPOSITE )

    generate_scanlines()
    generate_3d_shape()

    rt_ready = true

    hook_Call( "RefreshScreenTextures", rt_w, rt_h )

end
HOLOHUD2.render.RefreshScreenTextures = generate_render_targets

--- Captures the draw calls and produces the HUD textures to render.
--- WARNING: probably the most expensive function.
--- @param settings table
--- @param on_overlay boolean
function HOLOHUD2.render.ComputeHUD( settings, on_overlay )

    if not r_pp:GetBool() then return end -- do not compute HUD if post processing is disabled
    if not rt_ready then return end -- require render targets to proceed

    local scale = scale_Get()
    local x, y = offset.x, offset.y
    local scanlines = r_scanlines:GetInt()

    -- calculate post processing modifiers
    pp.abs_alpha        = 1
    pp.alpha            = 1
    pp.aberration_dist  = 1
    pp.aberration_r     = 1
    pp.aberration_g     = 1
    pp.aberration_b     = 1

    hook_Call( "CalcPostProcessing", pp )

    StartAlphaMultiplier( pp.abs_alpha )

    -- background panels
    render.PushRenderTarget( RT_FRAME )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()
    draw_elements( "PaintFrame", "HUDPaintFrame", settings, x, y, on_overlay )
    cam.End2D()
    render.PopRenderTarget()

    StartAlphaMultiplier( pp.alpha )

    -- glowing effect
    render.PushRenderTarget( RT_GLOWING )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()
    draw_elements( "PaintScanlines", "HUDPaintScanlines", settings, x, y, on_overlay )
    cam.End2D()

    -- apply blur effect if we're using any scanlining effects
    if scanlines ~= GLOWING_NONE then

        render.BlurRenderTarget( RT_GLOWING, glow_spread, glow_spread, r_scanlinespasses:GetInt() )

    end

    render.PopRenderTarget()

    -- final glowing effect with scanlines applied
    render.PushRenderTarget( RT_SCANLINED )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()

    local intensity = math.max( r_scanlinesmul:GetInt(), 0 )

    -- dim glow layer when it's not blurred
    if scanlines == GLOWING_NONE then

        intensity = math.ceil( intensity * .3 )

    end

    render.SetMaterial( MAT_GLOWING )

    for i=1, intensity do

        render.DrawScreenQuad()

    end

    -- apply scanlining
    if scanlines >= GLOWING_SCANLINED then

        render.SetMaterial( MAT_SCANLINES )
        render.DrawScreenQuad()

    end

    -- draw underglow
    if scanlines ~= GLOWING_NONE then

        render.SetMaterial( MAT_GLOWING )

        for i=1, math.ceil( intensity * math.Clamp( r_scanlinesglow:GetFloat(), 0, 1 ) ) do

            render.DrawScreenQuad()

        end

    end

    cam.End2D()
    render.PopRenderTarget()

    -- mix foreground and scanlines to create a layer for the chromatic aberration effect
    render.PushRenderTarget( RT_ABERRATION )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()
    draw_elements( "Paint", "HUDPaint", settings, x, y, on_overlay ) -- draw foreground beneath

    if scanlines >= GLOWING_SCANLINES then

        render.SetMaterial( MAT_SCANLINES )
        render.DrawScreenQuad()

    end

    render.SetMaterial( MAT_SCANLINED )
    render.DrawScreenQuad()

    cam.End2D()
    render.PopRenderTarget()

    EndAlphaMultiplier() -- end foreground alpha modifier

    -- create the additive composite layer with the foreground (after applying chromatic aberration) and background together
    render.PushRenderTarget( RT_COMPOSITE )
    render.Clear( 0, 0, 0, 0, true, true )
    cam.Start2D()
    draw_elements( "PaintBackground", "HUDPaintBackground", settings, x, y, on_overlay ) -- paint background beneath

    -- do chromatic aberration effect
    render.SetMaterial( MAT_ABERRATION )
    if r_aberration:GetBool() then

        local distance = math.max( r_aberrationdist:GetInt(), 1 ) * pp.aberration_dist * scale

        for i=1, #COLOR_ABR do

            local pos = distance * ( i - 2 )
            MAT_ABERRATION:SetVector( "$color", COLOR_ABR[ i ] * pp[ MOD_ABERRATION[ i ] ] ) -- set layer colour
            render.DrawScreenQuadEx( pos, pos, rt_w, rt_h )

        end

        MAT_ABERRATION:SetVector( "$color", COLOR_CLR ) -- reset colour

    else

        render.DrawScreenQuad() -- if the effect is disabled just render the foreground as is

    end

    cam.End2D()
    render.PopRenderTarget()

    EndAlphaMultiplier() -- end absolute alpha modifier

    computed = true

end

--- Draws the scanlines overlay texture. Can be used during additive texture generation to apply scanlining.
function HOLOHUD2.render.DrawScanlines()

    if r_scanlines:GetInt() < GLOWING_SCANLINED then return end
    if not MAT_SCANLINES then return end

    render.SetMaterial( MAT_SCANLINES )
    render.DrawScreenQuad()

end

-- Renders the HUD background.
-- @param settings table
function HOLOHUD2.render.RenderHUDBackground( settings )

    if not r_pp:GetBool() then return end

    -- if we couldn't compute the post processing, skip
    if not computed then return end

    if r_3d:GetBool() then

        render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD ) -- HACK: prevent render target shenanigans
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( MAT_FRAME )
        for i=1, #polygons do surface.DrawPoly( polygons[ i ] ) end
        render.OverrideBlend( false )

        return

    end

    render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD ) -- HACK: prevent render target shenanigans
    render.SetMaterial( MAT_FRAME )
    render.DrawScreenQuad()
    render.OverrideBlend( false )

end

-- raw draw hooks
local skip_paint = false
local skip_paintover = false

--- Renders the HUD.
--- @param settings table
--- @param on_overlay boolean
function HOLOHUD2.render.RenderHUD( settings, on_overlay )

    -- if no post processing is being drawn, just draw the HUD raw
    if not r_pp:GetBool() then

        local x, y = offset.x, offset.y
        local skip_frame = hook_Call( "HUDPaintFrame", settings, x, y, on_overlay )

        if not skip_frame then

            for i=1, #elements do

                local element = elements[ i ]

                if ( on_overlay and not element.on_overlay ) then continue end

                element:PaintFrame( settings[ element.id ], x, y )

            end

        end

        local skip_background = hook_Call( "HUDPaintBackground", settings, x, y, on_overlay )

        for i=1, #elements do

            local element = elements[ i ]

            if ( on_overlay and not element.on_overlay ) then continue end

            local element_settings = settings[ element.id ]

            if not skip_background then element:PaintBackground( element_settings, x, y ) end
            if not skip_paint then element:Paint( element_settings, x, y ) end
            if not skip_paintover then element:PaintOver( element_settings ) end

        end

        skip_paint = hook_Call( "HUDPaint", settings, x, y, on_overlay )
        skip_paintover = hook_Call( "HUDPaintOver", settings, 0, 0, on_overlay )

        return

    end

    -- if we couldn't compute the post processing, skip
    if not computed then return end

    -- draw the 3D effect
    if r_3d:GetBool() then

        if debug:GetBool() then

            surface.SetMaterial( DEBUG_OVERLAY )
            for i=1, #polygons do

                local poly = polygons[ i ]
                surface.SetDrawColor( 255, 255, 255 )
                surface.DrawPoly( polygons[ i ] )

                -- wireframe
                surface.SetDrawColor( 255, 255, 255, 64 )
                for j=2, #poly do

                    local first, cur = poly[ 1 ], poly[ j ]
                    surface.DrawLine( first.x, first.y, cur.x, cur.y )

                end

            end

        end

        -- surface.SetDrawColor( 255, 255, 255, 255 )
        -- surface.SetMaterial( MAT_FRAME )
        -- for i=1, #polygons do surface.DrawPoly( polygons[ i ] ) end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( MAT_COMPOSITE )
        for i=1, #polygons do surface.DrawPoly( polygons[ i ] ) end

    else

        -- render.SetMaterial( MAT_FRAME )
        -- render.DrawScreenQuad()

        render.SetMaterial( MAT_COMPOSITE )
        render.DrawScreenQuad()

    end

    -- draw the direct paint layer on top of everything
    draw_elements( "PaintOver", "HUDPaintOver", settings, 0, 0, on_overlay )

end

---
--- Refresh 3D shape when quality or margin settings change.
---
cvars.AddChangeCallback( "holohud2_r_3d", generate_3d_shape )
cvars.AddChangeCallback( "holohud2_r_3dmargin", generate_3d_shape )

---
--- Refreshes the scanlines effect when distance is changed.
---
cvars.AddChangeCallback( "holohud2_r_scanlinesdist", generate_scanlines )
cvars.AddChangeCallback( "holohud2_r_pp", generate_scanlines )

---
--- Refresh materials when invalidated.
---
HOLOHUD2.hook.Add( "InvalidateMaterials", "render", function()

    generate_render_targets()
    generate_scanlines()

end)

---
--- Refresh visible elements list.
---
HOLOHUD2.hook.Add( "OnSettingsChanged", "render", function( settings )

    elements = {}

    for _, element in pairs( HOLOHUD2.element.All() ) do

        if not settings[ element.id ]._visible then continue end

        table.insert( elements, element )

    end

end)
