library ComplexTerrainPathing initializer init requires TerrainGlobals, Vector2
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
	
	private constant boolean DEBUG_UNNATURAL_NE = true
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
    private static integer instanceCount = 0
    private static thistype recycle = 0
    private thistype recycleNext
    
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
	
	public method Print takes nothing returns nothing
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Pathing: " + I2S(.TerrainPathingForPoint) + ", Quadrant " + I2S(.QuadrantForPoint))
	endmethod
    
    public static method CreateSimple takes integer pathingType, real terrainMidX, real terrainMidY returns thistype
        local thistype new 

        //first check to see if there are any structs waiting to be recycled
        if (recycle == 0) then
            //if recycle is 0, there are no structs, so increase instance count
            set instanceCount = instanceCount + 1
            set new = instanceCount
        else
            //a struct is waiting to be recycled, so use it
            set new = recycle
            set recycle = recycle.recycleNext
            
            set new.QuadrantForPoint = 0
            set new.RelevantXTerrainTypeID = 0
            set new.RelevantYTerrainTypeID = 0
        endif
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Create Simple, CTPR Count: " + I2S(RecycleCount))
        
        set new.TerrainPathingForPoint = pathingType
        //set new.RelevantXTerrainTypeID = relevantTerrainType
        set new.TerrainMidpointX = terrainMidX
        set new.TerrainMidpointY = terrainMidY
                
        return new
    endmethod
    public static method CreateComplex takes integer pathingType, real terrainMidX, real terrainMidY, integer quadrant, integer terrainPushedX, integer terrainPushedY returns thistype
        local thistype new 
        
        //first check to see if there are any structs waiting to be recycled
        if (recycle == 0) then
            //if recycle is 0, there are no structs, so increase instance count
            set instanceCount = instanceCount + 1
            set new = instanceCount
        else
            //a struct is waiting to be recycled, so use it
            set new = recycle
            set recycle = recycle.recycleNext
        endif
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Create Complex, CTPR Count: " + I2S(RecycleCount))
        
        set new.TerrainPathingForPoint = pathingType
        //set new.RelevantXTerrainTypeID = relevantTerrainType
        set new.TerrainMidpointX = terrainMidX
        set new.TerrainMidpointY = terrainMidY
        
        set new.QuadrantForPoint = quadrant
        set new.RelevantXTerrainTypeID = terrainPushedX
        set new.RelevantYTerrainTypeID = terrainPushedY
        
        return new
    endmethod
    public static method create takes integer pathingType returns thistype
        local thistype new
        
        //first check to see if there are any structs waiting to be recycled
        if (recycle == 0) then
            //if recycle is 0, there are no structs, so increase instance count
            set instanceCount = instanceCount + 1
            set new = instanceCount
        else
            //a struct is waiting to be recycled, so use it
            set new = recycle
            set recycle = recycle.recycleNext
            
            set new.TerrainMidpointX = 0
            set new.TerrainMidpointY = 0
            set new.QuadrantForPoint = 0
            set new.RelevantXTerrainTypeID = 0
            set new.RelevantYTerrainTypeID = 0
        endif
        
        set new.TerrainPathingForPoint = pathingType
        
        return new
    endmethod
    
    public method destroy takes nothing returns nothing
        //add to recycle stack
        set recycleNext = recycle
        set recycle = this
    endmethod
endstruct

public function GetPathingForPoint takes real x, real y returns ComplexTerrainPathingResult
    local real terrainCenterX
    local real terrainCenterY
    
    local integer ttype
    local integer ttypeX
    local integer ttypeY

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
    
    
    //the order terrain is checked in is to optimize for the following assumptions:
    //majority of the usable map will be open space
    //followed by square blocks
    //and finally diagonals
    
    //all terrain tiles must fall into 1 of those 3 categories or they'll be ignored entirely
    
    //this is a very expensive function and its called every physics loop per player, so evaluation order should be kept relevent to the map contents
    
    set ttype = GetTerrainType(x, y)
    
    if TerrainGlobals_IsTerrainPathable(ttype) then
        //step 1: figure out which diagonal we need to check
        //step 2: see if diagonal exists
        //step 3: see if point within diagonal and return ID (only 1 possible)
        
        if x >= terrainCenterX and y >= terrainCenterY then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "3, y: " + R2S(y - terrainCenterY - 64) + " x: " + R2S(x - terrainCenterX)) 
            //checking for diagonal ID 3
            set ttypeX = GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y)
            set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
            if TerrainGlobals_IsTerrainDiagonal(ttypeX) and TerrainGlobals_IsTerrainDiagonal(ttypeY) and (y - terrainCenterY - 64 >= -x + terrainCenterX) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttypeX, ttypeY)
            endif
        elseif x < terrainCenterX and y < terrainCenterY then
            //checking for diagonal ID 1
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
            set ttypeX = GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y)
            set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
            if TerrainGlobals_IsTerrainDiagonal(ttypeX) and TerrainGlobals_IsTerrainDiagonal(ttypeY) and (y - terrainCenterY <= -x + terrainCenterX - 64) then
                //call CreateUnit(Player(0), 'etst', x, y, 6)
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttypeX, ttypeY)
            endif
        elseif x >= terrainCenterX then //y < terrainCenterY
            //checking for diagonal ID 4
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4, y: " + R2S(y - terrainCenterY + 64) + " x: " + R2S(x - terrainCenterX)) 
            set ttypeX = GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y)
            set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
            if TerrainGlobals_IsTerrainDiagonal(ttypeX) and TerrainGlobals_IsTerrainDiagonal(ttypeY) and ((y - terrainCenterY + 64) <= (x - terrainCenterX)) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttypeX, ttypeY)
            endif
        else //x < terrainCenterX and y >= terrainCenterY
            //checking for diagonal ID 2
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
            set ttypeX = GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y)
            set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
            if TerrainGlobals_IsTerrainDiagonal(ttypeX) and TerrainGlobals_IsTerrainDiagonal(ttypeY) and ((y - terrainCenterY) >= (x - terrainCenterX + 64)) then
                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttypeX, ttypeY)
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
        
        if x >= terrainCenterX then
            //either way we are going to check the terrain directly right to see if it's pathable
            set ttypeX = GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y)
            if TerrainGlobals_IsTerrainPathable(ttypeX) then
                if y >= terrainCenterY then
                    set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "between, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX))
                            if y - terrainCenterY >= x - terrainCenterX then //which side of the diagonal the point is on simplifies to this when diagonal passes through terrainCenter
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype) //extends from NW corner
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype) //extends from SE corner
                            endif
                        else //type for (right, below) irrelevant
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY - 64) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY - TERRAIN_QUADRANT_SIZE <= -1 * (x - terrainCenterX)  then //check if within NE corner
                                //call CreateUnit(Player(1), 'etst', x, y, 6)
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, ttype) //point is in/extends from NE corner
                            endif
                        endif
                    else //x >= terrainCenterX, y >= terrainCenterY, right pathable, above unpathable
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            if y - terrainCenterY < x - terrainCenterX then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, 0) //vertical diagonal
                        endif
                    endif
                else //x>= terrainCenterX, y < terrainCenterY
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "south east")
                    set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "between, y: " + R2S(y - terrainCenterY) + " x: " + R2S(-x + terrainCenterX))
                            if y - terrainCenterY >= -x + terrainCenterX then //which side of the diagonal the point is on simplifies to this when diagonal passes through terrainCenter
                                //call CreateUnit(Player(2), 'etst', x, y, 6)
                                //returns invalid combination, so project to the nearest valid side of same tile
                                //return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype)
                                static if DEBUG_UNNATURAL_NE then
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal 1")
								endif
								
								return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from SW corner
                            endif
                        else //type for (right, below) irrelevant
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY + 64) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY + TERRAIN_QUADRANT_SIZE >= x - terrainCenterX  then //check if within NE corner
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype) //point is in/extends from NE corner
                            endif
                        endif
                    else //x >= terrainCenterX, y < terrainCenterY, right pathable, below unpathable
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY + 64) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY >= -x + terrainCenterX then
                                //call CreateUnit(Player(3), 'etst', x, y, 6)
								static if DEBUG_UNNATURAL_NE then
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal 2")
								endif
								
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX + TERRAIN_TILE_SIZE, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, 0) //vertical diagonal
                        endif
                    endif
                endif
            else //x >= terrainCenterX, right not pathable
                if y >= terrainCenterY then //x >= terrainCenterX, y >= terrainCenterY, right not pathable
                    set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        //check if this is a horizontal or diagonal                    
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            //see which side of diagonal point falls on
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY >= x - terrainCenterX then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NE, 0, ttype)
                        endif
                    else //x >= terrainCenterX, y >= terrainCenterY, right not pathable, above not pathable
                        return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                    endif
                else //x >= terrainCenterX, y < terrainCenterY, right not pathable
                    set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        //check if this is a horizontal or diagonal                    
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x + TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            //see which side of diagonal point falls on
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY <= -x + terrainCenterX then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, 0, ttype)
                        endif
                    else //x >= terrainCenterX, y < terrainCenterY, right not pathable, below not pathable
                        return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                    endif
                endif
            endif
        else //x < terrainCenterX                    
            //either way we are going to check the terrain directly left to see if it's pathable
            set ttypeX = GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y)
            if TerrainGlobals_IsTerrainPathable(ttypeX) then
                if y >= terrainCenterY then
                    set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "between, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX))
                            if y - terrainCenterY >= -1 * (x - terrainCenterX) then //which side of the diagonal the point is on simplifies to this when diagonal passes through terrainCenter
                                //call CreateUnit(Player(4), 'etst', x, y, 6)
								static if DEBUG_UNNATURAL_NE then
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal 3")
								endif
								
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from SW corner
                            endif
                        else //type for (left, below) irrelevant
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
                            if y - terrainCenterY <= x - terrainCenterX + TERRAIN_QUADRANT_SIZE  then //check if within NE corner
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype) //point is in/extends from NW corner
                            endif
                        endif
                    else //x < terrainCenterX, y >= terrainCenterY, left is pathable, above is unpathable
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            if y - terrainCenterY < -x + terrainCenterX then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from SW corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, 0) //vertical diagonal
                        endif
                    endif
                else //y < terrainCenterY
                    set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "between, y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX))
                            if y - terrainCenterY >= x - terrainCenterX then //which side of the diagonal the point is on simplifies to this when diagonal passes through terrainCenter
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype) //extends from NW corner
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype) //extends from SE corner
                            endif
                        else //type for (right, below) irrelevant
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX + 64)) 
                            if y - terrainCenterY >= -1 * (x - terrainCenterX + TERRAIN_QUADRANT_SIZE)  then //check if within NE corner
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //point is in/extends from SW corner
                            endif
                        endif
                    else //x < terrainCenterX, y < terrainCenterY, left is pathable, below is unpathable
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            if y - terrainCenterY >= x - terrainCenterX then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, ttype, ttype) //extends from SW corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, 0) //vertical diagonal
                        endif
                    endif
                endif
            else //x < terrainCenterX, left not pathable
                if y >= terrainCenterY then //x < terrainCenterX, y >= terrainCenterY, left not pathable
                    set ttypeY = GetTerrainType(x, y + TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        //check if this is a horizontal or diagonal                    
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y + TERRAIN_QUADRANT_SIZE)) then
                            //see which side of diagonal point falls on
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY >= -x + terrainCenterX then
                                //call CreateUnit(Player(5), 'etst', x, y, 6)
								static if DEBUG_UNNATURAL_NE then
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered unnatural diagonal 4")
								endif
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, terrainCenterX, terrainCenterY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, 0, ttype)
                        endif
                    else //x < terrainCenterX, y >= terrainCenterY, left not pathable, above not pathable
                        //if TerrainGlobals_IsTerrainDiagonal(ttypeY) then
                        //    if y - terrainCenterY >= 64 + x - terrainCenterX then
                        //        return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from SW corner
                        //    else
                        //        return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                        //    endif
                        //else
                            return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                        //endif
                    endif
                else //x < terrainCenterX, y < terrainCenterY, left not pathable
                    set ttypeY = GetTerrainType(x, y - TERRAIN_QUADRANT_SIZE)
                    if TerrainGlobals_IsTerrainPathable(ttypeY) then
                        //check if this is a horizontal or diagonal                    
                        if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(x - TERRAIN_QUADRANT_SIZE, y - TERRAIN_QUADRANT_SIZE)) then
                            //see which side of diagonal point falls on
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y - terrainCenterY) + " x: " + R2S(x - terrainCenterX)) 
                            if y - terrainCenterY <= x - terrainCenterX then
                                //call CreateUnit(Player(11), 'etst', x, y, 6)
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SE, ttype, ttype) //extends from NE corner
                            else
                                return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                            endif
                        else
                            return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, terrainCenterX, terrainCenterY, ComplexTerrainPathing_NW, 0, ttype)
                        endif
                    else //x < terrainCenterX, y < terrainCenterY, left not pathable, below not pathable
                        //if TerrainGlobals_IsTerrainDiagonal(ttypeY) then
                        //    if y - terrainCenterY >= 64 + x - terrainCenterX then
                        //        return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, terrainCenterX, terrainCenterY, ComplexTerrainPathing_SW, ttype, ttype) //extends from SW corner
                        //    else
                        //        return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                        //    endif
                        //else
                            return ComplexTerrainPathingResult.CreateSimple(ComplexTerrainPathing_Inside, terrainCenterX, terrainCenterY) //inside triangle piece
                        //endif
                    endif
                endif
            endif
        endif
    endif
    
    //null represents no diagonal
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
    
    /*
    set NE_UnitVector = vector2.create(SIN_45, -SIN_45)
    set SE_UnitVector = vector2.create(SIN_45, SIN_45)
    set SW_UnitVector = vector2.create(SIN_45, -SIN_45)
    set NW_UnitVector = vector2.create(SIN_45, SIN_45)
    */
    
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(Up_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(Down_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(Left_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(Right_UnitVector))
//    
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(NE_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(SE_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(SW_UnitVector))
//    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(NW_UnitVector))    
endfunction
    
endlibrary