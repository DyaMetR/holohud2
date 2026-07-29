
local PANEL = {}

local TEXT_COLOR    = Color( 180, 180, 180 )

surface.CreateFont( "holohud2_about0", {
    font        = "Roboto Light",
    size        = 20,
    weight      = 1000,
    additive    = true
} )

surface.CreateFont( "holohud2_about1", {
    font        = "Roboto Condensed Light",
    size        = 16,
    weight      = 1000,
    additive    = true
} )

surface.CreateFont( "holohud2_about2", {
    font        = "Roboto Condensed Light",
    size        = 18,
    weight      = 1000,
    additive    = true
} )

surface.CreateFont( "holohud2_about3", {
    font        = "Roboto Condensed Light",
    size        = 18,
    weight      = 0,
    additive    = true
} )

function PANEL:Init()

    self:SetTitle( HOLOHUD2.Name )

    local background = vgui.Create( "DImage", self )
    background:Dock( FILL )
    background:SetImage( "holohud2/about.png" )
    background:SetMouseInputEnabled( true )

    local version = vgui.Create( "DLabel", background )
    version:Dock( TOP )
    version:DockMargin( 0, 8, 16, 0 )
    version:SetFont( "holohud2_about0" )
    version:SetText( "v" .. HOLOHUD2.Version )
    version:SetTextColor( Color( 120, 180, 255 ) )
    version:SetContentAlignment( 6 )

    local date = vgui.Create( "DLabel", background )
    date:Dock( TOP )
    date:DockMargin( 0, 0, 16, 32 )
    date:SetFont( "holohud2_about1" )
    date:SetText( HOLOHUD2.util.DateFormat( language.GetPhrase( "holohud2.properties.last_update.format" ), HOLOHUD2.Date ) )
    date:SetContentAlignment( 6 )
    date:SetTextColor(TEXT_COLOR)

    local thanks0 = vgui.Create( "DLabel", background )
    thanks0:Dock( TOP )
    thanks0:DockMargin( 0, 0, 0, 4 )
    thanks0:SetFont( "holohud2_about2" )
    thanks0:SetText( string.format( language.GetPhrase( "holohud2.about.thanks_user" ), HOLOHUD2.Name ) )
    thanks0:SetContentAlignment( 5 )
    thanks0:SetTextColor(TEXT_COLOR)

    local thanks1 = vgui.Create( "DLabel", background )
    thanks1:Dock( TOP )
    thanks1:SetFont( "holohud2_about3" )
    thanks1:SetText( "#holohud2.about.thanks_community" )
    thanks1:SetContentAlignment( 5 )
    thanks1:SetTextColor(TEXT_COLOR)

    local footer = vgui.Create( "Panel", background )
    footer:Dock( BOTTOM )
    footer:DockMargin( 4, 0, 4, 4 )

        local author = vgui.Create( "DLabel", footer )
        author:Dock( LEFT )
        author:DockMargin( 4, 0, 0, 0 )
        author:SetFont( "holohud2_about2" )
        author:SetText( "DyaMetR" )
        author:SetTextColor(TEXT_COLOR)

        local github = vgui.Create( "DImageButton", footer )
        github:Dock( RIGHT )
        github:SetSize( 16, 16 )
        github:SetImage( "holohud2/github16.png" )
        github:SetTooltip( "#holohud2.about.github" )
        github:SetStretchToFit( false )

        local steamworkshop = vgui.Create( "DImageButton", footer )
        steamworkshop:Dock( RIGHT )
        steamworkshop:DockMargin( 0, 0, 4, 0 )
        steamworkshop:SetSize( 16, 16 )
        steamworkshop:SetImage( "holohud2/steam16.png" )
        steamworkshop:SetTooltip( "#holohud2.about.steamworkshop" )
        steamworkshop:SetStretchToFit( false )

end

vgui.Register( "HOLOHUD2_DAbout", PANEL, "DFrame" )
