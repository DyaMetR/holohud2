---
--- Populate options menu
---
HOLOHUD2.hook.Add( "PopulateOptionsMenu", "holohud2", function( modifiers )

    local scale = HOLOHUD2.scale.Get()

    local COLOR2 = Color( 255, 255, 255, 12 )

    local font_controls = {} -- DEPRECATED

    ---
    --- Common
    ---
    HOLOHUD2.vgui.AddOptionControls( function( panel, parent )

        -- automatically hide
        local autohide = vgui.Create( "HOLOHUD2_DParameter_Option", panel )
        autohide:Dock( TOP )
        autohide:SetName( "#holohud2.parameter.autohide" )
        autohide:SetOptions( { "#holohud2.option.use_defaults", "#holohud2.option.always", "#holohud2.option.never" } )
        autohide:SetValue( modifiers.autohide == nil and 1 or ( modifiers.autohide and 2 or 3 ) )
        autohide:SetResettable( modifiers.autohide ~= nil )
        autohide.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.autohide = nil
                autohide:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.autohide = value == 2
            autohide:SetResettable( true )
            parent:OnChange()

        end
        autohide.OnValueReset = function( _, value )

            autohide:SetValue( 1 )

        end

        local size = vgui.Create("HOLOHUD2_DParameter_Range", panel)
        size:Dock( TOP )
        size:SetName( "#holohud2.parameter.scale" )
        size.Slider:SetMinMax( .01, 3 )
        size:SetValue( modifiers.scale or 1 )
        size:SetResettable( modifiers.scale ~= nil )
        size.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.scale = nil
                size:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.scale = value
            size:SetResettable( true )
            parent:OnChange()

        end
        size.OnValueReset = function( _, value )

            size:SetValue( 1 )

        end

    end)

    ---
    --- Colouring
    ---
    HOLOHUD2.vgui.AddOptionControls( function( panel, parent )

        -- theme
        local color = vgui.Create( "HOLOHUD2_DParameter_Color", panel )
        color:Dock( TOP )
        color:SetName( "#holohud2.parameter.tint" )
        color:SetValue( modifiers.color or color_white )
        color:SetResettable( modifiers.color )
        color.OnValueChanged = function( _, value )

            if color.PreventUpdate then return end

            modifiers.color = value
            color:SetResettable( true )
            parent:OnChange()

        end
        color.OnValueReset = function()

            color.PreventUpdate = true

            color:SetValue( color_white )
            modifiers.color = nil
            color:SetResettable( false )
            parent:OnChange()

            color.PreventUpdate = false

        end

        -- back color
        local color2 = vgui.Create( "HOLOHUD2_DParameter_Color", panel )
        color2:Dock( TOP )
        color2:SetName( "#holohud2.parameter.back_color" )
        color2:SetValue( modifiers.color2 or COLOR2 )
        color2:SetResettable( modifiers.color2 )
        color2.OnValueChanged = function( _, value )

            if color2.PreventUpdate then return end

            modifiers.color2 = value
            color2:SetResettable( true )
            parent:OnChange()

        end
        color2.OnValueReset = function()

            color2.PreventUpdate = true

            color2:SetValue( COLOR2 )
            modifiers.color2 = nil
            color2:SetResettable( false )
            parent:OnChange()

            color2.PreventUpdate = false

        end

    end, "#holohud2.category.coloring")

    ---
    --- Panel
    ---
    HOLOHUD2.vgui.AddOptionControls( function( panel, parent )

        local BACKGROUND_COLOR  = Color( 0, 0, 0, 94 )

        local sample = HOLOHUD2.component.Create( "AnimatedPanel" )
        sample:SetBlurred( false )
        sample:SetSmoothenTransforms( false )
        sample:SetPos( -57, -28 )
        sample:SetSize( 114, 56 )
        sample:SetAnimationDirection( HOLOHUD2.GROWDIRECTION_UP )

        local preview = vgui.Create( "HOLOHUD2_DPreviewImage", panel )
        preview:Dock( TOP )
        preview:SetTall( 96 * scale )
        preview:SetKeepAspect( true )
        preview:SetMouseInputEnabled( true )
        preview.PaintOver = function( self, w, h )

            sample:SetDrawBackground( modifiers.background ~= false )
            sample:SetColor( modifiers.background_color or BACKGROUND_COLOR )
            sample:SetAnimation( modifiers.panel_animation or HOLOHUD2.PANELANIMATION_FLASH )

            sample:SetOrigin( self:LocalToScreen() )
            sample:Think()
            sample:SetDeployed( math.floor( CurTime() / 2 ) % 2 < .75 )

            sample:PaintFrame( w / 2, h / 2 )

        end
        panel:SetTall( preview:GetTall() + 76 )

        -- visibility parameter
        local visible = vgui.Create( "HOLOHUD2_DParameter_Option", panel )
        visible:Dock( TOP )
        visible:SetName( "#holohud2.parameter.background" )
        visible:SetOptions( { "#holohud2.option.use_defaults", "#holohud2.option.show", "#holohud2.option.hide" } )
        visible:SetValue( modifiers.background == nil and 1 or ( modifiers.background and 2 or 3 ) )
        visible:SetResettable( modifiers.background ~= nil )
        visible.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.background = nil
                visible:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.background = value == 2
            visible:SetResettable( true )
            parent:OnChange()

        end
        visible.OnValueReset = function( _ )

            visible:SetValue( 1 )

        end

        -- background color selector
        local color = vgui.Create( "HOLOHUD2_DParameter_Color", panel )
        color:Dock( TOP )
        color:SetName( "#holohud2.parameter.color" )
        color:SetValue( modifiers.background_color or BACKGROUND_COLOR )
        color:SetResettable( modifiers.background_color )
        color.OnValueChanged = function( _, value )

            if color.PreventUpdate then return end

            modifiers.background_color = value
            color:SetResettable( true )
            parent:OnChange()

        end
        color.OnValueReset = function()

            color.PreventUpdate = true

            color:SetValue( BACKGROUND_COLOR )
            modifiers.background_color = nil
            color:SetResettable( false )
            parent:OnChange()

            color.PreventUpdate = false

        end

        local animations = table.Copy( HOLOHUD2.PANELANIMATIONS )
        table.insert( animations, 1, "#holohud2.option.use_defaults" )

        -- panel animation selector
        local animation = vgui.Create( "HOLOHUD2_DParameter_Option", panel )
        animation:Dock( TOP )
        animation:SetName( "#holohud2.parameter.animation" )
        animation:SetOptions( animations )
        animation:SetValue( ( modifiers.panel_animation or 0 ) + 1 )
        animation:SetResettable( modifiers.panel_animation )
        animation.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.panel_animation = nil
                animation:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.panel_animation = value - 1
            animation:SetResettable( true )
            parent:OnChange()

        end
        animation.OnValueReset = function( _ )

            animation:SetValue( 1 )

        end

    end, "#holohud2.category.panel" )

    ---
    --- Number
    ---
    HOLOHUD2.vgui.AddOptionControls( function( panel, parent )

        local WIREFRAME_COLOR = HOLOHUD2.WIREFRAME_COLOR

        local fonts = {
            { name = "#holohud2.derma.properties.common.font_0", font = "holohud2_preview0", size = 37, value = "number_font", offset = "number_offset", default = { font = "Roboto Light", size = 0, weight = 1000, italic = false } },
            { name = "#holohud2.derma.properties.common.font_1", font = "holohud2_preview1", size = 22, value = "number2_font", offset = "number2_offset", default = { font = "Roboto Condensed Light", size = 0, weight = 1000, italic = false } },
            { name = "#holohud2.derma.properties.common.font_2", font = "holohud2_preview2", size = 16, value = "number3_font", offset = "number3_offset", default = { font = "Roboto Condensed Light", size = 0, weight = 1000, italic = false } }
        }
        local font_previews = {}
        for i, font in ipairs( fonts ) do

            local values = modifiers[ font.value ] or font.default
            font_previews[ i ] = { font = values.font, size = font.size + values.size, weight = values.weight, italic = values.italic }

            HOLOHUD2.font.Register( font.font, font_previews[ i ] )
            HOLOHUD2.font.Create( font.font )

        end

        -- create sample components
        local sample0 = HOLOHUD2.component.Create( "Number" )
        sample0:SetPos( -27, -18 )
        sample0:SetFont( fonts[ 1 ].font )
        sample0:SetValue( 47 )

        local sample1 = HOLOHUD2.component.Create( "Number" )
        sample1:SetPos( -19, -11 )
        sample1:SetFont( fonts[ 2 ].font )
        sample1:SetValue( 225 )
        sample1:SetDigits( 4 )

        local sample2 = HOLOHUD2.component.Create( "Number" )
        sample2:SetPos( -11, -9 )
        sample2:SetFont( fonts[ 3 ].font )
        sample2:SetValue( 60 )

        local samples = { sample0, sample1, sample2 }

        -- add options
        local preview = vgui.Create( "HOLOHUD2_DPreviewImage", panel )
        preview:Dock( TOP )
        preview:SetTall( 96 * scale )
        preview:SetKeepAspect( true )
        preview:SetMouseInputEnabled( true )
        preview.PaintOver = function( self, w, h )

            -- update sample properties
            for _, sample in ipairs( samples ) do

                sample:SetBackground( modifiers.number_background or HOLOHUD2.NUMBERBACKGROUND_EXPENSIVE )
                sample:SetRenderMode( modifiers.number_rendermode or HOLOHUD2.NUMBERRENDERMODE_STATIC )
                sample:SetColor( modifiers.color or color_white )
                sample:SetColor2( modifiers.color2 or COLOR2 )
                sample:PerformLayout()

            end

            local x, y = w * .25, h / 2

            draw.SimpleText( language.GetPhrase( "holohud2.derma.properties.common.font_0_preview" ), "HudHintTextLarge", x, 12, color_white, TEXT_ALIGN_CENTER )

            local pw, ph = 93, 44
            surface.SetDrawColor( WIREFRAME_COLOR )
            surface.DrawOutlinedRect( x - pw / 2, y - ph / 2, pw, ph )

            if modifiers.number_offset then

                x = x + modifiers.number_offset.x
                y = y + modifiers.number_offset.y

            end

            sample0:PaintBackground( x, y )
            sample0:Paint( x, y )

            local x, y = w * .5, h / 2

            draw.SimpleText( language.GetPhrase( "holohud2.derma.properties.common.font_1_preview" ), "HudHintTextLarge", x, 12, color_white, TEXT_ALIGN_CENTER )

            local pw, ph = 67, 26
            surface.SetDrawColor( WIREFRAME_COLOR )
            surface.DrawOutlinedRect( x - pw / 2, y - ph / 2, pw, ph )

            if modifiers.number2_offset then

                x = x + modifiers.number2_offset.x
                y = y + modifiers.number2_offset.y

            end

            sample1:PaintBackground( x, y )
            sample1:Paint( x, y )

            local x, y = w *.75, h / 2

            draw.SimpleText( language.GetPhrase( "holohud2.derma.properties.common.font_2_preview" ), "HudHintTextLarge", x, 12, color_white, TEXT_ALIGN_CENTER )

            local pw, ph = 39, 21
            surface.SetDrawColor( WIREFRAME_COLOR )
            surface.DrawOutlinedRect( x - pw / 2, y - ph / 2, pw, ph )

            if modifiers.number3_offset then

                x = x + modifiers.number3_offset.x
                y = y + modifiers.number3_offset.y

            end

            sample2:PaintBackground( x, y )
            sample2:Paint( x, y )

        end

        local backgrounds = table.Copy( HOLOHUD2.NUMBERBACKGROUNDS )
        table.insert( backgrounds, 1, "#holohud2.option.use_defaults" )

        -- background
        local background = vgui.Create( "HOLOHUD2_DParameter_Option", panel )
        background:Dock( TOP )
        background:SetName( "#holohud2.parameter.background" )
        background:SetOptions( backgrounds )
        background:SetValue( ( modifiers.number_background or 0 ) + 1 )
        background:SetResettable( modifiers.number_background )
        background.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.number_background = nil
                background:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.number_background = value - 1
            background:SetResettable( true )
            parent:OnChange()

        end
        background.OnValueReset = function( _ )

            background:SetValue( 1 )

        end

        local rendermodes = table.Copy( HOLOHUD2.NUMBERRENDERMODES )
        table.insert( rendermodes, 1, "#holohud2.option.use_defaults" )

        -- render mode
        local rendermode = vgui.Create( "HOLOHUD2_DParameter_Option", panel )
        rendermode:Dock( TOP )
        rendermode:SetName( "#holohud2.parameter.rendermode" )
        rendermode:SetOptions( rendermodes )
        rendermode:SetValue( ( modifiers.number_rendermode or 0 ) + 1 )
        rendermode:SetResettable( modifiers.number_rendermode )
        rendermode.OnValueChanged = function( _, value )

            if value == 1 then

                modifiers.number_rendermode = nil
                rendermode:SetResettable( false )
                parent:OnChange()
                return

            end

            modifiers.number_rendermode = value - 1
            rendermode:SetResettable( true )
            parent:OnChange()

        end
        rendermode.OnValueReset = function( _ )

            rendermode:SetValue( 1 )

        end

        -- create font controls
        for i, font in ipairs( fonts ) do

            local control = vgui.Create( "HOLOHUD2_DParameter_Font", panel )
            control:Dock( TOP )
            control:SetName( font.name )
            control.Size:SetTooltip( "#holohud2.derma.properties.common.font_size" )
            control.Size:SetMin( -72 )
            control:SetResettable( modifiers[ font.value ] )
            control:SetValue( modifiers[ font.value ] or font.default )
            control.OnValueChanged = function( _, value )

                if control.PreventUpdate then return end

                table.Merge( font_previews[ i ], value )
                font_previews[ i ].size = font.size + value.size
                HOLOHUD2.font.Create( font.font )
                samples[ i ]:InvalidateLayout()

                modifiers[ font.value ] = value
                control:SetResettable( true )
                parent:OnChange()

            end
            control.OnValueReset = function( _ )

                control.PreventUpdate = true

                table.Merge( font_previews[ i ], font.default )
                font_previews[ i ].size = font.size
                HOLOHUD2.font.Create( font.font )
                samples[ i ]:InvalidateLayout()

                control:SetValue( font.default )
                modifiers[ font.value ] = nil
                control:SetResettable( false )
                parent:OnChange()

                control.PreventUpdate = false

            end

            local collapsible = vgui.Create( "HOLOHUD2_DCollapsiblePanel", panel )
            collapsible:Dock( TOP )

                local offset = vgui.Create( "HOLOHUD2_DParameter_Vector", collapsible )
                offset:Dock( TOP )
                -- offset:DockPadding( 16, 0, 0, 0 )
                offset:SetName( "#holohud2.parameter.offset" )
                offset:SetValue( modifiers[ font.offset ] or { x = 0, y = 0 } )
                offset:SetResettable( modifiers[ font.offset ] )
                offset.OnValueChanged = function( _, value )

                    if offset.PreventUpdate then return end

                    modifiers[ font.offset ] = value
                    offset:SetResettable( true )
                    parent:OnChange()

                end
                offset.OnValueReset = function( _ )

                    offset.PreventUpdate = true

                    offset:SetValue( { x = 0, y = 0 } )
                    modifiers[ font.offset ] = nil
                    offset:SetResettable( false )
                    parent:OnChange()

                    offset.PreventUpdate = false

                end

            collapsible:SetExpanded( true )

            table.insert( font_controls, control )

        end

    end, "#holohud2.derma.properties.common.numbers" )

    ---
    --- Text
    ---
    HOLOHUD2.vgui.AddOptionControls( function( panel, parent )

        local fonts             = {
            { name = "#holohud2.derma.properties.common.font_0", font = "holohud2_preview3", size = 12, value = "text_font", offset = "text_offset", default = { font = "Roboto Light", size = 0, weight = 0, italic = false } },
            { name = "#holohud2.derma.properties.common.font_1", font = "holohud2_preview4", size = 10, value = "text2_font", offset = "text2_offset", default = { font = "Roboto Condensed Light", size = 0, weight = 1000, italic = true } }
        }
        local font_previews     = {}
        for i, font in ipairs( fonts ) do

            local values = modifiers[ font.value ] or font.default
            font_previews[ i ] = { font = values.font, size = font.size + values.size, weight = values.weight, italic = values.italic }

            HOLOHUD2.font.Register( font.font, font_previews[ i ] )
            HOLOHUD2.font.Create( font.font )

        end

        -- create sample components
        local sample0 = HOLOHUD2.component.Create( "Text" )
        sample0:SetAlign( TEXT_ALIGN_CENTER )
        sample0:SetFont( fonts[ 1 ].font )
        sample0:SetText( "#holohud2.derma.properties.common.text_preview" )

        local sample1 = HOLOHUD2.component.Create( "Text" )
        sample1:SetAlign( TEXT_ALIGN_CENTER )
        sample1:SetFont( fonts[ 2 ].font )
        sample1:SetText( "#holohud2.derma.properties.common.text_preview" )

        local samples = { sample0, sample1 }

        -- add options
        local preview = vgui.Create( "HOLOHUD2_DPreviewImage", panel )
        preview:Dock( TOP )
        preview:SetTall( 96 * scale )
        preview:SetKeepAspect( true )
        preview:SetMouseInputEnabled( true )
        preview.PaintOver = function( self, w, h )

            -- update sample properties
            for _, sample in ipairs( samples ) do

                sample:SetColor( modifiers.color or color_white )
                sample:PerformLayout()

            end

            local x, y = w * .5, 32

            draw.SimpleText( language.GetPhrase( "holohud2.derma.properties.common.font_0_preview" ), "HudHintTextLarge", x, 12, color_white, TEXT_ALIGN_CENTER )

            if modifiers.text_offset then

                x = x + modifiers.text_offset.x
                y = y + modifiers.text_offset.y

            end

            sample0:Paint( x, y )

            local x, y = w * .5, h / 2 + 20

            draw.SimpleText( language.GetPhrase( "holohud2.derma.properties.common.font_1_preview" ), "HudHintTextLarge", x, h / 2, color_white, TEXT_ALIGN_CENTER )

            if modifiers.text_offset2 then

                x = x + modifiers.text_offset2.x
                y = y + modifiers.text_offset2.y

            end

            sample1:Paint( x, y )

        end

        -- create font controls
        for i, font in ipairs( fonts ) do

            local control = vgui.Create( "HOLOHUD2_DParameter_Font", panel )
            control:Dock( TOP )
            control:SetName( font.name )
            control.Size:SetTooltip( "#holohud2.derma.properties.font_size" )
            control.Size:SetMin( -72 )
            control:SetResettable( modifiers[ font.value ] )
            control:SetValue( modifiers[ font.value ] or font.default )
            control.OnValueChanged = function( _, value )

                if control.PreventUpdate then return end

                table.Merge( font_previews[ i ], value )
                font_previews[ i ].size = font.size + value.size
                HOLOHUD2.font.Create( font.font )
                samples[ i ]:InvalidateLayout()

                modifiers[ font.value ] = value
                control:SetResettable( true )
                parent:OnChange()

            end
            control.OnValueReset = function( _ )

                control.PreventUpdate = true

                table.Merge( font_previews[ i ], font.default )
                font_previews[ i ].size = font.size
                HOLOHUD2.font.Create( font.font )
                samples[ i ]:InvalidateLayout()

                control:SetValue( font.default )
                modifiers[ font.value ] = nil
                control:SetResettable( false )
                parent:OnChange()

                control.PreventUpdate = false

            end

            local collapsible = vgui.Create( "HOLOHUD2_DCollapsiblePanel", panel )
            collapsible:Dock( TOP )

                local offset = vgui.Create( "HOLOHUD2_DParameter_Vector", collapsible )
                offset:Dock( TOP )
                -- offset:DockPadding( 16, 0, 0, 0 )
                offset:SetName( "#holohud2.parameter.offset" )
                offset:SetValue( modifiers[ font.offset ] or { x = 0, y = 0 } )
                offset:SetResettable( modifiers[ font.offset ] )
                offset.OnValueChanged = function( _, value )

                    if offset.PreventUpdate then return end

                    modifiers[ font.offset ] = value
                    offset:SetResettable( true )
                    parent:OnChange()

                end
                offset.OnValueReset = function( _ )

                    offset.PreventUpdate = true

                    offset:SetValue( { x = 0, y = 0 } )
                    modifiers[ font.offset ] = nil
                    offset:SetResettable( false )
                    parent:OnChange()

                    offset.PreventUpdate = false

                end

            collapsible:SetExpanded( true )

            table.insert( font_controls, control )

        end

    end, "#holohud2.parameter.text" )

end)

---
--- Add preset group
---
HOLOHUD2.presets.Register( "options", "options" )
