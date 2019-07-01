
AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

if ( CLIENT ) then

	CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "cl_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
	CreateConVar( "cl_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )

end

local PLAYER = {}


PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking

--
-- Creates a Taunt Camera
--
PLAYER.TauntCam = TauntCamera()

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 320

--
-- Set up the network table accessors
--
function PLAYER:SetupDataTables()

	BaseClass.SetupDataTables( self )

end


function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()

	self.Player:SwitchToDefaultWeapon()

end

function PLAYER:SetModel()

	BaseClass.SetModel( self )

end

--
-- Called when the player spawns
--
function PLAYER:Spawn()

	BaseClass.Spawn( self )
	
	local col = Vector( team.GetColor( self.Player:Team() ) )
	self.Player:SetWeaponColor( col )

end

--
-- Return true to draw local (thirdperson) camera - false to prevent - nothing to use default behaviour
--
function PLAYER:ShouldDrawLocal() 

	--if ( self.TauntCam:ShouldDrawLocalPlayer( self.Player, self.Player:IsPlayingTaunt() ) ) then return true end

end

--
-- Allow player class to create move
--
function PLAYER:CreateMove( cmd )
	if ( self.TauntCam:ShouldDrawLocalPlayer( self.Player, self.Player:IsPlayingTaunt() ) ) then
		cmd:RemoveKey( IN_ATTACK )
		cmd:RemoveKey( IN_ATTACK2 )
	end
end



--
-- Allow changing the player's view
--
function PLAYER:CalcView( view )
	
end

function PLAYER:GetHandsModel()

	-- return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }

	local cl_playermodel = self.Player:GetModel()
	return player_manager.TranslatePlayerHands( cl_playermodel )

end

player_manager.RegisterClass( "player_sandbox", PLAYER, "player_default" )
