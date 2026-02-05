---
--- Properties menu
---

local parameters_advanced = CreateClientConVar( "holohud2_menu_advancedparams", 0, true, false, "Stores the preference for advanced parameters menu between sessions.", 0, 1 )

local state = {
    on_advanced     = false,
    last_element    = nil,
    tabs            = {},
    parameters      = {},
    filename        = nil
}

local function open_properties()

    -- cache client settings
    local modifiers = table.Copy( HOLOHUD2.client.GetModifiers() )
    local settings  = table.Copy( HOLOHUD2.client.Get() )
    local preview   = {}

    local frame = vgui.Create( "HOLOHUD2_DFrame" )
    frame:SetSize( math.max( ScrW() * .4, 640 ), math.max( ScrH() * .8, 480 ) )
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton( false )
    frame.DoApply = function( _ )

        HOLOHUD2.client.SubmitModifiers( table.Copy( modifiers ) )
        HOLOHUD2.client.Submit( table.Copy( settings ) )
        HOLOHUD2.persistence.WriteTemp( settings, modifiers )

    end
    frame.SaveAs = function( _ )

        local browser = vgui.Create( "HOLOHUD2_DBrowser" )
        browser:SetSize( 400, 300 )
        browser:Center()
        browser:MakePopup()
        browser:DoModal()
        browser:SetBackgroundBlur( true )
        browser:SetTitle( "#holohud2.derma.properties.save_as" )
        browser:SetAction( "#holohud2.derma.properties.save" )
        browser:SetHeader( "holohud2/presets" )
        browser:SetContents( HOLOHUD2.persistence.Find() )
        browser.OnAction = function( _, filename )

            HOLOHUD2.persistence.Write( settings, modifiers, filename )
            state.filename = filename
            browser:Close()

        end
        browser.OnDelete = function( _, filename )

            HOLOHUD2.persistence.Delete( filename )
            browser:SetContents( HOLOHUD2.persistence.Find(), HOLOHUD2.persistence.All() )
            browser:SetDeletable( false )

        end

    end
    frame.Populate = function( _ )

        if frame.Contents then frame.Contents:Remove() end

        local tabs = vgui.Create( "DPropertySheet", frame )
        tabs:Dock( FILL )
        tabs:DockMargin( 0, 4, 0, 4 )
        frame.Contents = tabs

        ---
        --- General options
        ---
        local options = tabs:AddSheet( "#holohud2.derma.properties.common", vgui.Create( "HOLOHUD2_DProperties_Options" ), "icon16/application_view_list.png" )
        options.Panel:Populate( modifiers )
        options.Panel.OnChange = function( _ )

            table.Empty( preview ) -- invalidate current element preview

        end
        options.Panel.DoReset = function( _ )

            table.Empty( modifiers )
            options.Panel:Populate( modifiers )

        end
        options.Panel.OnPresetSelected = function( _, values )

            modifiers = table.Copy( values )
            options.Panel:Populate( modifiers )

        end
        options.Panel.AddPreset = function( _, name )

            return HOLOHUD2.presets.Write( options.Panel.presets, name, modifiers )

        end

        ---
        --- Advanced options
        ---
        local advanced = tabs:AddSheet( "#holohud2.derma.properties.parameters", vgui.Create( "HOLOHUD2_DProperties_Advanced" ), "icon16/application_view_gallery.png" )
        advanced.Panel:SetAdvancedToggle( parameters_advanced:GetBool() )
        advanced.Panel.OnAdvancedToggle = function( _, toggle )

            parameters_advanced:SetBool( toggle )

        end
        advanced.Panel.OnSelected = function( panel, id )

            state.last_element = id
            local element = HOLOHUD2.element.Get( id )

            local properties = panel:Select( id, advanced.Panel:GetAdvancedToggle() )
            properties.GeneratePreview = function( _, force )

                if not preview[ id ] or force then

                    preview[ id ] = table.Copy( element.values )
                    table.Merge( preview[ id ], HOLOHUD2.modifier.Call( preview, modifiers, id ) )
                    if settings[ id ] then table.Merge( preview[ id ], settings[ id ], true ) end

                end

                -- generate fonts
                if element.preview_fonts then

                    for font, data in pairs( element.preview_fonts ) do

                        HOLOHUD2.font.Register( data, preview[ id ][ font ] )
                        HOLOHUD2.font.Create( data )

                    end

                end

                element:OnPreviewChanged( preview[ id ] )

            end
            advanced.Panel.OnAdvancedToggle = function( _, toggle )

                parameters_advanced:SetBool( toggle )
                properties:Populate( element, toggle )
                properties:SetValues( element.values, settings[ id ] or {} )
                state.parameters = {}
                state.tabs = {}

            end
            properties.OnPresetSelected = function( _, values )

                table.Empty( preview )
                settings[ id ] = table.Copy( values )
                properties:SetValues( element.values, settings[ id ] )
                properties:GeneratePreview( true )

            end
            properties.AddPreset = function( _, name )

                if not HOLOHUD2.presets.Write( id, name, settings[ id ] or {} ) then

                    Derma_Message( "#holohud2.derma.preset_dialog.write_error", "#holohud2.derma.error", "#holohud2.derma.ok" )
                    return false

                end

                return true

            end
            properties.DoReset = function( _ )

                table.Empty( preview )
                settings[ id ] = nil
                properties:SetValues( element.values, {} )
                properties:SetResettable( false )
                properties:GeneratePreview( true )

            end
            properties.DoImport = function( _ )

                Derma_StringRequest( "#holohud2.derma.properties.import", "#holohud2.derma.properties.import.dialog", "", function( value )

                    local decoded = util.JSONToTable( util.Base64Decode( value ) or "" )

                    if not decoded then

                        Derma_Message( "#holohud2.derma.properties.import.error", "#holohud2.derma.error", "#holohud2.derma.ok" )
                        return

                    end

                    properties:OnPresetSelected( decoded )

                end )

            end
            properties.DoExport = function( _, lua_table )

                local window = vgui.Create( "HOLOHUD2_DExportWindow" )

                local result = settings[ id ] or {}

                if lua_table then

                    window:SetSize( 380, 480 )
                    window:SetText( "HOLOHUD2.presets.Add( " .. id .. ", \"Untitled preset\", " .. table.ToString( result, nil, table.IsEmpty( result ) ) .. " )" )

                else

                    window:SetSize( 380, 78 )
                    window:SetText( util.Base64Encode( util.TableToJSON( result ) ) )

                end

                window:Center()

            end
            properties.OnValueChanged = function( _, parameter, value )

                if not settings[ id ] then settings[ id ] = {} end

                settings[ id ][ parameter ] = value
                properties:SetResettable( true )

                preview[ id ][ parameter ] = value

                -- regenerate font (if exists)
                if element.preview_fonts and element.preview_fonts[ parameter ] then

                    HOLOHUD2.font.Register( element.preview_fonts[ parameter ], preview[ id ][ parameter ] )
                    HOLOHUD2.font.Create( element.preview_fonts[ parameter ] )

                end

                element:OnPreviewChanged( preview[ id ] )

            end
            properties.OnValueReset = function( _, parameter )

                settings[ id ][ parameter ] = nil

                if table.IsEmpty( settings[ id ] ) then settings[ id ] = nil end

                properties:SetResettable( settings[ id ] ~= nil )

                local default = element.values[ parameter ]
                if istable( default ) then default = table.Copy( default ) end

                preview[ id ][ parameter ] = default
                local modified = HOLOHUD2.modifier.Call( preview, modifiers, id )

                preview[ id ][ parameter ] = modified and modified[ parameter ] or default

                -- regenerate font (if exists)
                if element.preview_fonts and element.preview_fonts[ parameter ] then

                    HOLOHUD2.font.Register( element.preview_fonts[ parameter ], preview[ id ][ parameter ] )
                    HOLOHUD2.font.Create( element.preview_fonts[ parameter ] )

                end

                element:OnPreviewChanged( preview[ id ] )

            end
            properties.OnPanelExpanded = function( _, parameter, expanded )

                if expanded then

                    if not state.parameters[ id ] then state.parameters[ id ] = {} end
                    state.parameters[ id ][ parameter ] = true

                else

                    if not state.parameters[ id ] then return end

                    state.parameters[ id ][ parameter ] = nil

                    if not table.IsEmpty( state.parameters[ id ] ) then return end

                    state.parameters[ id ] = nil

                end

            end
            properties.OnTabChanged = function( _, tab )

                state.tabs[ id ] = tab

            end
            properties.PaintPreview = function( _, x, y, w, h )

                if not preview[ id ] then return end

                element:PreviewPaint( x, y, w, h, preview[ id ] )

            end
            properties:SetState( state.parameters[ id ] or {}, state.tabs[ id ] )
            properties:SetValues( element.values, settings[ id ] or {} )
            properties:SetResettable( settings[ id ] ~= nil )
            properties:GeneratePreview()
            element:PreviewInit( properties.Preview )

        end
        advanced.Panel.FetchElementVisibility = function( _, id, element )

            if not settings[ id ] or settings[ id ]._visible == nil then

                return element.visible ~= false

            end

            return settings[ id ]._visible

        end
        advanced.Panel.OnVisibilityChanged = function( _, id, visible )

            if not settings[ id ] then settings[ id ] = {} end

            settings[ id ]._visible = visible

        end
        tabs.OnActiveTabChanged = function( _, _, tab )

            state.on_advanced = tab == advanced.Tab

            if not state.on_advanced then return end
            if not advanced.Panel.SelectedID then return end

            advanced.Panel.Selected:GeneratePreview()

        end

        -- apply state
        if state.on_advanced then

            tabs:SetActiveTab( advanced.Tab )

            if state.last_element then

                advanced.Panel:OnSelected( state.last_element )

            end

        end

        -- set cached visibility on the checkbox list
        for id, line in pairs( advanced.Panel.Lines ) do

            line:SetChecked( advanced.Panel:FetchElementVisibility( id, HOLOHUD2.element.Get( id ) ) )

        end

    end
    frame:Populate()

    ---
    --- Menu bar
    ---

    -- File
    local file = frame:AddMenu( "#holohud2.derma.properties.file" )

        file:AddOption( "#holohud2.derma.properties.new", function()

            settings = {}
            modifiers = {}
            preview = {}
            state.on_advanced = false
            state.last_element = nil
            state.parameters = {}
            state.tabs = {}
            frame:Populate()

        end):SetIcon( "icon16/page.png" )
        file:AddOption( "#holohud2.derma.properties.open", function()

            local browser = vgui.Create( "HOLOHUD2_DBrowser" )
            browser:SetSize( 400, 300 )
            browser:Center()
            browser:MakePopup()
            browser:DoModal()
            browser:SetBackgroundBlur( true )
            browser:SetTitle( "#holohud2.derma.properties.open" )
            browser:SetAction( "#holohud2.derma.properties.open" )
            browser:SetHeader( "holohud2/presets" )
            browser:SetContents( HOLOHUD2.persistence.Find(), HOLOHUD2.persistence.All() )
            browser:SetEditable( false )
            browser.OnAction = function( _, filename, hardcoded )

                local read0, read1

                if hardcoded then

                    local data = table.Copy( HOLOHUD2.persistence.Get( hardcoded ) )
                    read0, read1 = data.settings, data.modifiers

                else

                    read0, read1 = HOLOHUD2.persistence.Read( filename )

                end

                if not settings or not modifiers then

                    Derma_Message( "#holohud2.derma.properties.open.error", "#holohud2.derma.error", "#holohud2.derma.ok" )
                    return

                end

                settings = read0
                modifiers = read1
                preview = {}
                state.on_advanced = false
                state.last_element = nil
                state.parameters = {}
                state.tabs = {}
                state.filename = filename
                frame:Populate()
                browser:Close()

            end
            browser.OnDelete = function( _, filename )

                HOLOHUD2.persistence.Delete( filename )
                browser:SetContents( HOLOHUD2.persistence.Find(), HOLOHUD2.persistence.All() )
                browser:SetText( "" )
                browser:SetDeletable( false )

            end

        end):SetIcon( "icon16/folder.png" )
        file:AddSpacer()
        file:AddOption( "#holohud2.derma.properties.save", function( _ )

            if state.filename then

                HOLOHUD2.persistence.Write( settings, modifiers, state.filename )
                return

            end

            frame:SaveAs()

        end):SetIcon( "icon16/disk.png" )
        file:AddOption( "#holohud2.derma.properties.save_as", function() frame:SaveAs() end ):SetIcon( "icon16/disk_multiple.png" )
        file:AddSpacer()

        file:AddOption( "#holohud2.derma.properties.import", function()

            Derma_StringRequest( "#holohud2.derma.properties.import", "#holohud2.derma.properties.import.dialog", "", function( value )

                local decoded = util.JSONToTable( util.Base64Decode( value ) or "" )

                if not decoded then

                    Derma_Message( "#holohud2.derma.properties.import.error", "#holohud2.derma.error", "#holohud2.derma.ok" )
                    return

                end

                settings = decoded.settings
                modifiers = decoded.modifiers
                preview = {}
                frame:Populate()

            end )

        end):SetIcon( "icon16/page_white_get.png" )

        local submenu, parent = file:AddSubMenu( "#holohud2.derma.properties.export" )
        submenu:SetDeleteSelf( false )
        parent:SetImage( "icon16/page_white_go.png" )

        submenu:AddOption( "#holohud2.derma.properties.export.code", function()

            local window = vgui.Create( "HOLOHUD2_DExportWindow" )
            window:SetSize( 380, 78 )
            window:Center()
            window:SetText( util.Base64Encode( util.TableToJSON( { settings = settings, modifiers = modifiers } ) ) )

        end):SetImage( "icon16/attach.png" )
        submenu:AddOption( "#holohud2.derma.properties.export.lua", function()

            local window = vgui.Create( "HOLOHUD2_DExportWindow" )
            window:SetSize( 380, 480 )
            window:Center()
            window:SetText( "HOLOHUD2.persistence.Add( \"Untitled preset\", " .. table.ToString( settings, nil, not table.IsEmpty( settings ) ) .. ", " .. table.ToString( modifiers, nil, not table.IsEmpty( modifiers ) ) .. " )" )

        end):SetImage( "icon16/application_xp_terminal.png" )

        file:AddSpacer()
        file:AddOption( "#holohud2.derma.properties.exit", function() frame:Close() end ):SetIcon( "icon16/door.png" )

    -- Server
    if not game.SinglePlayer() and LocalPlayer():IsAdmin() then

        local server = frame:AddMenu( "#holohud2.derma.properties.server" )

            local default, parent = server:AddSubMenu( "#holohud2.derma.properties.server.default" )
            parent:SetIcon( "icon16/server_connect.png" )
            default:SetDeleteSelf( false )

                default:AddOption( "#holohud2.derma.properties.server.default.submit", function() HOLOHUD2.server.SubmitDefaults( table.Copy( settings ), modifiers ) end):SetIcon( "icon16/script_go.png" )
                local reset = default:AddOption( "#holohud2.derma.properties.server.default.restore", function() HOLOHUD2.server.ClearDefaults() end )
                reset:SetIcon( "icon16/arrow_refresh.png" )
                reset.Think = function() -- HACK

                    reset:SetEnabled( not table.IsEmpty( HOLOHUD2.server.Defaults() ) )

                end

            local config, parent = server:AddSubMenu( "#holohud2.derma.properties.server.settings" )
            parent:SetIcon( "icon16/server_edit.png" )
            config:SetDeleteSelf( false )

                config:AddOption( "#holohud2.derma.properties.server.settings.submit", function() HOLOHUD2.server.Submit( table.Copy( settings ), modifiers, false ) end ):SetIcon( "icon16/script_go.png" )
                config:AddOption( "#holohud2.derma.properties.server.settings.force", function() HOLOHUD2.server.Submit( table.Copy( settings ), modifiers, true ) end):SetIcon( "icon16/lock.png" )
                local remove = config:AddOption( "#holohud2.derma.properties.server.settings.restore", function() HOLOHUD2.server.Clear() end )
                remove:SetIcon( "icon16/delete.png" )
                remove.Think = function() -- HACK

                    remove:SetEnabled( not table.IsEmpty( HOLOHUD2.server.Get() ) )

                end
    end

    -- Help
    local help = frame:AddMenu( "#holohud2.derma.properties.help" )

        -- local docs, parent = help:AddSubMenu( "#holohud2.derma.properties.help.docs" )
        -- parent:SetIcon( "icon16/book.png" )
        -- docs:SetDeleteSelf( false )

        --     docs:AddOption( "#holohud2.derma.properties.help.docs.user_guide" ):SetIcon( "icon16/user.png" )
        --     docs:AddOption( "#holohud2.derma.properties.help.docs.dev_reference" ):SetIcon( "icon16/script.png" )

        local report, parent = help:AddSubMenu( "#holohud2.derma.properties.help.report" )
        parent:SetIcon( "icon16/bug.png" )
        report:SetDeleteSelf( false )

            report:AddOption( "#holohud2.derma.properties.help.report.steam", function() gui.OpenURL( "https://steamcommunity.com/workshop/filedetails/discussion/3459525275/594019691431754721" ) end ):SetIcon( "holohud2/steam16.png" )
            report:AddOption( "#holohud2.derma.properties.help.report.github", function() gui.OpenURL( "https://github.com/DyaMetR/holohud2/issues/new" ) end ):SetIcon( "holohud2/github16.png" )

        help:AddOption( "#holohud2.derma.properties.help.about", function()

            local dialog = vgui.Create( "HOLOHUD2_DAbout" )
            dialog:SetSize( 480, 230 )
            dialog:Center()
            dialog:SetBackgroundBlur( true )
            dialog:MakePopup()
            dialog:DoModal()

        end):SetIcon( "icon16/information.png" )

    if game.SinglePlayer() then return end -- NOTE: ignore warning if on singleplayer

    ---
    --- Server overrides warning
    ---
    local warning = vgui.Create( "HOLOHUD2_DHint", frame )
    warning:Dock( TOP )
    warning:DockMargin( 0, 2, 0, 0 )
    warning:SetIcon( "icon16/error.png" )
    warning:SetText( "#holohud2.properties.override_warning" )
    frame.Think = function()

        local visible = not table.IsEmpty( HOLOHUD2.server.Get() )

        if warning:IsVisible() == visible then return end

        warning:SetVisible( visible )
        frame:InvalidateLayout()

    end

end
concommand.Add( "holohud2_properties", open_properties )
