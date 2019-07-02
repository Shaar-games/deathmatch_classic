
--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

-----------------------------------------------------------]]

include( 'shared.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_notice.lua' )
include( 'cl_hints.lua' )
include( 'cl_worldtips.lua' )
include( 'cl_search_models.lua' )
include( 'gui/IconEditor.lua' )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )


local physgun_halo = CreateConVar( "physgun_halo", "1", { FCVAR_ARCHIVE }, "Draw the physics gun halo?" )

function GM:Initialize()

	BaseClass.Initialize( self )
	
end

function GM:LimitHit( name )

	self:AddNotify( "#SBoxLimit_"..name, NOTIFY_ERROR, 6 )
	surface.PlaySound( "buttons/button10.wav" )

end

function GM:OnUndo( name, strCustomString )
	
	if ( !strCustomString ) then
		self:AddNotify( "#Undone_"..name, NOTIFY_UNDO, 2 )
	else	
		self:AddNotify( strCustomString, NOTIFY_UNDO, 2 )
	end
	
	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:OnCleanup( name )

	self:AddNotify( "#Cleaned_"..name, NOTIFY_CLEANUP, 5 )
	
	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:UnfrozeObjects( num )

	self:AddNotify( "Unfroze "..num.." Objects", NOTIFY_GENERIC, 3 )
	
	-- Find a better sound :X
	surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )

end

function GM:HUDPaint()

	self:PaintWorldTips()

	-- Draw all of the default stuff
	BaseClass.HUDPaint( self )
	
	self:PaintNotes()
	
end

--[[---------------------------------------------------------
	Draws on top of VGUI..
-----------------------------------------------------------]]
function GM:PostRenderVGUI()

	BaseClass.PostRenderVGUI( self )

end

local PhysgunHalos = {}

--[[---------------------------------------------------------
   Name: gamemode:DrawPhysgunBeam()
   Desc: Return false to override completely
-----------------------------------------------------------]]
function GM:DrawPhysgunBeam( ply, weapon, bOn, target, boneid, pos )

	if ( physgun_halo:GetInt() == 0 ) then return true end

	if ( IsValid( target ) ) then
		PhysgunHalos[ ply ] = target
	end
	
	return true

end

hook.Add( "PreDrawHalos", "AddPhysgunHalos", function()

	if ( !PhysgunHalos || table.IsEmpty( PhysgunHalos ) ) then return end


	for k, v in pairs( PhysgunHalos ) do

		if ( !IsValid( k ) ) then continue end

		local size = math.random( 1, 2 )
		local colr = k:GetWeaponColor() + VectorRand() * 0.3
		 
		halo.Add( PhysgunHalos, Color( colr.x * 255, colr.y * 255, colr.z * 255 ), size, size, 1, true, false )
		
	end
	
	PhysgunHalos = {}

end )


--[[---------------------------------------------------------
   Name: gamemode:NetworkEntityCreated()
   Desc: Entity is created over the network
-----------------------------------------------------------]]
function GM:NetworkEntityCreated( ent )

	--
	-- If the entity wants to use a spawn effect
	-- then create a propspawn effect if the entity was
	-- created within the last second (this function gets called
	-- on every entity when joining a server)
	--

	if ( ent:GetSpawnEffect() && ent:GetCreationTime() > (CurTime() - 1.0) ) then
	
		local ed = EffectData()
			ed:SetOrigin( ent:GetPos() )
			ed:SetEntity( ent )
		util.Effect( "propspawn", ed, true, true )

	end

end

--local lastWeapon
--
--function GM:PlayerSwitchWeapon( ply, oldWeapon, newWeapon )
--	if lastWeapon != oldWeapon then
--		lastWeapon = oldWeapon
--	end
--end
--
--function GM:PlayerBindPress( ply, bind, pressed )
--
--	if bind:find( "lastinv" ) and pressed then
--		if IsValid( lastWeapon ) then
--			input.SelectWeapon( lastWeapon )
--		end
--		return true
--	end
--
--end



game.Limit = false

function GM:WeaponsMenu()

	RestoreCursorPosition()

	local TABLE = util.JSONToTable( net.ReadString() )
	local Panel = vgui.Create( "DFrame" )
	Panel:SetSize( ScrW()/1.5, ScrH()/1.5 )
	Panel:Center()
	Panel:SetTitle( "Weapon config menu" )
	Panel:SetDraggable( true )
	Panel:MakePopup()

	Panel.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
	end

	local class = vgui.Create( "DPanelList", Panel )
	class:SetPos( 0 , 50 )
	class:SetSize( Panel:GetWide()/2 , Panel:GetTall()/1.5 - 50 )

	class.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(20,20,20,255))
	end

	local class2 = vgui.Create( "DPanelList", Panel )
	class2:SetPos( Panel:GetWide()/2 , 50 )
	class2:SetSize( Panel:GetWide()/2 , Panel:GetTall()/1.5 - 50 )

	class2.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
	end

	local class3 = vgui.Create( "DPanelList", Panel )
	class3:SetPos( Panel:GetWide()/2 , Panel:GetTall()/1.5 )
	class3:SetSize( Panel:GetWide()/2 , Panel:GetTall()/3 )
	class3:EnableVerticalScrollbar()
	class3.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
	end

	for k,v in pairs(TABLE.configs) do
		b = vgui.Create("DButton" )
		b:SetText( v )
		b:SetSize( class3:GetWide() , 50 )
		b:SetTextColor( Color( 255,255,255 ) ) 
		b.Paint = function( self , w , h)
		if !self:IsHovered() then
			if TABLE.active:lower()..".dat" == v then
				draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,200,50,255))
				return
			end
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
			end
	
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
		end
		b.DoClickInternal = function( ... )
			net.Start("dm_weaponmenu", true )
			net.WriteString( v )
			net.SendToServer()
			RememberCursorPosition()
			Panel:Remove()
		end

		b.DoRightClick = function ( )
			local menu = DermaMenu()
			menu:AddOption( "Delete", function() 
				net.Start("dm_deleteconfig")
				net.WriteString( v )
				net.SendToServer()

				timer.Simple(0.01 ,function()
				net.Start("dm_weaponmenu", true )
				net.WriteString( "" )
				net.SendToServer()
				RememberCursorPosition()
				Panel:Remove()
				end)
			end )
			menu:AddOption( "close", function() menu:Remove() end )
			menu:Open()
		end

		class3:AddItem( b )
	end

	local configname = vgui.Create("DTextEntry", Panel )
	configname:SetPos( 0 , Panel:GetTall()/1.5 )
	configname:SetSize( Panel:GetWide()/2 , 50 )
	configname:SetText( TABLE.name or "config_name" )
	configname:SetTextColor( Color( 0,0,0 ) ) 
	--configname.Paint = function( self , w , h)
	--	if !self:IsHovered() then
	--		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
	--		return
	--	end
	--
	--	draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	--end

	
	local texts = {}

	local content = {}

	content[1] = "melee weapon"
	content[2] = "soft pistol"
	content[3] = "heavy pistol"
	content[4] = "shotgun"
	content[5] = "sniper"
	content[6] = "submachinegun"
	content[7] = "grenade"
	content[8] = "dropable explosive"
	content[9] = "assault rifle"
	content[10] = "rpg"
	content[11] = "rifle"
	content[12] = "bonus weapon"

	for k,v in pairs(  weapons.GetList() ) do
		local i = vgui.Create( "DTextEntry" )
		i:SetText( v.ClassName or "" )
		i:SetContentAlignment( 5 )
		class2:AddItem( i )
	end


	for i=1,12 do
		
		local lb = vgui.Create( "DLabel"  )
		lb:SetText( content[i] )
		lb:SetContentAlignment( 5 )
		lb:SetTextColor( Color( 200 , 200, 200 ) )

		
		texts[i] = vgui.Create( "DTextEntry" )
		texts[i]:SetContentAlignment( 5 )
		texts[i]:SetText( TABLE[i] or "" )
		class:AddItem( lb )
		class:AddItem( texts[i] )
	end

	local save = vgui.Create("DButton", Panel )
	save:SetPos( 0 , Panel:GetTall()/1.5 + 50 )
	save:SetSize( Panel:GetWide()/2 , 50 )
	save:SetText( "SAVE" )
	save:SetTextColor( Color( 255,255,255 ) ) 
	save.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end

		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	save.DoClickInternal = function( ... )
		local tbl = {}
	
		for i,v in ipairs(texts) do
			tbl[i] = v:GetText()
		end

		tbl.name = configname:GetText()
		net.Start( "dm_weaponconfig" )
		net.WriteString( util.TableToJSON( tbl ) )
		net.SendToServer()

		timer.Simple(0.01 ,function()
		net.Start("dm_weaponmenu", true )
		net.WriteString( tbl.name:lower() )
		net.SendToServer()
		end)
		RememberCursorPosition()
		Panel:Remove()
	end

	local reset = vgui.Create("DButton", Panel )
	reset:SetPos( 0 , Panel:GetTall()/1.5 + 100 )
	reset:SetSize( Panel:GetWide()/2 , 50 )
	reset:SetText( "RESET" )
	reset:SetTextColor( Color( 255,255,255 ) ) 

	reset.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	reset.DoClickInternal = function( ... )
		net.Start("dm_weaponmenu", true )
		net.WriteString("")
		net.SendToServer()
		RememberCursorPosition()
		Panel:Remove()
	end

	local setcurrent = vgui.Create("DButton", Panel )
	setcurrent:SetPos( 0 , Panel:GetTall()/1.5 + 150 )
	setcurrent:SetSize( Panel:GetWide()/2 , 50 )
	setcurrent:SetText( "Set Active config" )
	setcurrent:SetTextColor( Color( 255,255,255 ) ) 

	setcurrent.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	setcurrent.DoClickInternal = function( ... )

	net.Start("dm_setactiveconfig")
	net.WriteString( configname:GetText() )
	net.SendToServer()
	RememberCursorPosition()
	Panel:Remove()
	end


class:EnableVerticalScrollbar()
class2:EnableVerticalScrollbar()



end

concommand.Add("dm_weaponmenu",function()
	net.Start("dm_weaponmenu", true )
	net.WriteString("")
	net.SendToServer()
end)

net.Receive("dm_weaponmenu",GM.WeaponsMenu)

function GM.SpawnPointMenu()

	local content = {}

	content[1] = "melee weapon"
	content[2] = "soft pistol"
	content[3] = "heavy pistol"
	content[4] = "shotgun"
	content[5] = "sniper"
	content[6] = "submachinegun"
	content[7] = "grenade"
	content[8] = "dropable explosive"
	content[9] = "assault rifle"
	content[10] = "rpg"
	content[11] = "rifle"
	content[12] = "bonus weapon"
	local str = string.Explode("///", net.ReadString() )
	local playerspawns = util.JSONToTable( str[1] ) or {}
	local weaponspawns = util.JSONToTable( str[2] ) or {}

	local Panel = vgui.Create( "DFrame" )
	Panel:SetSize( ScrW()/1.5, ScrH()/1.5 )
	Panel:Center()
	Panel:SetTitle( "spawnpoint config menu" )
	Panel:SetDraggable( true )
	Panel:MakePopup()

	Panel.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
	end

	local class = vgui.Create( "DPanelList", Panel )
	class:SetPos( 0 , 50 )
	class:SetSize( Panel:GetWide()/2 , Panel:GetTall()/1.5 - 50 )

	class.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(20,100,20,255))
	end

	local class2 = vgui.Create( "DPanelList", Panel )
	class2:SetPos( Panel:GetWide()/2 , 50 )
	class2:SetSize( Panel:GetWide()/2 , Panel:GetTall()/1.5 - 50 )

	class2.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(100,20,20,255))
	end

	local mt = {}
	mt.__newindex = function( self , k , v )
		local d = vgui.Create("DButton")
		d:SetText( game.GetMap() .. " Spawn n° " .. k )
		d:SetSize( Panel:GetWide()/2 , 50 )
		d:SetTextColor( Color( 255 ,255 ,255) )
		d.Paint = function( self , w , h)
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(10 + k*3,10 + k*3,10 + k*3,255))
		end

		d.DoRightClick = function( me )
			local menu = DermaMenu()
			menu:AddOption( "Goto", function() 
				net.Start( "dm_spawnpointgoto" )
				net.WriteAngle( v.ang )
				net.WriteVector( v.pos )
				net.SendToServer()
			end )
			menu:AddOption( "Remove", function() self[k] = nil me:Remove() end )
			menu:AddOption( "Close", function() menu:Remove() end )
			menu:Open()
		end

		class:AddItem( d )

		rawset( self , k , v )
	end

	for k,v in pairs( playerspawns ) do
		local d = vgui.Create("DButton")
		d:SetText( game.GetMap() .. " Spawn n° " .. k )
		d:SetSize( Panel:GetWide()/2 , 50 )
		d:SetTextColor( Color( 255 ,255 ,255) )
		d.Paint = function( self , w , h)
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(10 + k*3,10 + k*3,10 + k*3,255))
		end

		d.DoRightClick = function( me )
			local menu = DermaMenu()
			menu:AddOption( "Goto", function() 
				net.Start( "dm_spawnpointgoto" )
				net.WriteAngle( v.ang )
				net.WriteVector( v.pos )
				net.SendToServer()
			end )
			menu:AddOption( "Remove", function() playerspawns[k] = nil d:Remove() end )
			menu:AddOption( "Close", function() menu:Remove() end )
			menu:SetPos( gui.MousePos() )
			menu:Open()
		end

		class:AddItem( d )
	end

	setmetatable( playerspawns , mt )


	local mt = {}

	mt.__newindex = function( self , k , v )
		rawset( self , k , v )
		local d = vgui.Create("DButton")
		d:SetText( "Weapon n° " .. k )
		d:SetSize( Panel:GetWide()/2 , 50 )
		d:SetTextColor( Color( 255 ,255 ,255) )
		d.Paint = function( self , w , h)
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(10 + k*3,10 + k*3,10 + k*3,255))
		end

		d.DoRightClick = function( me )
			local menu = DermaMenu()
			menu:AddOption( "Remove", function() self[k] = nil me:Remove() end )
			menu:AddOption( "Close", function() menu:Remove() end )
			menu:Open()
		end

		class2:AddItem( d )

		
	end

	for k,v in pairs( weaponspawns ) do
		local d = vgui.Create("DButton")
		d:SetText( "Weapon " .. content[ v.index ] .. " n° " .. k )
		d:SetSize( Panel:GetWide()/2 , 50 )
		d:SetTextColor( Color( 255 ,255 ,255) )
		d.Paint = function( self , w , h)
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(10 + k*3,10 + k*3,10 + k*3,255))
		end

		d.DoRightClick = function( me )
			local menu = DermaMenu()
			
			menu:AddOption( "Remove", function() weaponspawns[k] = nil me:Remove() end )
			menu:AddOption( "Close", function() menu:Remove() end )
			menu:Open()
		end

		class2:AddItem( d )
	end

	setmetatable( weaponspawns , mt )


	local addspawn = vgui.Create("DButton" , Panel )
	addspawn:SetPos( 0 , Panel:GetTall()/1.5 + 5 )
	addspawn:SetSize( Panel:GetWide()/2 , 50 )
	addspawn:SetText( "Add Player spawn" )
	addspawn:SetTextColor( Color( 255 ,255 ,255 ))
	addspawn.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	addspawn.DoClickInternal = function( self )
		local index =  #playerspawns + 1

		playerspawns[ index ] = {}
		playerspawns[ index ].pos = LocalPlayer():GetPos()
		playerspawns[ index ].ang = LocalPlayer():EyeAngles()

	end

	local addspawn = vgui.Create("DButton" , Panel )
	addspawn:SetPos( Panel:GetWide()/2 , Panel:GetTall()/1.5 + 5 )
	addspawn:SetSize( Panel:GetWide()/2 , 50 )
	addspawn:SetText( "Add Weapon spawn" )
	addspawn:SetTextColor( Color( 255 ,255 ,255 ))
	addspawn.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	addspawn.DoClickInternal = function( self )

		local menu = DermaMenu()
		
		for k,v in pairs( content ) do
				menu:AddOption( v , function()
				local index =  #weaponspawns + 1
				weaponspawns[ index ] = {}
				weaponspawns[ index ].pos = LocalPlayer():GetEyeTrace().HitPos
				weaponspawns[ index ].index = k
			end )
		end
		
		menu:AddOption( "Close", function() menu:Remove() end )
		menu:Open()

	end

	local save = vgui.Create("DButton" , Panel )
	save:SetPos( 0 , Panel:GetTall()/1.5 + 100 )
	save:SetSize( Panel:GetWide()/2 , 50 )
	save:SetText( "SAVE playerspawns" )
	save:SetTextColor( Color( 255 ,255 ,255 ))
	save.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	save.DoClickInternal = function ( )
		net.Start("dm_spawnpoint",true)
		net.WriteString( util.TableToJSON( playerspawns ) )
		net.SendToServer()
	end

	local save = vgui.Create("DButton" , Panel )
	save:SetPos( Panel:GetWide()/2 , Panel:GetTall()/1.5 + 100 )
	save:SetSize( Panel:GetWide()/2 , 50 )
	save:SetText( "SAVE weaponspawns" )
	save:SetTextColor( Color( 255 ,255 ,255 ))
	save.Paint = function( self , w , h)
		if !self:IsHovered() then
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
			return
		end
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(60,60,60,255))
	end

	save.DoClickInternal = function ( )
		net.Start("dm_weaponspawn",true)
		net.WriteString( util.TableToJSON( weaponspawns ) )
		net.SendToServer()
	end


	class:EnableVerticalScrollbar()
	class2:EnableVerticalScrollbar()


end


concommand.Add("dm_spawnpoint",function()
	net.Start("dm_spawnpoint", true )
	net.SendToServer()
end)

net.Receive("dm_spawnpoint",GM.SpawnPointMenu)

local dm_Scoreboard = {}

surface.CreateFont( "dm_Scoreboard", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
} )

surface.CreateFont( "dm_Scoreboard2", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 16,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
} )

function dm_Scoreboard:show()
	--gui.EnableScreenClicker( true )

	dm_Scoreboard.Panel = vgui.Create( "DFrame" )
	dm_Scoreboard.Panel:SetSize( ScrW()/1.5, ScrH()/1.5 )
	dm_Scoreboard.Panel:Center()
	dm_Scoreboard.Panel:SetDraggable( false )
	dm_Scoreboard.Panel:SetTitle("")
	dm_Scoreboard.Panel:ShowCloseButton( false )
	dm_Scoreboard.Panel.Paint = function( self , w , h)
		draw.RoundedBox( 2 ,0 ,0 ,w  ,h  ,Color(0,0,0,200))
	end

	local plist = vgui.Create( "DPanelList", dm_Scoreboard.Panel )
	plist:SetPos( 0 , 60 )
	plist:SetSize( dm_Scoreboard.Panel:GetWide() , dm_Scoreboard.Panel:GetTall() )
	
	local name = vgui.Create("DLabel" , dm_Scoreboard.Panel )
	name:SetPos( 0 , 0 )
	name:SetSize( dm_Scoreboard.Panel:GetWide()  , 55 )
	name:SetText( GetHostName() )
	name:SetContentAlignment( 5 )
	name:SetFont( "dm_Scoreboard" )

	local p = vgui.Create("DButton")
	p:SetSize( dm_Scoreboard.Panel:GetWide()/10 , dm_Scoreboard.Panel:GetTall()/math.max( 15 , player.GetCount() + 4 ) )
	p:SetPos( 0 , 0 )
	p:SetText("")
	p.Paint = function( self , w , h)
		draw.RoundedBox( 2 ,0 ,0 ,w  ,h  ,Color(0,0,0,200))
	end

	local l = Label( "Name" , p )
	l:SetPos( p:GetWide()/6 , 0 )
	l:SetSize( p:GetWide()/3 , p:GetTall() )
	l:SetFont("dm_Scoreboard2")
	l:SetContentAlignment( 5 )

	local l = Label( "Frags" , p )
	l:SetPos( p:GetWide()*6 , 0 )
	l:SetSize( p:GetWide()/3 , p:GetTall() )
	l:SetFont("dm_Scoreboard2")
	l:SetContentAlignment( 5 )

	local l = Label( "Deaths" , p )
	l:SetPos( p:GetWide()*7 , 0 )
	l:SetSize( p:GetWide()/3 , p:GetTall() )
	l:SetFont("dm_Scoreboard2")
	l:SetContentAlignment( 5 )

	local l = Label( "K/D" , p )
	l:SetPos( p:GetWide()*8 , 0 )
	l:SetSize( p:GetWide()/3 , p:GetTall() )
	l:SetFont("dm_Scoreboard2")
	l:SetContentAlignment( 5 )

	local l = Label( "Ping", p )
	l:SetPos( p:GetWide()*9 , 0 )
	l:SetSize( p:GetWide()/3 , p:GetTall() )
	l:SetFont("dm_Scoreboard2")
	l:SetContentAlignment( 5 )

	plist:AddItem( p )


	for k,v in pairs( player.GetAll() ) do
		local p = vgui.Create("DButton")
		p:SetSize( dm_Scoreboard.Panel:GetWide()/10 , dm_Scoreboard.Panel:GetTall()/math.max( 15 , player.GetCount() + 4 ) )
		p:SetPos( 0 , 0 )
		p:SetText("")
		p.Paint = function( self , w , h)
			draw.RoundedBox( 2 ,0 ,0 ,w  ,h  ,Color(0,0,0,200))
		end

		local l = Label( v:Name() , p )
		l:SetPos( p:GetWide()/6 , 0 )
		l:SetSize( p:GetWide()/3 , p:GetTall() )
		l:SetFont("dm_Scoreboard2")
		l:SetContentAlignment( 5 )

		local l = Label( v:Frags() , p )
		l:SetPos( p:GetWide()*6 , 0 )
		l:SetSize( p:GetWide()/3 , p:GetTall() )
		l:SetFont("dm_Scoreboard2")
		l:SetContentAlignment( 5 )

		local l = Label( v:Deaths() , p )
		l:SetPos( p:GetWide()*7 , 0 )
		l:SetSize( p:GetWide()/3 , p:GetTall() )
		l:SetFont("dm_Scoreboard2")
		l:SetContentAlignment( 5 )

		local function moy()
			local x = v:Frags()
			local y = v:Deaths()

			if x == 0 then
				x = 1
			end

			if y == 0 then
				y = 1
			end
			return math.Round( x/y ,2) 
		end

		local l = Label( moy() , p )
		l:SetPos( p:GetWide()*8 , 0 )
		l:SetSize( p:GetWide()/3 , p:GetTall() )
		l:SetFont("dm_Scoreboard2")
		l:SetContentAlignment( 5 )

		local l = Label( v:Ping() , p )
		l:SetPos( p:GetWide()*9 , 0 )
		l:SetSize( p:GetWide()/3 , p:GetTall() )
		l:SetFont("dm_Scoreboard2")
		l:SetContentAlignment( 5 )

		plist:AddItem( p )
	end

	plist:EnableVerticalScrollbar()

end

function dm_Scoreboard:hide()
	--gui.EnableScreenClicker( false )
	if IsValid( dm_Scoreboard.Panel ) then
		dm_Scoreboard.Panel:Remove()
	end
end

hook.Add( "ScoreboardShow", "dm_ScoreboardShow", function()
	if not game.Limit then
		dm_Scoreboard:show()
	end
	return false
end )

hook.Add( "ScoreboardHide", "dm_ScoreboardShow", function()
	if not game.Limit then
		dm_Scoreboard:hide()
	end
	return false
end )

function game.ShowScoreBoard()
	if game.Limit then
		surface.PlaySound("endtheme" .. math.random( 1 , 2 ) ..".mp3")
		dm_Scoreboard:hide()
		dm_Scoreboard:show()
	else
		dm_Scoreboard:hide()
	end
end

local dis = 0

local function IsPlayingTaunt( ply, pos, angles, fov )

	if not ply:IsPlayingTaunt() then dis = 0 return end
	dis = dis + 2
	local view = {}

	view.origin = pos - ( angles:Forward()*math.min( 80 , dis ) )
	view.angles = angles
	view.fov = fov
	view.drawviewer = true

	return view
end

hook.Add( "CalcView", "IsPlayingTaunt", IsPlayingTaunt )

concommand.Add("dm_restart",function ()
	if not LocalPlayer():IsAdmin() then return end
    net.Start("dm_restart")
    net.SendToServer()
end)


concommand.Add("dm_settings",function ()

	local Panel = vgui.Create( "DFrame" )
	Panel:SetSize( ScrW()/3, ScrH()/1.5 )
	Panel:Center()
	Panel:SetTitle( "Settings" )
	Panel:SetDraggable( true )
	Panel:MakePopup()

	Panel.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
	end

	local class = vgui.Create( "DPanelList", Panel )
	class:SetPos( 0 , 50 )
	class:SetSize( Panel:GetWide() , Panel:GetTall() )

	class.Paint = function( self , w , h)
		draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(50,50,50,255))
	end

	local Convars = {}

	Convars[1] = "dm_max_kills"
	Convars[2] = "dm_max_time"
	Convars[3] = "dm_min_players"
	Convars[4] = "dm_min_players"
	Convars[4] = "dm_restart_time"

	for k,v in pairs(  Convars ) do
		local x = vgui.Create("Panel" )
		local u = vgui.Create( "DLabel" , x)
		u:SetPos( 0 , 0 )
		u:SetText( v or "" )
		u:SetContentAlignment( 5 )
		u:SetSize( x:GetWide()*5 , x:GetTall() )

		u.Paint = function( self , w , h)
			draw.RoundedBox(0 ,0 ,0 ,w  ,h  ,Color(30,30,30,255))
		end
		local i = vgui.Create( "DTextEntry" , x)
		i:SetPos( x:GetWide()*5 , 0 )
		i:SetSize( x:GetWide()*5 , x:GetTall() )
		i:SetText( GetConVarNumber( v ) )
		i:SetContentAlignment( 5 )
		class:AddItem( x )
	end

	class:EnableVerticalScrollbar()

end)