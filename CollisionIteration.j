library MazingCollision initializer Init requires MazerGlobals, DummyCaster, PlayerUtils, SimpleList, RespawningUnit

globals
    //private timer tc
    private unit CollidingMazer
    private group NearbyUnits = CreateGroup()
	    
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
	elseif User(pID).GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
		call User(pID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
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
	local IndexedUnit cuInfo
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
						
			//max enum range is determined by level to accomodate level's typically having a theme for model size, but that can vary widely for how small/big
			call GroupEnumUnitsInRange(NearbyUnits, muX, muY, User(curUserNode.value).Team.OnLevel.MaxCollisionSize, null)
			
			loop
			set cu = FirstOfGroup(NearbyUnits)
			exitwhen cu == null
				if User(curUserNode.value).LastCollidedUnit != cu then
					set cuInfo = IndexedUnit(GetUnitUserData(cu))
					set cuTypeID = GetUnitTypeId(cu)
					set cuX = GetUnitX(cu)
					set cuY = GetUnitY(cu)
					
					//filter units that appear in EDW but do not collide
					if cuInfo != 0 and cuInfo.Collideable then
					// if cuTypeID != MAZER then
						//get collision geometry type from the units indexed property RectangularGeometry
						if cuInfo.RectangularGeometry then
						// if cuTypeID == TANK or cuTypeID == TRUCK or cuTypeID == FIRETRUCK or cuTypeID == AMBULANCE or cuTypeID == JEEP or cuTypeID == PASSENGERCAR or cuTypeID == CORVETTE or cuTypeID == POLICECAR then
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
							
							if not MobImmune[curUserNode.value] then
								if cuTypeID == TANK then
									//! runtextmacro IfInAxisRectEx("65.", "115.", "65.", "65.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In tank")
										endif
									endif
								elseif cuTypeID == TRUCK then
									//! runtextmacro IfInAxisRectEx("205.", "215.", "68.", "68.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In truck")
										endif
									endif
								elseif cuTypeID == FIRETRUCK then
									//! runtextmacro IfInAxisRectEx("215.", "200.", "68.", "68.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In firetruck")
										endif
									endif
								elseif cuTypeID == AMBULANCE then
									//! runtextmacro IfInAxisRectEx("240.", "175.", "80.", "80.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In ambulance")
										endif
									endif
								elseif cuTypeID == JEEP then
									//! runtextmacro IfInAxisRectEx("145.", "130.", "64.", "64.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In jeep")
										endif
									endif
								elseif cuTypeID == CORVETTE then
									//! runtextmacro IfInAxisRectEx("140.", "140.", "64.", "64.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In vette")
										endif
									endif
								elseif cuTypeID == PASSENGERCAR then
									//! runtextmacro IfInAxisRectEx("120.", "115.", "62.", "62.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In car")
										endif
									endif
								elseif cuTypeID == POLICECAR then
									//! runtextmacro IfInAxisRectEx("150.", "150.", "62.", "62.")
										static if APPLY_RECTANGLE_COLLISION then
											//TODO special splat if in front
											call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "In police car")
										endif
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
							
							if dist <= User(curUserNode.value).ActiveUnitRadius + cuInfo.Radius then
								if not MobImmune[curUserNode.value] and (cuTypeID == GUARD or cuTypeID == LGUARD or cuTypeID == ICETROLL or cuTypeID == SPIRITWALKER or cuTypeID == CLAWMAN or cuTypeID == WWWISP or cuTypeID == WWSKUL/* or (User(curUserNode.value).ActiveUnit != cu and (cuTypeID == MAZER or cuTypeID == PLATFORMERWISP))*/) then
									call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
									
									call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
								endif
									
								if cuTypeID == REGRET or cuTypeID == LMEMORY or cuTypeID == GUILT then
									call CollisionDeathEffect(User(curUserNode.value).ActiveUnit, cu)
									
									call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
								elseif InWorldPowerup.IsPowerupUnit(cuTypeID) then
									//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with powerup")
									call InWorldPowerup.GetFromUnit(cu).OnUserAcquire(curUserNode.value)
									
									call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
									//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished colliding")
									//keys
								elseif cuTypeID == RKEY and MazerColor[curUserNode.value] != KEY_RED then
									call RShieldEffect(User(curUserNode.value).ActiveUnit)
									call User(curUserNode.value).SetKeyColor(KEY_RED)
									// set MazerColor[curUserNode.value] = KEY_RED
									// call SetUnitVertexColor(MazersArray[curUserNode.value], 255, 0, 0, 255)
									
									// call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
								elseif cuTypeID == BKEY and MazerColor[curUserNode.value] != KEY_BLUE then
									call BShieldEffect(User(curUserNode.value).ActiveUnit)
									call User(curUserNode.value).SetKeyColor(KEY_BLUE)
									// set MazerColor[curUserNode.value] = KEY_BLUE
									// call SetUnitVertexColor(MazersArray[curUserNode.value], 0, 0, 255, 255)
									
									// call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
								elseif cuTypeID == GKEY and MazerColor[curUserNode.value] != KEY_GREEN then
									call GShieldEffect(User(curUserNode.value).ActiveUnit)
									call User(curUserNode.value).SetKeyColor(KEY_GREEN)
									// set MazerColor[curUserNode.value] = KEY_GREEN
									// call SetUnitVertexColor(MazersArray[curUserNode.value], 0, 255, 0, 255)
									
									// call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
								elseif cuTypeID == TEAM_REVIVE_UNIT_ID then
									//currently you will revive anyone whose circle you hit, this may change how you play
									if CanReviveOthers[curUserNode.value] then
										//revive unit at position of mazer to avoid reviving in an illegal position
										if User(curUserNode.value).GameMode == Teams_GAMEMODE_STANDARD then
											call User(GetPlayerId(GetOwningPlayer(cu))).SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, muX, muY)
											// call SetDefaultCameraForPlayer(GetPlayerId(GetOwningPlayer(cu)), .5)
											call User(GetPlayerId(GetOwningPlayer(cu))).ApplyDefaultCameras(.5)
											call User(GetPlayerId(GetOwningPlayer(cu))).ApplyDefaultSelections()
										elseif User(curUserNode.value).GameMode == Teams_GAMEMODE_PLATFORMING then
											call User(GetPlayerId(GetOwningPlayer(cu))).SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, muX, muY)
										endif
										
										call TimerStart(NewTimerEx(GetPlayerId(GetOwningPlayer(cu))), P2P_REVIVE_PAUSE_TIME, false, function AfterMazerReviveCB)
									endif
								elseif cuTypeID == KEYR and MazerColor[curUserNode.value] != KEY_NONE then									
									call ShieldRemoveEffect(User(curUserNode.value).ActiveUnit)
									call User(curUserNode.value).SetKeyColor(KEY_NONE)
									
									// call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
								elseif cuTypeID == TELEPORT then
									call TeleportEffect(cu, curUserNode.value)
									
									call User(curUserNode.value).RespawnAtRect(User(curUserNode.value).Team.Revive, true)
								endif
								
								//check units that only collide with specific game modes / active unit types
								//if any of the above kill a User, the users gamemode will currently by DYING
								if User(curUserNode.value).GameMode == Teams_GAMEMODE_STANDARD then
									if cuTypeID == RFIRE then
										if (MazerColor[curUserNode.value] != KEY_RED) then
											call RFireEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
										endif
									elseif cuTypeID == BFIRE then
										if (MazerColor[curUserNode.value] != KEY_BLUE) then
											call BFireEffect(User(curUserNode.value).ActiveUnit)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
										endif
									elseif cuTypeID == GFIRE then
										if (MazerColor[curUserNode.value] != KEY_GREEN) then
											call GFireEffect(User(curUserNode.value).ActiveUnit, cu)
											
											call User(curUserNode.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
										else
											call User(curUserNode.value).InitializeAfterCollisionCB(cu, COLLISION_TIME)
										endif
									endif
								elseif User(curUserNode.value).GameMode == Teams_GAMEMODE_PLATFORMING then
									if cuTypeID == GRAVITY then
										if User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY) != 0 then
											set User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value = -1 * User(curUserNode.value).Platformer.GravityEquation.getAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY).Value 
										else
											call User(curUserNode.value).Platformer.GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRAVITY, -1)
										endif
										set User(curUserNode.value).Platformer.GravitationalAccel = User(curUserNode.value).Platformer.GravityEquation.calculateAdjustedValue(User(curUserNode.value).Platformer.BaseProfile.GravitationalAccel)
										//set User(curUserNode.value).Platformer.GravitationalAccel = -1 * User(curUserNode.value).Platformer.GravitationalAccel
										set User(curUserNode.value).Platformer.YVelocity = 0
										
										call User(curUserNode.value).InitializeAfterCollisionCB(cu, 2.)
										
										call GravityEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == BOUNCER then
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
										
										call User(curUserNode.value).InitializeAfterCollisionCB(cu, .25)
										
										call BounceEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == UBOUNCE then
										set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity + DIR_BOUNCER_SPEED
														
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), UBOUNCE, 90, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
										
										call DirectionalBounceEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == RBOUNCE then
										set User(curUserNode.value).Platformer.XVelocity = User(curUserNode.value).Platformer.XVelocity + DIR_BOUNCER_SPEED
										
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), RBOUNCE, 0, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
										
										call DirectionalBounceEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == DBOUNCE then
										set User(curUserNode.value).Platformer.YVelocity = User(curUserNode.value).Platformer.YVelocity - DIR_BOUNCER_SPEED
										
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), DBOUNCE, 270, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
										
										call DirectionalBounceEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == LBOUNCE then
										set User(curUserNode.value).Platformer.XVelocity = User(curUserNode.value).Platformer.XVelocity - DIR_BOUNCER_SPEED
														
										call AutoRespawningUnit.create(GetUnitX(cu), GetUnitY(cu), LBOUNCE, 180, DIR_BOUNCER_RESPAWN_TIME)
										call Recycle_ReleaseUnit(cu)
										
										call DirectionalBounceEffect(User(curUserNode.value).ActiveUnit, cu)
									elseif cuTypeID == SUPERSPEED then
										//repurpose var for angle
										set dx = GetUnitFacing(cu) * bj_DEGTORAD
										set User(curUserNode.value).Platformer.XVelocity = SUPERSPEED_SPEED * Cos(dx)
										set User(curUserNode.value).Platformer.YVelocity = SUPERSPEED_SPEED * Sin(dx)
										
										call User(curUserNode.value).InitializeAfterCollisionCB(cu, 1.)
										
										call SuperSpeedEffect(User(curUserNode.value).ActiveUnit, cu)
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