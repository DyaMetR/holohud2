
local PANEL = {}

function PANEL:Init()

    local helptext = vgui.Create( "HOLOHUD2_DHint", self )
    helptext:Dock( TOP )
    self.Help = helptext

    local presets = vgui.Create( "HOLOHUD2_DPresets", self )
    presets:Dock( TOP )
    presets:DockMargin( 0, 4, 0, 4 )
    presets.OnPresetAdded = function( _, name )

        if not self:AddPreset( name ) then return end

        presets:Fetch( self.presets )

    end
    presets.SelectPreset = function( _, values )

        self:OnPresetSelected( values )
        
        if table.IsEmpty( values ) then return end

        self.Reset:SetEnabled( true )

    end
    presets.OpenPresetsEditor = function()

        local editor = vgui.Create( "HOLOHUD2_DPresetEditor" )
        editor:SetSize( 300, 400 )
        editor:Center()
        editor:MakePopup()
        editor:DoModal()
        editor:SetBackgroundBlur( true )
        editor:SetTitle( "Presets" )
        editor.OnDeletePreset = function( _, filename )

            self:DeletePreset( filename )
            editor:Populate( self.presets )
            presets:Fetch( self.presets )

        end
        editor.OnRenamePreset = function( _, filename, name )

            self:RenamePreset( filename, name )
            editor:Populate( self.presets )
            presets:Fetch( self.presets )

        end

    end
    self.Presets = presets

        local export = vgui.Create( "DImageButton", presets )
        export:Dock( RIGHT )
        export:DockMargin( 0, 0, 4, 0 )
        export:SetWide( 16 )
        export:SetStretchToFit( false )
        export:SetImage( "icon16/page_go.png" )
        export:SetTooltip( "#holohud2.derma.properties.exportimport" )
        export.DoClick = function()

            local menu = DermaMenu()

            menu:AddOption( "#holohud2.derma.properties.import", function()

                self:DoImport()

            end ):SetImage( "icon16/page_white_get.png" )

            local submenu, parent = menu:AddSubMenu( "#holohud2.derma.properties.export" )
            parent:SetImage( "icon16/page_white_go.png" )

            submenu:AddOption( "#holohud2.derma.properties.export.code", function() self:DoExport( false ) end ):SetImage( "icon16/attach.png" )
            submenu:AddOption( "#holohud2.derma.properties.export.lua", function() self:DoExport( true ) end ):SetImage( "icon16/application_xp_terminal.png" )
           
            menu:Open()

        end

    local preview = vgui.Create( "HOLOHUD2_DPreview", self )
    preview:Dock( TOP )
    preview:SetTall( 114 * HOLOHUD2.scale.Get() )
    preview.PaintPreview = function( _, x, y, w, h )

        self:PaintPreview( x, y, w, h )

    end
    self.Preview = preview

    local controls = vgui.Create( "Panel", self )
    controls:Dock( TOP )
    controls:DockMargin( 4, 4, 0, 4 )

        local visible = vgui.Create( "DCheckBoxLabel", controls )
        visible:Dock( LEFT )
        visible:SetText( "#holohud2.common.visible" )
        visible.OnChange = function( _, value )

            self:OnVisibilityChanged( value )

        end
        self.Visible = visible

        local reset = vgui.Create( "DButton", controls )
        reset:Dock( RIGHT )
        reset:SetWide( 212 )
        reset:SetText( "#holohud2.common.reset_to_default" )
        reset:SetImage( "icon16/bomb.png" )
        reset.DoClick = function()

            self:DoReset()

        end
        self.Reset = reset

    local parameters = vgui.Create( "HOLOHUD2_DParameters", self )
    parameters:Dock( FILL )
    parameters.OnValueChanged = function( _, parameter, value )

        self:OnValueChanged( parameter, value )

    end
    parameters.OnValueReset = function( _, parameter )

        self:OnValueReset( parameter )

    end
    parameters.OnPanelExpanded = function( _, parameter, expanded )

        self:OnPanelExpanded( parameter, expanded )

    end
    parameters.OnTabChanged = function( _, tab )

        self:OnTabChanged( tab )

    end
    self.Parameters = parameters

end

function PANEL:SetHelpText( helptext )

    self.Help:SetText( helptext )

end

function PANEL:SetVisibility( visible )

    self.Visible:SetChecked( visible )

end

function PANEL:SetResettable( resettable )

    self.Reset:SetEnabled( resettable )

end

function PANEL:SetPresets( group )

    self.presets = group
    self.Presets:Fetch( group )

end

function PANEL:Populate( element, advanced )

    self.Preview:SetVisible( element:HasPreview() )
    self.Parameters:Populate( element, advanced )

end

function PANEL:SetState( state, tab )

    self.Parameters:SetState( state, tab )

end

function PANEL:SetValues( default, values )

    self.Parameters:SetValues( default, values )

end

function PANEL:OnVisibilityChanged( visible ) end
function PANEL:PaintPreview( x, y, w, h ) end
function PANEL:OnPresetSelected( values ) end
function PANEL:AddPreset( name ) return false end
function PANEL:DoReset() end
function PANEL:OnValueChanged( parameter, value ) end
function PANEL:OnValueReset( parameter ) end
function PANEL:OnPanelExpanded( parameter, expanded ) end
function PANEL:OnTabChanged( tab ) end
function PANEL:DoExport( lua_table ) end
function PANEL:DoImport() end

vgui.Register( "HOLOHUD2_DElementProperties", PANEL, "Panel" )