library MazingCollision initializer Init requires MazerGlobals, DummyCaster, PlayerUtils, SimpleList, RespawningUnit

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
    //constant real CollisMaxRadius = 137.00
    
    //right now this also means the collision size for revive circles, since that's the only things its used for. will need to modify P2PCollisionIter and provide sizes for the different unitIds
    constant real P2P_MAX_COLLISION_SIZE = 90
    constant real P2P_REVIVE_PAUSE_TIME = 2
    
    //used to group units of similar sizes together
    // constant real CollisSmlRadius = 45.00
    // constant real CollisMedRadius = 80.00
    constant real CollisLrgRadius = 135.00
    
	private constant real COLLISION_TIMESTEP = .05
		
	private constant boolean DEBUG_RECTANGLE_COLLISION = false
	// private constant boolean DEBUG_UNMATCHED_ID = false
	private constant boolean APPLY_RECTANGLE_COLLISION = true
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
//! textmacro IfInAxisRectEx takes BACK, FRONT, LEFT, RIGHT
	if cuX - $BACK$ <= dx and cuX + $FRONT$ >= dx and cuY - $LEFT$ <= dy and cuY + $RIGHT$ >= dy then
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
		//only collide when in standard on platforming modes
		if User(curUserNode.value).GameMode == Teams_GAMEMODE_STANDARD or User(curUserNode.value).GameMode == Teams_GAMEMODE_PLATFORMING then
			set muX = GetUnitX(User(curUserNode.value).ActiveUnit)
			set muY = GetUnitY(User(curUserNode.value).ActiveUnit)
						
			//TODO might need to make this a property of the current level
			//vehicles are really quite large
			call GroupEnumUnitsInRange(NearbyUnits, muX, muY, User(curUserNode.value).Team.OnLevel.MaxCollisionSize, null)
			
			loop
			set cu = FirstOfGroup(NearbyUnits)
			exitwhen cu == null
				if LastCollidedUnit[curUserNode.value] != cu then
					set cuTypeID = GetUnitTypeId(cu)
					set cuX = GetUnitX(cu)
					set cuY = GetUnitY(cu)
					
					//filter unit type IDs that appear in EDW but do not collide
					if cuTypeID != MAZER and cuTypeID != FROG and cuTypeID != SMLTARG and cuTypeID != BLACKHOLE then
						//get collision geometry type
						//the geometry type could be cached by indexing all collideable units and running the type comparison once on index... consider doing this as rect type list grows beyond 5-7 (cuts runtime performance to two array lookups and a single int equality comparison, but also adds overhead of indexing all units whereas currently only a few are)
						//with the above addition, the radius of circular units could also be cached, which would greatly increase the scalability of adding unit type IDs
						//same goes for if the unit uses this default collision iteration loop at all (omit vs not)
						if cuTypeID == TANK or cuTypeID == TRUCK or cuTypeID == FIRETRUCK or cuTypeID == AMBULANCE or cuTypeID == JEEP or cuTypeID == PASSENGERCAR or cuTypeID == CORVETTE or cuTypeID == POLICECAR then
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
								
								call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diff x: " + R2S(cuX - dx) + ", y: " + R2S(cuY - dy))
							endif
														
							if cuTypeID == TANK then
								//! runtextmacro IfInAxisRectEx("65.", "115.", "65.", "65.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In tank")
									endif
								endif
							elseif cuTypeID == TRUCK then
								//! runtextmacro IfInAxisRectEx("205.", "215.", "68.", "68.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In truck")
									endif
								endif
							elseif cuTypeID == FIRETRUCK then
								//! runtextmacro IfInAxisRectEx("215.", "200.", "68.", "68.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In firetruck")
									endif
								endif
							elseif cuTypeID == AMBULANCE then
								//! runtextmacro IfInAxisRectEx("240.", "175.", "80.", "80.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In ambulance")
									endif
								endif
							elseif cuTypeID == JEEP then
								//! runtextmacro IfInAxisRectEx("145.", "135.", "64.", "64.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In jeep")
									endif
								endif
							elseif cuTypeID == CORVETTE then
								//! runtextmacro IfInAxisRectEx("140.", "140.", "64.", "64.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In vette")
									endif
								endif
							elseif cuTypeID == PASSENGERCAR then
								//! runtextmacro IfInAxisRectEx("125.", "115.", "62.", "62.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In car")
									endif
								endif
							elseif cuTypeID == POLICECAR then
								//! runtextmacro IfInAxisRectEx("150.", "150.", "62.", "62.")
									static if APPLY_RECTANGLE_COLLISION then
										//TODO special splat if in front
										call CollisionDeathEffect(User(curUserNode.value).ActiveUnit)
										
										call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
									else
										debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In police car")
									endif
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
							//keys
							elseif cuTypeID == RKEY then
								if dist < 65 then
									set LastCollidedUnit[curUserNode.value] = cu
									
									call RShieldEffect(User(curUserNode.value).ActiveUnit)
									set MazerColor[curUserNode.value] = KEY_RED
									call SetUnitVertexColor(MazersArray[curUserNode.value], 255, 0, 0, 255)
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
							elseif cuTypeID == BKEY then
								if dist < 65 then
									set LastCollidedUnit[curUserNode.value] = cu
									
									call BShieldEffect(User(curUserNode.value).ActiveUnit)
									set MazerColor[curUserNode.value] = KEY_BLUE
									call SetUnitVertexColor(MazersArray[curUserNode.value], 0, 0, 255, 255)
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
							
							elseif cuTypeID == GKEY then
								if dist < 65 then
									set LastCollidedUnit[curUserNode.value] = cu
									
									call GShieldEffect(User(curUserNode.value).ActiveUnit)
									set MazerColor[curUserNode.value] = KEY_GREEN
									call SetUnitVertexColor(MazersArray[curUserNode.value], 0, 255, 0, 255)
									
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
									call SetUnitVertexColor(MazersArray[curUserNode.value], 255, 255, 255, 255)
									
									call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
								endif
								// static if DEBUG_UNMATCHED_ID then
									// else
										// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unmatched unit type ID: " + I2S(cuTypeID) + ", distance: " + R2S(dist))
								// endif
							endif
							
							//check units that only collide with specific game modes / active unit types
							//if any of the above kill a User, the users gamemode will currently by DYING
							if User(curUserNode.value).GameMode == Teams_GAMEMODE_STANDARD then
								if cuTypeID == RFIRE then
									if dist < 80 then
										if (MazerColor[curUserNode.value] != KEY_RED) then
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											set LastCollidedUnit[curUserNode.value] = cu
											
											call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
										endif
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
								elseif cuTypeID == GFIRE then
									if dist < 80 then
										if (MazerColor[curUserNode.value] != KEY_GREEN) then
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											set LastCollidedUnit[curUserNode.value] = cu
											
											call TimerStart(NewTimerEx(curUserNode.value), COLLISION_TIME, false, function AfterCollisionCB)
										endif
									endif
								endif
							elseif User(curUserNode.value).GameMode == Teams_GAMEMODE_PLATFORMING then
								if cuTypeID == GRAVITY then
									if dist < 60 then
										if User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY) != 0 then
											set User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value = -1 * User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value 
										else
											call User(curUserNode.value).Platformer.GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY, -1)
										endif
										set User(curUserNode.value).Platformer.GravitationalAccel = User(curUserNode.value).Platformer.GravityEquation.calculateAdjustedValue(User(curUserNode.value).Platformer.BaseProfile.GravitationalAccel)
										//set User(curUserNode.value).Platformer.GravitationalAccel = -1 * User(curUserNode.value).Platformer.GravitationalAccel
										set User(curUserNode.value).Platformer.YVelocity = 0
										
										set LastCollidedUnit[curUserNode.value] = cu
										call TimerStart(NewTimerEx(curUserNode.value), .6, false, function AfterCollisionCB)
									endif
								elseif cuTypeID == BOUNCER then
									if dist < 55 then
										if User(curUserNode.value).Platformer.GravitationalAccel >= 0 then
											if User(curUserNode.value).Platformer.YVelocity > 0 then
												set User(curUserNode.value).Platformer.YVelocity = -BOUNCER_SPEED
											else
												if User(curUserNode.value).Platformer.YVelocity > BOUNCER_MAX_SPEED and User(curUserNode.value).Platformer.YVelocity - BOUNCER_SPEED <= -BOUNCER_MAX_SPEED then
													set User(curUserNode.value).Platformer.YVelocity = -BOUNCER_MAX_SPEED
												else
													set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity - BOUNCER_SPEED
												endif
											endif
										else
											if User(curUserNode.value).Platformer.YVelocity < 0 then
												set User(curUserNode.value).Platformer.YVelocity = BOUNCER_SPEED
											else
												if User(curUserNode.value).Platformer.YVelocity < BOUNCER_MAX_SPEED and User(curUserNode.value).Platformer.YVelocity + BOUNCER_SPEED >= BOUNCER_MAX_SPEED then
													set User(curUserNode.value).Platformer.YVelocity = BOUNCER_MAX_SPEED
												else
													set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity + BOUNCER_SPEED
												endif
											endif
										endif
										
										set LastCollidedUnit[curUserNode.value] = cu
										call TimerStart(NewTimerEx(curUserNode.value), .1, false, function AfterCollisionCB)
									endif
								elseif cuTypeID == UBOUNCE then
									if dist < 50 then
										set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity + DIR_BOUNCER_SPEED
														
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), UBOUNCE, 90, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
									endif
								elseif cuTypeID == RBOUNCE then
									if dist < 50 then
										set User(curUserNode.value).Platformer.XVelocity = User(curUserNode.value).Platformer.XVelocity + DIR_BOUNCER_SPEED
										
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), RBOUNCE, 0, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
									endif
								elseif cuTypeID == DBOUNCE then
									if dist < 50 then
										set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity - DIR_BOUNCER_SPEED
										
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), DBOUNCE, 270, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
									endif
								elseif cuTypeID == LBOUNCE then
									if dist < 50 then
										set User(curUserNode.value).Platformer.XVelocity = User(curUserNode.value).Platformer.XVelocity - DIR_BOUNCER_SPEED
														
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), LBOUNCE, 180, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
									endif
								elseif cuTypeID == SUPERSPEED then
									if dist < 100 then
										//repurpose var for angle
										set dx = GetUnitFacing(cu) * bj_DEGTORAD
										set User(curUserNode.value).Platformer.XVelocity = SUPERSPEED_SPEED * Cos(dx)
										set User(curUserNode.value).Platformer.YVelocity = SUPERSPEED_SPEED * Sin(dx)
										
										//call DisplayTextToForce(bj_FORCE_PLAYER[0], "unit is angle: " + R2S(dx))
										
										set LastCollidedUnit[curUserNode.value] = cu
										call TimerStart(NewTimerEx(curUserNode.value), .1, false, function AfterCollisionCB)
									endif
								endif
							endif
						endif
					endif
				endif
			call GroupRemoveUnit(NearbyUnits, cu)
			endloop
		endif
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