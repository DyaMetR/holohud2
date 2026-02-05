local CVAR_ACCESSIBILITY = {
    holohud2_r_flickering           = 1,
    holohud2_r_shaking              = 1,
    holohud2_r_shaking_min          = 1,
    holohud2_r_shaking_add          = 3,
    holohud2_nosuit                 = 0,
    holohud2_panel_lerp             = 1,
    holohud2_sway                   = 1,
    holohud2_sway_mul               = 2,
    holohud2_sway_speed             = 1,
    holohud2_headbob_mul			= 1,
    holohud2_headbob_speed			= 1,
    holohud2_draw_minglow           = .2,
    holohud2_r_scanlinesmul         = 6,
    holohud2_r_scanlinespasses      = 2,
    holohud2_r_scanlinesglow        = .4,
    holohud2_r_scanlinesdist        = 1,
    holohud2_r_aberrationdist       = 1,
    holohud2_r_3dmargin             = .1,
    holohud2_draw_compassprecision  = 1
}

local CVAR_PERFORMANCE = {
    holohud2_r_3d                   = 4,
    holohud2_r_scanlines            = 2,
    holohud2_r_blur                 = 1,
    holohud2_r_aberration           = 1,
    holohud2_draw_expensivedigits   = 1,
    holohud2_draw_graphquality      = 1,
    holohud2_r_pp                   = 1
}

---
--- Populate the tool menu.
---
hook.Add( "PopulateToolMenu", "holohud2", function()

    ---
    --- Properties
    ---
    spawnmenu.AddToolMenuOption( "Utilities", HOLOHUD2.Name, "holohud2_a", "#holohud2.properties", nil, nil, function( panel )

        panel:ClearControls()

        panel:Help( HOLOHUD2.Name .. " v" .. HOLOHUD2.Version )
        panel:ControlHelp( language.GetPhrase( "holohud2.properties.last_update" ) .. HOLOHUD2.util.DateFormat( language.GetPhrase( "holohud2.properties.last_update.format" ), HOLOHUD2.Date ) )

        panel:CheckBox( "#holohud2.common.enabled", "holohud2" )
        panel:Button( "#holohud2.properties", "holohud2_properties" )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.credits" ) .. "\n" )

        for _, credits in ipairs( HOLOHUD2.Credits ) do

            local line = vgui.Create( "HOLOHUD2_DCredits", panel )
            line:Dock( TOP )
            line:DockMargin( 16, 0, 16, 0 )
            line:SetCredits( credits )

        end

    end )

    ---
    --- Accessibility
    ---
    spawnmenu.AddToolMenuOption( "Utilities", HOLOHUD2.Name, "holohud2_b", "#holohud2.accessibility", nil, nil, function( panel )

        panel:ClearControls()

        panel:Help( "#holohud2.accessibility.helptext" )

        panel:ToolPresets( "holohud2_access",  CVAR_ACCESSIBILITY )

        panel:CheckBox( "#holohud2.accessibility.nosuit", "holohud2_nosuit" )
        panel:CheckBox( "#holohud2.accessibility.quickinfo_hideonads", "holohud2_quickinfo_hideonads" )
        panel:CheckBox( "#holohud2.accessibility.panel_lerp", "holohud2_draw_smoothpaneltransforms" )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header0" ) )
        panel:CheckBox( "#holohud2.accessibility.flickering", "holohud2_r_flickering" )
        panel:ControlHelp( "#holohud2.accessibility.flickering.helptext" )
        panel:CheckBox( "#holohud2.accessibility.shaking", "holohud2_r_shaking" )
        panel:ControlHelp( "#holohud2.accessibility.shaking.helptext" )
        panel:NumSlider( "#holohud2.accessibility.shaking_min", "holohud2_r_shaking_min", 0, 16, 1 )
        panel:NumSlider( "#holohud2.accessibility.shaking_add", "holohud2_r_shaking_add", 0, 16, 1 )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header1" ) )
        local sway = panel:ComboBox( "#holohud2.accessibility.sway", "holohud2_sway" )
        sway:SetSortItems(false)
        sway:AddChoice( "#holohud2.accessibility.sway_0", 0 )
        sway:AddChoice( "#holohud2.accessibility.sway_1", 1 )
        sway:AddChoice( "#holohud2.accessibility.sway_2", 2 )
        sway:AddChoice( "#holohud2.accessibility.sway_3", 3 )

        panel:NumSlider( "#holohud2.accessibility.sway_mul", "holohud2_sway_mul", 0, 4, 1 )
        panel:NumSlider( "#holohud2.accessibility.sway_speed", "holohud2_sway_speed", 0, 2, 1 )

        panel:NumSlider( "#holohud2.accessibility.headbob_mul", "holohud2_headbob_mul", 0, 2, 1 )
        panel:NumSlider( "#holohud2.accessibility.headbob_speed", "holohud2_headbob_speed", 0, 2, 1 )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header2" ) )
        panel:KeyBinder( "#holohud2.accessibility.inspect_hud", "holohud2_inspect_key" )
        panel:CheckBox( "#holohud2.accessibility.weapon_inspect", "holohud2_hideonweaponinspect" )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header3" ) )
        panel:NumSlider( "#holohud2.accessibility.minglow", "holohud2_draw_minglow", 0, 1, 1 )

        panel:NumSlider( "#holohud2.accessibility.scanlinesmul", "holohud2_r_scanlinesmul", 0, 10, 0 )

        panel:NumSlider( "#holohud2.accessibility.scanlinespasses", "holohud2_r_scanlinespasses", 0, 16, 0 )

        panel:NumSlider( "#holohud2.accessibility.scanlinesglow", "holohud2_r_scanlinesglow", 0, 1, 1 )
        panel:ControlHelp( "#holohud2.accessibility.scanlinesglow.helptext" )

        panel:NumSlider( "#holohud2.accessibility.scanlinesdist", "holohud2_r_scanlinesdist", 1, 16, 0 )
        panel:ControlHelp( "#holohud2.accessibility.scanlinesdist.helptext" )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header4" ) )
        panel:CheckBox( "#holohud2.accessibility.shortnumbers", "holohud2_shortnumbers" )
        panel:ControlHelp( "#holohud2.accessibility.shortnumbers.helptext" )
        panel:NumSlider( "#holohud2.accessibility.shortnumbers_decimals", "holohud2_shortnumbers_decimals", 0, 5, 0 )

        panel:ControlHelp( "\n\n" .. language.GetPhrase( "holohud2.accessibility.header5" ) )
        panel:NumSlider( "#holohud2.accessibility.aberrationdist", "holohud2_r_aberrationdist", 1, 16, 0 )
        panel:ControlHelp( "#holohud2.accessibility.aberrationdist.helptext" )

        panel:NumSlider( "#holohud2.accessibility.3dmargin", "holohud2_r_3dmargin", 0.01, 1, 2 )
        panel:ControlHelp( "#holohud2.accessibility.3dmargin.helptext" )

        panel:NumSlider( "#holohud2.accessibility.compassprecision", "holohud2_draw_compassprecision", 0, 1, 1 )
        panel:CheckBox( "#holohud2.accessibility.worldsizespeed", "holohud2_speedometer_worldsize" )

    end )

    ---
    --- Performance
    ---
    spawnmenu.AddToolMenuOption( "Utilities", HOLOHUD2.Name, "holohud2_c", "#holohud2.performance", nil, nil, function( panel )

        panel:ClearControls()

        panel:Help( "#holohud2.performance.helptext" )

        panel:ToolPresets( "holohud2_quality", CVAR_PERFORMANCE )

        local combobox = panel:ComboBox( "#holohud2.performance.3d", "holohud2_r_3d" )
        combobox:SetSortItems( false )
        combobox:AddChoice( "#holohud2.performance.3d_5", 5 )
        combobox:AddChoice( "#holohud2.performance.3d_4", 4 )
        combobox:AddChoice( "#holohud2.performance.3d_3", 3 )
        combobox:AddChoice( "#holohud2.performance.3d_2", 2 )
        combobox:AddChoice( "#holohud2.performance.3d_1", 1 )
        combobox:AddChoice( "#holohud2.performance.3d_0", 0 )
        panel:ControlHelp( "#holohud2.performance.3d.helptext" )

        local glow = panel:ComboBox( "#holohud2.performance.filter", "holohud2_r_scanlines" )
        glow:SetSortItems( false )
        glow:AddChoice( "#holohud2.performance.filter_3", 3 )
        glow:AddChoice( "#holohud2.performance.filter_2", 2 )
        glow:AddChoice( "#holohud2.performance.filter_1", 1 )
        glow:AddChoice( "#holohud2.performance.filter_0", 0 )

        panel:CheckBox( "#holohud2.performance.blur", "holohud2_r_blur" )
        panel:CheckBox( "#holohud2.performance.aberration", "holohud2_r_aberration" )
        panel:CheckBox( "#holohud2.performance.expensivedigits", "holohud2_draw_expensivedigits" )
        panel:NumSlider( "#holohud2.performance.graphquality", "holohud2_draw_graphquality", 0, 1, 2 )

        panel:CheckBox( "#holohud2.performance.pp", "holohud2_r_pp" )
        panel:ControlHelp( "#holohud2.performance.pp.helptext" )

    end )

    ---
    --- Other
    ---
    spawnmenu.AddToolMenuOption( "Utilities", HOLOHUD2.Name, "holohud2_d", "#holohud2.other", nil, nil, function( panel )

        panel:ClearControls()

        panel:Button( "#holohud2.other.debug_welcome", "holohud2_debug_welcome" )
        panel:Button( "#holohud2.other.debug_startup", "holohud2_debug_startup" )

    end )

end)

---
--- Default quality presets.
---
presets.Add( "holohud2_quality", "Classic", {
    holohud2_r_3d                   = 0,
    holohud2_r_scanlines            = 2,
    holohud2_r_blur                 = 1,
    holohud2_r_aberration           = 1,
    holohud2_draw_expensivedigits   = 1,
    holohud2_draw_graphquality      = 1,
    holohud2_r_pp                   = 1
} )

presets.Add( "holohud2_quality", "Basic", {
    holohud2_r_3d                   = 0,
    holohud2_r_scanlines            = 1,
    holohud2_r_blur                 = 1,
    holohud2_r_aberration           = 0,
    holohud2_draw_expensivedigits   = 1,
    holohud2_draw_graphquality      = 1,
    holohud2_r_pp                   = 1
} )

presets.Add( "holohud2_quality", "Budget", {
    holohud2_r_3d                   = 0,
    holohud2_r_scanlines            = 0,
    holohud2_r_blur                 = 0,
    holohud2_r_aberration           = 0,
    holohud2_draw_expensivedigits   = 0,
    holohud2_draw_graphquality      = .9,
    holohud2_r_pp                   = 1
} )

presets.Add( "holohud2_quality", "Potato",{
    holohud2_r_3d                   = 0,
    holohud2_r_scanlines            = 0,
    holohud2_r_blur                 = 0,
    holohud2_r_aberration           = 0,
    holohud2_draw_expensivedigits   = 0,
    holohud2_draw_graphquality      = .8,
    holohud2_r_pp                   = 0
} )
