library StandardGameLoop requires Effects, IceMovement
	globals
		private constant real STD_TERRAIN_OFFSET = 32.
		private constant real STD_DIAGONAL_TERRAIN_OFFSET = 32. * SIN_45
	endglobals

//checks points in a square formation around the unit's x,y coordinate
//in the diagram, the * mark where the check is performed while u marks the location of the unit
//*_________*_________*
//|                   |
//|                   |
//|                   |
//*         U         *
//|                   |
//|                   |
//|                   |
//*---------*---------*


//! textmacro GetTerrainPriority takes TType, TPriority
	if $TType$ == ABYSS or $TType$ == LRGBRICKS or $TType$ == RTILE then
		set $TPriority$ = 0
	elseif $TType$ == LAVA then
		set $TPriority$ = 1
	elseif $TType$ == NOEFFECT or $TType$ == VINES or $TType$ == SAND or $TType$ == RSNOW then
		set $TPriority$ = 2
	elseif $TType$ == GRASS or $TType$ == SNOW then
		set $TPriority$ = 3
	elseif $TType$ == D_GRASS or $TType$ == SLOWICE then
		set $TPriority$ = 4
	elseif $TType$ == LEAVES or $TType$ == MEDIUMICE then
		set $TPriority$ = 5
	elseif $TType$ == FASTICE then
		set $TPriority$ = 6
	elseif $TType$ == RUNEBRICKS then
		set $TPriority$ = 7
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

function TerrainCheckAdvancedFlexible takes real x, real y, integer terrain, integer i returns boolean
    //by default is 20
    local real offset = DefaultTerrainOffset
        
    //if the unit is currently set to be immune to death regions, dont bother checking to see if it should die
    if AbyssImmune[i] then
        return false
    endif
    
    //flexible offsets for different terrain types
    if terrain == D_GRASS then
        set offset = offset + 6
    elseif terrain == GRASS then
        set offset = offset + 2
    elseif terrain == VINES then
        set offset = offset + 16
    elseif terrain == LEAVES then
        set offset = offset + 16
    elseif terrain == SAND then
        set offset = offset + 3
    elseif terrain == SNOW then
        set offset = offset + 3
    elseif terrain == LRGBRICKS then
        set offset = offset - 5
    elseif terrain == RUNEBRICKS then
        set offset = offset + 15
    elseif terrain == SLOWICE then
        set offset = offset + 4
    elseif terrain == MEDIUMICE then
        set offset = offset + 22
    elseif terrain == FASTICE then
        set offset = offset + 6
    endif
            
    //since this code is called so often, nested if's were used to optimize it
    //checks corners/diagonals
    if terrain == GetTerrainType(x, y) then
        if terrain == GetTerrainType(x + offset, y) then
            if terrain == GetTerrainType(x - offset, y) then
                if terrain == GetTerrainType(x, y + offset) then
                    if terrain == GetTerrainType (x, y - offset) then
                        if terrain == GetTerrainType(x + offset, y + offset) then
                            if terrain == GetTerrainType (x - offset, y + offset) then
                                if terrain == GetTerrainType (x - offset, y - offset) then
                                    if terrain == GetTerrainType(x + offset, y - offset) then
                                        //unit is on abyss even with flexible offset
                                        return true
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endif
    
    //if all those conditions aren't reached, then unit is not really on abyss
    return false
endfunction

//checks points in a square formation around the unit's x,y coordinate
//in the diagram, the * mark where the check is performed while u marks the location of the unit
//*_________*_________*
//|                   |
//|                   |
//|                   |
//*         U         *
//|                   |
//|                   |
//|                   |
//*---------*---------*
function newTerrainCheckAdvancedFlexible takes real x, real y, integer killTerrain, integer i returns boolean
    //if the unit is currently set to be immune to death regions, dont bother checking to see if it should die
    if AbyssImmune[i] then
        return false
    endif
    
    //call DisplayTextToForce(bj_FORCE_PLAYER[i], "curent offset: " + R2S(TerrainOffset[i]))
    
    //since this code is called so often, nested if's were used to optimize it
    //checks corners/diagonals
    if killTerrain == GetTerrainType(x, y) then
        if killTerrain == GetTerrainType(x + TerrainOffset[i], y) then
            if killTerrain == GetTerrainType(x - TerrainOffset[i], y) then
                if killTerrain == GetTerrainType(x, y + TerrainOffset[i]) then
                    if killTerrain == GetTerrainType (x, y - TerrainOffset[i]) then
                        if killTerrain == GetTerrainType(x + TerrainOffset[i], y + TerrainOffset[i]) then
                            if killTerrain == GetTerrainType (x - TerrainOffset[i], y + TerrainOffset[i]) then
                                if killTerrain == GetTerrainType (x - TerrainOffset[i], y - TerrainOffset[i]) then
                                    if killTerrain == GetTerrainType(x + TerrainOffset[i], y - TerrainOffset[i]) then
                                        //unit is on abyss even with flexible TerrainOffset[i]
                                        return true
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endif
    
    //if all those conditions aren't reached, then unit is not really on abyss
    return false
endfunction


//checks points in a diamond formation around the unit's x,y coordinate
//in the diagram, the * mark where the check is performed while u marks the location of the unit
//take the diagram with a grain of salt, slash marks suck
//             *
//             /\
//            /  \
//          */    \*
//          /      \
//         /        \
//        *     U    *
//         \        /
//          \      /
//          *\    /*
//            \  /
//             \/
//             *


function GetTerrainDominantType takes real x, real y, integer pID returns integer
    local real terrainOffset
    local integer otherTerrainType
    //local integer array otherTerrainTypes
    
    //TODO move out of this function
    //if the unit is currently set to be immune to death regions, dont bother checking to see if it should die
    //if AbyssImmune[i] then
    //    return false
    //endif
    
    //call DisplayTextToForce(bj_FORCE_PLAYER[i], "curent offset: " + R2S(TerrainOffset[i]))
    
    //since this code is called so often, nested if's were used to optimize it
    //checks corners/diagonals
    set otherTerrainType = GetTerrainType(x, y)
    if ABYSS == otherTerrainType then
        set terrainOffset = TerrainOffset[pID]
        set otherTerrainType = GetTerrainType(x + terrainOffset, y)
        
        if ABYSS == otherTerrainType then
            set otherTerrainType = GetTerrainType(x - terrainOffset, y)
            if ABYSS == otherTerrainType then
                set otherTerrainType = GetTerrainType(x, y + terrainOffset)
                if ABYSS == otherTerrainType then
                    set otherTerrainType = GetTerrainType(x, y - terrainOffset)
                    if ABYSS == otherTerrainType then
                        set otherTerrainType = GetTerrainType(x + terrainOffset, y + terrainOffset)
                        if ABYSS == otherTerrainType then
                            set otherTerrainType = GetTerrainType(x - terrainOffset, y + terrainOffset)
                            if ABYSS == otherTerrainType then
                                set otherTerrainType = GetTerrainType(x - terrainOffset, y - terrainOffset)
                                if ABYSS == otherTerrainType then
                                    set otherTerrainType = GetTerrainType(x + terrainOffset, y - terrainOffset)
                                    if ABYSS == otherTerrainType then
                                        //unit is on abyss even with flexible terrainOffset
                                        return ABYSS
                                    else
                                        return otherTerrainType
                                    endif
                                else
                                    return otherTerrainType
                                endif
                            else
                                return otherTerrainType
                            endif
                        else
                            return otherTerrainType
                        endif
                    else
                        return otherTerrainType
                    endif
                else
                    return otherTerrainType
                endif
            else
                return otherTerrainType
            endif
        else
            return otherTerrainType
        endif
    else
        return otherTerrainType
    endif
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
    elseif oldterrain == GRASS then
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
    elseif (oldterrain == D_GRASS) then
        call SetUnitMoveSpeed(u, DefaultMoveSpeed)
    elseif (oldterrain == VINES) then
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
        
        call GroupRemoveUnit(OnRSnowGroup, u)
        set NumberOnRSnow = NumberOnRSnow - 1
        
        if NumberOnRSnow == 0 then
            call DisableTrigger(gg_trg_RSnow_Movement)
        endif
        
        if (curterrain == SAND or curterrain == SNOW or curterrain == SLOWICE or curterrain == MEDIUMICE or curterrain == FASTICE) then
            //velocity carries over to sand/snow, so do nothing
        else
            set VelocityX[i] = 0
            set VelocityY[i] = 0
        endif
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "P" + I2S(i) + "X: " + R2S(VelocityX[i]))
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Y: " + R2S(VelocityY[i]))
    elseif (oldterrain == LAVA) then
        call GroupRemoveUnit(OnLavaGroup, u)
        set NumberOnLava = NumberOnLava - 1
        
        if NumberOnLava == 0 then
            call DisableTrigger(gg_trg_Lava_Damage)
        endif
    elseif (oldterrain == LEAVES) then
        call GroupRemoveUnit(SuperFastGroup, u)
        call GroupRemoveUnit(DestinationGroup, u)
        set NumberOnSuperFast = NumberOnSuperFast - 1
        
        if NumberOnSuperFast == 0 then
            call DisableTrigger(gg_trg_Super_Fast_Movement)
        endif
        
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
    
    //local real Offset = TerrainOffset[i]
    
    //on Abyss
    //flattened version of newTerrainCheckAdvancedFlexible(x, y, ABYSS, i)
    /*
    if (not AbyssImmune[i] and (GetTerrainType(x, y) == ABYSS and GetTerrainType(x + Offset, y) == ABYSS and GetTerrainType(x - Offset, y) == ABYSS and GetTerrainType(x, y + Offset) == ABYSS and GetTerrainType(x, y - Offset) == ABYSS and GetTerrainType(x + Offset, y + Offset) == ABYSS and GetTerrainType(x - Offset, y + Offset) == ABYSS and GetTerrainType(x + Offset, y - Offset) == ABYSS and GetTerrainType(x - Offset, y - Offset) == ABYSS)) then
        call HeroKill(i)
        return //skip remaining actions -- the player died lol
    endif
    */
    
	local integer basicterrain = GetBestTerrainForPoint(x, y)
	//local integer basicterrain = GetBestTerrainForPoint(x, y, 32.)
	//local integer basicterrain = GetTerrainType(x, y)
    local real terrainOffset
    local vector2 terrainCenterPoint
    
    //if on abyss, then try to get the next nearest terrain
    /*
    if ABYSS == basicterrain then
        set terrainOffset = TerrainOffset[i]
        set basicterrain = GetTerrainType(x + terrainOffset, y)
        
        if ABYSS == basicterrain then
            set basicterrain = GetTerrainType(x - terrainOffset, y)
            if ABYSS == basicterrain then
                set basicterrain = GetTerrainType(x, y + terrainOffset)
                if ABYSS == basicterrain then
                    set basicterrain = GetTerrainType(x, y - terrainOffset)
                    if ABYSS == basicterrain then
                        set basicterrain = GetTerrainType(x + terrainOffset, y + terrainOffset)
                        if ABYSS == basicterrain then
                            set basicterrain = GetTerrainType(x - terrainOffset, y + terrainOffset)
                            if ABYSS == basicterrain then
                                set basicterrain = GetTerrainType(x - terrainOffset, y - terrainOffset)
                                if ABYSS == basicterrain then
                                    set basicterrain = GetTerrainType(x + terrainOffset, y - terrainOffset)
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endif
    */
    /*
    if ABYSS == basicterrain or LAVA == basicterrain then
        set terrainOffset = TerrainOffset[i]
        set basicterrain = GetTerrainType(x + terrainOffset, y)
        
        if ABYSS == basicterrain or LAVA == basicterrain then
            set basicterrain = GetTerrainType(x - terrainOffset, y)
            if ABYSS == basicterrain or LAVA == basicterrain then
                set basicterrain = GetTerrainType(x, y + terrainOffset)
                if ABYSS == basicterrain or LAVA == basicterrain then
                    set basicterrain = GetTerrainType(x, y - terrainOffset)
                    if ABYSS == basicterrain or LAVA == basicterrain then
                        set basicterrain = GetTerrainType(x + terrainOffset, y + terrainOffset)
                        if ABYSS == basicterrain or LAVA == basicterrain then
                            set basicterrain = GetTerrainType(x - terrainOffset, y + terrainOffset)
                            if ABYSS == basicterrain or LAVA == basicterrain then
                                set basicterrain = GetTerrainType(x - terrainOffset, y - terrainOffset)
                                if ABYSS == basicterrain or LAVA == basicterrain then
                                    set basicterrain = GetTerrainType(x + terrainOffset, y - terrainOffset)
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endif
    */
    if not AbyssImmune[i] and basicterrain == ABYSS then
        call HeroKill(i)
        return //skip remaining actions -- the player died lol
    endif
    
    //if last step in Gameloop had the same terrain as this step, nothing needs to be changed
    //otherwise proceed with GameLoopNewTerrainAction actions
    //always remove the old effect before adding a new one
    if previousterrain == basicterrain then
        return
    else
        //RUNEBRICKS keep the effect of whatever terrain type the unit was on previously
        if (basicterrain == RUNEBRICKS) then
            return
        //ABYSS should be similar to RUNEBRICKS in code but completely different in function
        elseif (basicterrain == ABYSS) then
            return
        //ABYSS/RUNEBRICKS is handled differently and should never be stored as the previous terrain
        //the above checks makes sure that by this point basic terrain is neither ABYSS nor RUNEBRICKS
        else
            //switch previous terrain types
            //set PreviousTerrainType2[i] = PreviousTerrainType[i]
            //set PreviousTerrainType[i] = previousterrain 
            //debug
            //call DisplayTextToForce(bj_FORCE_PLAYER[i], ("Remove Effect Call " + I2S(i) + " " + I2S(previousterrain) + " " + I2S(basicterrain)))
            //remove the previous terrain effect
            call GameLoopRemoveTerrainAction(u, i, previousterrain, basicterrain) 
        endif
    endif
    
    //call DisplayTextToForce(bj_FORCE_PLAYER[i], "loop")
    
    //on Fast Ice? Uses equivalent of Simple Terrain Check
    if (basicterrain == FASTICE) then
        set CanSteer[i] = true
        set SkateSpeed[i] = FastIceSpeed
        
        call IceMovement_Add(MazersArray[i])
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "On Fast Ice")
        set TerrainOffset[i] = FASTICEOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif (basicterrain == MEDIUMICE) then
        set CanSteer[i] = true
        set SkateSpeed[i] = MediumIceSpeed
        
        call IceMovement_Add(MazersArray[i])
        
        set TerrainOffset[i] = MEDIUMICEOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif (basicterrain == SLOWICE) then
        set CanSteer[i] = true
        set SkateSpeed[i] = SlowIceSpeed
        
        call IceMovement_Add(MazersArray[i])
        
        set TerrainOffset[i] = SLOWICEOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif (basicterrain == VINES) then
        call SetUnitMoveSpeed(u, SlowGrassSpeed)
        
        set TerrainOffset[i] = VINESOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif (basicterrain == GRASS) then
        call SetUnitMoveSpeed(u, MediumGrassSpeed)
        
        set TerrainOffset[i] = GRASSOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif (basicterrain == D_GRASS) then
        call SetUnitMoveSpeed(u, FastGrassSpeed)
        
        set TerrainOffset[i] = D_GRASSOFFSET
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
        
        set TerrainOffset[i] = RTILEOFFSET
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
        set TerrainOffset[i] = SANDOFFSET
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
        set TerrainOffset[i] = SNOWOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif basicterrain == RSNOW then
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "On RSnow")
        set RSFacing[i] = (GetUnitFacing(u)/180) * bj_PI
        
        set CanSteer[i] = true
        
        //if the sand movement trigger was previously off, turn it on
        if NumberOnRSnow == 0 then
            call EnableTrigger(gg_trg_RSnow_Movement)
        endif
        
        //add unit to the group of units definitely on sand
        call GroupAddUnit(OnRSnowGroup, u)
        set NumberOnRSnow = NumberOnRSnow + 1
        
        //momentum going onto sand from regular ice (do momentum ice later)
        if previousterrain == FASTICE or previousterrain == MEDIUMICE or previousterrain == SLOWICE then
            set VelocityX[i] = Cos(RSFacing[i]) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
            set VelocityY[i] = Sin(RSFacing[i]) * SkateSpeed[i] * ICE2MOMENTUMFACTOR
        endif
        
        //update previous terrain type
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Setting PreviousTerrainTypedx[" + I2S(i) + "] as: " + I2S(basicterrain))
        set TerrainOffset[i] = RSNOWOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif basicterrain == LAVA then
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "Lava")
        if NumberOnLava == 0 then
            call EnableTrigger(gg_trg_Lava_Damage)
        endif
        
        call GroupAddUnit(OnLavaGroup, u)
        set NumberOnLava = NumberOnLava + 1
        
        set TerrainOffset[i] = LAVAOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif basicterrain == LEAVES then        
        call SetUnitMoveSpeed(u, FastGrassSpeed)
        
        //check if unit is moving currently, otherwise set isMoving appropriately
        if GetUnitCurrentOrder(u) == OrderId("none") or GetUnitCurrentOrder(u) == OrderId("stop") then
            set isMoving[i] = false
        else
            set isMoving[i] = true
        endif
        
        if NumberOnSuperFast == 0 then
            call EnableTrigger(gg_trg_Super_Fast_Movement)
        endif
        
        call GroupAddUnit(SuperFastGroup, u)
        call GroupAddUnit(DestinationGroup, u)
        set NumberOnSuperFast = NumberOnSuperFast + 1
        
        set TerrainOffset[i] = LEAVESOFFSET
        set PreviousTerrainTypedx[i] = basicterrain
    elseif basicterrain == LRGBRICKS then
        //call PlatformingAux_StartPlatforming(i)
//        call StopRegularMazing(i)
//        call Platformer.AllPlatformers[i].StartPlatforming(x, y)
//        
//        set TerrainOffset[i] = LRGBRICKSOFFSET
//        set PreviousTerrainTypedx[i] = basicterrain
        call user.SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
	else
		//otherwise set the previous terrain to the current terrain (which has no effect)
		set PreviousTerrainTypedx[i] = basicterrain
    endif
endfunction

function GameLoop takes nothing returns nothing
//the loop for the map which periodically (every .05 seconds) checks the position of every playing mazing unit versus the types of terrain
//which have effects
    call ForGroup(MazersGroup, function GameLoopNewTerrainAction)
endfunction


//===========================================================================
function InitTrig_Game_Loop_With_Effects takes nothing returns nothing
    set gg_trg_Game_Loop_With_Effects = CreateTrigger(  )
    call TriggerRegisterTimerEvent(gg_trg_Game_Loop_With_Effects, .05, true)
    call TriggerAddAction( gg_trg_Game_Loop_With_Effects, function GameLoop )
endfunction

endlibrary