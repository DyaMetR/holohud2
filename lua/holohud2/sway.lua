---
--- DepthHUD Inline inspired swaying.
--- https://github.com/polivilas/DepthHUD
---

local LocalPlayer = LocalPlayer
local FrameTime = FrameTime
local Lerp = Lerp
local math = math
local scale_Get = HOLOHUD2.scale.Raw

local SWAY_NONE     = 0
local SWAY_MINIMAL  = 1
local SWAY_MOVEMENT = 2
local SWAY_HEADBOB  = 3

local swaying       = CreateClientConVar( "holohud2_sway", 1, true, false, "Selects the type of swaying. ( 0 = disabled, 1 = camera only, 2 = strafing and falling, 3 = headbobbing )" )
local sway_mul      = CreateClientConVar( "holohud2_sway_mul", 1, true, false, "Scales the swaying intesity." )
local sway_speed    = CreateClientConVar( "holohud2_sway_speed", 1, true, false, "Scales the speed of the swaying." )
local headbob_mul	= CreateClientConVar( "holohud2_headbob_mul", 1, true, false, "Scales the intensity of the head bobbing." )
local headbob_speed	= CreateClientConVar( "holohud2_headbob_speed", 1, true, false, "Scales the speed of the head bobbing." )

local CAMERA_SWAY_SPEED     = 8
local MOVEMENT_SWAY_SPEED   = 8
local MOVEMENT_MAX_SPEED    = 5
local HEADBOB_RATE          = 8

local last_angle
local camera    = { x = 0, y = 0 }
local movement  = { x = 0, y = 0 }

---
--- Calculates the swaying for both axis.
---
local localplayer
local headbob = 0
local function calculate()

    local swaying = swaying:GetInt()

    localplayer = localplayer or LocalPlayer()
    local delta = FrameTime()

    -- camera based swaying
    local angle = localplayer:EyeAngles()

    if not last_angle then

        last_angle = angle

    end

    local x = math.AngleDifference( angle.y, last_angle.y ) * sway_mul:GetFloat()
    local y = -math.AngleDifference( angle.p, last_angle.p ) * sway_mul:GetFloat()

    local speed = delta * CAMERA_SWAY_SPEED * sway_speed:GetFloat()
    camera.x = camera.x + ( x - camera.x ) * speed
    camera.y = camera.y + ( y - camera.y ) * speed

    last_angle = angle

    -- skip movement based swaying if disabled
    if swaying == SWAY_MINIMAL then return camera.x, camera.y end

    -- movement based swaying
    local velocity = localplayer:GetVelocity()
    local strafe_velocity = -velocity:Dot( localplayer:GetAngles():Right() ) / 128
    local fall_velocity = velocity.z / 128

    movement.x = Lerp( delta * MOVEMENT_SWAY_SPEED, movement.x, math.Clamp( strafe_velocity, -MOVEMENT_MAX_SPEED, MOVEMENT_MAX_SPEED ) )
    movement.y = Lerp( delta * MOVEMENT_SWAY_SPEED, movement.y, math.min( fall_velocity, MOVEMENT_MAX_SPEED ) )

    -- head bobbing
    if swaying == SWAY_HEADBOB and localplayer:OnGround() and not localplayer:InVehicle() then

		local mul = headbob_mul:GetFloat()
        local velocity = math.min( velocity:Length() / 350, 1 )

        camera.x = camera.x + math.sin( headbob * 3 ) * .45 * velocity * mul
        camera.y = camera.y + math.sin( headbob * 9 ) * .45 * velocity * mul

        headbob = headbob + delta * Lerp( velocity, 1, 2.5 ) * headbob_speed:GetFloat()

    end

    return camera.x + movement.x, camera.y + movement.y

end

---
--- Apply swaing.
---
HOLOHUD2.hook.Add( "CalcOffset", "sway", function( offset )

    if not swaying:GetBool() then return end

    local scale = scale_Get()
    local u, v = calculate()

    offset.x = offset.x + math.Round( u * scale )
    offset.y = offset.y + math.Round( v * scale )

end)
