library TerrainHelpers requires TerrainGlobals, UnitGlobals, Vector2
    globals
        private group NearbyUnits = CreateGroup()
    endglobals
    
    public function IsValidTerrain takes integer ttype returns boolean
        return ttype != ABYSS and ttype != LAVA and ttype != PLATFORMING
    endfunction
    
    public function IsValidTerrain_Standard takes integer ttype returns boolean
        return ttype != ABYSS and ttype != PLATFORMING
    endfunction
    
    public function IsValidTerrain_Platforming takes integer ttype returns boolean
        return ttype != LAVA and ttype != PLATFORMING
    endfunction
        
    public function NoStaticUnits takes real x, real y returns boolean
        local integer uTypeId 
        local boolean flag
        local unit u
        
        local real dx
        local real dy
        local real dist
        
        call GroupEnumUnitsInRange(NearbyUnits, x, y, CollisLrgRadius, null)
        
        loop
        set u = FirstOfGroup(NearbyUnits)
        exitwhen u == null
            set uTypeId = GetUnitTypeId(FirstOfGroup(NearbyUnits))
            if (uTypeId == REGRET or uTypeId == GUILT or uTypeId == LMEMORY or uTypeId == BFIRE or uTypeId == RFIRE or uTypeId == GFIRE) then
                //check if within range
                set dx = x - GetUnitX(u)
                set dy = y - GetUnitY(u)
                set dist = SquareRoot(dx * dx + dy * dy)
                
                if (uTypeId == REGRET and dist < 43) or (uTypeId == LMEMORY and dist < 57) or (uTypeId == GUILT and dist < 120) or (uTypeId == BFIRE and dist < 80) or (uTypeId == RFIRE and dist < 80) or (uTypeId == GFIRE and dist < 80) then
                    call GroupClear(NearbyUnits)
                    set u = null
                    
                    return false
                endif
            endif
        call GroupRemoveUnit(NearbyUnits, u)
        endloop
        
        set u = null
        return true
    endfunction
	
	function GetDistanceFromTile takes real tileCenterX, real tileCenterY, real x, real y returns real
		//  var dx = Math.max(rect.min.x - p.x, 0, p.x - rect.max.x);
		//	var dy = Math.max(rect.min.y - p.y, 0, p.y - rect.max.y);
		//	return Math.sqrt(dx*dx + dy*dy);
		local real dx = tileCenterX - TERRAIN_QUADRANT_SIZE - x
		local real dy = tileCenterY - TERRAIN_QUADRANT_SIZE - y
		
		if dx < 0 then
			set dx = 0
		endif
		if dx < x - tileCenterX - TERRAIN_QUADRANT_SIZE then
			set dx = x - tileCenterX - TERRAIN_QUADRANT_SIZE
		endif
		
		if dy < 0 then
			set dy = 0
		endif
		if dy < y - tileCenterY - TERRAIN_QUADRANT_SIZE then
			set dy = y - tileCenterY - TERRAIN_QUADRANT_SIZE
		endif
		
		return SquareRoot(dx*dx + dy*dy)
	endfunction
	    
    public function TryGetFirstSafeLocation takes real x, real y, integer maxRadius, integer prevGameMode returns vector2
        local integer iSide
        local integer iRadius
								
		local vector2 tileCenter
		
		local real checkDistance
		local real bestDistance = 10000
		local vector2 bestCenter = 0
                
        //handle radius 1 separately
        if NoStaticUnits(x, y) and (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x, y)))  or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x, y)))) then
            return vector2.create(x, y)
        endif
		
		//get x,y tile center, to define other nearby tiles and check the distance between them and x,y
        set tileCenter = GetTerrainCenterpoint(x, y)
		
        set iRadius = 2
        loop
        exitwhen iRadius > maxRadius  
            //check the two long sides
            set iSide = 1
            loop
            exitwhen iSide > iRadius * 2 - 1      
                //debug call CreateUnit(Player(0), WWWISP, x - 128 * iRadius + 128 * iSide, y + 128 * (iRadius - 1), 0)
                //debug call CreateUnit(Player(1), WWWISP, x - 128 * iRadius + 128 * iSide, y - 128 * (iRadius - 1), 0)
                
                if NoStaticUnits(x - 128 * iRadius + 128 * iSide, y + 128 * (iRadius - 1)) and (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x - 128 * iRadius + 128 * iSide, y + 128 * (iRadius - 1)))) or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x - 128 * iRadius + 128 * iSide, y + 128 * (iRadius - 1))))) then
                    //get the distance between the check center and previous best center
					set checkDistance = GetDistanceFromTile(tileCenter.x  - 128 * iRadius + 128 * iSide, tileCenter.y  + 128 * (iRadius - 1), x, y)
					if checkDistance < bestDistance then
						set bestDistance = checkDistance
						
						if bestCenter != 0 then
							call bestCenter.deallocate()
						endif
						set bestCenter = vector2.create(tileCenter.x - 128 * iRadius + 128 * iSide, tileCenter.y + 128 * (iRadius - 1))
					endif
                endif
				
				if NoStaticUnits(x - 128 * iRadius + 128 * iSide, y - 128 * (iRadius - 1)) and (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x - 128 * iRadius + 128 * iSide, y - 128 * (iRadius - 1)))) or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x - 128 * iRadius + 128 * iSide, y - 128 * (iRadius - 1))))) then
                    set checkDistance = GetDistanceFromTile(tileCenter.x - 128 * iRadius + 128 * iSide, tileCenter.y - 128 * (iRadius - 1), x, y)
					if checkDistance < bestDistance then
						set bestDistance = checkDistance
						
						if bestCenter != 0 then
							call bestCenter.deallocate()
						endif
						set bestCenter = vector2.create(tileCenter.x - 128 * iRadius + 128 * iSide, tileCenter.y - 128 * (iRadius - 1))
					endif
                endif
            set iSide = iSide + 1
            endloop
                        
            //check the two short sides
            set iSide = 1
            loop
            exitwhen iSide > iRadius * 2 - 3
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "placing y: " + R2S(y - 128 * (iRadius - 1) + 128 * iSide))
                //debug call CreateUnit(Player(2), WWWISP, x + 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide, 0)
                //debug call CreateUnit(Player(3), WWWISP, x - 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide, 0)                
                if NoStaticUnits(x + 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide) and (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x + 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide))) or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x + 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide)))) then
                    set checkDistance = GetDistanceFromTile(tileCenter.x + 128 * (iRadius - 1), tileCenter.y - 128 * (iRadius - 1) + 128 * iSide, x, y)
					if checkDistance < bestDistance then
						set bestDistance = checkDistance
						
						if bestCenter != 0 then
							call bestCenter.deallocate()
						endif
						set bestCenter = vector2.create(tileCenter.x + 128 * (iRadius - 1), tileCenter.y - 128 * (iRadius - 1) + 128 * iSide)
					endif
                elseif NoStaticUnits(x - 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide) and (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x - 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide))) or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x - 128 * (iRadius - 1), y - 128 * (iRadius - 1) + 128 * iSide)))) then
                    set checkDistance = GetDistanceFromTile(tileCenter.x - 128 * (iRadius - 1), tileCenter.y - 128 * (iRadius - 1) + 128 * iSide, x, y)
					if checkDistance < bestDistance then
						set bestDistance = checkDistance
						
						if bestCenter != 0 then
							call bestCenter.deallocate()
						endif
						set bestCenter = vector2.create(tileCenter.x - 128 * (iRadius - 1), tileCenter.y - 128 * (iRadius - 1) + 128 * iSide)
					endif
                endif
            set iSide = iSide + 1
            endloop
			
			//the best center for any single ring will be better than any best center in the next ring
			if bestCenter != 0 then
				call tileCenter.deallocate()
				return bestCenter
			endif
        set iRadius = iRadius + 1
        endloop
        
        //failed to find a safe location, return 0 and pass the buck
		call tileCenter.deallocate()
        return 0
    endfunction
    
    public function TryGetLastValidLocation takes real x, real y, real facing, integer prevGameMode returns vector2
        local vector2 validPoint
        //first check the current position, maybe death was due to collision or some other natural means
        if NoStaticUnits(x, y) and IsValidTerrain(GetTerrainType(x, y)) then
            set validPoint = vector2.create(x, y)
        else
            //terrain check is very flexible so need to put revive somewhere more reachable
            //convert facing to radians, now that its needed
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "facing " + R2S(facing))
            
            set facing = facing * DEGREE_TO_RADIANS
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "facing " + R2S(facing))
            //debug call CreateUnit(Player(0), WWWISP, x + 128*Cos(facing), y + 128*Sin(facing), 0)
            
            //check if terrain opposite mazer's facing is not abyss
            if (((prevGameMode == Teams_GAMEMODE_STANDARD or prevGameMode == Teams_GAMEMODE_STANDARD_PAUSED) and IsValidTerrain_Standard(GetTerrainType(x - 128*Cos(facing), y - 128*Sin(facing)))) or ((prevGameMode == Teams_GAMEMODE_PLATFORMING or prevGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED) and IsValidTerrain_Platforming(GetTerrainType(x - 128*Cos(facing), y - 128*Sin(facing))))) and NoStaticUnits(x - 128*Cos(facing), y - 128*Sin(facing)) then
                //debug call CreateUnit(Player(0), WWWISP, x, y, 0)
                set validPoint = GetTerrainCenterpoint(x - 128*Cos(facing), y - 128*Sin(facing))
            else
                //not safe, so need to iterate all terrain tiles in area
                set validPoint = TryGetFirstSafeLocation(x, y, 3, prevGameMode)

                //check that a point was found
                if validPoint == 0 then
                    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Now, how did you get way out here...?")
                    set validPoint = vector2.create(x, y)
                endif
            endif
        endif
        
        return validPoint
    endfunction
endlibrary