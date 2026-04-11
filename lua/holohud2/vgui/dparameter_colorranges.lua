local surface = surface

DEFINE_BASECLASS( "HOLOHUD2_DParameter" )

local PANEL = {}

function PANEL:Init()

    self.Colors     = {}
    self.Fraction   = false
    self.Gradual    = false

    local viewer = vgui.Create( "HOLOHUD2_DColorRangesViewer", self )
    viewer:Dock( RIGHT )
    viewer:DockMargin( 0, 2, 4, 2 )
    viewer:SetWide( 128 )
    viewer.DoClick = function()

        local menu = DermaMenu()
        menu:AddOption( "#holohud2.derma.colorranges.add", function()

            self:OpenEditor()

        end):SetIcon( "icon16/add.png" )
        menu:AddSpacer()

        for value, color in SortedPairs( self.Colors ) do

            local option, parent = menu:AddSubMenu( value )

            option:AddOption( "#holohud2.derma.colorranges.edit", function()

                self:OpenEditor( value )

            end):SetIcon( "icon16/pencil.png" )

            local remove = option:AddOption( "#holohud2.derma.colorranges.remove", function()

                self.Colors[ value ] = nil
                self.Viewer:SetColors( self.Colors )
                self:ValueChange()

            end)
            remove:SetIcon( "icon16/delete.png" )
            remove:SetEnabled( table.Count( self.Colors ) > 1 )
            remove:SetTooltip( not remove:IsEnabled() and "#holohud2.derma.colorranges.delete_empty" )

            local preview = vgui.Create( "Panel", parent )
            preview:SetPos( 3, 3 )
            preview:SetSize( 16, 16 )
            preview.Paint = function( _, w, h )

                surface.SetDrawColor( color.r, color.g, color.b, math.max( color.a, 64 ) )
                surface.DrawRect( 2, 2, w - 4, h - 4 )
                surface.SetDrawColor( 0, 0, 0, 150 )
                surface.DrawOutlinedRect( 0, 0, w, h )

            end

        end

        menu:Open()

    end
    self.Viewer = viewer

    local fraction = vgui.Create( "DCheckBoxLabel", self )
    fraction:Dock( RIGHT )
    fraction:DockMargin( 0, 0, 8, 0 )
    fraction:SetText( "%" )
    fraction:SetDark( true )
    fraction:SetTooltip( "#holohud2.derma.colorranges.fraction" )
    fraction.OnChange = function( _, value )

        self:ValueChange()

    end
    self.Fraction = fraction

    local gradualicon = vgui.Create( "DImage", self )
    gradualicon:Dock( RIGHT )
    gradualicon:DockMargin( 0, 4, 10, 4 )
    gradualicon:SetWide( 16 )
    gradualicon:SetImage( "icon16/chart_curve.png" )

    local gradual = vgui.Create( "DCheckBox", self )
    gradual:Dock( RIGHT )
    gradual:DockMargin( 0, 4, 5, 5 )
    gradual:SetWide( 15 )
    gradual:SetTooltip( "#holohud2.derma.colorranges.gradual" )
    gradual.OnChange = function( _, value )

        self:ValueChange()

    end
    self.Gradual = gradual

end

function PANEL:OpenEditor( value )

    local editor = vgui.Create( "HOLOHUD2_DColorRangesEditor" )
    editor:SetSize( 250, 300 )
    editor:SetBackgroundBlur( true )
    editor:MakePopup()
    editor:DoModal()
    editor:Center()

    if value then

        editor:SetValue( value )
        editor:SetColor( self.Colors[ value ] )

    end

    editor.OnSubmit = function( _, old, value, color )

        if old then self.Colors[ old ] = nil end -- remove old value

        self.Colors[ value ] = color
        self.Viewer:SetColors( self.Colors )
        self:ValueChange()

    end

end

function PANEL:ValueChange()

    self:OnValueChanged( self:GetValue() )

end

function PANEL:GetValue()

    local colors = {}

    for k, v in pairs( self.Colors ) do

        colors[ k ] = Color( v.r, v.g, v.b, v.a )

    end

    return {
        colors      = colors,
        fraction    = self.Fraction:GetChecked(),
        gradual     = self.Gradual:GetChecked()
    }

end

function PANEL:SetValue( value )

    self.Colors = {}

    for k, v in pairs( value.colors ) do

        self.Colors[ k ] = Color( v.r, v.g, v.b, v.a )

    end

    self.Viewer:SetColors( self.Colors )
    self.Fraction:SetChecked( value.fraction )
    self.Gradual:SetChecked( value.gradual )

end

vgui.Register( "HOLOHUD2_DParameter_ColorRanges", PANEL, "HOLOHUD2_DParameter" )
