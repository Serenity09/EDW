library ComplexTerrainPathing initializer init requires TerrainGlobals, Vector2, Alloc
globals
    constant real SIN_45            = .7071
    
    //public constant integer Recycled = -99
    
    //public constant integer None = 0
    public constant integer Inside = 20
    
    //all square terrain are the same, 128x128, centered on midpoint
    public constant integer Square = 10
    
    //similar to a square block, but instead of being 128x128 it's 64x64
    //i think these are needed because a single diagonal tile can be part square, part diagonal depending on what other tiles are around it
    public constant integer Left = -1
    public constant integer Right = -2
    public constant integer Top = -3
    public constant integer Bottom = -4
    
    public constant integer NE = 1
    public constant integer SE = 2
    public constant integer SW = 3
    public constant integer NW = 4
    
    public vector2 Up_UnitVector
    public vector2 Down_UnitVector
    public vector2 Left_UnitVector
    public vector2 Right_UnitVector
    
    public vector2 NE_UnitVector
    public vector2 SE_UnitVector
    public vector2 SW_UnitVector
    public vector2 NW_UnitVector
	
	private constant boolean DEBUG_NATURAL = false
	
	private constant boolean DEBUG_UNNATURAL_NE = false
	private constant boolean DEBUG_UNNATURAL_NW = false
	private constant boolean DEBUG_UNNATURAL_SW = false
	private constant boolean DEBUG_UNNATURAL_SE = false
endglobals

//returns a vector that represents the orthogonal to a pathing map
public function GetUnitVectorForPathing takes integer terrainPathing returns vector2
    if terrainPathing == Top then
        return Up_UnitVector
    elseif terrainPathing == Bottom then
        return Down_UnitVector
    elseif terrainPathing == Left then
        return Left_UnitVector
    elseif terrainPathing == Right then
        return Right_UnitVector
    elseif terrainPathing == NE then
        return NE_UnitVector
    elseif terrainPathing == SE then
        return SE_UnitVector
    elseif terrainPathing == SW then
        return SW_UnitVector
    elseif terrainPathing == NW then
        return NW_UnitVector
    endif
    
    return 0
endfunction

public function GetParallelForPathing takes integer terrainPathing returns vector2
    if terrainPathing == Top then
        return Right_UnitVector
    elseif terrainPathing == Bottom then
        return Left_UnitVector
    elseif terrainPathing == Left then
        return Down_UnitVector
    elseif terrainPathing == Right then
        return Up_UnitVector
    elseif terrainPathing == NE then
        return NW_UnitVector
    elseif terrainPathing == SE then
        return SW_UnitVector
    elseif terrainPathing == SW then
        return SE_UnitVector
    elseif terrainPathing == NW then
        return NE_UnitVector
    endif
	
	return 0
endfunction
	
//direction is x or y based for horizontal and vertical walls, but is purely x based for diagonals
public function GetParallelForPathingDirection takes integer terrainPathing, boolean direction returns vector2
	if direction and (terrainPathing == Top or terrainPathing == Bottom) then
        return Right_UnitVector
    elseif not direction and (terrainPathing == Top or terrainPathing == Bottom) then
        return Left_UnitVector
    elseif direction and (terrainPathing == Left or terrainPathing == Right) then
        return Up_UnitVector
    elseif not direction and (terrainPathing == Left or terrainPathing == Right) then
        return Down_UnitVector
    elseif direction and (terrainPathing == NE or terrainPathing == SW) then
        return SE_UnitVector
    elseif not direction and (terrainPathing == NE or terrainPathing == SW) then
        return NW_UnitVector
    elseif direction and (terrainPathing == SE or terrainPathing == NW) then
        return NE_UnitVector
    elseif not direction and (terrainPathing == SE or terrainPathing == NW) then
        return SW_UnitVector
    endif
    
    return 0
endfunction

public function GetAngleForUnitVector takes vector2 unitVector returns real
    if unitVector == Up_UnitVector then
        //return 90.
        return bj_PI * .5
    elseif unitVector == Down_UnitVector then
        //return 270.
        return bj_PI * 1.5
    elseif unitVector == Left_UnitVector then
        //return 180.
        return bj_PI
    elseif unitVector == Right_UnitVector then
        return 0.
    elseif unitVector == NE_UnitVector then
        //return 45.
        return bj_PI * .75
    elseif unitVector == SE_UnitVector then
        //return 315.
        return bj_PI * 1.25
    elseif unitVector == SW_UnitVector then
        //return 225.
        return bj_PI * 1.75
    elseif unitVector == NW_UnitVector then
        //return 135.
        return bj_PI * .25
    endif
    
    return 0.
endfunction

struct ComplexTerrainPathingResult extends array  
    //should be one of the above 10 directional values
    public integer TerrainPathingForPoint
    
    //0 = not pushed against any unpathable terrain on that axis
    //not 0 = pushed against that terrain on that axis
    //may be different than the vanilla GetTerrainTypeID for diagonal terrains
    public integer RelevantXTerrainTypeID
    public integer RelevantYTerrainTypeID
    
    //should be NE, SE, SW, or NW
    public integer QuadrantForPoint

    //need to be able to reproduce the diagonal accurately
    //midpoint + Diagonal type should be enough to reproduce the line
    public real TerrainMidpointX
    public real TerrainMidpointY
    //do i need all this info to represent a linear line? eq will either be y = constant, x = constant, y = x, or y = -x
    //public real DiagonalPointAx
    //public real DiagonalPointAy
    //public real DiagonalPointBx
    //public real DiagonalPointBy
    
    //do we?
    //need the position of the unit entering the diagonal
    //public real OriginPointX
    //public real OriginPointY
    //public real DestinationPointX
    //public real DestinationPointY

    implement Alloc
	
	public method Print takes nothing returns nothing
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Pathing: " + I2S(.TerrainPathingForPoint) + ", Quadrant " + I2S(.QuadrantForPoint))
	endmethod
    
	public method GetXTerrainType takes nothing returns integer
		if .TerrainPathingForPoint == ComplexTerrainPathing_Square then
			return GetTerrainType(.TerrainMidpointX, .TerrainMidpointY)
		else
			return .RelevantXTerrainTypeID
		endif
	endmethod
	public method GetYTerrainType takes nothing returns integer
		if .TerrainPathingForPoint == ComplexTerrainPathing_Square then
			return GetTerrainType(.TerrainMidpointX, .TerrainMidpointY)
		else
			return .RelevantYTerrainTypeID
		endif
	endmethod
	
    public static method CreateSimple takes integer pathingType, real terrainMidX, real terrainMidY returns thistype
        local thistype new = thistype.allocate()
        set new.QuadrantForPoint = 0
        set new.RelevantXTerrainTypeID = 0
        set new.RelevantYTerrainTypeID = 0
               
        set new.TerrainPathingForPoint = pathingType
        set new.TerrainMidpointX = terrainMidX
        set new.TerrainMidpointY = terrainMidY
                
        return new
    endmethod
    public static method CreateComplex takes integer pathingType, real terrainMidX, real terrainMidY, integer quadrant, integer terrainPushedX, integer terrainPushedY returns thistype
        local thistype new = thistype.allocate()
        
        set new.TerrainPathingForPoint = pathingType
        set new.TerrainMidpointX = terrainMidX
        set new.TerrainMidpointY = terrainMidY
        
        set new.QuadrantForPoint = quadrant
        set new.RelevantXTerrainTypeID = terrainPushedX
        set new.RelevantYTerrainTypeID = terrainPushedY
        
        return new
    endmethod
    public static method create takes integer pathingType returns thistype
        local thistype new = thistype.allocate()
        
        set new.TerrainMidpointX = 0
        set new.TerrainMidpointY = 0
        set new.QuadrantForPoint = 0
        set new.RelevantXTerrainTypeID = 0
        set new.RelevantYTerrainTypeID = 0
        
        set new.TerrainPathingForPoint = pathingType
        
        return new
    endmethod
    
    public method destroy takes nothing returns nothing
        set this.TerrainMidpointX = 0
        set this.TerrainMidpointY = 0
        set this.QuadrantForPoint = 0
        set this.RelevantXTerrainTypeID = 0
        set this.RelevantYTerrainTypeID = 0
        set this.TerrainPathingForPoint = 0
        
        //add to recycle stack
        call this.deallocate()
    endmethod
endstruct

public function GetPathingForPoint takes real x, real y returns ComplexTerrainPathingResult
    local real terrainCenterX
    local real terrainCenterY
    
    local integer ttype
	
	local real relX
	local real relY

    //get the center coordinates for the tile containing (x,y)
    /*
    if x >= 0 then
        set terrainCenterX = R2I(x / TERRAIN_TILE_SIZE + .50000) * TERRAIN_TILE_SIZE
    else
        set terrainCenterX = R2I(x / TERRAIN_TILE_SIZE - .50000) * TERRAIN_TILE_SIZE
    endif
    if y >= 0 then
        set terrainCenterY = R2I(y / TERRAIN_TILE_SIZE + .50000) * TERRAIN_TILE_SIZE
    else
        set terrainCenterY = R2I(y / TERRAIN_TILE_SIZE - .50000) * TERRAIN_TILE_SIZE
    endif
    */
    
    if x >= 0 then
        set terrainCenterX = R2I((x + 64.500) / 128.) * 128.
    else
        set terrainCenterX = R2I((x - 63.499) / 128.) * 128.
    endif
    if y >= 0 then
        set terrainCenterY = R2I((y + 64.500) / 128.) * 128.
    else
        set terrainCenterY = R2I((y - 63.499) / 128.) * 128.
    endif
    
    set relX = x - terrainCenterX
	set relY = y - terrainCenterY
	
    //the order terrain is checked in is to optimize for the following assumptions:
    //majority of the usable map will be open space
    //followed by square blocks
    //and finally diagonals
    
    //all terrain tiles must fall into 1 of those 3 categories or they'll be ignored entirely
    
    //this is a very expensive function and its called every physics loop per player, so evaluation order should be kept relevent to the map contents
    
    set ttype = GetTerrainType(terrainCenterX, terrainCenterY)
    
    if TerrainGlobals_IsTerrainPathable(ttype) then
        //step 1: figure out which diagonal we need to check
        //step 2: see if diagonal exists
        //step 3: see if point within diagonal and return ID (only 1 possible)
        
        if x >= terrainCenterX and y >= terrainCenterY then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "3, y: " + R2S(y - terrainCenterY - 64) + " x: " + R2S(x - terrainCenterX)) 
            //checking for diagonal ID 3
            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY)) and TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE)) and (y - terrainCenterY - 64 >= -x + terrainCenterX) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY), GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE))
            endif
        elseif x < terrainCenterX and y < terrainCenterY then
            //checking for diagonal ID 1
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY)) and TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE)) and (y - terrainCenterY <= -x + terrainCenterX - 64) then
                //call CreateUnit(Player(0), 'etst', x, y, 6)
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY), GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE))
            endif
        elseif x >= terrainCenterX then //y < terrainCenterY
            //checking for diagonal ID 4
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4, y: " + R2S(y - terrainCenterY + 64) + " x: " + R2S(x - terrainCenterX)) 
            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY)) and TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE)) and ((y - terrainCenterY + 64) <= (x - terrainCenterX)) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY), GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE))
            endif
        else //x < terrainCenterX and y >= terrainCenterY
            //checking for diagonal ID 2
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY)) and TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE)) and ((y - terrainCenterY) >= (x - terrainCenterX + 64)) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY), GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE))
            endif
        endif
        
        //otherwise we're on an open tile that doesn't have any diagonal tiles nearby overlapping onto this x, y coordinate
        return 0
    elseif TerrainGlobals_IsTerrainSquare(ttype) then
        return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Square, terrainCenterX, terrainCenterY)
    //check if (x,y) is even pathable (we should be there at all) and then check to see if adjoining tiles are diagonal and we overlap
    else //there are only 3 types of terrain pathing -- square and diagonal are the two 'solid' types, with diagonal being only partially solid, and open
    //elseif IsTerrainDiagonal(GetTerrainType(x, y)) then
        //step 1: figure out which diagonals we might need to check
        //step 2: figure out which of those actually exist based on what terrain is adjacent
        //step 3: see if (x,y) is within any of those diagonals
        //step 4: return the diagonal ID (x,y) is within (0 for none)
        
		//**********
		//Quadrant 1
        if x >= terrainCenterX and y >= terrainCenterY then //quadrant 1
			if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY + TERRAIN_TILE_SIZE)) then
				if relY >= relX then
					static if DEBUG_UNNATURAL_NW then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal NW 1")
					endif
					//nearest natural diagonal above
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, ttype, ttype)
				else
					static if DEBUG_UNNATURAL_SE then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal SE 1")
					endif
					//nearest natural diagonal in same tile
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype)
				endif
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, 0)
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, 0, ttype)
			else
				if relY <= TERRAIN_QUADRANT_SIZE - relX then
					static if DEBUG_NATURAL then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered natural diagonal NE 2")
					endif
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, ttype)
				endif
			endif
			
		//**********
		//Quadrant 2
		elseif x < terrainCenterX and y >= terrainCenterY then //quadrant 2
			if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY + TERRAIN_TILE_SIZE)) then
				if relY >= -relX then
					static if DEBUG_UNNATURAL_NE then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal NE 1")
					endif
					//nearest natural diagonal above
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, ttype, ttype)
				else
					static if DEBUG_UNNATURAL_SW then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal SW 1")
					endif
					//nearest natural diagonal in same tile
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype)
				endif
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, 0)
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, 0, ttype)
			else
				if relY <= TERRAIN_QUADRANT_SIZE + relX then
					static if DEBUG_NATURAL then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered natural diagonal NW 2")
					endif
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype)
				endif
			endif
			
		//**********
		//Quadrant 3
		elseif x < terrainCenterX then //and y < terrainCenterY    quadrant 3
			if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY - TERRAIN_TILE_SIZE)) then
				if relY >= relX then
					static if DEBUG_UNNATURAL_NW then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal NW 2")
					endif
					//nearest natural diagonal in same tile
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype)
				else
					static if DEBUG_UNNATURAL_SE then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal SE 2")
					endif
					//nearest natural diagonal below
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, ttype, ttype)
				endif
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, 0)
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX - TERRAIN_TILE_SIZE, terrainCenterY)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, 0, ttype)
			else
				if relY >= -relX - TERRAIN_QUADRANT_SIZE then
					static if DEBUG_NATURAL then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered natural diagonal SW 2")
					endif
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype)
				endif
			endif
			
		//**********
		//Quadrant 4
		else //x >= terrainCenterY and y < terrainCenterX    //quadrant 4
			if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY - TERRAIN_TILE_SIZE)) then
				if relY >= -relX then
					static if DEBUG_UNNATURAL_NE then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal NE 2")
					endif
					//nearest natural diagonal in same tile
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, ttype)
				else
					static if DEBUG_UNNATURAL_SW then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal SW 2")
					endif
					//nearest natural diagonal below
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, ttype, ttype)
				endif
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX, terrainCenterY - TERRAIN_TILE_SIZE)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, 0)
			elseif not TerrainGlobals_IsTerrainPathable(GetTerrainType(terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY)) then
				return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, 0, ttype)
			else
				if relY >= relX - TERRAIN_QUADRANT_SIZE then
					static if DEBUG_NATURAL then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered natural diagonal SE 2")
					endif
					return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype)
				endif
			endif
			
        endif
    endif
    
    //0 represents null -- ie, a pathable result for the x,y location
    return 0
endfunction
    
private function init takes nothing returns nothing
    set Up_UnitVector = vector2.create(0, 1)
    set Down_UnitVector = vector2.create(0, -1)
    set Left_UnitVector = vector2.create(-1, 0)
    set Right_UnitVector = vector2.create(1, 0)
    
    set NE_UnitVector = vector2.create(SIN_45, SIN_45)
    set SE_UnitVector = vector2.create(SIN_45, -SIN_45)
    set SW_UnitVector = vector2.create(-SIN_45, -SIN_45)
    set NW_UnitVector = vector2.create(-SIN_45, SIN_45)
endfunction
    
endlibrary