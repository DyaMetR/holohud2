
local BaseClass = HOLOHUD2.component.Get( "HudExtensionCounter" )

local COMPONENT = {}

function COMPONENT:Init()

    BaseClass.Init( self )

    self.Icon:SetTexture( surface.GetTextureID( "holohud2/killicons/generic" ), 64, 64 )

end

function COMPONENT:ApplySettings( settings, fonts )

    local icon = self.Icon
    icon:SetVisible( settings.icon )
    icon:SetPos( settings.icon_pos.x, settings.icon_pos.y )
    icon:SetSize( settings.icon_size )
    icon:SetColor( settings.color )

    local number = self.Number
    number:SetVisible( settings.number )
    number:SetPos( settings.number_pos.x, settings.number_pos.y )
    number:SetFont( fonts.number_font )
    number:SetRenderMode( settings.number_rendermode )
    number:SetBackground( settings.number_background )
    number:SetAlign( settings.number_align )
    number:SetDigits( settings.number_digits )
    number:SetColor( settings.color )
    number:SetColor2( settings.color2 )

    local text = self.Text
    text:SetVisible( settings.text )
    text:SetPos( settings.text_pos.x, settings.text_pos.y )
    text:SetFont( fonts.text_font )
    text:SetAlign( settings.text_align )
    text:SetColor( settings.color )
    self:SetDrawTextOnBackground( settings.text_on_background )

end

HOLOHUD2.component.Register( "HudExtensionKillstreak", COMPONENT, "HudExtensionCounter" )