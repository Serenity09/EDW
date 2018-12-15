library MazingCollision initializer Init requires MazerGlobals, DummyCaster

globals
    //private timer tc
    private unit CollidingMazer
    private group NearbyUnits = CreateGroup()
    private boolean array IsNotColliding[NumberPlayers]
    private unit array LastCollidedUnit[NumberPlayers]
    
    private constant real COLLISION_TIME = 1.0000
    private constant real REVIVE_PAUSE_TIME = 1.0000
    
    private constant real MAIN_TIMESTEP = .05
    private constant real P2P_TIMESTEP = .15
    
    
    //should be slightly more than CollisLrgRadius to be less buggy
    constant real CollisMaxRadius = 137.00
    
    //right now this also means the collision size for revive circles, since that's the only things its used for. will need to modify P2PCollisionIter and provide sizes for the different unitIds
    constant real P2P_MAX_COLLISION_SIZE = 90
    constant real P2P_REVIVE_PAUSE_TIME = 2
    
    //used to group units of similar sizes together
    constant real CollisSmlRadius = 45.00
    constant real CollisMedRadius = 80.00
    constant real CollisLrgRadius = 135.00
    
    private constant real COLLISION_RADIUS_BUFFER = 5
    private constant real COLLISION_SMALL_TIMESTEP = .075
    private constant real COLLISION_MEDIUM_TIMESTEP = .15
    private constant real COLLISION_LARGE_TIMESTEP = .25
endglobals

private function AfterCollisionCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    set IsNotColliding[pID] = true
    set LastCollidedUnit[pID] = null
    
    call ReleaseTimer(t)
    set t = null
endfunction

private function CollisionSmallIter takes nothing returns nothing
    local unit mu = GetEnumUnit()
    local unit cu
    
    local integer pID = GetPlayerId(GetOwningPlayer(mu))
    
    local integer cuTypeID
    
    local real dx
    local real dy
    local real dist
    
    call GroupEnumUnitsInRange(NearbyUnits, GetUnitX(mu), GetUnitY(mu), CollisSmlRadius + COLLISION_RADIUS_BUFFER, GreenOrBrown)
    
    set cu = FirstOfGroup(NearbyUnits)
    loop
    exitwhen cu == null
        //check that we aren't currently colliding with a unit or that this is a different unit entirely
        if IsNotColliding[pID] or LastCollidedUnit[pID] != cu then
            set cuTypeID = GetUnitTypeId(cu)
        
            //computes the distance between the mazer and the colliding unit
            set dx = GetUnitX(mu) - GetUnitX(cu)
            set dy = GetUnitY(mu) - GetUnitY(cu)
            set dist = SquareRoot(dx * dx + dy * dy)
            
            if dist < 39 and (cuTypeID == GUARD or cuTypeID == LGUARD) and not MobImmune[pID] then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == WWWISP and dist < 40 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == WWSKUL and dist < 42 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == REGRET and dist < 43 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            endif
        endif
        
    call GroupRemoveUnit(NearbyUnits, cu)
    set cu = FirstOfGroup(NearbyUnits)
    endloop
    
    call GroupClear(NearbyUnits)
        
    set mu = null
    set cu = null
endfunction

public function CollisionSmallIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    call ForGroup(MazersGroup, function CollisionSmallIter)
endfunction

private function CollisionMediumIter takes nothing returns nothing
    local unit mu = GetEnumUnit()
    local unit cu
    
    local integer pID = GetPlayerId(GetOwningPlayer(mu))
    
    local integer cuTypeID
    
    local real dx
    local real dy
    local real dist
    
    call GroupEnumUnitsInRange(NearbyUnits, GetUnitX(mu), GetUnitY(mu), CollisMedRadius + COLLISION_RADIUS_BUFFER, GreenOrBrown)
    
    set cu = FirstOfGroup(NearbyUnits)
    loop
    exitwhen cu == null
        //check that we aren't currently colliding with a unit or that this is a different unit entirely
        if IsNotColliding[pID] or LastCollidedUnit[pID] != cu then
            set cuTypeID = GetUnitTypeId(cu)
        
            //computes the distance between the mazer and the colliding unit
            set dx = GetUnitX(mu) - GetUnitX(cu)
            set dy = GetUnitY(mu) - GetUnitY(cu)
            set dist = SquareRoot(dx*dx + dy*dy)
        
            if cuTypeID == LMEMORY and dist < 57 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == ROGTHT and dist < 55 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == ICETROLL and dist < 60 and not MobImmune[pID] then  //TERRAIN_QUADRANT_SIZE - 4
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif InWorldPowerup.IsPowerupUnit(cuTypeID) and dist < 65 then
                set IsNotColliding[pID] = false
                set LastCollidedUnit[pID] = cu
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with powerup")
                call InWorldPowerup.GetFromUnit(cu).OnUserAcquire(pID)
                
                call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished colliding")
                set mu = null
                set cu = null
                return
            //keys and doors
            elseif dist < 80 and cuTypeID == RFIRE then
                if (MazerColor[pID] != KEY_RED) then
                    call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                else
                    set IsNotColliding[pID] = false
                    set LastCollidedUnit[pID] = cu
                    
                    call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                endif
                
                set mu = null
                set cu = null
                return
            elseif dist < 65 and cuTypeID == RKEY then
                set IsNotColliding[pID] = false
                set LastCollidedUnit[pID] = cu
                
                call RShieldEffect(mu)
                set MazerColor[pID] = KEY_RED
                call SetUnitVertexColor(mu, 255, 0, 0, 255)
                
                call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                
                set mu = null
                set cu = null
                return
            elseif dist < 80 and cuTypeID == BFIRE then
                if (MazerColor[pID] != KEY_BLUE) then
                    call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                else
                    set IsNotColliding[pID] = false
                    set LastCollidedUnit[pID] = cu
                    
                    call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                endif
                
                set mu = null
                set cu = null
                return
            elseif dist < 65 and cuTypeID == BKEY then
                set IsNotColliding[pID] = false
                set LastCollidedUnit[pID] = cu
                
                call BShieldEffect(mu)
                set MazerColor[pID] = KEY_BLUE
                call SetUnitVertexColor(mu, 0, 0, 255, 255)
                
                call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                
                set mu = null
                set cu = null
                return
            elseif dist < 80 and cuTypeID == GFIRE then
                if (MazerColor[pID] != KEY_GREEN) then
                    call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                else
                    set IsNotColliding[pID] = false
                    set LastCollidedUnit[pID] = cu
                    
                    call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                endif
                set mu = null
                set cu = null
                return
            elseif dist < 65 and cuTypeID == GKEY then
                set IsNotColliding[pID] = false
                set LastCollidedUnit[pID] = cu
                
                call GShieldEffect(mu)
                set MazerColor[pID] = KEY_GREEN
                call SetUnitVertexColor(mu, 0, 255, 0, 255)
                
                call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                
                set mu = null
                set cu = null
                return
            endif
        endif
        
    call GroupRemoveUnit(NearbyUnits, cu)
    set cu = FirstOfGroup(NearbyUnits)
    endloop
    
    call GroupClear(NearbyUnits)
        
    set mu = null
    set cu = null
endfunction

public function CollisionMediumIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    call ForGroup(MazersGroup, function CollisionMediumIter)
endfunction

private function CollisionLargeIter takes nothing returns nothing
    local unit mu = GetEnumUnit()
    local unit cu
    
    local integer pID = GetPlayerId(GetOwningPlayer(mu))
    
    local integer cuTypeID
    
    local real dx
    local real dy
    local real dist
    
    call GroupEnumUnitsInRange(NearbyUnits, GetUnitX(mu), GetUnitY(mu), CollisLrgRadius + COLLISION_RADIUS_BUFFER, GreenOrBrown)
    
    set cu = FirstOfGroup(NearbyUnits)
    loop
    exitwhen cu == null
        //check that we aren't currently colliding with a unit or that this is a different unit entirely
        if IsNotColliding[pID] or LastCollidedUnit[pID] != cu then
            set cuTypeID = GetUnitTypeId(cu)
        
            //computes the distance between the mazer and the colliding unit
            set dx = GetUnitX(mu) - GetUnitX(cu)
            set dy = GetUnitY(mu) - GetUnitY(cu)
            set dist = SquareRoot(dx*dx + dy*dy)
        
            if cuTypeID == GUILT and dist < 120 then
                call CollisionDeathEffect(mu)
                
                call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
                set mu = null
                set cu = null
                return
            elseif cuTypeID == KEYR and dist < 125 then
                set IsNotColliding[pID] = false
                set LastCollidedUnit[pID] = cu
                
                call ShieldRemoveEffect(mu)
                set MazerColor[pID] = KEY_NONE
                call SetUnitVertexColor(mu, 255, 255, 255, 255)
                
                call TimerStart(NewTimerEx(pID), COLLISION_TIME, false, function AfterCollisionCB)
                
                set mu = null
                set cu = null
                return
            endif
        endif
        
    call GroupRemoveUnit(NearbyUnits, cu)
    set cu = FirstOfGroup(NearbyUnits)
    endloop
    
    call GroupClear(NearbyUnits)
        
    set mu = null
    set cu = null
endfunction

public function CollisionLargeIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    call ForGroup(MazersGroup, function CollisionLargeIter)
endfunction

private function AfterMazerInvulnCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    //check that the unit is still standard
    if User(pID).GameMode == Teams_GAMEMODE_STANDARD then
        call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
    endif
    
    set MobImmune[pID] = false
    set CanReviveOthers[pID] = true
    
    set t = null
endfunction

private function AfterMazerReviveCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    //check that the unit is still paused
    if User(pID).GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
        call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
    endif
    
    //set immune for 1 sec and create effect
    call DummyCaster['A006'].castTarget(Player(pID), 1, OrderId("bloodlust"), User(pID).ActiveUnit)
    set MobImmune[pID] = true
    set CanReviveOthers[pID] = false
    
    call TimerStart(t, P2P_REVIVE_PAUSE_TIME, false, function AfterMazerInvulnCB)
    set t = null
endfunction

private function P2PCollisionIter takes nothing returns nothing
    local unit mu = CollidingMazer
    local unit cu = GetEnumUnit()
    
    local integer pID = GetPlayerId(GetOwningPlayer(mu))
    
    local integer cuID = GetUnitTypeId(cu)
    local integer cuPID = GetPlayerId(GetOwningPlayer(cu))
    
    //computes the distance between the mazer and the colliding unit
    //local real dx = GetUnitX(mu) - GetUnitX(cu)
    //local real dy = GetUnitY(mu) - GetUnitY(cu)
    //local real dist = SquareRoot(dx * dx + dy * dy)
    
    //only thing is revive beacon, so just use the max collis size
    //if cuID == TEAM_REVIVE_UNIT_ID and dist < 90 then
    if cuID == TEAM_REVIVE_UNIT_ID then        
        //colliding mazer will always be in standard gamemode because this collision loop only checks that group
        //currently you will revive anyone whose circle you hit, this may change how you play
        if CanReviveOthers[pID] and User(pID).GameMode == Teams_GAMEMODE_STANDARD then            
            //revive unit at position of mazer to avoid reviving in an illegal position
            call User(cuPID).SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, GetUnitX(mu), GetUnitY(mu))
            call SetDefaultCameraForPlayer(cuPID, .5)
            
            call TimerStart(NewTimerEx(cuPID), P2P_REVIVE_PAUSE_TIME, false, function AfterMazerReviveCB)
        else
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Non standard unit inside standard collision")
        endif
        
        set mu = null
        set cu = null
        return
    endif
    
    set mu = null
    set cu = null
endfunction

private function CollisionP2PIter takes nothing returns nothing
    local unit u = GetEnumUnit()
    
    call GroupEnumUnitsInRange(NearbyUnits, GetUnitX(u), GetUnitY(u), P2P_MAX_COLLISION_SIZE, PlayerOwned)
    set CollidingMazer = u
    call ForGroup(NearbyUnits, function P2PCollisionIter)
    call GroupClear(NearbyUnits)
    
    set u = null
endfunction

public function CollisionP2PIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    call ForGroup(MazersGroup, function CollisionP2PIter)
endfunction

private function CollisionBlackhole takes nothing returns nothing
    local unit mu = CollidingMazer
    local unit cu = GetEnumUnit()
    
    local integer pID = GetPlayerId(GetOwningPlayer(mu))
    
    local integer cuID = GetUnitTypeId(cu)
    
    local Blackhole blackhole
    
    if cuID == BLACKHOLE then
        //get blackhole struct
        set blackhole = Blackhole.GetActiveBlackholeFromUnit(cu)
        
        if blackhole != 0 then
            //add unit to blackhole watch list
            call blackhole.WatchPlayer(pID)
        endif
        
        
    endif
endfunction

private function CollisionBlackholeIter takes nothing returns nothing
    local unit u = GetEnumUnit()
    
    call GroupEnumUnitsInRange(NearbyUnits, GetUnitX(u), GetUnitY(u), BLACKHOLE_MAXRADIUS, GreenOrBrown)
    set CollidingMazer = u
    call ForGroup(NearbyUnits, function CollisionBlackhole)
    call GroupClear(NearbyUnits)
    
    set u = null
endfunction

public function CollisionBlackholeIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    call ForGroup(MazersGroup, function CollisionBlackholeIter)
endfunction

//===========================================================================

private function Init takes nothing returns nothing
    //set tc = CreateTimer()
    //call TimerStart(tc, TIMESTEP, true, function CollisionIterInit)
    call TimerStart(CreateTimer(), COLLISION_SMALL_TIMESTEP, true, function CollisionSmallIterInit)
    call TimerStart(CreateTimer(), COLLISION_MEDIUM_TIMESTEP, true, function CollisionMediumIterInit)
    call TimerStart(CreateTimer(), COLLISION_LARGE_TIMESTEP, true, function CollisionLargeIterInit)
    call TimerStart(CreateTimer(), P2P_TIMESTEP, true, function CollisionP2PIterInit)
    call TimerStart(CreateTimer(), BLACKHOLE_TIMESTEP, true, function CollisionBlackholeIterInit)
endfunction

endlibrary