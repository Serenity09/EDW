library MazingCollision initializer Init requires MazerGlobals, DummyCaster, PlayerUtils, SimpleList

globals
    //private timer tc
    private unit CollidingMazer
    private group NearbyUnits = CreateGroup()
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
    
	private constant real COLLISION_TIMESTEP = .05
		
	private constant boolean DEBUG_RECTANGLE_COLLISION = false
	private constant boolean DEBUG_UNMATCHED_ID = false
endglobals

private function AfterCollisionCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    set LastCollidedUnit[pID] = null
    
    call ReleaseTimer(t)
    set t = null
endfunction
private function AfterMazerInvulnCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    set MobImmune[pID] = false
    set CanReviveOthers[pID] = true
    
	call ReleaseTimer(t)
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


//! textmacro IfInAxisRect takes WIDTH, HEIGHT
	if cuX - $WIDTH$ <= dx and cuX + $WIDTH$ >= dx and cuY - $HEIGHT$ <= dy and cuY + $HEIGHT$ >= dy then
//! endtextmacro
//! textmacro IfInAxisRectEx takes LWIDTH, RWIDTH, BHEIGHT, THEIGHT
	if cuX - $LWIDTH$ <= dx and cuX + $RWIDTH$ >= dx and cuY - $BHEIGHT$ <= dy and cuY + $THEIGHT$ >= dy then
//! endtextmacro

private function CollisionIteration takes nothing returns nothing
	local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
	
	//all collision
	local real muX
	local real muY
	
	local unit cu
    local integer cuTypeID
	local real cuX
	local real cuY
	
	local real dx
    local real dy
	
	//circle collision
    local real dist
	
	//rect collision
	local real cosA
	local real sinA
	
	loop
	exitwhen curUserNode == 0
		set muX = GetUnitX(User(curUserNode.value).ActiveUnit)
		set muY = GetUnitY(User(curUserNode.value).ActiveUnit)
		call GroupEnumUnitsInRange(NearbyUnits, muX, muY, CollisMaxRadius, null)
		
		loop
		set cu = FirstOfGroup(NearbyUnits)
		exitwhen cu == null
			if LastCollidedUnit[curUserNode.value] != cu and (User(curUserNode.value).GameMode == Teams_GAMEMODE_STANDARD or User(curUserNode.value).GameMode == Teams_GAMEMODE_PLATFORMING) then
				set cuTypeID = GetUnitTypeId(cu)
				set cuX = GetUnitX(cu)
				set cuY = GetUnitY(cu)
				
				//filter unit type IDs that appear in EDW but do not collide
				if cuTypeID != MAZER and cuTypeID != FROG and cuTypeID != SMLTARG and cuTypeID != BLACKHOLE then
					//get collision geometry type
					//the geometry type could be cached by indexing all collideable units and running the type comparison once on index... consider doing this as rect type list grows beyond 5-7 (cuts runtime performance to two array lookups and a single int equality comparison, but also adds overhead of indexing all units whereas currently only a few are)
					if cuTypeID == TANK then
						//*********************
						//RECTANGULAR COLLISION
						//*********************
						set dx = (360. - GetUnitFacing(cu)) * bj_DEGTORAD
						set cosA = Cos(dx)
						set sinA = Sin(dx)
						set dx = cosA * (muX - cuX) - sinA * (muY - cuY) + cuX
						set dy = sinA * (muX - cuX) + cosA * (muY - cuY) + cuY
						
						static if DEBUG_RECTANGLE_COLLISION then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Active unit x: " + R2S(muX) + ", y: " + R2S(muY))
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Rotated x: " + R2S(dx) + ", y: " + R2S(dy))
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Facing angle: " + R2S(GetUnitFacing(cu)))
						endif
						
						if cuTypeID == TANK then
							//! runtextmacro IfInAxisRectEx("65.", "115.", "65.", "65.")
								debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In tank")
								
							endif
						endif
					else
						//******************
						//CIRCULAR COLLISION
						//******************
						set dx = cuX - muX
						set dy = cuY - muY
						set dist = SquareRoot(dx*dx + dy*dy)
						
						if cuTypeID == GUARD or cuTypeID == LGUARD then
							if not MobImmune[curUserNode.value] and dist < 39 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == WWWISP then
							if dist < 40 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == WWSKUL then
							if dist < 40 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == REGRET then
							if dist < 42 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == LMEMORY then
							if dist < 57 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == ROGTHT then
							if dist < 55 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == ICETROLL then
							if dist < 58 and not MobImmune[curUserNode.value] then  //TERRAIN_QUADRANT_SIZE - 4
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == SPIRITWALKER then
							if dist < 60 and not MobImmune[curUserNode.value] then  //TERRAIN_QUADRANT_SIZE - 4
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif InWorldPowerup.IsPowerupUnit(cuTypeID) then
							if dist < 65 then
								set LastCollidedUnit[curUserNode.value] = cu
								//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with powerup")
								call InWorldPowerup.GetFromUnit(cu).OnUserAcquire(curUserNode.value)
								
								call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished colliding")
							endif
						elseif cuTypeID == CLAWMAN then
							if dist < 68 and not MobImmune[curUserNode.value] then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						//keys and doors
						elseif cuTypeID == RFIRE then
							if dist < 80 then
								if (MazerColor[curUserNode.value] != KEY_RED) then
									call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
								else
									set LastCollidedUnit[curUserNode.value] = cu
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
							endif
						elseif cuTypeID == RKEY then
							if dist < 65 then
								set LastCollidedUnit[curUserNode.value] = cu
								
								call RShieldEffect(User(curUserNode.value).ActiveUnit)
								set MazerColor[curUserNode.value] = KEY_RED
								call SetUnitVertexColor(User(curUserNode.value).ActiveUnit, 255, 0, 0, 255)
								
								call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
							endif
						elseif cuTypeID == BFIRE then
							if dist < 80 then
								if (MazerColor[curUserNode.value] != KEY_BLUE) then
									call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
								else
									set LastCollidedUnit[curUserNode.value] = cu
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
							endif
						elseif cuTypeID == BKEY then
							if dist < 65 then
								set LastCollidedUnit[curUserNode.value] = cu
								
								call BShieldEffect(User(curUserNode.value).ActiveUnit)
								set MazerColor[curUserNode.value] = KEY_BLUE
								call SetUnitVertexColor(User(curUserNode.value).ActiveUnit, 0, 0, 255, 255)
								
								call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
							endif
						elseif cuTypeID == GFIRE then
							if dist < 80 then
								if (MazerColor[curUserNode.value] != KEY_GREEN) then
									call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
								else
									set LastCollidedUnit[curUserNode.value] = cu
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
							endif
						elseif cuTypeID == GKEY then
							if dist < 65 then
								set LastCollidedUnit[curUserNode.value] = cu
								
								call GShieldEffect(User(curUserNode.value).ActiveUnit)
								set MazerColor[curUserNode.value] = KEY_GREEN
								call SetUnitVertexColor(User(curUserNode.value).ActiveUnit, 0, 255, 0, 255)
								
								call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
							endif
						elseif cuTypeID == TEAM_REVIVE_UNIT_ID then
							if dist < 90 then        
								//currently you will revive anyone whose circle you hit, this may change how you play
								if CanReviveOthers[curUserNode.value] then
									//revive unit at position of mazer to avoid reviving in an illegal position
									call User(GetPlayerId(GetOwningPlayer(cu))).SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, GetUnitX(User(curUserNode.value).ActiveUnit), GetUnitY(User(curUserNode.value).ActiveUnit))
									call SetDefaultCameraForPlayer(GetPlayerId(GetOwningPlayer(cu)), .5)
									
									call TimerStart(NewTimerEx(GetPlayerId(GetOwningPlayer(cu))), P2P_REVIVE_PAUSE_TIME, false, function AfterMazerReviveCB)
								endif
							endif
						elseif cuTypeID == GUILT then
							if dist < 120 then
								call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
								
								call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
							endif
						elseif cuTypeID == KEYR then
							if dist < 125 then
								set LastCollidedUnit[curUserNode.value] = cu
								
								call ShieldRemoveEffect(User(curUserNode.value).ActiveUnit)
								set MazerColor[curUserNode.value] = KEY_NONE
								call SetUnitVertexColor(User(curUserNode.value).ActiveUnit, 255, 255, 255, 255)
								
								call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
							endif
							static if DEBUG_UNMATCHED_ID then
								else
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unmatched unit type ID: " + I2S(cuTypeID) + ", distance: " + R2S(dist))
							endif
						endif
					endif
				endif
			endif
		call GroupRemoveUnit(NearbyUnits, cu)
		endloop
	set curUserNode = curUserNode.next
	endloop
endfunction

//===========================================================================

private function Init takes nothing returns nothing
    //set tc = CreateTimer()
    //call TimerStart(tc, TIMESTEP, true, function CollisionIterInit)
    call TimerStart(CreateTimer(), COLLISION_TIMESTEP, true, function CollisionIteration)
endfunction

endlibrary