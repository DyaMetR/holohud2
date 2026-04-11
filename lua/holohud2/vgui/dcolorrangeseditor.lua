
local PANEL = {}

function PANEL:Init()

    self:SetTitle( "" )

    local wanglabel = vgui.Create( "Panel", self )
    wanglabel:Dock( TOP )
    self.WangLabel = wanglabel

        local label = vgui.Create( "DLabel", wanglabel )
        label:Dock( LEFT )
        label:DockMargin( 2, 0, 0, 0 )
        label:SetText( "#holohud2.derma.colorranges.value" )
        label:SizeToContents()

        local numberwang = vgui.Create( "DNumberWang", wanglabel )
        numberwang:Dock( RIGHT )
        numberwang:DockMargin( 0, 2, 0, 2 )
        numberwang:SetWide( 128 )
        numberwang:SetMinMax( 0, 2147483647 )
        self.NumberWang = numberwang

    local colormixer = vgui.Create( "DColorMixer", self )
    colormixer:Dock( FILL )
    colormixer:DockMargin( 0, 2, 0, 4 )
    self.ColorMixer = colormixer

    local options = vgui.Create( "Panel", self )
    options:Dock( BOTTOM )

        local cancel = vgui.Create( "DButton", options )
        cancel:Dock( RIGHT )
        cancel:SetText( "#holohud2.derma.cancel" )
        cancel.DoClick = function( _ )

            self:Close()

        end

        local submit = vgui.Create( "DButton", options )
        submit:Dock( RIGHT )
        submit:DockMargin( 0, 0, 4, 0 )
        submit:SetText( "#holohud2.derma.ok" )
        submit.DoClick = function( _ )

            self:OnSubmit( self.old, math.Round( self.NumberWang:GetValue() ), colormixer:GetColor() )
            self:Close()

        end

end

function PANEL:SetValue( value )

    self.old = value
    self.NumberWang:SetValue( value )

end

function PANEL:SetColor( color )

    self.ColorMixer:SetColor( color )

end

function PANEL:OnSubmit( value, color ) end

vgui.Register('HOLOHUD2_DColorRangesEditor', PANEL, 'DFrame')
