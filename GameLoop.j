library StandardGameLoop initializer init requires EDWEffects, LavaDamage, IceMovement, SuperFastMovement, RSnowMovement, SnowMovement, SandMovement
	globals
		private constant real STD_TERRAIN_OFFSET = 32.
		private constant real STD_DIAGONAL_TERRAIN_OFFSET = 32. * SIN_45 //32. * SIN_45 == 27, 32^2 = 2*a^2 -> a = 22.63
		
		public timer GameLoopTimer = CreateTimer()
		private constant real TIMESTEP = .05
		
		private constant boolean DEBUG_TERRAIN_CHANGE = false
		private constant boolean DEBUG_BEST_TERRAIN = false
		
		public constant string LAVA_MOVEMENT_FX = "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl"
		public constant string VINES_MOVEMENT_FX = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
			
		//public constant string PLATFORMING_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl"
		public constant string PLATFORMING_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl"
	endglobals

//! textmacro GetTerrainPriority takes TType, TPriority
	if $TType$ == ABYSS /* or $TType$ == LRGBRICKS */ or $TType$ == RTILE or $TType$ == ROAD then
		set $TPriority$ = 0
	elseif $TType$ == LAVA then
		set $TPriority$ = 1
	elseif $TType$ == NOEFFECT then
		set $TPriority$ = 3
	elseif $TType$ == GRASS or $TType$ == SNOW then
		set $TPriority$ = 4
	elseif $TType$ == D_GRASS or $TType$ == SLOWICE then
		set $TPriority$ = 5
	elseif $TType$ == LEAVES or $TType$ == MEDIUMICE then
		set $TPriority$ = 6
	elseif $TType$ == FASTICE then
		set $TPriority$ = 7
	else //if $TType$ == VINES or $TType$ == SAND or $TType$ == RSNOW or $TType$ == LRGBRICKS then
		set $TPriority$ = 2
	endif
//! endtextmacro
//! textmacro UpdatePriorityTerrain takes CurTType, CurTPriority, BestTType, BestTPriority
	if $CurTPriority$ > $BestTPriority$ then
		set $BestTPriority$ = $CurTPriority$
		set $BestTType$ = $CurTType$
	endif
//! endtextmacro

function GetBestTerrainForPoint takes real x, real y returns integer
	local integer bestTType = GetTerrainType(x, y)
	local integer bestTPriority
	
	local integer curTType
	local integer curTPriority
	
	//special case for platforming tile -- always use exact boundaries when that is the ttype for the current location
	if bestTType == LRGBRICKS then
		return bestTType
	endif
	
	//initialize bestTPriority
	//! runtextmacro GetTerrainPriority("bestTType", "bestTPriority")
	
	//check cardinal directions
	set curTType = GetTerrainType(x + STD_TERRAIN_OFFSET, y)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x - STD_TERRAIN_OFFSET, y)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x, y + STD_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x, y - STD_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	
	//check diagonal directions
	set curTType = GetTerrainType(x + STD_DIAGONAL_TERRAIN_OFFSET, y + STD_DIAGONAL_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x - STD_DIAGONAL_TERRAIN_OFFSET, y + STD_DIAGONAL_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x + STD_DIAGONAL_TERRAIN_OFFSET, y - STD_DIAGONAL_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
	
	set curTType = GetTerrainType(x - STD_DIAGONAL_TERRAIN_OFFSET, y - STD_DIAGONAL_TERRAIN_OFFSET)
	//! runtextmacro GetTerrainPriority("curTType", "curTPriority")
	//! runtextmacro UpdatePriorityTerrain("curTType", "curTPriority", "bestTType", "bestTPriority")
		
	return bestTType
endfunction

function HeroKill takes User user returns nothing
    //call DisplayTextToForce(bj_FORCE_PLAYER[user], "Dead")
    call TerrainDeathEffect(MazersArray[user])
    
    //call KillUnit(MazersArray[user])
    call user.SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
endfunction

function GameLoopRemoveTerrainAction takes unit u, integer i, integer oldterrain, integer curterrain returns nothing
    local real r
    //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Removing: " + I2S(oldterrain) + " Adding: " + I2S(curterrain))
    
    if oldterrain == FASTICE then
        set CanSteer[i] = false
        call IceMovement_Remove(MazersArray[i])
        
        if curterrain == SNOW or curterrain == SAND or curterrain == RSNOW then
        
        elseif curterrain == SLOWICE then
            //set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityX[i] + VelocityY[i] * VelocityY[i]))            
            set VelocityX[i] = VelocityX[i] + (FastIceSpeed - SlowIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (FastIceSpeed - SlowIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        elseif curterrain == MEDIUMICE then
            set VelocityX[i] = VelocityX[i] + (FastIceSpeed - MediumIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (FastIceSpeed - MediumIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif    
    elseif oldterrain == MEDIUMICE then
        set CanSteer[i] = false
        call IceMovement_Remove(MazersArray[i])
                
        if curterrain == SNOW or curterrain == SAND or curterrain == RSNOW then
            //velocity carries over to sand, so do nothing
//        elseif (curterrain == RSNOW) then
//            set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityY[i]))
//            set VelocityX[i] = r * Cos(GetUnitFacing(u)/180*bj_PI)
//            set VelocityY[i] = r * Sin(GetUnitFacing(u)/180*bj_PI)
        elseif curterrain == SLOWICE then
            //set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityX[i] + VelocityY[i] * VelocityY[i]))            
            set VelocityX[i] = VelocityX[i] + (MediumIceSpeed - SlowIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (MediumIceSpeed - SlowIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        elseif curterrain == FASTICE then
            set VelocityX[i] = VelocityX[i] + (MediumIceSpeed - FastIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (MediumIceSpeed - FastIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
    elseif oldterrain == SLOWICE then
        set CanSteer[i] = false
        call IceMovement_Remove(MazersArray[i])
             
        if curterrain == SNOW or curterrain == SAND or curterrain == RSNOW or curterrain == MEDIUMICE or curterrain == FASTICE then
            //velocity carries over to sand, so do nothing
//        elseif (curterrain == RSNOW) then
//            set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityY[i]))
//            set VelocityX[i] = r * Cos(GetUnitFacing(u)/180*bj_PI)
//            set VelocityY[i] = r * Sin(GetUnitFacing(u)/180*bj_PI)
        elseif curterrain == MEDIUMICE then
            //set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityX[i] + VelocityY[i] * VelocityY[i]))            
            set VelocityX[i] = VelocityX[i] + (SlowIceSpeed - MediumIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (SlowIceSpeed - MediumIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        elseif curterrain == FASTICE then
            set VelocityX[i] = VelocityX[i] + (SlowIceSpeed - FastIceSpeed) * Cos(GetUnitFacing(u)/180*bj_PI)
            set VelocityY[i] = VelocityY[i] + (SlowIceSpeed - FastIceSpeed) * Sin(GetUnitFacing(u)/180*bj_PI)
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
    elseif oldterrain == GRASS or oldterrain == D_GRASS or oldterrain == ROAD then
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
	elseif oldterrain == VINES then
		call SetUnitMoveSpeed(u, DefaultMoveSpeed)
		
		call User(i).ClearActiveEffect()
    elseif oldterrain == SAND then
		call SandMovement.Remove(i)
		call SetUnitMoveSpeed(u, DefaultMoveSpeed)
		
		call User(i).ClearActiveEffect()
        
        if curterrain == SNOW or curterrain == RSNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE then
            //velocity carries over to snow
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], R2S(VelocityX[i]))
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], R2S(VelocityY[i]))
    elseif oldterrain == SNOW then
        set CanSteer[i] = false
        call SnowMovement.Remove(u)
        
        if curterrain == SAND or curterrain == RSNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE then
            //velocity carries over to sand, so do nothing
//        elseif (curterrain == RSNOW) then
//            set r = SquareRoot(RAbsBJ(VelocityX[i] * VelocityY[i]))
//            set VelocityX[i] = r * Cos(GetUnitFacing(u)/180*bj_PI)
//            set VelocityY[i] = r * Sin(GetUnitFacing(u)/180*bj_PI)
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "P" + I2S(i) + "X: " + R2S(VelocityX[i]))
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Y: " + R2S(VelocityY[i]))
    elseif oldterrain == RSNOW then
        set CanSteer[i] = false
        
        call RSnowMovement.Remove(u)
        
        if (curterrain == SAND or curterrain == SNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE) then
            //velocity carries over to sand/snow, so do nothing
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "P" + I2S(i) + "X: " + R2S(VelocityX[i]))
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Y: " + R2S(VelocityY[i]))
    elseif oldterrain == LAVA then
        call LavaDamage.Remove(i)
    elseif oldterrain == LEAVES then
        call SuperFastMovement.Remove(i)
        
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
    elseif oldterrain == LRGBRICKS then
        //should do nothing
    elseif oldterrain == RTILE then
        //call RotationCameras[i].cPause()
        set UseTeleportMovement[i] = false
    endif
endfunction

function GameLoop takes nothing returns nothing
	//the loop for the map which periodically (every .05 seconds) checks the position of every playing mazing unit versus the types of terrain
	//which have effects
	local SimpleList_ListNode curUserNode = StandardMazingUsers.first
	local User user
	local unit u
    
    local real x
    local real y
    local integer previousterrain
    
    local real facingRad
   
    //flattened version of newTerrainCheckAdvancedFlexible(x, y, ABYSS, user)  
	local integer basicterrain
    local vector2 terrainCenterPoint
	
	loop
	exitwhen curUserNode == 0
		set user = User(curUserNode.value)
		
		if user.GameMode == Teams_GAMEMODE_STANDARD then
			set u = user.ActiveUnit
			set x = GetUnitX(u)
			set y = GetUnitY(u)
			set previousterrain = PreviousTerrainTypedx[user]
			
			//flattened version of newTerrainCheckAdvancedFlexible(x, y, ABYSS, user)  
			set basicterrain = GetBestTerrainForPoint(x, y)
			static if DEBUG_BEST_TERRAIN then
				call DisplayTextToForce(bj_FORCE_PLAYER[user], ("Best terrain: " + I2S(basicterrain)))
			endif
			
			//if on abyss, then try to get the next nearest terrain
			if not AbyssImmune[user] and basicterrain == ABYSS then
				call HeroKill(user)
				return //skip remaining actions -- the player died lol
			endif
			
			//if last step in Gameloop had the same terrain as this step, nothing needs to be changed
			//otherwise proceed with GameLoopNewTerrainAction actions
			//always remove the old effect before adding a new one
			if previousterrain != basicterrain and basicterrain != ABYSS then
				static if DEBUG_TERRAIN_CHANGE then
					call DisplayTextToForce(bj_FORCE_PLAYER[user], ("Removing terrain: " + I2S(previousterrain) + ", new terrain: " + I2S(basicterrain)))
				endif
				
				//remove the previous terrain effect before applying a new one
				call GameLoopRemoveTerrainAction(u, user, previousterrain, basicterrain)
								
				//apply new terrain logic
				if (basicterrain == FASTICE) then
					set CanSteer[user] = true
					set SkateSpeed[user] = FastIceSpeed
					
					call IceMovement_Add(MazersArray[user])
				elseif (basicterrain == MEDIUMICE) then
					set CanSteer[user] = true
					set SkateSpeed[user] = MediumIceSpeed
					
					call IceMovement_Add(MazersArray[user])
				elseif (basicterrain == SLOWICE) then
					set CanSteer[user] = true
					set SkateSpeed[user] = SlowIceSpeed
					
					call IceMovement_Add(MazersArray[user])
				elseif (basicterrain == VINES) then
					call SetUnitMoveSpeed(u, SlowGrassSpeed)
					
					call user.SetActiveEffect(VINES_MOVEMENT_FX, "origin")
				elseif (basicterrain == GRASS) then
					call SetUnitMoveSpeed(u, MediumGrassSpeed)
				elseif (basicterrain == D_GRASS) then
					call SetUnitMoveSpeed(u, FastGrassSpeed)
				elseif (basicterrain == RTILE) then
					//call DisplayTextToForce(bj_FORCE_PLAYER[user], "R Tiles")
					//call RotationCameras[user].cUnpause()
					//functionality defined within Ice.isMoving
					set UseTeleportMovement[user] = true
					set terrainCenterPoint = GetTerrainCenterpoint(x, y)
					call SetUnitX(u, terrainCenterPoint.x)
					call SetUnitY(u, terrainCenterPoint.y)
					call IssueImmediateOrder(u, "stop")
					
					call terrainCenterPoint.destroy()
				elseif (basicterrain == SAND) then
					//call DisplayTextToForce(bj_FORCE_PLAYER[user], "On Sand")
					call SandMovement.Add(user)
					call SetUnitMoveSpeed(u, SandMovement_MOVESPEED)
					
					//momentum going onto sand from regular ice (do momentum ice later)
					if (previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE) then
						set facingRad = (GetUnitFacing(u)/180) * bj_PI
						
						set VelocityX[user] = Cos(facingRad) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
						set VelocityY[user] = Sin(facingRad) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
					endif
					
					// if isMoving[user] or XVelocity[user] != 0 or YVelocity[user] != 0 then
						// call user.SetActiveEffect(SAND_MOVEMENT_FX, "origin")
					// endif
				elseif (basicterrain == SNOW) then
					set CanSteer[user] = true
					call SnowMovement.Add(u)
					
					//momentum going onto sand from regular ice (do momentum ice later)
					if (previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE) then
						set facingRad = (GetUnitFacing(u)/180) * bj_PI
						set VelocityX[user] = Cos(facingRad) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
						set VelocityY[user] = Sin(facingRad) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
					endif
				elseif basicterrain == RSNOW then
					//call DisplayTextToForce(bj_FORCE_PLAYER[user], "On RSnow")
					set CanSteer[user] = true
					
					call RSnowMovement.Add(u)
					
					//momentum going onto sand from regular ice (do momentum ice later)
					if previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE then
						set VelocityX[user] = Cos(RSFacing[user]) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
						set VelocityY[user] = Sin(RSFacing[user]) * SkateSpeed[user] * ICE2MOMENTUMFACTOR
					endif
				elseif basicterrain == LAVA then
					//call DisplayTextToForce(bj_FORCE_PLAYER[user], "Lava")
					call LavaDamage.Add(user)
				elseif basicterrain == LEAVES then        
					call SetUnitMoveSpeed(u, FastGrassSpeed)
					
					call SuperFastMovement.Add(user)
				elseif basicterrain == LRGBRICKS then
					call DestroyEffect(AddSpecialEffect(PLATFORMING_FX, GetUnitX(user.ActiveUnit), GetUnitY(user.ActiveUnit)))
					
					call user.SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
					
					if user.IsAFK then
						call user.Team.UpdateAwaitingAFKState()
					endif
				elseif basicterrain == ROAD then
					call SetUnitMoveSpeed(u, RoadSpeed)
				endif
				
				set PreviousTerrainTypedx[user] = basicterrain
			endif
		endif
	set curUserNode = curUserNode.next
	endloop	
endfunction


//===========================================================================

private function init takes nothing returns nothing
	call TimerStart(GameLoopTimer, TIMESTEP, true, function GameLoop)
endfunction

endlibrary