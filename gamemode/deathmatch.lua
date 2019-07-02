
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

resource.AddWorkshop("1416249216")

RunConsoleCommand("hl1_sk_plr_dmg_crowbar","30")
RunConsoleCommand("hl1_sk_plr_dmg_9mm_bullet","24")
RunConsoleCommand("hl1_sk_plr_dmg_357_bullet","80")
RunConsoleCommand("hl1_sk_plr_dmg_buckshot","15")
RunConsoleCommand("hl1_sk_plr_dmg_mp5_bullet","15")
RunConsoleCommand("hl1_sk_plr_dmg_mp5_grenade","100")
RunConsoleCommand("hl1_sk_plr_dmg_rpg","100")
RunConsoleCommand("hl1_sk_plr_dmg_xbow_bolt_plr","30")
RunConsoleCommand("hl1_sk_plr_dmg_xbow_bolt_npc","100")
RunConsoleCommand("hl1_sk_plr_dmg_egon_wide","28")
RunConsoleCommand("hl1_sk_plr_dmg_gauss","40")
RunConsoleCommand("hl1_sk_plr_dmg_grenade","100")
RunConsoleCommand("hl1_sk_plr_dmg_hornet","21")
RunConsoleCommand("hl1_sk_plr_dmg_tripmine","150")
RunConsoleCommand("hl1_sk_plr_dmg_satchel","150")


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

    if atbl == nil then return {} end
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

    if ply:IsBot() then
        ply:SelectWeapon( wep:GetClass() )
    end
    if ply:GetAmmoCount( wep:GetPrimaryAmmoType() ) < wep:Clip1()/2 then
        ply:GiveAmmo( wep:Clip1()*2 , wep:GetPrimaryAmmoType() , true )
    end
    return true
end )

local function RestartGame()

    if DEATHMATCH.Limit == true then return end 
	GetWeaponSpawn = DEATHMATCH.GetWeaponSpawn()
    GetWeapons = DEATHMATCH.GetWeapons()

    for k,v in pairs( player.GetAll() ) do
        v:Lock()
    end
	
    DEATHMATCH.Limit = true
	
    timer.Simple( 3 ,function()
        BroadcastLua( [[ game.Limit = true game.ShowScoreBoard() ]] )
    end)
   	
    timer.Simple( 60 ,function()
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

end


net.Receive("dm_restart",function( len , ply )

   if not ply:IsAdmin() then return end

   RestartGame()
  
end)

concommand.Add("dm_restart",function ()
	RestartGame()
end)

hook.Add( "PlayerDeath", "dm_clasic_PlayerDeath" , function( victim, inflictor, attacker )
    if !attacker:IsPlayer() then
        attacker = attacker:GetOwner()
    end
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

    if not next( tbl ) then return end

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

  	ply:SetPos( v.pos + v.ang:Forward() * de + Vector( 0 ,0 , de/3) )
  	ply:SetEyeAngles( v.ang )

    for i,v in ipairs( DEATHMATCH.OldGetWeapons() ) do
        ply:Give( v )
        if i >= 2 then
            ply:SelectWeapon( i )
            break 
        end
    end

    
end)

hook.Add("PlayerDeathSound","dm_clasic_DeathSound",function()
    return true
    
end)


print("DEATHMATCH CLASSIC" , debug.getinfo(1).source)

end)

local function IsVisibleOnScreen( user , ent )

    if ent:GetPos():Distance( user:GetPos() ) < 30 then
        return true
    end

    local pos

    if ent:IsPlayer() then
        pos = ent:LocalToWorld(ent:OBBCenter())
    else
        pos = ent:GetPos() + Vector( 0 , 0 , 1)
    end
    local trace = {
        start = user:EyePos(),
        endpos = pos + Vector( 0 , 0 , 0),
        filter = {ply , user},
        mask = MASK_SHOT,
    };

    if (util.TraceLine(trace).Fraction == 1 ) then
        return true;
    end

    return util.QuickTrace( user:EyePos() - user:GetForward()*1 , pos , user ).Entity == ent
end

local WantedWeapon = {}

local BlacklistWeapon = {}

local Velocity = {}

local Targets = {}

local lastActivity = {}

local Focus = {}

local function Iscarried( weapon )
    for k,u in pairs(player.GetAll()) do
        for k,u in pairs(u:GetWeapons() ) do
            if weapon:EntIndex() == u:EntIndex() then
                return true
            end
        end
    end
    return false
end


local function GetOBBCenter(ply)
    return ply:LocalToWorld(ply:OBBCenter())
end

local function GetCenter(v)
    local bonepos = v.GetBonePosition( v , 0)
    if(!bonepos) then return GetOBBCenter(v) end
    return bonepos
end

local function GetHeadPos(v)
    local head = v.GetHitBoxBone( v , 0 , 0)
    if(!head or math.random( 0, 10 ) == 10 ) then return GetCenter(v); end
    local min, max = v.GetHitBoxBounds( v , 0 , 0)
    local bonepos = v.GetBonePosition( v , head )
    return (bonepos + ((min + max) / 2))
end

local function GetActivity( ply , tbl , bool )

    local wmin = 10^10
    local ent

     for k, v in pairs( tbl ) do

        local pos = v:GetPos():Distance( ply:GetPos() )

        if v:IsWeapon() then
            if not Iscarried( v ) then
                if wmin > pos and pos != 0 and !table.HasValue( BlacklistWeapon[ ply ] or {} , v ) and IsVisibleOnScreen( ply , v ) then
                    wmin = pos
                    ent = v
                end
            end
        end
        if v:IsPlayer() and not bool then
            if v:Alive() then
                if wmin > pos and pos != 0 and IsVisibleOnScreen( ply , v ) then
                    wmin = pos
                    ent = v
                end
            end
        end
        

        if wmin < 100 then
            ent = v
            break
        end
    end

    return ent
end

local function BotAttack( ply , cmd , victim )
    Focus[ ply ] = 100
    lastActivity[ ply ] = 10
    cmd:SetViewAngles( (GetHeadPos( victim  ) - ply:GetShootPos()):Angle() + Angle( math.random( -0.0001 , 0.0001 ), math.random( -0.0001 , 0.0001 ) , 0 ) )
    cmd:SetForwardMove( ply:GetRunSpeed() )
    cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_SPEED ) )

    cmd:SetForwardMove( 0 )
    cmd:SetSideMove( math.random(  ply:GetRunSpeed()*-1 , ply:GetRunSpeed() ) )
    
    if IsValid( ply:GetActiveWeapon() ) then

        if ply:GetActiveWeapon():GetNextPrimaryFire() < CurTime() then
            cmd:SetButtons( IN_ATTACK )
        else
            cmd:RemoveKey( IN_ATTACK )
            cmd:RemoveKey( IN_RELOAD )
        end

        if ply:GetActiveWeapon():GetNextSecondaryFire() < CurTime() and math.random( 0 , 500 ) == 500 then
            cmd:SetButtons( IN_ATTACK2 )
        else
            cmd:RemoveKey( IN_ATTACK2 )
        end

    end
end

local function GetAmmo( ply , wp )
    if ( !IsValid( ply ) ) then return -1 end

    local wep = wp
    if ( !IsValid( wep ) ) then return -1 end
    if ply:GetAmmoCount( wep:GetPrimaryAmmoType() ) == -1 then
        return 1
    end
    return ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
end

local function NeedAmmo( ply , wp )
    if !IsValid( wp ) then return false end

    if wp:GetNextPrimaryFire() < CurTime() + 1 and wp:Clip1() == 0 then
        return true
    end

end

local function FixMovement(cmd , ang )

    local vec = G.Vector( _R["CUserCmd"].GetForwardMove( cmd ) , _R["CUserCmd"].GetSideMove( cmd ), 0)
    local vel = G.math.sqrt(vec.x*vec.x + vec.y*vec.y)
    local mang = _R["Vector"].Angle( vec )
    local yaw 

    yaw = _R["CUserCmd"].GetViewAngles( cmd ).y - ang.y + mang.y

    if ((_R["CUserCmd"].GetViewAngles( cmd ).p+90)%360) > 180 then
        yaw = 180 - yaw
    end

    yaw = ((yaw + 180)%360)-180
    _R["CUserCmd"].SetForwardMove( cmd , math.cos(math.rad(yaw)) * vel ) -- cmd:SetForwardMove(math.cos(math.rad(yaw)) * vel)
    _R["CUserCmd"].SetSideMove( cmd , math.sin(math.rad(yaw)) * vel ) --cmd:SetSideMove(math.sin(math.rad(yaw)) * vel)

end


hook.Add( "StartCommand", "dm_clasic_bot_AI", function( ply, cmd )
    
    if not ply:IsBot() then return end

    cmd:ClearMovement()
    cmd:ClearButtons()

    if not Velocity[ ply ] then
        Velocity[ ply ] = 600
        lastActivity[ ply ] = 1
        BlacklistWeapon[ ply ] = {}
        Focus[ ply ] = 0
    end

    cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_SPEED ) )

    if math.random( 0 , 500 ) == 500 then
        cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_JUMP ) )
        cmd:SetUpMove( 10000 )
    end

    if !ply:Alive() then
        cmd:RemoveKey( IN_ATTACK )
        cmd:RemoveKey( IN_ATTACK2 )        
        BlacklistWeapon[ ply ] = {}
        WantedWeapon[ ply ] = nil
        Targets[ ply ] = nil
        lastActivity[ ply ] = 0
    end

    

    if Focus[ ply ] > 0 then
        Focus[ ply ] = Focus[ ply ] -1
    end

    if IsValid( Targets[ ply ] ) then
        if !Targets[ ply ]:Alive() then
            Targets[ ply ] = nil
        end
    else
        Targets[ ply ] = nil
    end

    local ent = Targets[ ply ]

    if !IsValid( ent ) then
        ent = GetActivity( ply , player.GetAll() )
    else
        if !ent:Alive() or ply:GetPos():Distance( ent:GetPos()) > 700 or not IsVisibleOnScreen( ply , ent ) then
            ent = GetActivity( ply , player.GetAll() )

            if Focus[ ply ] < 10 then
                ent = nil
            end
        end
    end

    local wp = ply:GetActiveWeapon()
    for k,v in pairs( ply:GetWeapons() ) do
        if GetAmmo( ply , v ) >= GetAmmo( ply , wp ) then
            wp = v
        end
    end

    if IsValid( wp ) then
        cmd:SelectWeapon( wp )    
    end

    if NeedAmmo( ply , ply:GetActiveWeapon() ) then
        ent = nil
    end

    if ent then
        if ent:GetPos():Distance( ply:GetPos() ) < 2000 then
            BotAttack( ply , cmd , ent )
            Velocity[ ply ] = ply:GetVelocity():Length()
            Targets[ ply ] = ent
            return
        end
    end

    local ent2 = WantedWeapon[ ply ]

    if IsValid( WantedWeapon[ ply ] ) and !table.HasValue( BlacklistWeapon[ ply ] or {} , WantedWeapon[ ply ] ) and !Iscarried( WantedWeapon[ ply ] ) then
        ent2 = WantedWeapon[ ply ]
    else
        ent2 = GetActivity( ply , ents.GetAll() , true )
    end

    if IsValid( ent2 ) and NeedAmmo( ply , ply:GetActiveWeapon() ) or !IsValid( ent ) and IsValid( ent2 ) and Focus[ ply ] < 10 then
        if ply:GetVelocity():Length() < 100 and Velocity[ ply ] < 100 then
            BlacklistWeapon[ ply ] = BlacklistWeapon[ ply ] or {}
            BlacklistWeapon[ ply ][table.getn(BlacklistWeapon) + 1] = ent2
        else

            local t
            if Targets[ ply ] then
                if Focus[ ply ] < 10 and IsVisibleOnScreen( ply , Targets[ ply ] ) then
                    t = Targets[ ply ] 
                end
            end

            WantedWeapon[ ply ] = ent2
            if not t then
                t = ent2
            end
            cmd:SetViewAngles( ( GetHeadPos( t ) - ply:GetShootPos()):Angle() )

            cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_FORWARD ) )
            cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_SPEED ) )
            Velocity[ ply ] = ply:GetVelocity():Length()

            local vec = Vector( ply:GetRunSpeed() , 0 , 0)
            local vel = math.sqrt(vec.x*vec.x + vec.y*vec.y)
            local mang = vec:Angle()
            local yaw 

            yaw = cmd:GetViewAngles().y - (ent2:GetPos() - ply:GetShootPos()):Angle().y + mang.y

            if ((cmd:GetViewAngles().p+90)%360) > 180 then
                yaw = 180 - yaw
            end

            yaw = ((yaw + 180)%360)-180
            cmd:SetForwardMove(math.cos(math.rad(yaw)) * vel)
            cmd:SetSideMove(math.sin(math.rad(yaw)) * vel)

            return
        end
    end

    if ent then
        BotAttack( ply , cmd , ent )
        Targets[ ply ] = ent
        Velocity[ ply ] = ply:GetVelocity():Length()
        return
    end

    if IsValid( Targets[ ply ] ) then
        BotAttack( ply , cmd , Targets[ ply ] )
    end
    

    if lastActivity[ ply ]  < 0 then
        cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_FORWARD ) )
        cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_SPEED ) )
        cmd:SetForwardMove( ply:GetRunSpeed() )
    end

    if ply:IsOnGround() and Focus[ ply ] < 2 and ply:GetVelocity():Length() > ply:GetRunSpeed()*1.2 then
        cmd:SetButtons(bit.bor( cmd:GetButtons() , IN_JUMP ) )
    end

    lastActivity[ ply ] = lastActivity[ ply ] - 1

    if Velocity[ ply ] == -10 and ply:GetVelocity():Length() < 1 and ply:Alive() then
        ply:KillSilent()
    end
    Velocity[ ply ] = ply:GetVelocity():Length()
    if Velocity[ ply ] < 1 and ply:GetVelocity():Length() < 1 then
        Velocity[ ply ] = Velocity[ ply ] -1
    end

    if ply:GetEyeTrace().HitPos:Distance( ply:GetShootPos() ) < 100 then
        cmd:SetViewAngles( Angle(0 , 0 + CurTime()*math.random( 0 , 30 ) , 0) )
        cmd:SetForwardMove( 0 )
        return
    end
    
    --if math.random( 0 , 500 ) == 500 then
    --    cmd:SetViewAngles( Angle( math.random( -180 , 180 ) , math.random( -180 , 180 ) , 0 ) )
    --end

    return

end )