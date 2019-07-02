
DEATHMATCH = {}

DEATHMATCH.CurrentWeaponConfig =  CreateConVar( "dm_weaponconfig", "Half-Life 2", FCVAR_ARCHIVE , "" )

DEATHMATCH.Limit = false

util.AddNetworkString("dm_weaponmenu")

util.AddNetworkString("dm_weaponconfig")

util.AddNetworkString("dm_setactiveconfig")

util.AddNetworkString("dm_deleteconfig")

util.AddNetworkString("dm_spawnpoint")

util.AddNetworkString("dm_spawnpointgoto")

util.AddNetworkString("dm_weaponspawn")

util.AddNetworkString("dm_restart")

DEATHMATCH.WeaponConfig = {}

local HL = {}

HL[1] = "weapon_hl1_crowbar"
HL[2] = "weapon_hl1_glock"
HL[3] = "weapon_hl1_357"
HL[4] = "weapon_hl1_shotgun"
HL[5] = "weapon_hl1_crossbow"
HL[6] = "weapon_hl1_mp5"
HL[7] = "weapon_hl1_handgrenade"
HL[8] = "weapon_hl1_satchel"
HL[9] = "weapon_hl1_hornetgun"
HL[10] = "weapon_hl1_rpg"
HL[11] = "weapon_hl1_gauss"
HL[12] = "weapon_hl1_egon"

HL.name = "Half-Life"

DEATHMATCH.WeaponConfig["Half-Life"] = HL

local BMS = {}

BMS[1] = "weapon_bms_crowbar"
BMS[2] = "weapon_bms_glock"
BMS[3] = "weapon_bms_357"
BMS[4] = "weapon_bms_shotgun"
BMS[5] = "weapon_bms_crossbow"
BMS[6] = "weapon_bms_mp5"
BMS[7] = "weapon_bms_frag"
BMS[8] = "weapon_bms_satchel"
BMS[9] = "weapon_bms_hivehand"
BMS[10] = "weapon_bms_rpg"
BMS[11] = "weapon_bms_tau"
BMS[12] = "weapon_bms_gluon"

BMS.name = "Black Mesa"

DEATHMATCH.WeaponConfig["Black Mesa"] = BMS

local HL2 = {}

HL2[1] = "weapon_crowbar"
HL2[2] = "weapon_pistol"
HL2[3] = "weapon_357"
HL2[4] = "weapon_shotgun"
HL2[5] = "weapon_crossbow"
HL2[6] = "weapon_smg1"
HL2[7] = "weapon_frag"
HL2[8] = "weapon_slam"
HL2[9] = "weapon_ar2"
HL2[10] = "weapon_rpg"
HL2[11] = "weapon_physcannon"
HL2[12] = "weapon_medkit"

HL2.name = "Half-Life 2"

DEATHMATCH.WeaponConfig["Half-Life 2"] = HL2



file.CreateDir("dm_clasic")
file.CreateDir("dm_clasic/spawnpoint")
file.CreateDir("dm_clasic/weaponconfig")
file.CreateDir("dm_clasic/weaponspawn")

timer.Simple( 1 ,function()

net.Receive("dm_weaponmenu",function( len , ply )
    if not ply:IsAdmin() then return end
    local t = net.ReadString()
    local r = ""

    if file.Exists( "dm_clasic/weaponconfig/" .. t  , "DATA" ) then
       r = file.Read( "dm_clasic/weaponconfig/" .. t , "DATA" )
    end

    if t == "" then
       r = file.Read( "dm_clasic/weaponconfig/" .. DEATHMATCH.CurrentWeaponConfig:GetString():lower() .. ".dat" , "DATA" )
    end

    local a = util.JSONToTable( r or "[]" )
    a.configs = file.Find( "dm_clasic/weaponconfig/*", "DATA" )
    a.active = DEATHMATCH.CurrentWeaponConfig:GetString()

    r = util.TableToJSON( a )

    net.Start("dm_weaponmenu", true )
    net.WriteString( r )
    net.Send( ply )
end)

net.Receive("dm_weaponconfig",function( len , ply )
    if not ply:IsAdmin() then return end
    local tbl = util.JSONToTable( net.ReadString() )
    local tosave = {}
    for i=1,12 do
       if weapons.GetStored( tbl[i] ) then
          tosave[i] = tbl[i]
       else
          print( tbl[i] .. " is not a valid weapon")
          ply:PrintMessage( 3 ,  tbl[i] .. " is not a valid weapon" )
          tosave[i] = HL2[i]
       end
    end

    tosave.name = tbl.name

    tbl.name = tbl.name:lower()
    file.Write("dm_clasic/weaponconfig/" .. tbl.name .. ".dat" , util.TableToJSON( tosave ) )
    print( "saving " .. tbl.name .. " config")
    ply:PrintMessage( 3 ,  "saving " .. tbl.name .. " config" )
end)

net.Receive("dm_setactiveconfig",function( len , ply )
    if not ply:IsAdmin() then return end
    local conf = net.ReadString()
    if file.Exists( "dm_clasic/weaponconfig/" .. conf:lower() .. ".dat" , "DATA") then
       DEATHMATCH.CurrentWeaponConfig:SetString( conf )
       return
    end
    ply:PrintMessage( 3 ,  "you must save the config before" )
end)

net.Receive("dm_deleteconfig",function( len , ply )
    if not ply:IsAdmin() then return end
    local conf = net.ReadString()
    file.Delete( "dm_clasic/weaponconfig/" .. conf:lower() )
end)

function DEATHMATCH.GetWeapons( ... )
    return util.JSONToTable( file.Read( "dm_clasic/weaponconfig/" .. DEATHMATCH.CurrentWeaponConfig:GetString():lower() .. ".dat" , "DATA" ) )
end

net.Receive("dm_spawnpoint",function( len , ply )
    if not ply:IsAdmin() then return end
    local text = net.ReadString()

    if not util.JSONToTable( text ) then
        if not file.Exists( "dm_clasic/weaponspawn/" .. game.GetMap() .. ".dat" , "DATA" ) then
           file.Write("dm_clasic/weaponspawn/" .. game.GetMap() .. ".dat", "" )
        end

        if not file.Exists( "dm_clasic/spawnpoint/" .. game.GetMap() .. ".dat" , "DATA" ) then
           file.Write("dm_clasic/spawnpoint/" .. game.GetMap() .. ".dat", "" )
        end

        net.Start("dm_spawnpoint")
        net.WriteString( file.Read( "dm_clasic/spawnpoint/" .. game.GetMap() .. ".dat" , "DATA" ) .. "///" .. file.Read( "dm_clasic/weaponspawn/" .. game.GetMap() .. ".dat" , "DATA" ) )
        net.Send( ply )
    else
        file.Write("dm_clasic/spawnpoint/" .. game.GetMap() .. ".dat", text )
    end

end)

net.Receive("dm_weaponspawn",function( len , ply )
    if not ply:IsAdmin() then return end
    local text = net.ReadString()
    file.Write("dm_clasic/weaponspawn/" .. game.GetMap() .. ".dat", text )

end)

net.Receive("dm_spawnpointgoto",function( len , ply )

    if not ply:IsAdmin() then return end

    local ang = net.ReadAngle()
    local pos = net.ReadVector()

    ply:SetPos( pos )
    ply:SetEyeAngles( ang )

end)


function DEATHMATCH.GetSpawnPoints()

    local atbl = util.JSONToTable( file.Read( "dm_clasic/spawnpoint/" .. game.GetMap() .. ".dat" , "DATA" ) or "[]" )
    local tbl = {}
    local i = 1
    for k,v in pairs(atbl) do
       tbl[i] = v
       i = i + 1
    end

    i = nil
    atbl = nil

    table.sort( tbl, function( a , b ) 

        local maxpos = 0
        local adis = 0
        local bdis = 0

        for i,v in ipairs( player.GetAll() ) do

            local dis = v:GetPos():Distance( a.pos )
            if dis > adis then
                adis = dis
            end

            local dis = v:GetPos():Distance( b.pos )
            if dis > bdis then
                bdis = dis
            end

            return adis > bdis
        end
    end)

    return tbl
end

function DEATHMATCH.GetWeaponSpawn() 
    return util.JSONToTable( file.Read( "dm_clasic/weaponspawn/" .. game.GetMap() .. ".dat" , "DATA" ) or "[]" )
end

timer.Create("dm_spawnvalid",10 , 0 ,function()

    if DEATHMATCH.GetSpawnPoints() and DEATHMATCH.GetWeaponSpawn() then
       timer.Remove("dm_spawnvalid")
    else
        if DEATHMATCH.GetWeaponSpawn() then
           PrintMessage( HUD_PRINTTALK, " weapon spawn have not been configured => dm_spawnpoint  " )
        end
        if DEATHMATCH.GetSpawnPoints() then
           PrintMessage( HUD_PRINTTALK, " player spawn have not been configured => dm_spawnpoint  " )
        end
    end
end)

local time = CurTime()
local GetWeaponSpawn = DEATHMATCH.GetWeaponSpawn()
local GetWeapons = DEATHMATCH.GetWeapons()
local Wp = {}
local Vlid = {}


function DEATHMATCH.OldGetWeapons()
    return GetWeapons
end

for k,v in pairs( player.GetAll() ) do
    v:StripWeapons()
    v:StripAmmo()
    v:UnLock()
    v:Spawn()
    v:UnLock()
    v:SetFrags( 0 )
    v:SetDeaths( 0 )
end

BroadcastLua( [[ game.Limit = false game.ShowScoreBoard() ]] )
RunConsoleCommand("gmod_admin_cleanup")

hook.Add("Think","WeaponSpawnSystem",function()

    if player.GetCount() < 0 or DEATHMATCH.Limit then return end

    for k,v in pairs( GetWeaponSpawn or {}) do
        if !IsValid( Wp[k] ) and Vlid[k] != true then
            Vlid[k] = true
            timer.Simple( math.random( 5 , 10 ) ,function()

                Wp[k] = ents.Create( GetWeapons[v.index] )
                Wp[k]:SetPos( v.pos )
                Wp[k]:Spawn()
                Wp[k]:Activate()
           
                Wp[k]:EmitSound("items/ammopickup2.wav", 75, 100, 1, CHAN_AUTO )

                Vlid[k] = false
            end)
        end
    end
end)

hook.Add( "PlayerCanPickupWeapon", "WeaponSpawnSystem", function( ply, wep )
    if ply:GetAmmoCount( wep:GetPrimaryAmmoType() ) < wep:Clip1()/2 then
        ply:GiveAmmo( wep:Clip1()*2 , wep:GetPrimaryAmmoType() , true )
    end
    return true
end )

local function RestartGame()

	GetWeaponSpawn = DEATHMATCH.GetWeaponSpawn()
    GetWeapons = DEATHMATCH.GetWeapons()

    for k,v in pairs( player.GetAll() ) do
        v:Lock()
    end
	
    DEATHMATCH.Limit = true
	
    timer.Simple( 3 ,function()
        BroadcastLua( [[ game.Limit = true game.ShowScoreBoard() ]] )
    end)
   	
    timer.Simple( 29 ,function()
        BroadcastLua( [[ game.Limit = false game.ShowScoreBoard() ]] )
        RunConsoleCommand("gmod_admin_cleanup")
    
        for k,v in pairs( player.GetAll() ) do
            v:StripWeapons()
            v:StripAmmo()
            v:UnLock()
            v:Spawn()
            v:UnLock()
            v:SetFrags( 0 )
            v:SetDeaths( 0 )
            DEATHMATCH.Limit = false
        end
    end)
	
    timer.Simple( 30 ,function()
        for k,v in pairs( player.GetAll() ) do
            v:UnLock()
        end
    end)
end


net.Receive("dm_restart",function( len , ply )

   if not ply:IsAdmin() then return end

   RestartGame()
  
end)

concommand.Add("dm_restart",function ()
	RestartGame()
end)

hook.Add( "PlayerDeath", "dm_clasic_PlayerDeath" , function( victim, inflictor, attacker )
	if attacker:Frags() + 1 > 30 then
		RestartGame()
	end
end)

hook.Add( "StartCommand", "dm_clasic_cmd" ,function( ply, cmd )
    if DEATHMATCH.Limit then
        cmd:ClearButtons()
        cmd:ClearMovement()
    end
end)

local LastSpawn = math.random( 1 , table.getn( DEATHMATCH.GetSpawnPoints() ) )
local LastTimeSpawn = CurTime()
local dec = 0

hook.Add( "PlayerSpawn", "dm_clasic_spawn" ,function( ply )

    local tbl = DEATHMATCH.GetSpawnPoints()
    if LastSpawn > table.getn( tbl ) then
        LastSpawn = 1
    end

    local v = tbl[LastSpawn]

    LastSpawn = LastSpawn + 1
    LastTimeSpawn = CurTime()
    local de = 0
    for y,p in pairs( player.GetAll() ) do
        if v.pos:Distance( p:GetPos() ) < 100  then
            de = 100
            break
        end
    end
    print( de )
  	ply:SetPos( v.pos + v.ang:Forward() * de + Vector( 0 ,0 , 1) )
  	ply:SetEyeAngles( v.ang )

    for i,v in ipairs( DEATHMATCH.OldGetWeapons() ) do
        ply:Give( v )
        if i >= 2 then break end
    end
end)

hook.Add("PlayerDeathSound","dm_clasic_DeathSound",function()
    return true
end)

print("DEATHMATCH CLASSIC" , debug.getinfo(1).source)

end)

print( os.time() )