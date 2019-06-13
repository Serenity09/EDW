library StandardGameLoop initializer init requires Effects, LavaDamage, IceMovement, SuperFastMovement, RSnowMovement, SnowMovement, SandMovement
	globals
		private constant real STD_TERRAIN_OFFSET = 32.
		private constant real STD_DIAGONAL_TERRAIN_OFFSET = 32. * SIN_45 //32. * SIN_45 == 27, 32^2 = 2*a^2 -> a = 22.63
		
		public timer GameLoopTimer = CreateTimer()
		private constant real TIMESTEP = .05
		
		private constant boolean DEBUG_TERRAIN_CHANGE = false
	endglobals

//! textmacro GetTerrainPriority takes TType, TPriority
	if $TType$ == ABYSS or $TType$ == LRGBRICKS or $TType$ == RTILE or $TType$ == ROAD then
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
	else //if $TType$ == VINES or $TType$ == SAND or $TType$ == RSNOW then
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

function HeroKill takes integer i returns nothing
    //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Dead")
    call TerrainDeathEffect(MazersArray[i])
    
    //call KillUnit(MazersArray[i])
    call User(i).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
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
                
        if (curterrain == SNOW or curterrain == SAND or curterrain == RSNOW) then
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
             
        if (curterrain == SNOW or curterrain == SAND or curterrain == RSNOW or curterrain == MEDIUMICE or curterrain == FASTICE) then
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
    elseif oldterrain == GRASS or oldterrain == D_GRASS or oldterrain == VINES or oldterrain == ROAD then
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
    elseif (oldterrain == SAND) then
		call SandMovement.Remove(u)
		call GroupRemoveUnit(DestinationGroup, u)
		call SetUnitMoveSpeed(u, DefaultMoveSpeed)
        
        if (curterrain == SNOW or curterrain == RSNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE) then
            //velocity carries over to snow
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], R2S(VelocityX[i]))
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], R2S(VelocityY[i]))
    elseif (oldterrain == SNOW) then
        set CanSteer[i] = false
        call SnowMovement.Remove(u)
        
        if (curterrain == SAND or curterrain == RSNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE) then
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
    elseif (oldterrain == RSNOW) then
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
    elseif (oldterrain == LAVA) then
        call LavaDamage.Remove(i)
    elseif (oldterrain == LEAVES) then
        call SuperFastMovement.Remove(u)
        
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
    elseif (oldterrain == LRGBRICKS) then
        //should do nothing
    elseif (oldterrain == RTILE) then
        //call RotationCameras[i].cPause()
        set UseTeleportMovement[i] = false
    endif
	
endfunction

function GameLoopNewTerrainAction takes nothing returns nothing
    local unit u = GetEnumUnit()
    local integer i = GetPlayerId(GetOwningPlayer(u))
    local User user = User.GetUserFromPlayerID(i)
    
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    
    
    local integer previousterrain = PreviousTerrainTypedx[i]
    
    local real facingRad
    //local integer basicterrain = GetTerrainType(x, y)
   
    //on Abyss
    //flattened version of newTerrainCheckAdvancedFlexible(x, y, ABYSS, i)  
	local integer basicterrain = GetBestTerrainForPoint(x, y)
	//local integer basicterrain = GetBestTerrainForPoint(x, y, 32.)
	//local integer basicterrain = GetTerrainType(x, y)
    local real terrainOffset
    local vector2 terrainCenterPoint
    
    //if on abyss, then try to get the next nearest terrain
    if not AbyssImmune[i] and basicterrain == ABYSS then
        call HeroKill(i)
        return //skip remaining actions -- the player died lol
    endif
    
    //if last step in Gameloop had the same terrain as this step, nothing needs to be changed
    //otherwise proceed with GameLoopNewTerrainAction actions
    //always remove the old effect before adding a new one
	if previousterrain != basicterrain and basicterrain != ABYSS then
		static if DEBUG_TERRAIN_CHANGE then
			call DisplayTextToForce(bj_FORCE_PLAYER[i], ("Removing terrain: " + I2S(previousterrain) + ", new terrain: " + I2S(basicterrain)))
		endif
		
		//remove the previous terrain effect before applying a new one
		call GameLoopRemoveTerrainAction(u, i, previousterrain, basicterrain)
		
		//apply new terrain logic
		if (basicterrain == FASTICE) then
			set CanSteer[i] = true
			set SkateSpeed[i] = FastIceSpeed
			
			call IceMovement_Add(MazersArray[i])
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "On Fast Ice")
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == MEDIUMICE) then
			set CanSteer[i] = true
			set SkateSpeed[i] = MediumIceSpeed
			
			call IceMovement_Add(MazersArray[i])
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == SLOWICE) then
			set CanSteer[i] = true
			set SkateSpeed[i] = SlowIceSpeed
			
			call IceMovement_Add(MazersArray[i])
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == VINES) then
			call SetUnitMoveSpeed(u, SlowGrassSpeed)
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == GRASS) then
			call SetUnitMoveSpeed(u, MediumGrassSpeed)
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == D_GRASS) then
			call SetUnitMoveSpeed(u, FastGrassSpeed)
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == RTILE) then
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "R Tiles")
			//call RotationCameras[i].cUnpause()
			//functionality defined within Ice.isMoving
			set UseTeleportMovement[i] = true
			set terrainCenterPoint = GetTerrainCenterpoint(x, y)
			call SetUnitX(u, terrainCenterPoint.x)
			call SetUnitY(u, terrainCenterPoint.y)
			call IssueImmediateOrder(u, "stop")
			
			set PreviousTerrainTypedx[i] = basicterrain
			
			call terrainCenterPoint.destroy()
		elseif (basicterrain == SAND) then
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "On Sand")
			call SandMovement.Add(u)
			call SetUnitMoveSpeed(u, SandMovement_MOVESPEED)
			call GroupAddUnit(DestinationGroup, u)
			
			//momentum going onto sand from regular ice (do momentum ice later)
			if (previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE) then
				set facingRad = (GetUnitFacing(u)/180) * bj_PI
				
				set VelocityX[i] = Cos(facingRad) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
				set VelocityY[i] = Sin(facingRad) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
			endif
			
			//update previous terrain type
			set PreviousTerrainTypedx[i] = basicterrain
		elseif (basicterrain == SNOW) then
			set CanSteer[i] = true
			call SnowMovement.Add(u)
			
			//momentum going onto sand from regular ice (do momentum ice later)
			if (previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE) then
				set facingRad = (GetUnitFacing(u)/180) * bj_PI
				set VelocityX[i] = Cos(facingRad) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
				set VelocityY[i] = Sin(facingRad) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
			endif
			
			//update previous terrain type
			set PreviousTerrainTypedx[i] = basicterrain
		elseif basicterrain == RSNOW then
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "On RSnow")
			set CanSteer[i] = true
			
			call RSnowMovement.Add(u)
			
			//momentum going onto sand from regular ice (do momentum ice later)
			if previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE then
				set VelocityX[i] = Cos(RSFacing[i]) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
				set VelocityY[i] = Sin(RSFacing[i]) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
			endif
			
			//update previous terrain type
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "Setting PreviousTerrainTypedx[" + I2S(i) + "] as: " + I2S(basicterrain))
			set PreviousTerrainTypedx[i] = basicterrain
		elseif basicterrain == LAVA then
			//call DisplayTextToForce(bj_FORCE_PLAYER[i], "Lava")
			call LavaDamage.Add(i)
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif basicterrain == LEAVES then        
			call SetUnitMoveSpeed(u, FastGrassSpeed)
			
			call SuperFastMovement.Add(u)
			
			set PreviousTerrainTypedx[i] = basicterrain
		elseif basicterrain == LRGBRICKS then
			//call PlatformingAux_StartPlatforming(i)
	//        call StopRegularMazing(i)
	//        call Platformer.AllPlatformers[i].StartPlatforming(x, y)
	//        
	//        set TerrainOffset[i] = LRGBRICKSOFFSET
	//        set PreviousTerrainTypedx[i] = basicterrain
			call user.SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
			set PreviousTerrainTypedx[i] = basicterrain
		elseif basicterrain == ROAD then
			call SetUnitMoveSpeed(u, RoadSpeed)
			
			set PreviousTerrainTypedx[i] = basicterrain
		else
			//otherwise set the previous terrain to the current terrain (which has no effect)
			set PreviousTerrainTypedx[i] = basicterrain
		endif
	endif   
endfunction

function GameLoop takes nothing returns nothing
//the loop for the map which periodically (every .05 seconds) checks the position of every playing mazing unit versus the types of terrain
//which have effects
    call ForGroup(MazersGroup, function GameLoopNewTerrainAction)
endfunction


//===========================================================================

private function init takes nothing returns nothing
	call TimerStart(GameLoopTimer, TIMESTEP, true, function GameLoop)
endfunction

endlibrary