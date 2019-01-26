library PlatformingCollision initializer Init requires TimerUtils, GameGlobalConstants, Recycle, Effects, RespawningUnit
globals
    Platformer CollidingPlatformer
    group pCollisionGroup = CreateGroup()
    group pNearbyUnits = CreateGroup()
    unit array pLastCollisionUnit[NumberPlayers]
    
    public timer CollisionTimer
    constant real PLATFORMING_COLLISION_TIMEOUT = .1
endglobals

private function IsCollidingCallback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer i = GetTimerData(t)
    
    set pLastCollisionUnit[i] = null
    
    call ReleaseTimer(t)
    set t = null
endfunction

private function AfterInvulnCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
        
    set MobImmune[pID] = false
    set CanReviveOthers[pID] = true
    
	call ReleaseTimer(t)
    set t = null
endfunction
private function AfterPlatformerReviveCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
	//check that the unit is still plat paused
    if User(pID).GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
        call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
    endif
    
	//set immune for 1 sec and create effect
    call DummyCaster['A006'].castTarget(Player(pID), 1, OrderId("bloodlust"), User(pID).ActiveUnit)
	set MobImmune[pID] = true
    set CanReviveOthers[pID] = false
	
    call TimerStart(t, P2P_REVIVE_PAUSE_TIME, false, function AfterInvulnCB)
    set t = null
endfunction

private function PlayerCollision takes nothing returns nothing
    //local unit Platformer = CollidingPlatformer
    local unit cu = GetEnumUnit()
    
    local integer pID = GetPlayerId(GetOwningPlayer(CollidingPlatformer.Unit))
    
    local integer cuID = GetUnitTypeId(cu)
    local integer cuPID
    
    //computes the distance between the mazer and the colliding unit
    //local real dx = GetUnitX(mu) - GetUnitX(cu)
    //local real dy = GetUnitY(mu) - GetUnitY(cu)
    //local real dist = SquareRoot(dx * dx + dy * dy)
    
    //if cuID == TEAM_REVIVE_UNIT_ID and dist < 90 then
    if pLastCollisionUnit[pID] != cu and cuID == TEAM_REVIVE_UNIT_ID then
        //colliding mazer will always be in platforming gamemode because this collision loop only checks that group
        if User(pID).GameMode == Teams_GAMEMODE_PLATFORMING then
            set cuPID = GetPlayerId(GetOwningPlayer(cu))
            
            //safety check, this should never actually come up
            if cuPID != pID and CanReviveOthers[pID] then
                //revive unit at position of mazer to avoid reviving in an illegal position
                call User(cuPID).SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, CollidingPlatformer.XPosition, CollidingPlatformer.YPosition)
                call TimerStart(NewTimerEx(cuPID), P2P_REVIVE_PAUSE_TIME, false, function AfterPlatformerReviveCB)
static if DEBUG_MODE then
            else
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Platformer colliding with own revive circle")
endif
            endif
            //camera enforced by setting gamemode to platforming -- which always has a single static camera active and can be safely assumed to be set when mode is switched
        else
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Non platformer unit inside platforming collision")
        endif
        
        set cu = null
        return
    endif
    
    set cu = null
endfunction

private function CollisionIter2 takes nothing returns nothing
    local Platformer p = CollidingPlatformer
    local unit pu
    local unit cu = GetEnumUnit()
    local integer i = p.PID
    local timer t
    local AutoRespawningUnit wtr
    
    local integer cuID
    
    //computes the distance between the mazer and the colliding unit
    local real dx
    local real dy
    local real dist
        
    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "unit is distance: " + R2S(dist))
        
    if pLastCollisionUnit[i] != cu then
        set pu = p.Unit
        set cuID = GetUnitTypeId(cu)
        
        //set dx = GetUnitX(pu) - GetUnitX(cu)
        //set dy = GetUnitY(pu) - GetUnitY(cu)
        
        set dx = p.XPosition - GetUnitX(cu)
        set dy = p.YPosition - GetUnitY(cu)
        
        set dist = SquareRoot(dx * dx + dy * dy)
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "unit is distance: " + R2S(dist))
        if dist <= CollisSmlRadius then //CollisSmlRadius == 45
            if cuID == WWWISP and dist < 40 and not MobImmune[p.PID] then                
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == WWSKUL and dist < 42 and not MobImmune[p.PID] then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif (cuID == GUARD or cuID == LGUARD) and dist < 36 and not MobImmune[p.PID] then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == REGRET and dist < 43 then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            endif 
        endif
        
        if dist <= CollisMedRadius then //CollisMedRadius == 80
            if cuID == GRAVITY and dist < 60 then
                if p.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY) != 0 then
                    set p.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value = -1 * p.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value 
                else
                    call p.GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY, -1)
                endif
                set p.GravitationalAccel = p.GravityEquation.calculateAdjustedValue(p.BaseProfile.GravitationalAccel)
                //set p.GravitationalAccel = -1 * p.GravitationalAccel
                set p.YVelocity = 0
                
                set pLastCollisionUnit[i] = cu
                set t = NewTimerEx(i)
                call TimerStart(t, .6, false, function IsCollidingCallback)
                
                set t = null
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == BOUNCER and dist < 55 then
                if p.GravitationalAccel >= 0 then
                    if p.YVelocity > 0 then
                        set p.YVelocity = -BOUNCER_SPEED
                    else
                        if p.YVelocity > BOUNCER_MAX_SPEED and p.YVelocity - BOUNCER_SPEED <= -BOUNCER_MAX_SPEED then
                            set p.YVelocity = -BOUNCER_MAX_SPEED
                        else
                            set p.YVelocity = p.YVelocity - BOUNCER_SPEED
                        endif
                    endif
                else
                    if p.YVelocity < 0 then
                        set p.YVelocity = BOUNCER_SPEED
                    else
                        if p.YVelocity < BOUNCER_MAX_SPEED and p.YVelocity + BOUNCER_SPEED >= BOUNCER_MAX_SPEED then
                            set p.YVelocity = BOUNCER_MAX_SPEED
                        else
                            set p.YVelocity = p.YVelocity + BOUNCER_SPEED
                        endif
                    endif
                endif
                
                set pLastCollisionUnit[i] = cu
                set t = NewTimerEx(i)
                call TimerStart(t, .1, false, function IsCollidingCallback)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == UBOUNCE and dist < 50 then
                set p.YVelocity = p.YVelocity + DIR_BOUNCER_SPEED
                                
                set wtr = AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), UBOUNCE, 90, DIR_BOUNCER_RESPAWN_TIME)
                call Recycle_ReleaseUnit(cu)

                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == RBOUNCE and dist < 50 then
                set p.XVelocity = p.XVelocity + DIR_BOUNCER_SPEED
                
                set wtr = AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), RBOUNCE, 0, DIR_BOUNCER_RESPAWN_TIME)
                call Recycle_ReleaseUnit(cu)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == DBOUNCE and dist < 50 then
                set p.YVelocity = p.YVelocity - DIR_BOUNCER_SPEED
                
                set wtr = AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), DBOUNCE, 270, DIR_BOUNCER_RESPAWN_TIME)
                call Recycle_ReleaseUnit(cu)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == LBOUNCE and dist < 46 then
                set p.XVelocity = p.XVelocity - DIR_BOUNCER_SPEED
                                
                set wtr = AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), LBOUNCE, 180, DIR_BOUNCER_RESPAWN_TIME)
                call Recycle_ReleaseUnit(cu)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == ICETROLL and dist < 54 and not MobImmune[p.PID] then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
			elseif cuID == SPIRITWALKER and dist < 56 and not MobImmune[p.PID] then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
			elseif InWorldPowerup.IsPowerupUnit(cuID) and dist < 65 then
				set pLastCollisionUnit[p.PID] = cu
				
				call InWorldPowerup.GetFromUnit(cu).OnUserAcquire(p.PID)
                
				//no need to clear last collision unit from powerup, will never be able to interact with it again anyways
                //call TimerStart(NewTimerEx(p.PID), COLLISION_TIME, false, function IsCollidingCallback)
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished colliding")
                set pu = null
                set cu = null
                return
			elseif cuID == CLAWMAN and dist < 64 and not MobImmune[p.PID] then
				call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == RKEY and dist < 65  then
                call RShieldEffect(pu)
                set MazerColor[i] = KEY_RED
                call SetUnitVertexColor(MazersArray[i], 255, 0, 0, 255)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == BKEY and dist < 65  then
                call BShieldEffect(pu)
                set MazerColor[i] = KEY_BLUE
                call SetUnitVertexColor(MazersArray[i], 0, 0, 255, 255)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == GKEY and dist < 65 then
                call GShieldEffect(pu)
                set MazerColor[i] = KEY_GREEN
                call SetUnitVertexColor(MazersArray[i], 0, 255, 0, 255)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            endif
        endif
        
        if dist < CollisLrgRadius then
            if cuID == SUPERSPEED and dist < 100 then
                //repurpose var for angle
                set dx = GetUnitFacing(cu) / 180 * bj_PI
                set p.XVelocity = SUPERSPEED_SPEED * Cos(dx)
                set p.YVelocity = SUPERSPEED_SPEED * Sin(dx)
                
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "unit is angle: " + R2S(dx))
                
                set pLastCollisionUnit[i] = cu
                set t = NewTimerEx(i)
                call TimerStart(t, .1, false, function IsCollidingCallback)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == GUILT and dist < 120 then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == KEYR and dist < 125 then
                call ShieldRemoveEffect(pu)
                set MazerColor[i] = KEY_NONE
                call SetUnitVertexColor(MazersArray[i], 255, 255, 255, 255)
                
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            endif
        endif
    endif
    
    set pu = null
    set cu = null
endfunction

private function CollisionIter takes Platformer p returns nothing    
    call GroupEnumUnitsInRange(pNearbyUnits, p.XPosition, p.YPosition, CollisMaxRadius, GreenOrBrown)
    set CollidingPlatformer = p
    call ForGroup(pNearbyUnits, function CollisionIter2)
    call GroupClear(pNearbyUnits)
    
    call GroupEnumUnitsInRange(pNearbyUnits, p.XPosition, p.YPosition, CollisMaxRadius, PlayerOwned)
    set CollidingPlatformer = p
    call ForGroup(pNearbyUnits, function PlayerCollision)
    call GroupClear(pNearbyUnits)
endfunction

public function CollisionIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    //call ForGroup(KeyPressActions_ArrowKeyGroup, function pCollisionIter)
    
    local SimpleList_ListNode curPlatformer = Platformer.ActivePlatformers.first
    
    loop
    exitwhen curPlatformer == 0
        call CollisionIter(Platformer(curPlatformer.value))
    set curPlatformer = curPlatformer.next
    endloop
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local integer i = 0
    
    set CollisionTimer = CreateTimer()
    
    //Now handled in Platformer -- paused when no one is platforming, active when >0 are
    //call TimerStart(CollisionTimer, PLATFORMING_COLLISION_TIMEOUT, true, function CollisionIterInit)
    //call TimerStart(BlackholeTimer, BLACKHOLE_TIMESTEP, true, function CollisionBlackholeIterInit)
    
    loop
        set pLastCollisionUnit[i] = null
        
        set i = i + 1
        exitwhen i >= NumberPlayers
    endloop
endfunction
endlibrary
