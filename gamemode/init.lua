--[[---------------------------------------------------------

  Sandbox Gm

  This is GMod's default gm

-----------------------------------------------------------]]

-- These files get sent to the client


print("init")
unclude = unclude or include
function include( fileName )
	--print( fileName )
	return unclude( fileName )
end

AddCSLuaFile( "cl_hints.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_notice.lua" )
AddCSLuaFile( "cl_search_models.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_worldtips.lua" )
AddCSLuaFile( "persistence.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "save_load.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "gui/IconEditor.lua" )

RunConsoleCommand( "sv_airaccelerate", 1000 )
RunConsoleCommand( "sv_sticktoground", 0 )
RunConsoleCommand( "sbox_maxprops", 5 )
RunConsoleCommand( "sbox_noclip", 1 ) -- TODO set to 0
RunConsoleCommand( "sbox_godmode", 0 )
RunConsoleCommand( "sv_mincmdrate", 66 )
RunConsoleCommand( "sv_maxcmdrate", 100 )
RunConsoleCommand( "sv_minupdaterate", 33 )
RunConsoleCommand( "sv_maxupdaterate", 100 )
RunConsoleCommand( "sv_minrate", 10000 )
RunConsoleCommand( "sv_maxrate", 100000 )

include( "deathmatch.lua" )
include( 'shared.lua' )
include( 'commands.lua' )
include( 'player.lua' )
include( 'spawnmenu/init.lua' )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "gamemode_base" )

--[[---------------------------------------------------------
	Name: gm:PlayerSpawn()
	Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( ply )

	player_manager.SetPlayerClass( ply, "player_sandbox" )

	--ply:SetModel( "models/player/swat.mdl" )
	ply:SetRunSpeed( 320 )
	ply:SetWalkSpeed( 200 )
	ply:SetDuckSpeed( 0.3 )
	ply:SetUnDuckSpeed( 0.3 )

	BaseClass.PlayerSpawn( self, ply )

end

--[[---------------------------------------------------------
	Name: gm:OnPhysgunFreeze( weapon, phys, ent, player )
	Desc: The physgun wants to freeze a prop
-----------------------------------------------------------]]
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )

	-- Don't freeze persistent props (should already be froze)
	if ( ent:GetPersistent() ) then return false end

	BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )

	ply:SendHint( "PhysgunUnfreeze", 0.3 )
	ply:SuppressHint( "PhysgunFreeze" )

end

--[[---------------------------------------------------------
	Name: gm:OnPhysgunReload( weapon, player )
	Desc: The physgun wants to unfreeze
-----------------------------------------------------------]]
function GM:OnPhysgunReload( weapon, ply )

	local num = ply:PhysgunUnfreeze()

	if ( num > 0 ) then
		ply:SendLua( "GM:UnfrozeObjects(" .. num .. ")" )
	end

	ply:SuppressHint( "PhysgunUnfreeze" )

end

--[[---------------------------------------------------------
	Name: gm:PlayerShouldTakeDamage
	Return true if this player should take damage from this attacker
	Note: This is a shared function - the client will think they can
		damage the players even though they can't. This just means the
		prediction will show blood.
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )

---- The player should always take damage in single player..
--if ( game.SinglePlayer() ) then return true end

---- Global godmode, players can't be damaged in any way
--if ( cvars.Bool( "sbox_godmode", false ) ) then return false end

---- No player vs player damage
--if ( attacker:IsValid() && attacker:IsPlayer() ) then
--	return cvars.Bool( "sbox_playershurtplayers", true )
--end

---- Default, let the player be hurt
    return true

end

--[[---------------------------------------------------------
	Show the search when f1 is pressed
-----------------------------------------------------------]]
function GM:ShowHelp( ply )

	ply:SendLua( "hook.Run( 'StartSearch' )" )

end

--[[---------------------------------------------------------
	Called once on the player's first spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )

	BaseClass.PlayerInitialSpawn( self, ply )

end

--[[---------------------------------------------------------
	A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )

	-- Replace the entity with the ragdoll in cleanups etc
	undo.ReplaceEntity( entity, ragdoll )
	cleanup.ReplaceEntity( entity, ragdoll )

end

--[[---------------------------------------------------------
	Player unfroze an object
-----------------------------------------------------------]]
function GM:PlayerUnfrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
	effectdata:SetOrigin( physobject:GetPos() )
	effectdata:SetEntity( entity )
	util.Effect( "phys_unfreeze", effectdata, true, true )

end

--[[---------------------------------------------------------
	Player froze an object
-----------------------------------------------------------]]
function GM:PlayerFrozeObject( ply, entity, physobject )

	if ( DisablePropCreateEffect ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( physobject:GetPos() )
	effectdata:SetEntity( entity )
	util.Effect( "phys_freeze", effectdata, true, true )

end

--
-- Who can edit variables?
-- If you're writing prop protection or something, you'll
-- probably want to hook or override this function.
--
function GM:CanEditVariable( ent, ply, key, val, editor )

	-- Only allow admins to edit admin only variables!
	if ( editor.AdminOnly ) then
		return ply:IsAdmin()
	end

	-- This entity decides who can edit its variables
	if ( isfunction( ent.CanEditVariables ) ) then
		return ent:CanEditVariables( ply )
	end

	-- default in sandbox is.. anyone can edit anything.
	return true

end