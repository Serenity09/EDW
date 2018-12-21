library PlatformingCollision initializer Init requires TimerUtils, GameGlobalConstants, Recycle, Effects
globals
    Platformer CollidingPlatformer
    group pCollisionGroup = CreateGroup()
    group pNearbyUnits = CreateGroup()
    unit array pLastCollisionUnit[NumberPlayers]
    
    public timer CollisionTimer
    constant real PLATFORMING_COLLISION_TIMEOUT = .1
    
    public timer BlackholeTimer
endglobals

private function IsCollidingCallback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer i = GetTimerData(t)
    
    set pLastCollisionUnit[i] = null
    
    call ReleaseTimer(t)
    set t = null
endfunction

private struct WaitingToRespawn
    private real x
    private real y
    private integer uID
    private real facing 
    //in degrees
    //special values: {-1: random direction out of up,right,down,left, -2: random direction out of diagonals, }
    
    public static method callback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype wtr = thistype(GetTimerData(t))
        local real direction
        local unit u
        
        if wtr.facing >= 0 then
            set direction = wtr.facing
        else
            if wtr.facing == -1 then
                set direction = GetRandomInt(0, 3) * 90
            elseif wtr.facing == -2 then
                set direction = GetRandomInt(0, 3) * 90 + 45
            else
                set direction = 0
            endif
        endif
        
        //call Recycle_MakeAndPatrol(wtr.uID, wtr.x, wtr.y, wtr.x + 20, wtr.y + 20)
        call Recycle_MakeUnitWithFacing(wtr.uID, wtr.x, wtr.y, direction)
        //set u = CreateUnit(Player(10), wtr.uID, wtr.x, wtr.y, direction)
        //call SetUnitX(u, wtr.x)
        //call SetUnitY(u, wtr.y)
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "made unit with recycler for " + I2S(wtr.uID) + " at " + R2S(wtr.x))
        call ReleaseTimer(t)
        set t = null
        call wtr.destroy()
    endmethod
    
    public static method create takes real X, real Y, integer UID, real Facing returns thistype
        local thistype new = thistype.allocate()
        set new.x = X
        set new.y = Y
        set new.uID = UID
        set new.facing = Facing
        
        return new
    endmethod
endstruct

private function AfterPlatformerReviveCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    if User(pID).GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
        call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
    endif
    
    call ReleaseTimer(t)
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
            if cuPID != pID then
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
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Non platformer unit inside platforming collision")
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
    local WaitingToRespawn wtr
    
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
            if cuID == WWWISP and dist < 40 then                
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == WWSKUL and dist < 42 then
                call CollisionDeathEffect(pu)
                
                call p.KillPlatformer()
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif (cuID == GUARD or cuID == LGUARD) and dist < 36 then
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
            if cuID == GRAVITY and dist < 55 then
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
                //set pIsColliding[i] = true
                set p.YVelocity = p.YVelocity + DIR_BOUNCER_SPEED
                
                //set t = NewTimerEx(i)
                //call TimerStart(t, .4, false, function IsCollidingCallback)
                
                set wtr = WaitingToRespawn.create(GetUnitX(cu), GetUnitY(cu), UBOUNCE, 90)
                set t = NewTimerEx(wtr)
                //call KillUnit(cu)
                call Recycle_ReleaseUnit(cu)
                //call RemoveUnit(cu)
                call TimerStart(t, 3, false, function WaitingToRespawn.callback)
                
                set t = null
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == RBOUNCE and dist < 50 then
                //set pIsColliding[i] = true
                set p.XVelocity = p.XVelocity + DIR_BOUNCER_SPEED
                
                //set t = NewTimerEx(i)
                //call TimerStart(t, .4, false, function IsCollidingCallback)
                
                set wtr = WaitingToRespawn.create(GetUnitX(cu), GetUnitY(cu), RBOUNCE, 0)
                set t = NewTimerEx(wtr)
                //call KillUnit(cu)
                call RemoveUnit(cu)
                call TimerStart(t, 3, false, function WaitingToRespawn.callback)
                
                set t = null
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == DBOUNCE and dist < 50 then
                //set pIsColliding[i] = true
                set p.YVelocity = p.YVelocity - DIR_BOUNCER_SPEED
                
                //set t = NewTimerEx(i)
                //call TimerStart(t, .4, false, function IsCollidingCallback)
                
                set wtr = WaitingToRespawn.create(GetUnitX(cu), GetUnitY(cu), DBOUNCE, 270)
                set t = NewTimerEx(wtr)
                //call KillUnit(cu)
                call RemoveUnit(cu)
                call TimerStart(t, 3, false, function WaitingToRespawn.callback)
                
                set t = null
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == LBOUNCE and dist < 46 then
                //set pIsColliding[i] = true
                set p.XVelocity = p.XVelocity - DIR_BOUNCER_SPEED
                
                //set t = NewTimerEx(i)
                //call TimerStart(t, .4, false, function IsCollidingCallback)
                
                set wtr = WaitingToRespawn.create(GetUnitX(cu), GetUnitY(cu), LBOUNCE, 180)
                set t = NewTimerEx(wtr)
                //call KillUnit(cu)
                call RemoveUnit(cu)
                call TimerStart(t, 3, false, function WaitingToRespawn.callback)
                
                set t = null
                call GroupClear(pCollisionGroup)
                set pu = null
                set cu = null
                return
            elseif cuID == ICETROLL and dist < 56 then
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

private function CollisionBlackhole takes nothing returns nothing
    local Platformer p = CollidingPlatformer
    local unit cu = GetEnumUnit()
        
    local integer cuID = GetUnitTypeId(cu)
    local Blackhole blackhole
    
    if cuID == BLACKHOLE then
        call DisplayTextToForce(bj_FORCE_PLAYER[0], "near blackhole")
        
        //get blackhole struct
        set blackhole = Blackhole.GetActiveBlackholeFromUnit(cu)
        
        if blackhole != 0 then
            //add unit to blackhole watch list
            call blackhole.WatchPlayer(p.PID)
        endif
    endif
endfunction

private function CollisionBlackholeIter takes Platformer p returns nothing
    call GroupEnumUnitsInRange(pNearbyUnits, p.XPosition, p.YPosition, BLACKHOLE_MAXRADIUS, GreenOrBrown)
    set CollidingPlatformer = p
    call ForGroup(pNearbyUnits, function CollisionBlackhole)
    call GroupClear(pNearbyUnits)
endfunction

public function CollisionBlackholeIterInit takes nothing returns nothing
    //Group PlayingMazers is declared and set in trigger SetGlobals in Initialization folder
    local SimpleList_ListNode curPlatformer = Platformer.ActivePlatformers.first
    
    loop
    exitwhen curPlatformer == 0
        call CollisionBlackholeIter(Platformer(curPlatformer.value))
    set curPlatformer = curPlatformer.next
    endloop
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local integer i = 0
    
    set CollisionTimer = CreateTimer()
    set BlackholeTimer = CreateTimer()
    
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
