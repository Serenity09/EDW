library Platformer requires ListModule, PlatformerGlobals, PlatformerOcean, PlatformerIce, PlatformerProfile, PlatformerPropertyEquation, ComplexTerrainPathing, StandardGameLoop, TerrainGlobals

globals
    private constant integer KEY_UP     = 2
    private constant integer KEY_RIGHT  = 1
    private constant integer KEY_LEFT   = -1
    private constant integer KEY_DOWN   = -2
    
    private constant real	CAMERA_APPLY_TIMESTEP = 1.    
    
    private constant boolean PRESSED    = true
    private constant boolean RELEASED   = false
    
    private constant integer vjBUFFER       = 40
    private constant integer hjBUFFER       = 40
    
    private constant real   tOFFSET         = 30.0      //how much offset to use when determining terrain type for terrain kill
    private constant real   wOFFSET         = 1.5       //how much offset to use when determining if you're touching a wall, also used for wall jumps
    
    private constant integer xMINVELOCITY   = 1         //a velocity less than this will turn to 0
    private constant real   hJUMPCUTOFF     = 1.0       //if less than this value, set to 0
    private constant real   INSTANT_MS      = 1.25       //.MoveSpeed * INSTANT_MS = the amount offset immediately on left/right key press -- higher = more reactive
    
	private constant boolean APPLY_TERRAIN_KILL = true  //should only be false for debugging purposes
	
	private constant boolean DEBUG_CREATE = false
    private constant boolean DEBUG_GAMEMODE = false
	
	private constant boolean DEBUG_PHYSICS_LOOP = false
	private constant boolean DEBUG_PHYSICS_LOOP_DELTA = false
	
	private constant boolean DEBUG_POSITION = false
    
    private constant boolean DEBUG_VELOCITY = false
    private constant boolean DEBUG_VELOCITY_TERRAIN = false
    private constant boolean DEBUG_VELOCITY_FALLOFF = false
    private constant boolean DEBUG_VELOCITY_DIAGONAL = false
    
	private constant boolean DEBUG_SQUARE = false
	
    private constant boolean DEBUG_DIAGONAL = false
    
    private constant boolean DEBUG_DIAGONAL_TRANSITION = false
	private constant boolean DEBUG_DIAGONAL_TRANSITION_TERRAIN_METADATA = false
	private constant boolean DEBUG_DIAGONAL_ESCAPE_CHECK = false
	private constant boolean DEBUG_DIAGONAL_ESCAPE = false
    private constant boolean DEBUG_DIAGONAL_START = false
	private constant boolean DEBUG_DIAGONAL_START_CHECK = false
	
	private constant boolean BUFFER_STICKY_TRANSITION_ESCAPE = LEAVE_DIAGONAL_OFFSET > 0 //enable/disable: when leaving a diagonal into empty space due to exceeding the sticky limit for diagonal transitions, position is offset away from diagonal surface when enabled / left as-is when disabled
	
    private constant boolean DEBUG_TERRAIN_KILL = false
    private constant boolean DEBUG_TERRAIN_CHANGE = false
	private constant boolean DEBUG_GRASS_GRAVITY = false
    private constant boolean DEBUG_JUMPING = false
	
	private constant boolean DEBUG_CAMERA = false
	
	//public constant string STANDARD_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl"
	public constant string TERRAIN_STANDARD_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl"
	public constant string TERRAIN_VINES_FX = "Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl"
	
	public constant string VERTICAL_JUMP_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl"
	//public constant string VERTICAL_JUMP_FX = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl"
	public constant string NON_VERTICAL_JUMP_FX = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
	public constant string OCEAN_JUMP_FX = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
	
	public constant string TERRAIN_KILL_FX = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
    public constant string DEBUG_TERRAIN_KILL_FX = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
endglobals

    struct Platformer extends array
        public boolean    IsPlatforming
        public integer    PID
        public unit       Unit
        
        //all properties that support code mechanics
        public static trigger array  ArrowKeyTriggers[5]  //currently no trigger for up release, down press/release
        public integer        LastHorizontalKey    //-1: left, 1: right
        public boolean        LeftKey
        public boolean        RightKey
        public integer        HorizontalAxisState  //-1: left, 0: still, 1: right
        public static camerasetup    PlatformingCamera    //camera setup to apply periodically during platforming movement
        //public effect         FX                   //any visual effect needed for the platformer -- this shit was useless
        
        //all properties that support physics
        public PlatformerProfile    BaseProfile     //the set of default physics variables that describes what the world looks like without any additional effects
        
        public real         XPosition               //the actual physical position of the platformer unit. usually consistent with GetUnitX
        public real         YPosition               //the actual physical position of the platformer unit. usually consistent with GetUnitY
        public real           YVelocity            //this does not include left movement from key press (which is constant)
        public real           XVelocity            //this does not include right movement from key press (which is constant)
        public real          TerminalVelocityY    //this caps how fast a unit can go due to gravity, going faster in this will cause you to slow down to this over time
        public PlatformerPropertyEquation TVYEquation
        //TODO replace X and Y falloff with references to easing functions
        public real          XFalloff             //how much to reduce XVelocity by when != 0
        public PlatformerPropertyEquation XFalloffEquation
        public real          YFalloff             //how much to reduce YVelocity by when >= TerminalVelocityY (TODO change to be just != 0 like XFalloff)
        public PlatformerPropertyEquation YFalloffEquation
        public real          MoveSpeed            //this determines how fast a unit moves left/right
        public PlatformerPropertyEquation MSEquation
        //public real          VelMoveSpeedOffset   //how much trying to oppose your velocity 
        public real          MoveSpeedVelOffset   //how much moving in the opposite direction as your velocity decrements it. newXVeloc = oldXVeloc - .MoveSpeedVelOffset * .MoveSpeed
        public real          GravitationalAccel   //how strong the effect of gravity is
        public PlatformerPropertyEquation GravityEquation
        public real          vJumpSpeed           //how fast a wall jump is vertically
        public real          v2hJumpRatio         //0-1 how much of vJumpSpeed is still applied (vertically) during a wall jump
        public real          hJumpSpeed           //how fast a wall jump is horizontally
        public boolean       CanOceanJump
        
        //all properties that support terrain mechanics
        public integer     TerrainDX              //current terrain tile the unit is on TODO rename to CurrentTerrainOn
		public integer     XTerrainPushedAgainst    //set by physics loop
        public integer     XAppliedTerrainPushedAgainst     //set by terrain loop
        public integer     YTerrainPushedAgainst        //set by physics loop
        public integer     YAppliedTerrainPushedAgainst     //set by terrain loop
        public vector2     PushedAgainstVector              //UNIT vector that opposes the unpathable whatever that the platformer is pushed into
        
        public boolean     OnDiagonal                   //set by physics loop
        public ComplexTerrainPathingResult     DiagonalPathing   //set by physics loop
        
		private real		PhysicsLoopDeltaApplied //prevEffect * (timer timestep - time remaining on timer) / timer timestep
		
        //static properties shared among all platformers/players (1:1 platformer per player)
        //static integer ActivePlatformers //same as List's .count, with how it's used
        static timer            GameloopTimer
        static timer            TerrainloopTimer
		static timer			CameraTimer
        //TODO add a unit group of platformer units to enum through to bypass the WC3 operations limit OR give each platformer their own timer and stagger them
        
		static SimpleList_List		ActivePlatformers
		
		implement Alloc
        
        public static method IsPointInQuadrant takes real x, real y, ComplexTerrainPathingResult diagonal returns boolean
            local real diffCenter
            //because position in a quadrant is a function of x, the query for whether a quadrant has changed must be only determined by x. including y leads to unexpected results, due to y not always following the exact same start point            
            if diagonal.TerrainPathingForPoint == ComplexTerrainPathing_Left or diagonal.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                set diffCenter = y - diagonal.TerrainMidpointY
                
                if (diffCenter >= 0 and diffCenter <= TERRAIN_QUADRANT_SIZE) or (diffCenter < 0 and -diffCenter < TERRAIN_QUADRANT_SIZE) then
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Within same tile")                    
                    if diagonal.QuadrantForPoint == ComplexTerrainPathing_NE and y >= diagonal.TerrainMidpointY then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_SE and y < diagonal.TerrainMidpointY then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_SW and y < diagonal.TerrainMidpointY then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_NW and y >= diagonal.TerrainMidpointY then
                        return true
                    endif
                endif
            else
                set diffCenter = x - diagonal.TerrainMidpointX
                
                if (diffCenter >= 0 and diffCenter <= TERRAIN_QUADRANT_SIZE) or (diffCenter < 0 and -diffCenter < TERRAIN_QUADRANT_SIZE) then
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Within same tile")                    
                    if diagonal.QuadrantForPoint == ComplexTerrainPathing_NE and x >= diagonal.TerrainMidpointX then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_SE and x >= diagonal.TerrainMidpointX then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_SW and x < diagonal.TerrainMidpointX then
                        return true
                    elseif diagonal.QuadrantForPoint == ComplexTerrainPathing_NW and x < diagonal.TerrainMidpointX then
                        return true
                    endif
                endif
            endif
            
            return false
        endmethod
                
        //assuming that the point has been checked to escape the diagonal, and has been projected along the current one, there are only a few options left for where it could go next
        //there are only 3-4 possibilities for the next diagonal that should make this check less expensive than the full ComplexTerrainPathing_GetPathingForPoint check
        //corner piece: diagonal ends, continues as-is, or turns 45deg up or down
        //straight edge piece: continues as-is, or turns 45deg up or down
        public static method GetNextDiagonal takes ComplexTerrainPathingResult currentDiagonal, real currentX, real currentY, vector2 newPosition returns ComplexTerrainPathingResult
            local integer ttype
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "CurrentX, Y: " + R2S(currentX) + ", " + R2S(currentY) + "; NewX, Y" + R2S(newPosition.x) + ", " + R2S(newPosition.y))
            
            //local integer ttypeY
            //are we still within the same quadrant?
            if IsPointInQuadrant(currentX + newPosition.x, currentY + newPosition.y, currentDiagonal) then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Point in quadrant")
                //then reuse same pathing info
                return currentDiagonal
            //does the diagonal continue
            //otherwise need to find new diagonal if any
            else //we've changed quadrants
                //this assumes that the next diagonal will be in an adjacent quadrant to this one
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "CurrentX, Y: " + R2S(currentX) + ", " + R2S(currentY) + "; NewX, Y" + R2S(currentX + newPosition.x) + ", " + R2S(currentY + newPosition.y))
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant " + I2S(currentDiagonal.QuadrantForPoint) + " has changed, getting next diagonal from: " + I2S(currentDiagonal.TerrainPathingForPoint))
                
                //change currentX and currentY to be center points for consistency
                set currentX = currentDiagonal.TerrainMidpointX
                set currentY = currentDiagonal.TerrainMidpointY
                
                //step 1: determine terrain center point for new point
                //step 2: determine which adjacent quadrant the new point is in, based on the possibilities for the current diagonal
                //step 3: determine what the diagonal type is for that quadrant of the new point's tile
                
                //get the center coordinates for the tile containing (x,y)
                //are there any differences if the centerpoint remains the same?
                    //know what the tiles around the previous quadrant looked like -- at least one of those tiles will still be relevant                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finding next diagonal from : " + I2S(currentDiagonal.TerrainPathingForPoint))
                
                if currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Left then 
                    //platformer movement will only be vertical at this point. if horizontal was big enough, they would have escaped the diagonal and been back on standard pathing
                    if newPosition.y > 0 then
                        //moved up a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved up from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NW then
                            //top left
                            //only 2 possibilites: bottom or more left wall
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "right top 1")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE), 0)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE), 0)
                                endif
                            else
                                //for this to be right wall on the NW quad, this tile would need to be square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE))
                            endif
                        else 
                            //bottom left
                           //3 possibilites: top, NW (up), NE (down)
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE))
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if newPosition.y >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantXTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, 0)
                            endif
                        endif
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved down from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved down a quadrant
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NW then
                            //top left
                            //3 possibilites: more left, NE, SE           
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left - NW")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), currentDiagonal.RelevantXTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left - SW")
                                
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if -newPosition.y >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantXTerrainTypeID)
                                endif
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left - Left")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, 0)
                            endif
                        else 
                            //bottom left
                           //only 2 possibilites: wall or more left
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "left top 2")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE), 0)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE), 0)
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE))
                            endif
                        endif
                    endif
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                    //platformer movement will only be vertical at this point. if horizontal was big enough, they would have escaped the diagonal and been back on standard pathing
                    //have we moved up or down a quadrant?
                    if newPosition.y > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved up from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top right
                            //only 2 possibilites: bottom or more right wall
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "right top 1")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE), 0)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE), 0)
                                endif
                            else
                                //for this to be right wall on the NE quad, this tile would need to be square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, 0, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE))
                            endif
                        else 
                            //bottom right
                           //3 possibilites: top, NW (up), NE (down)                            
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE))
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if newPosition.y >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, 0)
                            endif
                        endif
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved down from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved down a quadrant
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top right
                            //3 possibilites: more right, NE, SE           
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right - NE")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right - SE")
                                if -newPosition.y >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right - Right")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, 0)
                            endif
                        else 
                            //bottom right
                           //only 2 possibilites: wall or more right 
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "left top 2")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE), 0)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE), 0)
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, 0, GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE))
                            endif
                        endif
                    endif
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                    //have we moved left or right a quadrant?
                    if newPosition.x > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top right
                            //only 2 possibilites: wall or more top
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "right top 1")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, 0, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY))
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, 0, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY))
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE), 0)
                            endif
                        else 
                            //top left
                           //3 possibilites: top, NW (up), NE (down)                            
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top - NW 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE), currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if newPosition.x >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantYTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, 0, currentDiagonal.RelevantYTerrainTypeID)
                            endif
                        endif
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top left
                            //3 possibilites: top, NW (up), NE (down)                            
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //NE (up)
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE), currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if -newPosition.x >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantYTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, 0, currentDiagonal.RelevantYTerrainTypeID)
                            endif
                        else 
                            //top left
                           //only 2 possibilites: wall or more top 
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "left top 2")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY))
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY))
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE), 0)
                            endif
                        endif
                    endif
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                    //have we moved left or right a quadrant?
                    if newPosition.x > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SE then
                            //bottom right
                            //only 2 possibilites: wall or more bottom
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "right top 1")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, 0, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY))
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, 0, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY))
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), 0)
                            endif
                        else 
                            //bottom left
                           //3 possibilites: bottom, NW (up), NE (down)                            
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Bottom - SW 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if newPosition.x >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantYTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, 0, currentDiagonal.RelevantYTerrainTypeID)
                            endif
                        endif
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SE then
                            //bottom right
                            //3 possibilites: top, NW (up), NE (down)                            
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //NE (up)
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                //check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                if -newPosition.x >= DIAGONAL_STICKYDISTANCE then
                                    return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantYTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, 0, currentDiagonal.RelevantYTerrainTypeID)
                            endif
                        else 
                            //bottom left
                           //only 2 possibilites: wall or more top 
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //top
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "left top 2")
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY)) then
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY))
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, 0, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY))
                                endif
                            else
                                //square
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Square, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE), 0)
                            endif
                        endif
                    endif

                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                    if newPosition.x > 0 then
                        //4 options
                        //continue, left, right, top
                        //have we moved left or right a quadrant?

                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top right
                            //only 3 possibilites: continues, ends, or right wall 
                            
                            //only 3 possibilites: continues, ends, or flat 
                                                        
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                return 0
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 1")
                                //right wall
                                if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, 0)
								endif
                            endif
                        else //SW quadrant
                            //bottom left
                           //2 possibilites: diagonal continues or turns to top
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 2")
                                    set ttype = GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, ttype, ttype)
                                else //going right, right tile not pathable. this will always be top
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 1")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                    //inside corner, in v shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                                //return 0
                            endif
                        endif
                    else //x < 0
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NE then
                            //top right
                            //only 3 possibilites: continues, ends, or flat 
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 3")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                return 0
                            else
                                //top on same 128x128 tile
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 2")
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, 0, currentDiagonal.RelevantYTerrainTypeID)
								endif
                            endif
                        else
                            //bottom left
                           //2 possibilites: diagonal continues or turns to left
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 4")
                                    set ttype = GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, ttype, ttype)
                                else //going left, left tile not pathable. this will always be left wall
                                    //ttype can't be square because then this wouldn't be an inside diagonal
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 2")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY), 0)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                    //inside corner, in < shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY), 0)
                                endif
                            endif
                        endif
                    endif
                    
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                    if newPosition.x > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SE then
                            //bottom right
                            //only 3 possibilites: continues, ends, or right wall 
                            
                            //only 3 possibilites: continues, ends, or flat 
                                                        
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Zero 1")
                                return 0
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 1")
                                //right wall
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, 0)
								endif
                            endif
                        else //NW quadrant
                            //bottom left
                           //2 possibilites: diagonal continues or turns to top
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 2")
                                    set ttype = GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, ttype, ttype)
                                else //going right, right tile not pathable. this will always be top
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 1")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                    //inside corner, making ^ shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            endif
                        endif
                    else //x < 0
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SE then
                            //bottom right
                            //only 3 possibilites: continues, ends, or flat 
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 3")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Zero 2")
                                return 0
                            else
                                //top on same 128x128 tile
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 2")
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, 0, currentDiagonal.RelevantYTerrainTypeID)
								endif
                            endif
                        else
                            //top left
                           //2 possibilites: diagonal continues or turns to left
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 4")
                                    set ttype = GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, ttype, ttype)
                                else //going left, left tile not pathable. this will always be left wall
                                    //ttype can't be square because then this wouldn't be an inside diagonal
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 2")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY), 0)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                    //inside corner, making < shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Right, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY), 0)
                                endif
                            endif
                        endif
                    endif
                    
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                    if newPosition.x > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SW then
                            //bottom right
                            //only 3 possibilites: continues, ends, or right wall 
                            
                            //only 3 possibilites: continues, ends, or flat 
                                                        
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                return 0
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 1")
                                //right wall
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, 0, currentDiagonal.RelevantYTerrainTypeID)
								endif
                            endif

                        else //NW quadrant
                            //bottom left
                           //2 possibilites: diagonal continues or turns to top
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 2")
                                    set ttype = GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, ttype, ttype)
                                else //going right, right tile not pathable. this will always be top
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 1")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, 0)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                    //inside corner, in > shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                    //return 0
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, 0)
                                endif
                            endif
                        endif
                    else //x < 0
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_SW then
                            //top right
                            //only 3 possibilites: continues, ends, or flat 
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 3")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                return 0
                            else
                                //top on same 128x128 tile
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 2")
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, 0)
								endif
                            endif
                        else
                            //bottom left
                           //2 possibilites: diagonal continues or turns to left
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 4")
                                    set ttype = GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, ttype, ttype)
                                else //going left, left tile not pathable. this will always be left wall
                                    //ttype can't be square because then this wouldn't be an inside diagonal
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right 2")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, 0, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE))
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                    //inside corner, in ^ shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Bottom, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SW, 0, GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE))
                                endif
                            endif
                        endif
                    endif                    
                
                elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                    //4 options
                    //continue, left, right, top
                    //have we moved left or right a quadrant?
                    if newPosition.x > 0 then
                        //moved right a quadrant
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved right from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NW then
                            //top left
                            //only 3 possibilites: continues, ends, or top 
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NW 1")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY + TERRAIN_TILE_SIZE, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)) then
                                return 0
                            else
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 1")
                                //top
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, 0, currentDiagonal.RelevantYTerrainTypeID)
								endif
                            endif
                        else //SE quadrant
                           //2 possibilites: diagonal continues or turns to left
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY + TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NW 2")
                                    set ttype = GetTerrainType(currentX + TERRAIN_TILE_SIZE, currentY)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, ttype, ttype)
                                else //going right, right tile not pathable. this will always be a left wall
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left 1")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, 0)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX, currentY + TERRAIN_TILE_SIZE)) then
                                    //inside corner, in > shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_SW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX + TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_NW, currentDiagonal.RelevantXTerrainTypeID, 0)
                                endif
                                //return 0
                            endif
                        endif
                    else //x < 0
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved left from quadrant: " + I2S(currentDiagonal.QuadrantForPoint))
                        //moved left a quadrant                        
                        if currentDiagonal.QuadrantForPoint == ComplexTerrainPathing_NW then
                            //top left
                            //only 3 possibilites: continues, ends, or left 
                            if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NW 3")
                                return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX - TERRAIN_TILE_SIZE, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SE, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                            elseif TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)) then
                                return 0
                            else
                                //left on same 128x128 tile
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left 2")
								if SquareRoot(newPosition.x*newPosition.x + newPosition.y*newPosition.y) >= DIAGONAL_STICKYDISTANCE then
									return 0
								else
									return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Left, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, 0)
								endif
                            endif
                        else
                            //bottom right
                           //2 possibilites: diagonal continues or turns to top
                            if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                if TerrainGlobals_IsTerrainPathable(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY - TERRAIN_TILE_SIZE)) then
                                    //TODO check if platformer is going too fast to stick to this diagonal change -- ie return down or return 0 for no diag
                                    //NE (down)
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE 4")
                                    set ttype = GetTerrainType(currentX, currentY - TERRAIN_TILE_SIZE)
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NW, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, ttype, ttype)
                                else //going left, left tile not pathable. this will always be left wall
                                    //ttype can't be square because then this wouldn't be an inside diagonal
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top 2")
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                            else
                                if TerrainGlobals_IsTerrainDiagonal(GetTerrainType(currentX - TERRAIN_TILE_SIZE, currentY)) then
                                    //inside corner, in v shape
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_NE, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY, ComplexTerrainPathing_SW, currentDiagonal.RelevantXTerrainTypeID, currentDiagonal.RelevantYTerrainTypeID)
                                else
                                    return ComplexTerrainPathingResult.CreateComplex(ComplexTerrainPathing_Top, currentDiagonal.TerrainMidpointX, currentDiagonal.TerrainMidpointY - TERRAIN_TILE_SIZE, ComplexTerrainPathing_NW, 0, currentDiagonal.RelevantYTerrainTypeID)
                                endif
                                //return 0
                            endif
                        endif
                        
                    endif
                else
                    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid Diagonal")
                endif
                
                return 0
            endif
        endmethod
        
        public static method ProjectPositionAlongCurrentDiagonal takes ComplexTerrainPathingResult currentDiagonal, vector2 newPosition returns nothing
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projection before: " + R2S(newPosition.x) + "," + R2S(newPosition.y))
            
            if currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                set newPosition.x = 0
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                set newPosition.x = 0
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top")
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top Y midpoint: " + R2S(currentDiagonal.TerrainMidpointY))
                set newPosition.y = 0
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Bottom")
                set newPosition.y = 0
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                call newPosition.projectUnitVector(ComplexTerrainPathing_SE_UnitVector)
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                call newPosition.projectUnitVector(ComplexTerrainPathing_NE_UnitVector)
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                call newPosition.projectUnitVector(ComplexTerrainPathing_NW_UnitVector)
            elseif currentDiagonal.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                call newPosition.projectUnitVector(ComplexTerrainPathing_SW_UnitVector)
            debug else
                debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Project Position: Invalid Diagonal")
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "after: " + R2S(newPosition.x) + "," + R2S(newPosition.y))
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Project Position Result: " + R2S(newPosition.x) + "," + R2S(newPosition.y))
        endmethod
                    
        public static method DoesPointEscapeDiagonal takes integer diagonalType, real newX, real newY, real escapeDistance returns boolean
            local vector2 proj
            local vector2 orthogonal = ComplexTerrainPathing_GetUnitVectorForPathing(diagonalType)
            local boolean ret
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Does escape check: " + I2S(diagonalType))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Orthogonal: " + orthogonal.toString())
            
            //SquareRoot(newX * newX + newY * newY) < DIAGONAL_NOMANUALESCAPEDISTANCE
            
            set proj = vector2.create(newX, newY)
            call proj.projectUnitVector(orthogonal)
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escape check raw x: " + R2S(newX) + ", y: " + R2S(newY))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected: " + proj.toString())
            
            //need to check direction!!! not enough that the length is big enough, if it's into the surface than that's burrowing not escaping!
            //first perform the least expensive check and make sure that the direction of the intended movement isn't into the surface of the diagonal
            //then see if the length of the projected vector is bigger than the supplied minimum escape distance
            //finally, check that the length of the original position change is less than the max distance before we can't manually escape the diagonal
            set ret = ((diagonalType == ComplexTerrainPathing_Top and proj.y >= 0) or (diagonalType == ComplexTerrainPathing_Bottom and proj.y < 0) or (diagonalType == ComplexTerrainPathing_Right and proj.x >= 0) or (diagonalType == ComplexTerrainPathing_Left and proj.x < 0) or (diagonalType == ComplexTerrainPathing_NE and proj.x >= 0 and proj.y >= 0) or (diagonalType == ComplexTerrainPathing_SE and proj.x >= 0 and proj.y < 0) or (diagonalType == ComplexTerrainPathing_SW and proj.x < 0 and proj.y < 0) or (diagonalType == ComplexTerrainPathing_NW and proj.x < 0 and proj.y >= 0)) and SquareRoot(proj.x * proj.x + proj.y * proj.y) >= escapeDistance
            
			static if DEBUG_DIAGONAL_ESCAPE_CHECK then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking escape from diagonal type " + I2S(diagonalType) + ", x " + R2S(newX) + ", y " + R2S(newY) + ", with proj" + proj.toString())
			endif
			
            call proj.destroy()
            
            return ret
        endmethod
        
        static if DEBUG_MODE then
            private static method RemoveCenterUnitCB takes nothing returns nothing
                local timer t = GetExpiredTimer()
                local IndexedUnit wrap = GetTimerData(t)
                
				call Recycle_ReleaseUnit(wrap.Unit)
                
                call ReleaseTimer(t)
                set t = null
            endmethod
        endif
        
        private method ApplyPhysics takes nothing returns nothing
            local real newX = 0
            local real newY = 0
            
            debug local real curYVelocity = .YVelocity
            debug local real curXVelocity = .XVelocity
            
			local real applyTimeDelta
            local real distance
            //local real angle
            
            local integer ttype
            local ComplexTerrainPathingResult pathingResult = 0
            local vector2 newPosition
            
            local integer directionX
            local integer directionY
            
            debug local unit centerUnit
            
			static if DEBUG_PHYSICS_LOOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applying physics ---")
            endif
			static if DEBUG_POSITION then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before Position: " + R2S(.XPosition) + "," + R2S(.YPosition))
			endif
			
			//to apply physics properly over multiple, variable-length frames we need to keep track of % of physics already rendered during a single timer tick
			//the % of a single tick that should be applied in the current call, applyTimeDelta, should be factored once into all physical forces that are applied over time
			set applyTimeDelta = TimerGetElapsed(.GameloopTimer) / PlatformerGlobals_GAMELOOP_TIMESTEP - .PhysicsLoopDeltaApplied
			
			static if DEBUG_PHYSICS_LOOP_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applied Delta: " + R2S(applyTimeDelta))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Elapsed time: " + R2S(TimerGetElapsed(.GameloopTimer)) + ", already applied time (%): " + R2S(.PhysicsLoopDeltaApplied))
			endif
			
			if TimerGetElapsed(.GameloopTimer) == PlatformerGlobals_GAMELOOP_TIMESTEP then
				set .PhysicsLoopDeltaApplied = 0.
				
				static if DEBUG_PHYSICS_LOOP_DELTA then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Reset delta")
				endif
			else
				set .PhysicsLoopDeltaApplied = .PhysicsLoopDeltaApplied + applyTimeDelta
			endif
			
            //Handle forces that affect the x and/or y direction and need to be as accurate as possible
            //apply constant forces -- forces applied into newX and newY do not need to factor applyTimeDelta in, since it can be factored in once at the end to cover all individual forces (F = D*f1 + D*f2 ... => F = D*(f1+ f2 +...))
            //apply horizontal key state
            if .HorizontalAxisState != 0 then
                if .OnDiagonal then
                    if DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                        set newX = .HorizontalAxisState * .MoveSpeed
                    elseif DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE or DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                        set newX = .HorizontalAxisState * .MoveSpeed * SIN_45
                        set newY = -.HorizontalAxisState * .MoveSpeed * SIN_45
                    elseif DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW or DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                        set newX = .HorizontalAxisState * .MoveSpeed * SIN_45
                        set newY = .HorizontalAxisState * .MoveSpeed * SIN_45
                    elseif DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Left or DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                        //TODO try it with no effect on position when sticking to a diagonal vertical wall
                        set newX = .HorizontalAxisState * .MoveSpeed
                    endif
                else
                    set newX = .HorizontalAxisState * .MoveSpeed
                endif                
            endif
            
            //TODO constant forces need to happen in the main physics loop, which is performance hungry, or can they go to a less performance needy timer?
            //apply constant X forces
            
            //apply constant Y forces
            //update Y velocity for gravity and wall pathing
			if .GravitationalAccel != 0 then
				if .OnDiagonal then					
					//check that gravity is in direction of current surface
                    if not .DoesPointEscapeDiagonal(.DiagonalPathing.TerrainPathingForPoint, 0, .GravitationalAccel, 0.01) then
						//reuse newposition vector and project function for velocity
						//set newPosition = vector2.create(.XVelocity, .YVelocity)
                        set newPosition = vector2.create(0, .GravitationalAccel)
						call .ProjectPositionAlongCurrentDiagonal(.DiagonalPathing, newPosition)
						
                        static if DEBUG_VELOCITY_DIAGONAL then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity before diagonal gravity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected Velocity: " + R2S(newPosition.x) + "," + R2S(newPosition.y))
                        endif
                        
						//TODO check that magnitude to newPosition does not exceed magnitude of [.TerminalVelocityX, .TerminalVelocityY]
						//get angle either from diagonal, newPosition.x >= 0 or from vector calc
						//reuse distance as angle
						//set distance = newPosition.getAngleHorizontal()
						set .XVelocity = .XVelocity + newPosition.x
						set .YVelocity = .YVelocity + newPosition.y
						
                        static if DEBUG_VELOCITY_DIAGONAL then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity after diagonal gravity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity angle: " + R2S(distance * 180 / bj_PI))
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "-----")
                        endif
                        
						call newPosition.destroy()
					else
						if .GravitationalAccel > 0 then //gravity up
							if .YVelocity > 0 then //also going up
								if .GravitationalAccel + .YVelocity < .TerminalVelocityY then //will adding gravity exceed terminal velocity
									set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
								endif
							else //gravity going up but velocity down
								set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
							endif
						else
							if .YVelocity < 0 then //velocity also down
								if .GravitationalAccel + .YVelocity > -.TerminalVelocityY then //will adding gravity exceed terminal velocity
									set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
								endif
							else
								set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
							endif
						endif
					endif					
				else
					if .GravitationalAccel > 0 then //gravity up
						if .YVelocity > 0 then //also going up
							if .GravitationalAccel + .YVelocity < .TerminalVelocityY then //will adding gravity exceed terminal velocity
								set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
							endif
						else //gravity going up but velocity down
							set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
						endif
					elseif .GravitationalAccel < 0 then //gravity down
						if .YVelocity < 0 then //velocity also down
							if .GravitationalAccel + .YVelocity > -.TerminalVelocityY then //will adding gravity exceed terminal velocity
								set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
							endif
						else
							set .YVelocity = .YVelocity + .GravitationalAccel * applyTimeDelta
						endif
					endif
				endif
			endif
			

            //apply X velocity
            set newX = newX + .XVelocity
                         
            //apply y velocity
            set newY = newY + .YVelocity
			 
			//update newX and newY based on % of current timestep fulfilled
			//this is relevant because apply physics is called after keyboard events, in order to maximize reactivity
			set newX = newX * applyTimeDelta
			set newY = newY * applyTimeDelta
			
            //check new x and/or y position for pathability and apply it dependingly
            if newX != 0 or newY != 0 then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Change in position")
                if .OnDiagonal then
                    //project newX and newY along the diagonal, sticking or releasing based on fun-syics logic
                    //step 1: check if newX / newY escape the current diagonal
                    //step 2a: if they do, leave the diagonal and switch back to normal path finding
                    //step 2: if they don't escape the diagonal, project newX and newY along the current diagonal
                    //step 3: check if the new location is part of a diagonal
                    //step 4a: if it's not, set on diagonal to false and switch back to normal path finding
                    //step 4b: if it's a different type of diagonal: adjust current physics values to fit new diagonal; push platformer to outside of diagonal; update diagonal
                    //step 4c: if it's the same type of diagonal, continue along it as they were
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "On diagonal") 
                    
                    //step 1: check if newX / newY escape the current diagonal
                    if DoesPointEscapeDiagonal(.DiagonalPathing.TerrainPathingForPoint, newX, newY, DIAGONAL_ESCAPEDISTANCE * applyTimeDelta) then
                        //bound newX and newY if they're too big -- this needs to occur AFTER checking if point escapes diagonal, or else the result may be skewed towards any much larger value
						set distance = SquareRoot(newX * newX + newY * newY)
						if distance > PLATFORMING_MAXCHANGE then
							//boundedPercent = PLATFORMING_MAXCHANGE / distance
							
							set newX = newX * PLATFORMING_MAXCHANGE / distance
							set newY = newY * PLATFORMING_MAXCHANGE / distance
						endif
						
						//step 2a: if they do, leave the diagonal and switch back to normal path finding
						//platformer is allowed to escape the diagonal, now need to check if destination is legal
						
                        //this is way more intense then i need here, and i can't even handle any of the cases appropriately as things are setup now
                        //would a CheckAndApplyNewDiagonal(.DiagonalPathing, .XPosition, .YPosition, newX, newY) function make sense?
                        //set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newX, .YPosition + newY)
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal manually!")
                        static if DEBUG_DIAGONAL_ESCAPE then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal manually! " + R2S(.XPosition) + "," + R2S(.YPosition) + "; " + R2S(newX) + "," + R2S(newY))
                        endif
                        
                        //i think this should always be 0 if the rest of the game is functioning properly
                        //NOTE: this would need to use the advanced path finding algorithm to work properly
                        set .OnDiagonal = false
                        call .DiagonalPathing.destroy()
                        set .DiagonalPathing = 0
                        
                        set .PushedAgainstVector = 0
                        
                        //update unit position
                        //if checking anything, its not enough to check terrain type at destination position, because that assumes terrain will be square. given that starting on a diagonal tile, that definitely isn't the case...
                        //if you don't check complex pathing then you'll likely return the tile that you started on, if the point on diagonal was well inside of it
                        set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newX, .YPosition + newY)
                        
                        //check if hitting empty space or somehow somewhere on the same tile
                        if pathingResult == 0 or (pathingResult.TerrainMidpointX == .DiagonalPathing.TerrainMidpointX and pathingResult.TerrainMidpointY == .DiagonalPathing.TerrainMidpointY) then
                            static if DEBUG_DIAGONAL_ESCAPE then
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal into empty space")
                            endif
                            
                            set .XTerrainPushedAgainst = 0
                            set .XPosition = .XPosition + newX
                            call SetUnitX(.Unit, .XPosition)
                            
                            set .YTerrainPushedAgainst = 0
                            set .YPosition = .YPosition + newY
                            call SetUnitY(.Unit, .YPosition)
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                            static if DEBUG_TRANSITION then
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal into left or right")
                            endif
                            
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 Colliding with hard x, setting velocity to 0")
                                endif
								
								if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .XVelocity)
								endif
								
								set .XVelocity = 0
                            endif
                            
                            set .YTerrainPushedAgainst = 0
                            set .YPosition = .YPosition + newY
                            call SetUnitY(.Unit, .YPosition)
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                            static if DEBUG_TRANSITION then
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal into top or bottom")
                            endif
                            
                            set .XTerrainPushedAgainst = 0
                            set .XPosition = .XPosition + newX
                            call SetUnitX(.Unit, .XPosition)
                            
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 Colliding with hard y, setting velocity to 0")
                                endif
                                
								if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .YVelocity)
								endif
								
								set .YVelocity = 0
                            endif
                        else//if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or <other> then                            
                            static if DEBUG_MODE then
                                if pathingResult.TerrainPathingForPoint != ComplexTerrainPathing_Square then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, unhandled case for escaping a diagonal into an unhandled destination terrain pathing type " + I2S(pathingResult.TerrainPathingForPoint))
                                endif
                            endif
                            
                            call pathingResult.destroy()
                            set pathingResult = 0
                        endif
                        //debug else
                        //    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, unhandled case for escaping a diagonal into an unpathable destination")
                        //endif
                    else
						//bound newX and newY if they're too big -- this needs to occur AFTER checking if point escapes diagonal, or else the result may be skewed towards any much larger value
						set distance = SquareRoot(newX * newX + newY * newY)
						if distance > PLATFORMING_MAXCHANGE then
							//boundedPercent = PLATFORMING_MAXCHANGE / distance
							
							set newX = newX * PLATFORMING_MAXCHANGE / distance
							set newY = newY * PLATFORMING_MAXCHANGE / distance
						endif
						
						//step 2: if they don't escape the diagonal, project newX and newY along the current diagonal
                        //project newX and newY along the current diagonal
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projecting") 
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Created") 
                        set newPosition = vector2.create(newX, newY)
                        call ProjectPositionAlongCurrentDiagonal(.DiagonalPathing, newPosition)
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Here 1") 
                        
                        //TODO temporary fix until I've implemented raycasting
                        //limit projected position to have a maximum length
                        
						//TODO does this need to be done a 2nd time?
						/*
                        set distance = SquareRoot(newPosition.x * newPosition.x + newPosition.y * newPosition.y)
                        if distance > DIAGONAL_MAXCHANGE then
                            //distancePercent = DIAGONAL_MAXCHANGE / distance
                            
                            set newPosition.x = newPosition.x * DIAGONAL_MAXCHANGE / distance
                            set newPosition.y = newPosition.y * DIAGONAL_MAXCHANGE / distance
                        endif
                        */
						
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Here 2") 
                        
                        //need to make sure projected vector still shows movement
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Updating diagonal position")
                        if newPosition.x != 0 or newPosition.y != 0 then
                            //step 3: check if the new location is part of a diagonal
							
							//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Center: " + R2S(.DiagonalPathing.TerrainMidpointX) + "," + R2S(.DiagonalPathing.TerrainMidpointY))
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Change: " + R2S(newPosition.x) + "," + R2S(newPosition.y))
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destination: " + R2S(.XPosition + newPosition.x) + "," + R2S(.YPosition + newPosition.y))
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                            
                            set pathingResult = GetNextDiagonal(.DiagonalPathing, .XPosition, .YPosition, newPosition)
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Got next diag") 
                            
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Here 3") 
                            if pathingResult.TerrainPathingForPoint == .DiagonalPathing.TerrainPathingForPoint then
                                //if the diagonal remains the same, then its fine to use the projected position as-is
                                static if DEBUG_DIAGONAL_TRANSITION_TERRAIN_METADATA then
                                    if pathingResult.QuadrantForPoint != .DiagonalPathing.QuadrantForPoint then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant changes from: " + I2S(.DiagonalPathing.QuadrantForPoint) + " to: " + I2S(pathingResult.QuadrantForPoint))
                                    else
                                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant stays same")
                                    endif
                                    
                                    if pathingResult.TerrainMidpointX != .DiagonalPathing.TerrainMidpointX or pathingResult.TerrainMidpointY != .DiagonalPathing.TerrainMidpointY then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "Midpoint x, y: " + R2S(pathingResult.TerrainMidpointX) + ", " + R2S(pathingResult.TerrainMidpointY) + ", index: " + R2S(pathingResult.TerrainMidpointX / TERRAIN_TILE_SIZE) + ", " + R2S(pathingResult.TerrainMidpointY / TERRAIN_TILE_SIZE))
                                        //set centerUnit = Recycle_MakeUnitForPlayer(DEBUG_UNIT, pathingResult.TerrainMidpointX, pathingResult.TerrainMidpointY, Player(0))
                                        //call TimerStart(NewTimerEx(GetUnitUserData(centerUnit)), 1, false, function thistype.RemoveCenterUnitCB)
                                    else
                                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Midpoint stays same")
                                    endif
                                endif
				
                                //the push vector also remains the same
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal continues")
                                //update unit position
                                set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                set .XPosition = .XPosition + newPosition.x
                                call SetUnitX(.Unit, .XPosition)
                                
                                //orthogonal for diagonal didn't change
                                //set .PushedAgainstVector = .PushedAgainstVector
                                
                                set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                set .YPosition = .YPosition + newPosition.y
                                call SetUnitY(.Unit, YPosition)
                                
                                if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom) and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                    static if DEBUG_VELOCITY_TERRAIN then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 Colliding with hard y, setting velocity to 0")
                                    endif
                                    
									if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
										call HardStopEffect(this, .YVelocity)
									endif
									
									set .YVelocity = 0
                                elseif (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right) and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                    static if DEBUG_VELOCITY_TERRAIN then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 Colliding with hard x, setting velocity to 0")
                                    endif
									
									if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
										call HardStopEffect(this, .XVelocity)
									endif
									
                                    set .XVelocity = 0
                                endif
                            //check if no next diagonal or if escaped the transition between two different diagonals
                            //elseif pathingResult == 0 then //does not allow platformer to escape between diagonal transitions
                            elseif pathingResult == 0 then
                                //diagonal ends
                                static if DEBUG_DIAGONAL_ESCAPE then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal ends from getting next diagonal")
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unbuffered new position: " + newPosition.toString())
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Buffered new x: " + R2S(newPosition.x + .PushedAgainstVector.x*LEAVE_DIAGONAL_OFFSET) + ", buffered y: " + R2S(newPosition.y + .PushedAgainstVector.y*LEAVE_DIAGONAL_OFFSET))
                                endif
                                
                                //update unit position
                                set .XTerrainPushedAgainst = 0
								static if BUFFER_STICKY_TRANSITION_ESCAPE then
									set .XPosition = .XPosition + newPosition.x + .PushedAgainstVector.x*LEAVE_DIAGONAL_OFFSET
								else
									set .XPosition = .XPosition + newPosition.x
								endif
                                call SetUnitX(.Unit, .XPosition)
                                
                                set .YTerrainPushedAgainst = 0
								static if BUFFER_STICKY_TRANSITION_ESCAPE then
									set .YPosition = .YPosition + newPosition.y + .PushedAgainstVector.y*LEAVE_DIAGONAL_OFFSET
								else
									set .YPosition = .YPosition + newPosition.y
								endif
                                call SetUnitY(.Unit, YPosition)
								
								set .PushedAgainstVector = 0
								set .OnDiagonal = false
                                call .DiagonalPathing.destroy()
                                set .DiagonalPathing = 0
                            else
                                //diagonal changed from previous position to new position
                                static if DEBUG_DIAGONAL_TRANSITION then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal changes from: " + I2S(.DiagonalPathing.TerrainPathingForPoint) + " to: " + I2S(pathingResult.TerrainPathingForPoint))
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant changes from: " + I2S(.DiagonalPathing.QuadrantForPoint) + " to: " + I2S(pathingResult.QuadrantForPoint))
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal changes, current x: " + R2S(.XPosition) + " y: " + R2S(.YPosition) + " new x " + R2S(newPosition.x) + " new y " + R2S(newPosition.y))
                                    
                                    if pathingResult.TerrainMidpointX != .DiagonalPathing.TerrainMidpointX or pathingResult.TerrainMidpointY != .DiagonalPathing.TerrainMidpointY then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "Midpoint x, y: " + R2S(pathingResult.TerrainMidpointX) + ", " + R2S(pathingResult.TerrainMidpointY) + ", index: " + R2S(pathingResult.TerrainMidpointX / TERRAIN_TILE_SIZE) + ", " + R2S(pathingResult.TerrainMidpointY / TERRAIN_TILE_SIZE))
                                        
                                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Midpoint stays same")
                                        //debug set centerUnit = Recycle_MakeUnitForPlayer(DEBUG_UNIT, pathingResult.TerrainMidpointX, pathingResult.TerrainMidpointY, Player(0))
                                        //debug call TimerStart(NewTimerEx(GetUnitUserData(centerUnit)), 1, false, function thistype.RemoveCenterUnitCB)
                                    endif
                                endif
                                
                                //if the diagonal has changed, then need to:
                                //project remaining distance along new diagonal (maybe approximate)
                                
                                //build equation for line and then plug in x and get y
                                //slope of line depends on diagonal
                                //intersect of line depends on diagonal and quadrant, and is relative to terrain centerX, Y
                                //project newX,newY onto new diagonal, in the proper direction
                                if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square then
                                    //project platformer onto the most relevant surface of the square OR deny movement entirely
                                    
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Encountered a square!")
                                    
                                    //either two cases: side continues as square tile OR side makes a corner with square tile
                                    //legal if changed only 1 of two compass directions (ex NE -> NW, but not NE -> SE)
                                    //check to see if hit a corner
                                    if (.DiagonalPathing.QuadrantForPoint == ComplexTerrainPathing_NE and pathingResult.QuadrantForPoint == ComplexTerrainPathing_SW) or (.DiagonalPathing.QuadrantForPoint == ComplexTerrainPathing_SE and pathingResult.QuadrantForPoint == ComplexTerrainPathing_NW) or (.DiagonalPathing.QuadrantForPoint == ComplexTerrainPathing_SW and pathingResult.QuadrantForPoint == ComplexTerrainPathing_NE) or (.DiagonalPathing.QuadrantForPoint == ComplexTerrainPathing_NW and pathingResult.QuadrantForPoint == ComplexTerrainPathing_SE) then
                                        //hit a corner, clear relevant x, y velocity
                                        if pathingResult.RelevantXTerrainTypeID != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "Inside diagonal/square corner setting x velocity to 0")
                                            endif
											
                                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
											
											if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
												call HardStopEffect(this, .XVelocity)
											endif
											
                                            set .XVelocity = 0
                                        endif
                                        
                                        if pathingResult.RelevantYTerrainTypeID != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "Inside diagonal/square corner setting y velocity to 0")
                                            endif
											
                                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                           
											if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
												call HardStopEffect(this, .YVelocity)
											endif
											
											set .YVelocity = 0
                                        endif
                                        
                                        //this only works when obstructing wall is square, if obstructing wall is diag then this glitches
                                        //its not very smooth when unit goes from diagonal to wall collision to free falling to diagonal... better to pretend we stayed on the same diagonal
                                        //to do this right we'd need a corner state for all 8 corners
                                        //call pathingResult.destroy()
                                        //set pathingResult = .DiagonalPathing
                                    else
                                        //continued onto square matching previous diagonal surface
                                        if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                                            static if DEBUG_DIAGONAL_TRANSITION then
                                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Switching from left to square")
                                            endif
                                            set newX = pathingResult.TerrainMidpointX - TERRAIN_QUADRANT_SIZE - wOFFSET
                                            set newY = .YPosition + newPosition.y
                                        elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                                            static if DEBUG_DIAGONAL_TRANSITION then
                                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Switching from right to square")
                                            endif
                                            set newX = pathingResult.TerrainMidpointX + TERRAIN_QUADRANT_SIZE + wOFFSET
                                            set newY = .YPosition + newPosition.y
                                        elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                                            static if DEBUG_DIAGONAL_TRANSITION then
                                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Switching from top to square")
                                            endif
                                            set newX = .XPosition + newPosition.x
                                            set newY = pathingResult.TerrainMidpointY + TERRAIN_QUADRANT_SIZE + wOFFSET
                                        elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                                            static if DEBUG_DIAGONAL_TRANSITION then    
                                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Switching from bottom to square")
                                            endif
                                            set newX = .XPosition + newPosition.x
                                            set newY = pathingResult.TerrainMidpointY - TERRAIN_QUADRANT_SIZE - wOFFSET
                                        endif
                                        
                                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Prev x: " + R2S(.XPosition) + ", " + R2S(newX))
                                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Prev y: " + R2S(.YPosition) + ", " + R2S(newY))
                                        
                                        set ttype = GetTerrainType(newX, .YPosition)
                                        if TerrainGlobals_IsTerrainPathable(ttype) then
                                            set .XTerrainPushedAgainst = 0
                                            set .XPosition = newX
                                            call SetUnitX(.Unit, .XPosition)
                                        else
                                            set .XTerrainPushedAgainst = ttype
                                            
                                            if newPosition.x > 0 then
                                                set .PushedAgainstVector = ComplexTerrainPathing_Left_UnitVector
                                            else
                                                set .PushedAgainstVector = ComplexTerrainPathing_Right_UnitVector
                                            endif
                                            
                                            if not TerrainGlobals_IsTerrainSoft(ttype) then
                                                static if DEBUG_VELOCITY_TERRAIN then
                                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "3 Colliding with hard x, setting velocity to 0")
                                                endif
												
												if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
													call HardStopEffect(this, .XVelocity)
												endif
												
                                                set .XVelocity = 0
                                            endif
                                        endif
                                        
                                        set ttype = GetTerrainType(.XPosition, newY)
                                        if TerrainGlobals_IsTerrainPathable(ttype) then
                                            set .YTerrainPushedAgainst = 0
                                            set .YPosition = newY
                                            call SetUnitY(.Unit, .YPosition)
                                        else
                                            set .YTerrainPushedAgainst = ttype
                                            
                                            if newPosition.y > 0 then
                                                set .PushedAgainstVector = ComplexTerrainPathing_Down_UnitVector
                                            else
                                                set .PushedAgainstVector = ComplexTerrainPathing_Up_UnitVector
                                            endif
                                            
                                            if not TerrainGlobals_IsTerrainSoft(ttype) then
                                                static if DEBUG_VELOCITY_TERRAIN then
                                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "3 Colliding with hard y, setting velocity to 0")
                                                endif

												if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
													call HardStopEffect(this, .YVelocity)
												endif
												
                                                set .YVelocity = 0
                                            endif
                                        endif
                                        
                                        set .OnDiagonal = false
                                        call .DiagonalPathing.destroy()
                                        set .DiagonalPathing = 0
                                        
                                        static if DEBUG_DIAGONAL_ESCAPE then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left diagonal via square transfer")
                                        endif
                                    endif
                                //I think this will project newPosition onto the new diagonal's orthogonal and see if it exceeds the sticky constant. If it does, then leave the diagonal
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                                    //restrict x to boundaries of wall
                                    set .XPosition = pathingResult.TerrainMidpointX - IN_DIAGONAL_OFFSET
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    call SetUnitX(.Unit, .XPosition)
                                    
                                    //let y go crazy
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    set .YPosition = .YPosition + newPosition.y
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_Left_UnitVector
                                    
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    //if we were coming from a diagonal then apply part of x velocity to y
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                                        set .YVelocity = .YVelocity - .XVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "4 Colliding with hard x, setting velocity to 0")
											endif
											
											set .XVelocity = 0
                                        else
                                            set .XVelocity = .XVelocity * SIN_45
                                        endif
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                                        set .YVelocity = .YVelocity + .XVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "5 Colliding with hard x, setting velocity to 0")
											endif
											
											set .XVelocity = 0
                                        else
                                            set .XVelocity = .XVelocity * SIN_45
                                        endif
                                    elseif .XVelocity != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "6 Colliding with hard x, setting velocity to 0")
										endif
										
										if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .XVelocity)
										endif
										
										set .XVelocity = 0
                                    endif
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                                    set .XPosition = pathingResult.TerrainMidpointX + IN_DIAGONAL_OFFSET
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    call SetUnitX(.Unit, .XPosition)
                                    
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    set .YPosition = .YPosition + newPosition.y
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_Right_UnitVector
                                    
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    //if we were coming from a diagonal then apply part of x velocity to y
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                                        set .YVelocity = .YVelocity + .XVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "7 Colliding with hard x, setting velocity to 0")
											endif
											
											set .XVelocity = 0
                                        else
                                            set .XVelocity = .XVelocity * SIN_45
                                        endif
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                                        set .YVelocity = .YVelocity - .XVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "8 Colliding with hard x, setting velocity to 0")
											endif
											
											set .XVelocity = 0
                                        else
                                            set .XVelocity = .XVelocity * SIN_45
                                        endif
                                    elseif .XVelocity != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "9 Colliding with hard x, setting velocity to 0")
										endif
										
										if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .XVelocity)
										endif
										
										set .XVelocity = 0
                                    endif
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                                    //let x go crazy
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    set .XPosition = .XPosition + newPosition.x
                                    call SetUnitX(.Unit, .XPosition)
                                    
                                    //restrict y to boundaries of wall
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    set .YPosition = pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_Up_UnitVector
                                    
                                    //if we were coming from a diagonal then apply part of x velocity to y
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                                        set .XVelocity = .XVelocity - .YVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "4 Colliding with hard y, setting velocity to 0")
											endif
											
											set .YVelocity = 0
                                        else
                                            set .YVelocity = .YVelocity * SIN_45
                                        endif
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                                        set .XVelocity = .XVelocity + .YVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "5 Colliding with hard y, setting velocity to 0")
											endif
											
											set .YVelocity = 0
                                        else
                                            set .YVelocity = .YVelocity * SIN_45
                                        endif
                                    elseif .YVelocity != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "6 Colliding with hard y, setting velocity to 0")
										endif
										
										if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .YVelocity)
										endif
										
										set .YVelocity = 0
                                    endif
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    set .XPosition = .XPosition + newPosition.x
                                    call SetUnitX(.Unit, .XPosition)
                                    
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    set .YPosition = pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_Down_UnitVector
                                    
                                    //if we were coming from a diagonal then apply part of x velocity to y
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                                        set .XVelocity = .XVelocity + .YVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "7 Colliding with hard y, setting velocity to 0")
											endif
											
											set .YVelocity = 0
                                        else
                                            set .YVelocity = .YVelocity * SIN_45
                                        endif
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                                        set .XVelocity = .XVelocity - .YVelocity * SIN_45
                                        
                                        if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                            static if DEBUG_VELOCITY_TERRAIN then
												call DisplayTextToForce(bj_FORCE_PLAYER[0], "8 Colliding with hard y, setting velocity to 0")
											endif
											
											set .YVelocity = 0
                                        else
                                            set .YVelocity = .YVelocity * SIN_45
                                        endif
                                    elseif .YVelocity != 0 and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "9 Colliding with hard y, setting velocity to 0")
										endif
										
										if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .YVelocity)
										endif
										
										set .YVelocity = 0
                                    endif
                                elseif (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE and (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SE or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NW)) or (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE and (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SW or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NE)) or (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW and (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NW or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SE)) or (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW and (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SW or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NE)) then
                                    //hit an inside corner
                                    set newPosition.x = 0
                                    
                                    //TODO get a more appropriate unit vector, orthogonal to a vert or horizontal
                                    //the above will be problematic, because the platformers orthogonal .PushedAgainstVector only updates on diagonal change
                                    //in order for it to work, corners would need their own pathing type, which might be a really good idea for caching reasons anyways
                                    if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                                        set .PushedAgainstVector = ComplexTerrainPathing_NE_UnitVector
                                    elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                                        set .PushedAgainstVector = ComplexTerrainPathing_SE_UnitVector
                                    elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                                        set .PushedAgainstVector = ComplexTerrainPathing_SW_UnitVector
                                    elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                                        set .PushedAgainstVector = ComplexTerrainPathing_NW_UnitVector
                                    endif
                                    
                                    //check if velocity should be zeroed
                                    if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "10 Colliding with hard x, setting velocity to 0")
										endif
										
										if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .XVelocity)
										endif
										
										set .XVelocity = 0
                                    endif
                                    if not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                        static if DEBUG_VELOCITY_TERRAIN then
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "10 Colliding with hard y, setting velocity to 0")
										endif
										
										if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .YVelocity)
										endif
										
										set .YVelocity = 0
                                    endif
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 current x: " + R2S(.XPosition) + " x delta: " + R2S(newPosition.x) + " terrain center Y: " + R2S(pathingResult.TerrainMidpointY))
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE, current x: " + R2S(.XPosition) + " new x: " + R2S(.XPosition + newPosition.x))                                    
                                    //simplify projection by ignoring the initial y coordinate
                                    set .XPosition = .XPosition + newPosition.x
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    
                                    if pathingResult.QuadrantForPoint == ComplexTerrainPathing_SW then
                                        //set .YPosition = -newPosition.x + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE Y1, current y: " + R2S(.YPosition) + " new y: " + R2S(pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET))
                                        set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                    else //all other quadrants use same b
                                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "NE Y2, current y: " + R2S(.YPosition) + " new y: " + R2S(pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET))
                                        set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                    endif                                
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0],  "1 x: " + R2S(.XPosition) + ", y: " + R2S(.YPosition)) 
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0],  "1 new x: " + R2S(newPosition.x) + ", new y: " + R2S(newPosition.y)) 
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 newX: " + R2S(newX) + " newY: " + R2S(pathingResult.TerrainMidpointY + newX - pathingResult.TerrainMidpointX)) 
                                    
                                    call SetUnitX(.Unit, .XPosition)
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_NE_UnitVector
                                    
                                    //if we were coming from top
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                                        set .XVelocity = .XVelocity * SIN_45
                                        set .YVelocity = .YVelocity - .XVelocity /* * SIN_45 */
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                                        set .YVelocity = .YVelocity * SIN_45
                                        set .XVelocity = .XVelocity - .YVelocity
                                    endif
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                                    //simplify projection by ignoring the initial y coordinate
                                    set .XPosition = .XPosition + newPosition.x
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    
                                    if pathingResult.QuadrantForPoint == ComplexTerrainPathing_NW then
                                        //set .YPosition = newPosition.x + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                        set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                    else //all other quadrants use same b
                                        set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                    endif                                
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                                    
                                    call SetUnitX(.Unit, .XPosition)
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_SE_UnitVector
                                    
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                                        set .XVelocity = .XVelocity * SIN_45
                                        set .YVelocity = .YVelocity + .XVelocity /* * SIN_45 */
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                                        set .YVelocity = .YVelocity * SIN_45
                                        set .XVelocity = .XVelocity + .YVelocity
                                    endif
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                                    //simplify projection by ignoring the initial y coordinate
                                    set .XPosition = .XPosition + newPosition.x
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    
                                    if pathingResult.QuadrantForPoint == ComplexTerrainPathing_NE then
                                        set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                    else //all other quadrants use same b
                                        set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                    endif                                
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "3 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                                    
                                    call SetUnitX(.Unit, .XPosition)
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_SW_UnitVector
                                    
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                                        set .XVelocity = .XVelocity * SIN_45
                                        set .YVelocity = .YVelocity - .XVelocity /* * SIN_45 */
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                                        set .YVelocity = .YVelocity * SIN_45
                                        set .XVelocity = .XVelocity - .YVelocity
                                    endif
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                                    //simplify projection by ignoring the initial y coordinate
                                    set .XPosition = .XPosition + newPosition.x
                                    set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                                    
                                    if pathingResult.QuadrantForPoint == ComplexTerrainPathing_SE then
                                        set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                    else //all other quadrants use same b
                                        set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                    endif                                
                                    set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID

                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                                    
                                    call SetUnitX(.Unit, .XPosition)
                                    call SetUnitY(.Unit, .YPosition)
                                    
                                    set .PushedAgainstVector = ComplexTerrainPathing_NW_UnitVector
                                    
                                    //if we were coming from top
                                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
                                    if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                                        set .XVelocity = .XVelocity * SIN_45
                                        set .YVelocity = .YVelocity + .XVelocity /* * SIN_45 */
                                    elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                                        set .YVelocity = .YVelocity * SIN_45
                                        set .XVelocity = .XVelocity + .YVelocity
                                    endif
                                else
                                    static if DEBUG_DIAGONAL_TRANSITION then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "Change Diagonals: Invalid Diagonal -- " + I2S(pathingResult.TerrainPathingForPoint))
                                    endif
                                endif                                
                            endif
                            
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished pathing!") 
                            
                            //finally update pathing if its changed
                            if pathingResult != .DiagonalPathing then
                                call .DiagonalPathing.destroy()
                                set .DiagonalPathing = pathingResult
                                
                                if pathingResult == 0 then
                                    set .OnDiagonal = false
                                endif
                            endif
                        else
                            //projected position (along diagonal) couldn't move -- check if we need to zero out velocity in either direction
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected position couldn't move") 
                            if .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top and .YVelocity < 0 and not TerrainGlobals_IsTerrainSoft(.DiagonalPathing.RelevantYTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "11 Colliding with hard y, setting velocity to 0")
                                endif
                                
								if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .YVelocity)
								endif
								
								set .YVelocity = 0
                            elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom and .YVelocity > 0 and not TerrainGlobals_IsTerrainSoft(.DiagonalPathing.RelevantYTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "12 Colliding with hard y, setting velocity to 0")
                                endif
                                
								if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .YVelocity)
								endif
								
								set .YVelocity = 0
                            elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Left and .XVelocity > 0 and not TerrainGlobals_IsTerrainSoft(.DiagonalPathing.RelevantXTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "11 Colliding with hard x, setting velocity to 0")
                                endif
                                
								if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .XVelocity)
								endif
								
								set .XVelocity = 0
                            elseif .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Right and .XVelocity < 0 and not TerrainGlobals_IsTerrainSoft(.DiagonalPathing.RelevantXTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "12 Colliding with hard x, setting velocity to 0")
                                endif
                                
								if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .XVelocity)
								endif
								
								set .XVelocity = 0
                            endif
                        endif
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destroyed") 
                        call newPosition.destroy()
                    endif
                else //not currently on a diagonal
                    //bound newX and newY if they're too big -- this needs to occur AFTER checking if point escapes diagonal, or else the result may be skewed towards any much larger value
					set distance = SquareRoot(newX * newX + newY * newY)
					if distance > PLATFORMING_MAXCHANGE then
						//boundedPercent = PLATFORMING_MAXCHANGE / distance
						
						set newX = newX * PLATFORMING_MAXCHANGE / distance
						set newY = newY * PLATFORMING_MAXCHANGE / distance
					endif
						
					//TODO implement raycasting to get the first non pathable complex terrain pathing result for newX newY pairs that are big enough to need it to be accurate
                    set newPosition = vector2.create(newX, newY)
                    
                    if newX > 0 then
                        set directionX = 1
                    elseif newX < 0 then
                        set directionX = -1
					else
						set directionX = 0
                    endif
                    if newY > 0 then
                        set directionY = 1
                    elseif newY < 0 then
                        set directionY = -1
					else
						set directionY = 0
                    endif
                    
                    static if PLATFORMING_CHECK_HALFWAY then
                        //try just checking halfway
                        set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newPosition.x * .5 + directionX * wOFFSET, .YPosition + newPosition.y * .5 + directionY * wOFFSET)
                        
                        if pathingResult == 0 then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking end of movement segment")
                            set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newPosition.x + directionX * wOFFSET, .YPosition + newPosition.y + directionY * wOFFSET)
                        endif
                    else
                        set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newPosition.x + directionX * wOFFSET, .YPosition + newPosition.y + directionY * wOFFSET)
						
						static if DEBUG_DIAGONAL_START_CHECK then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking pathing at x:" + R2SW(.XPosition + newPosition.x + directionX * wOFFSET, 4, 10) + ", y: " + R2SW(.YPosition + newPosition.y + directionY * wOFFSET, 4, 10))
						endif
					endif
                                        
                    if pathingResult == 0 then
                        //check if we are currently pushed against any surfaces, because if we are, we need to check that we're not pathing across an open diagonal between square blocks
                        if .XTerrainPushedAgainst != 0 or .YTerrainPushedAgainst != 0 then
                            //check if x and y terrain are pathable individually
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "open space, double check")
                            
                            if newPosition.x != 0 then
                                set ttype = GetTerrainType(.XPosition + newPosition.x, .YPosition)
                                if TerrainGlobals_IsTerrainPathable(ttype) then
                                    set .XTerrainPushedAgainst = 0
                                    set .XPosition = .XPosition + newPosition.x
                                    call SetUnitX(.Unit, .XPosition)
                                else
                                    set .XTerrainPushedAgainst = ttype
                                    
                                    if newPosition.x > 0 then
                                        set .PushedAgainstVector = ComplexTerrainPathing_Left_UnitVector
                                    else
                                        set .PushedAgainstVector = ComplexTerrainPathing_Right_UnitVector
                                    endif
                                    
                                    if not TerrainGlobals_IsTerrainSoft(ttype) then
                                        static if DEBUG_VELOCITY then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Open Setting x velocity to 0")
                                        endif
                                        
										if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .XVelocity)
										endif
										
                                        set .XVelocity = 0
                                    endif
                                endif
                            else
                                set .XTerrainPushedAgainst = 0
                            endif
                            
                            if newPosition.y != 0 then
                                set ttype = GetTerrainType(.XPosition, .YPosition + newPosition.y)
                                if TerrainGlobals_IsTerrainPathable(ttype) then
                                    call SetUnitY(.Unit, .YPosition + newPosition.y)
                                    set .YPosition = .YPosition + newPosition.y
                                    
                                    set .YTerrainPushedAgainst = 0
                                else
                                    set .YTerrainPushedAgainst = ttype
                                    
                                    if newPosition.y > 0 then
                                        set .PushedAgainstVector = ComplexTerrainPathing_Down_UnitVector
                                    else
                                        set .PushedAgainstVector = ComplexTerrainPathing_Up_UnitVector
                                    endif
                                    
                                    
                                    if not TerrainGlobals_IsTerrainSoft(ttype) then
                                        static if DEBUG_VELOCITY then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Open Setting y velocity to 0")
                                        endif
                                        
										if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
											call HardStopEffect(this, .YVelocity)
										endif
										
                                        set .YVelocity = 0
                                    endif
                                endif
                            else
                                set .YTerrainPushedAgainst = 0
                            endif
                        else
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "open space, single check")
                            
                            //open space, not pushed against any unpathable surfaces in the x direction
                            set .XTerrainPushedAgainst = 0
                            set .XPosition = .XPosition + newPosition.x
                            call SetUnitX(.Unit, .XPosition)
                            
                            set .YTerrainPushedAgainst = 0
                            set .YPosition = .YPosition + newPosition.y
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = 0
                        endif
                        
                        //finally release the pathing result as there's no point in storing an open pathing result
                        call pathingResult.destroy()
                                                
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Open Space")
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved to open space x, y: " + R2S(.XPosition) + ", " + R2S(.YPosition) + "; new x: " + R2S(newX) + ", new Y: " + R2S(newY))
                    elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Inside then
                        //--T-O-D-O-- consider iterating when we hit an inside point
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, going too fast for pathing and hit inside area of diagonal tiles")
                        call pathingResult.destroy()
                    elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square then
                        //need to evaluate x and y separately so that one can be applied even if the other can't
                        //apply x first
                        
                        //TODO if the unit would path into a wall, then don't completely deny their movement, move them up to the wall
                        
                        //too much work to do full complex pathing for this subcase, because then i'd need all the different cases inside
                        //call pathingResult.Release()
                        //set pathingResult = GetPathingForPoint(newX, .CurrentY)
                        if newPosition.x != 0 then
							//TODO does this all really need to happen or can i just check TerrainGlobals_IsTerrainPathable(GetTerrainType(.XPosition + newPosition.x + directionX*wOFFSET, .YPosition))
                            call pathingResult.destroy()
                            set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition + newPosition.x + directionX*wOFFSET, .YPosition)
                            
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "New x: " + R2S(newPosition.x) + ", velocity x: " + R2S(.XVelocity))
                            
                            if pathingResult == 0 then
                                set .XTerrainPushedAgainst = 0
                                set .XPosition = .XPosition + newPosition.x
                                call SetUnitX(.Unit, .XPosition)
                            else
                                set .XTerrainPushedAgainst = GetTerrainType(pathingResult.TerrainMidpointX, pathingResult.TerrainMidpointY)
                                
                                //needs a more accurate GetTerrainCenter
                                if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                                    if newPosition.x >= 0 then
                                        set .XPosition = GetTerrainLeft(pathingResult.TerrainMidpointX) - wOFFSET
                                    else
                                        set .XPosition = GetTerrainRight(pathingResult.TerrainMidpointX) + wOFFSET
                                    endif
                                    
									static if DEBUG_SQUARE then
										call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Position blocked by square tile: " + R2SW(.XPosition, 5, 10))
									endif
									
                                    call SetUnitX(.Unit, .XPosition)
                                endif
                                
                                if not TerrainGlobals_IsTerrainSoft(.XTerrainPushedAgainst) then
                                    static if DEBUG_VELOCITY_TERRAIN then
										call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with hard square x, setting velocity to 0")
									endif
									
									if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
										call HardStopEffect(this, .XVelocity)
									endif
									
									set .XVelocity = 0
                                endif
                            endif                            
                        else
                            set .XTerrainPushedAgainst = 0
                        endif
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "square x, y velocity: " + R2S(.XVelocity) + ", " + R2S(.YVelocity))
                        
                        if newPosition.y != 0 then
                            call pathingResult.destroy()
                            set pathingResult = ComplexTerrainPathing_GetPathingForPoint(.XPosition, .YPosition + newPosition.y + directionY*wOFFSET)
                            
							static if DEBUG_SQUARE then
								call DisplayTextToForce(bj_FORCE_PLAYER[0], "Getting exact Y pathing at: " + R2SW(.YPosition + newPosition.y + directionY*wOFFSET, 5, 10))
							endif
							
                            if pathingResult == 0 then
                                set .YTerrainPushedAgainst = 0
                                set .YPosition = .YPosition + newPosition.y
                                call SetUnitY(.Unit, .YPosition)
                            else
                                set .YTerrainPushedAgainst = GetTerrainType(pathingResult.TerrainMidpointX, pathingResult.TerrainMidpointY)
                                
                                //needs a more accurate GetTerrainCenter
								if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top then
									if newPosition.y >= 0 then
										set .YPosition = GetTerrainBottom(pathingResult.TerrainMidpointY) - wOFFSET
									else
										set .YPosition = GetTerrainTop(pathingResult.TerrainMidpointY) + wOFFSET
									endif
									
									static if DEBUG_SQUARE then
										call DisplayTextToForce(bj_FORCE_PLAYER[0], "Y Position blocked by square tile: " + R2SW(.YPosition, 5, 10))
									endif
									
									call SetUnitY(.Unit, .YPosition)
                                endif
								
                                if not TerrainGlobals_IsTerrainSoft(.YTerrainPushedAgainst) then
                                    static if DEBUG_VELOCITY_TERRAIN then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with hard square y, setting velocity to 0")
                                    endif
                                    
									if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
										call HardStopEffect(this, .YVelocity)
									endif
									
									set .YVelocity = 0
                                endif
                            endif                            
                        else
                            set .YTerrainPushedAgainst = 0
                        endif
                        
                        //set push vector
                        //don't represent both surfaces being pushed against for square tiles, instead just have the Y push trump the X
                        if .YTerrainPushedAgainst != 0 then
                            if newPosition.y > 0 then
                                set .PushedAgainstVector = ComplexTerrainPathing_Down_UnitVector
                            else
                                set .PushedAgainstVector = ComplexTerrainPathing_Up_UnitVector
                            endif
                        elseif .XTerrainPushedAgainst != 0 then
                            if newPosition.x > 0 then
                                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "newX: " + R2S(newPosition.x))
                                set .PushedAgainstVector = ComplexTerrainPathing_Left_UnitVector
                            else
                                set .PushedAgainstVector = ComplexTerrainPathing_Right_UnitVector
                            endif
                        endif
                        
                        //not storing square pathing description for now
                        call pathingResult.destroy()
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "square x, y: " + R2S(.XPosition) + ", " + R2S(.YPosition))
                    else //now on a diagonal tile!
                        set .OnDiagonal = true
                        set .DiagonalPathing = pathingResult
                        
                        static if DEBUG_DIAGONAL_START then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal " + I2S(pathingResult.TerrainPathingForPoint) + " starts in quadrant " + I2S(pathingResult.QuadrantForPoint))
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Midpoint x, y: " + R2S(pathingResult.TerrainMidpointX) + ", " + R2S(pathingResult.TerrainMidpointY) + ", index: " + R2S(pathingResult.TerrainMidpointX / TERRAIN_TILE_SIZE) + ", " + R2S(pathingResult.TerrainMidpointY / TERRAIN_TILE_SIZE))
                            //set centerUnit = Recycle_MakeUnitForPlayer(DEBUG_UNIT, pathingResult.TerrainMidpointX, pathingResult.TerrainMidpointY, Player(0))
                            //call TimerStart(NewTimerEx(GetUnitUserData(centerUnit)), 1, false, function thistype.RemoveCenterUnitCB)
                        endif
                        
                        //project newX,newY onto new diagonal, in the proper direction
                        if pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left then
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            set .XPosition = pathingResult.TerrainMidpointX - IN_DIAGONAL_OFFSET
                            call SetUnitX(.Unit, .XPosition)
                            
                            //let y go crazy
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            set .YPosition = .YPosition + newPosition.y
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_Left_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right then
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            set .XPosition = pathingResult.TerrainMidpointX + IN_DIAGONAL_OFFSET
                            call SetUnitX(.Unit, .XPosition)
                            
                            //let y go crazy
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            set .YPosition = .YPosition + newPosition.y
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_Right_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top then
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            set .YPosition = pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                            call SetUnitY(.Unit, .YPosition)
                            
                            //let x go crazy
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            set .XPosition = .XPosition + newPosition.x
                            call SetUnitX(.Unit, .XPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_Up_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            set .YPosition = pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                            call SetUnitY(.Unit, .YPosition)
                        
                            //let x go crazy
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            set .XPosition = .XPosition + newPosition.x
                            call SetUnitX(.Unit, .XPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_Down_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NE then
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 current x: " + R2S(.XPosition) + " x delta: " + R2S(newPosition.x) + " terrain center Y: " + R2S(pathingResult.TerrainMidpointY))
                            //simplify projection by ignoring the initial y coordinate
                            set .XPosition = .XPosition + newPosition.x
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            
                            if pathingResult.QuadrantForPoint == ComplexTerrainPathing_SW then
                                //set .YPosition = -newPosition.x + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                                set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                            else //all other quadrants use same b
                                set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                            endif                                
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0],  "1 x: " + R2S(.XPosition) + ", y: " + R2S(.YPosition)) 
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0],  "1 new x: " + R2S(newPosition.x) + ", new y: " + R2S(newPosition.y)) 
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "1 newX: " + R2S(newX) + " newY: " + R2S(pathingResult.TerrainMidpointY + newX - pathingResult.TerrainMidpointX)) 
                            
                            call SetUnitX(.Unit, .XPosition)
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_NE_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SE then
                            //simplify projection by ignoring the initial y coordinate
                            set .XPosition = .XPosition + newPosition.x
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            
                            if pathingResult.QuadrantForPoint == ComplexTerrainPathing_NW then
                                //set .YPosition = newPosition.x + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                                set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                            else //all other quadrants use same b
                                set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                            endif                                
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                            
                            call SetUnitX(.Unit, .XPosition)
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_SE_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_SW then
                            //simplify projection by ignoring the initial y coordinate
                            set .XPosition = .XPosition + newPosition.x
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            
                            if pathingResult.QuadrantForPoint == ComplexTerrainPathing_NE then
                                set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                            else //all other quadrants use same b
                                set .YPosition = pathingResult.TerrainMidpointX - .XPosition + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                            endif                                
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "3 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                            
                            call SetUnitX(.Unit, .XPosition)
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_SW_UnitVector
                        elseif pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_NW then
                            //simplify projection by ignoring the initial y coordinate
                            set .XPosition = .XPosition + newPosition.x
                            set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                            
                            if pathingResult.QuadrantForPoint == ComplexTerrainPathing_SE then
                                set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY - IN_DIAGONAL_OFFSET
                            else //all other quadrants use same b
                                set .YPosition = .XPosition - pathingResult.TerrainMidpointX + pathingResult.TerrainMidpointY + IN_DIAGONAL_OFFSET
                            endif                                
                            set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID

                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "4 y: " + R2S(.YPosition) + " x: " + R2S(.XPosition)) 
                            
                            call SetUnitX(.Unit, .XPosition)
                            call SetUnitY(.Unit, .YPosition)
                            
                            set .PushedAgainstVector = ComplexTerrainPathing_NW_UnitVector
                        else
                            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid Diagonal")
                        endif
                        
                        //show effect -- or don't...
                        //Abilities\Spells\Human\ManaFlare\ManaFlareMissile.mdl
                        //set .FX = AddSpecialEffect("Abilities\\Spells\\Human\\ManaFlare\\ManaFlareMissile.mdl", .XPosition, .YPosition)
                        //call DestroyEffect(.FX)
                        //set .FX = null
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "New push vector: " + I2S(.PushedAgainstVector))
                        
                        //check to see if velocity should be zeroed out
                        if .XVelocity != 0 or .YVelocity != 0 then
                            if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom) and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantYTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
									call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with hard top/bottom y, setting velocity to 0")
								endif
                                
								if .YVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .YVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .YVelocity)
								endif
								
								set .YVelocity = 0
                            elseif (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right) and not TerrainGlobals_IsTerrainSoft(pathingResult.RelevantXTerrainTypeID) then
                                static if DEBUG_VELOCITY_TERRAIN then
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Colliding with hard left/right, setting velocity to 0")
                                endif
                                
								if .XVelocity >= VELOCITY_HARDSTOP_THRESHOLD or .XVelocity <= -VELOCITY_HARDSTOP_THRESHOLD then
									call HardStopEffect(this, .XVelocity)
								endif
								
								set .XVelocity = 0
                            else
                                static if DEBUG_DIAGONAL_START then
                                    //get the angle (in rads) representing the target diagonals slope
									set newY = ComplexTerrainPathing_GetAngleForUnitVector(ComplexTerrainPathing_GetUnitVectorForPathing(pathingResult.TerrainPathingForPoint))
									
									//get angle (in rads) between unit's new position and the positive x axis (0 game degrees)
									//set newX = Atan2((.YPosition + newPosition.y) - .YPosition, (.XPosition + newPosition.x) - .XPosition)
									set newX = Atan2(newPosition.y, newPosition.x)
									
									if newX < 0 then
                                        set newX = newX + 2*bj_PI
                                    endif
                                    
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Movement angle: " + R2S(newX) + ", Diagonal angle: " + R2S(newY))
                                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Angle change: " + R2S(newY - newX) + ", percent in direction cos: " + R2S(RAbsBJ(Cos(newY - newX))) + ", sin: " + R2S(RAbsBJ(Sin(newY - newX))))
                                endif
                                
                                //transitionAngleChange = newX - newY
                                //percentInDirection = |Cos(transitionAngleChange)|
                                //set newX = RAbsBJ(Cos(newY - newX))
                                
                                //set newPosition.x = .XVelocity * RAbsBJ(Cos(newY - newX)) + .YVelocity * RAbsBJ(Sin(newY - newX))
                                //set newPosition.y = .YVelocity * RAbsBJ(Cos(newY - newX)) + .XVelocity * RAbsBJ(Sin(newY - newX))
                                //set newPosition.x = .XVelocity * Cos(newY - newX) + .YVelocity * Sin(newY - newX)
                                //set newPosition.y = .YVelocity * Cos(newY - newX) + .XVelocity * Sin(newY - newX)
                                
                                set newPosition.x = .XVelocity
                                set newPosition.y = .YVelocity
                                call ProjectPositionAlongCurrentDiagonal(pathingResult, newPosition)

                                set .XVelocity = newPosition.x
                                set .YVelocity = newPosition.y
                            endif
                        endif
                        
                        //update terrain pushed against based on new diagonal
                        set .XTerrainPushedAgainst = pathingResult.RelevantXTerrainTypeID
                        set .YTerrainPushedAgainst = pathingResult.RelevantYTerrainTypeID
                    endif
                
                    call newPosition.destroy()
                endif
            else //there was no movement in the x or y directions at all, possible or not
                
                
                if .OnDiagonal then
                    //check if we escape the diagonal's stickyness
					//won't ever escape a diagonal by not moving
					/*
                    if DoesPointEscapeCurrentDiagonal(.DiagonalPathing, .PushedAgainstVector, newX, newY, DIAGONAL_ESCAPEDISTANCE) then
						debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Escaping diagonal by not moving!")
						
						set .OnDiagonal = false
                        call .DiagonalPathing.destroy()
                        set .DiagonalPathing = 0
                    endif
					*/
                else
                    //only diagonals need/support stickyness
                    set .YTerrainPushedAgainst = 0
                    set .XTerrainPushedAgainst = 0
                endif
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished pathing!") 
            
			static if DEBUG_POSITION then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "After Position: " + R2S(.XPosition) + "," + R2S(.YPosition))
			endif
			
            static if DEBUG_VELOCITY_FALLOFF then
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
            endif
            
            //TODO does velocity falloff need to happen in the main physics loop, which is performance hungry, or can that happen in a less performance needy timer?
            //decrement all relevant forces on the x-axis
            //X velocity should tend towards 0 if it isn't (an object in motion should tend to rest)
            //TODO change function to somehow be a easing function
            if .XVelocity != 0 then
                //decrement velocity remaining
                //set 0 if approx 0
                
                if .XVelocity > 0 then //velocity going right
                    if .XVelocity < xMINVELOCITY then //going super slow
                        set .XVelocity = 0
                    //TODO replace with 2nd power easing
                    else //anywhere inbetween
                        set .XVelocity = .XVelocity - .XFalloff * applyTimeDelta
                    endif
                    
                    //TODO this doesn't work with diagonals when you're on an actual diagonal slant
                    if .MoveSpeedVelOffset != 0 and .HorizontalAxisState == -1 then //left key down in opposite direction as XVelocity -- decrement XVelocity extra
                        set .XVelocity = .XVelocity - .MoveSpeed * .MoveSpeedVelOffset * applyTimeDelta
                    endif
                else //velocity going left
                    if .XVelocity > -xMINVELOCITY then
                        set .XVelocity = 0
                    else
                        set .XVelocity = .XVelocity + .XFalloff * applyTimeDelta
                    endif
                    
                    //TODO this doesn't work with diagonals when you're on an actual diagonal slant
                     if .MoveSpeedVelOffset != 0 and .HorizontalAxisState == 1 then //right key down in opposite direction as XVelocity -- decrement XVelocity extra
                        set .XVelocity = .XVelocity + .MoveSpeed * .MoveSpeedVelOffset * applyTimeDelta
                    endif
                endif
            endif
            
            //YVelocity going up
            if .YVelocity > 0 then
                //decrement YVelocity if over terminal velocity
				if .YVelocity > .TerminalVelocityY then
                    //todo replace with a smoothing function
                    set .YVelocity = .YVelocity - .YFalloff * applyTimeDelta
                endif
				//set .YVelocity = .YVelocity - .YFalloff
            elseif .YVelocity < 0 then
                //decrement YVelocity if over terminal velocity
				if .YVelocity < -.TerminalVelocityY then
                    //todo replace with a easing function
                    set .YVelocity = .YVelocity + .YFalloff * applyTimeDelta
                endif
				//set .YVelocity = .YVelocity + .YFalloff
            endif
            
            static if DEBUG_VELOCITY_FALLOFF then
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "After Velocity: " + R2S(.XVelocity) + "," + R2S(.YVelocity))
            endif
            
			static if DEBUG_PHYSICS_LOOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished physics ---")
			endif
        endmethod
                
        private method RemoveTerrainEffect takes nothing returns nothing
            if .TerrainDX == OCEAN then
                call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                
                call .GravityEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN)
                set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                
                call .XFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN)
                set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                
                call .YFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN)
                set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                                
                call .TVYEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN)
                set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
                
                //set .GravitationalAccel = .GravitationalAccel / PlatformerOcean_GRAVITYPERCENT
                //set .MoveSpeed = .MoveSpeed / PlatformerOcean_MS
                set .hJumpSpeed = .hJumpSpeed / PlatformerOcean_HJUMP
                set .vJumpSpeed = .vJumpSpeed / PlatformerOcean_VJUMP
                set .v2hJumpRatio = .v2hJumpRatio / PlatformerOcean_V2H
                //set .TerminalVelocityY = .TerminalVelocityY / PlatformerOcean_TVX
                //set .TerminalVelocityX = .TerminalVelocityX / PlatformerOcean_TVY
                //set .XFalloff = .XFalloff / PlatformerOcean_XFALLOFF
                //set .YFalloff = .YFalloff / PlatformerOcean_YFALLOFF
                set .MoveSpeedVelOffset = .MoveSpeedVelOffset / PlatformerOcean_MSOFF
                
                call PlatformerOcean_Remove(this)
            elseif .TerrainDX == VINES then
                call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
				
				call .GravityEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES)
                set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                //set .GravitationalAccel = .GravitationalAccel / VINES_SLOWDOWNPERCENT
                
                call .TVYEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES)
                set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
				
                //set .TerminalVelocityY = .TerminalVelocityY / VINES_SLOWDOWNPERCENT
                
                //feels better when you don't get speed back after
                //set .YVelocity = .YVelocity / VINES_SLOWDOWNPERCENT
                //set .MoveSpeed = .MoveSpeed / VINES_MOVESPEEDPERCENT
            elseif .TerrainDX == SLIPSTREAM then
                call .GravityEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM)
                set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                
                //call .TVYEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM)
                //set .TerminalVelocityY = .GravityEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
                                
                call .YFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM)
                set .YFalloff = .GravityEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                //set .GravitationalAccel = .GravitationalAccel * 10
                    
                call PlatformerSlipStream_Remove(this)
			elseif .TerrainDX == BOOST then
				call PlatformerBounce.Remove(this)
            endif
        endmethod
        
        private method RemoveXSurfaceTerrainEffect takes nothing /* integer oldtypeX, integer oldtypeY, integer newtypeX, integer newtypeY */ returns nothing
            //remove any effect from previous pushed against x terrain
            if .XAppliedTerrainPushedAgainst == SAND then
                call .YFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SAND)
                set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                //set .YFalloff = .YFalloff / SAND_FALLOFF
            elseif .XAppliedTerrainPushedAgainst == DGRASS then
                //set .GravitationalAccel = .GravitationalAccel * 10
            elseif .XAppliedTerrainPushedAgainst == SLOWICE then
                call .YFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE)
                set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                //set .YFalloff = .YFalloff  / PlatformerIce_SLOW_XFALLOFF
                
                //only remove from ice if no part of the platformer is still on ice
                if .YAppliedTerrainPushedAgainst != SLOWICE and .YAppliedTerrainPushedAgainst != FASTICE and .YTerrainPushedAgainst != FASTICE then
                    call PlatformerIce_Remove(this)
                endif
            elseif .XAppliedTerrainPushedAgainst == FASTICE then
                call .YFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE)
                set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                //set .YFalloff = .YFalloff / PlatformerIce_FAST_XFALLOFF
                
                //only remove from ice if no part of the platformer is still on ice
                if .YAppliedTerrainPushedAgainst != SLOWICE and .YAppliedTerrainPushedAgainst != FASTICE and .YTerrainPushedAgainst != SLOWICE then
                    call PlatformerIce_Remove(this)
                endif
            endif
        endmethod
        
        private method RemoveYSurfaceTerrainEffect takes nothing /* integer oldtypeX, integer oldtypeY, integer newtypeX, integer newtypeY */ returns nothing
            //remove any effect from previous pushed against y terrain
            if .YAppliedTerrainPushedAgainst == SAND then
                call .XFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SAND)
                set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
            elseif .YAppliedTerrainPushedAgainst == GRASS then				
				call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRASS)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
				
                call .TVYEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRASS)
                set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
			elseif .YAppliedTerrainPushedAgainst == DGRASS then
                call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, DGRASS)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                //set .MoveSpeed = .MoveSpeed / DGRASS_MS
				
                call .TVYEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, DGRASS)
                set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
            elseif .YAppliedTerrainPushedAgainst == SLOWICE then
                call .XFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE)
                set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                
                call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                
                //only remove from ice if no part of the platformer is still on ice and we wouldn't just be putting them back on
                if .XAppliedTerrainPushedAgainst != SLOWICE and .XAppliedTerrainPushedAgainst != FASTICE and .YTerrainPushedAgainst != FASTICE then
                    call PlatformerIce_Remove(this)
                endif
            elseif .YAppliedTerrainPushedAgainst == FASTICE then
                call .XFalloffEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE)
                set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                
                call .MSEquation.removeAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE)
                set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                
                if .XAppliedTerrainPushedAgainst != SLOWICE and .XAppliedTerrainPushedAgainst != FASTICE and .YTerrainPushedAgainst != SLOWICE then
                    call PlatformerIce_Remove(this)
                endif
            endif
        endmethod
                
        public method KillPlatformer takes nothing returns nothing
            call User(.PID).SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
            //call .StopPlatforming()
        endmethod
        
        private method UpdateTerrain takes nothing returns nothing
            local real x = GetUnitX(.Unit)
            local real y = GetUnitY(.Unit)
                        
            //update terrain at unit's x, y
            local integer ttype
            local vector2 terrainCenter
            local real offsetZone = TERRAIN_QUADRANT_SIZE - tOFFSET
            
            if .OnDiagonal then
                //reuse terrain center. DONT DEALLOCATE UNIT VECTORS
                set terrainCenter = ComplexTerrainPathing_GetUnitVectorForPathing(.DiagonalPathing.TerrainPathingForPoint)
                
                set ttype = GetTerrainType(x + DIAGONAL_TERRAIN_CHECK_OFFSET*terrainCenter.x, y + DIAGONAL_TERRAIN_CHECK_OFFSET*terrainCenter.y)                
            else
                set ttype = GetTerrainType(x, y)
            endif
            
            //TODO get dominant terrain type when on DEATH
            if ttype == DEATH then
                //check full sides individually                
                //if GetTerrainType(x + tOFFSET, y) == DEATH and GetTerrainType(x + tOFFSET * .75, y + tOFFSET * .75) == DEATH and GetTerrainType(x + tOFFSET * .75, y - tOFFSET * .75) == DEATH then
                
                //endif
                
                //get centerpoint and check based on that
                set terrainCenter = GetTerrainCenterpoint(x, y)
                set terrainCenter.x = terrainCenter.x - x
                set terrainCenter.y = terrainCenter.y - y
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "offset: " + R2S(offsetZone) + "; x, y: " + R2S(terrainCenter.x) + ", " + R2S(terrainCenter.y))
                
				//check if unit is within a much smaller square centered on this tile
                if terrainCenter.x < offsetZone and terrainCenter.x > -offsetZone and terrainCenter.y < offsetZone and terrainCenter.y > -offsetZone then
                    static if DEBUG_TERRAIN_KILL then
                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, center")
                        call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                    else
                        call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                    endif
                    
                    static if APPLY_TERRAIN_KILL then
                        call .KillPlatformer()
                    endif
                    
					call terrainCenter.destroy()
                    return
                else
					//check if unit is within a larger rectangle, formed by multiple squares of adjoining lava or non pathable tiles
                    if terrainCenter.x <= -offsetZone then
                        //on right side -- either of two corners or the middle
                        set ttype = GetTerrainType(x + tOFFSET, y)
                        if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                            if terrainCenter.y <= -offsetZone then
                                //top right
                                set ttype = GetTerrainType(x + tOFFSET, y + tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x, y + tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, top right side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif

										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            elseif terrainCenter.y >= offsetZone then
                                //bot right
                                set ttype = GetTerrainType(x + tOFFSET, y - tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x, y - tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, bottom right side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif
                                        
										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            else
                                //right
                                set ttype = GetTerrainType(x + tOFFSET, y - tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x + tOFFSET, y + tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, right side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif
                                        
										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            endif
                        endif
                    elseif terrainCenter.x > offsetZone then
                        //on left side
                        set ttype = GetTerrainType(x - tOFFSET, y)
                        if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                            if terrainCenter.y <= -offsetZone then
                                //top left
                                set ttype = GetTerrainType(x - tOFFSET, y + tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x, y + tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, top left side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif
                                        
										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            elseif terrainCenter.y >= offsetZone then
                                //bot left
                                set ttype = GetTerrainType(x - tOFFSET, y - tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x, y - tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, bottom left side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif

										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            else
                                //left
                                set ttype = GetTerrainType(x - tOFFSET, y - tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    set ttype = GetTerrainType(x - tOFFSET, y + tOFFSET)
                                    if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                        static if DEBUG_TERRAIN_KILL then
                                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, left side")
                                            call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        else
                                            call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                        endif
                                        
                                        static if APPLY_TERRAIN_KILL then
                                            call .KillPlatformer()
                                        endif

										call terrainCenter.destroy()
                                        return
                                        //set ttype = DEATH
                                    endif
                                endif
                            endif
                        endif
                    elseif terrainCenter.y <= -offsetZone then
                        //top middle side
                        set ttype = GetTerrainType(x, y + tOFFSET)
                        if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                            set ttype = GetTerrainType(x - tOFFSET, y + tOFFSET)
                            if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                set ttype = GetTerrainType(x + tOFFSET, y + tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    static if DEBUG_TERRAIN_KILL then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, top side")
                                        call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                    else
                                        call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                    endif
                                    
                                    static if APPLY_TERRAIN_KILL then
                                        call .KillPlatformer()
                                    endif

									call terrainCenter.destroy()
                                    return
                                    //set ttype = DEATH
                                endif
                            endif
                        endif
                    elseif terrainCenter.y >= offsetZone then
                        //bottom middle side
                        set ttype = GetTerrainType(x, y - tOFFSET)
                        if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                            set ttype = GetTerrainType(x - tOFFSET, y - tOFFSET)
                            if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                set ttype = GetTerrainType(x + tOFFSET, y - tOFFSET)
                                if ttype == DEATH or not TerrainGlobals_IsTerrainPathable(ttype) then
                                    static if DEBUG_TERRAIN_KILL then
                                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "On lava, bottom side")
                                        call DestroyEffect(AddSpecialEffect(DEBUG_TERRAIN_KILL_FX, .XPosition, .YPosition))
                                    else
                                        call DestroyEffect(AddSpecialEffect(TERRAIN_KILL_FX, .XPosition, .YPosition))
                                    endif
                                    
                                    static if APPLY_TERRAIN_KILL then
                                        call .KillPlatformer()
                                    endif

									call terrainCenter.destroy()
                                    return
                                    //set ttype = DEATH
                                endif
                            endif
                        endif
                    endif                
                endif
                
                call terrainCenter.destroy()
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "On terrain " + I2S(.TerrainDX) + ", new on terrain: " + I2S(ttype))
            
            //TODO change so that platformer dies if there are 3 adjacent points in the 8 points around them that are all lava
            //  * * X
            //  * O X
            //  X X X
            //
            // Safe
            //
            //  X * X
            //  * O X
            //  X X X
            //
            // Dead
            
            //check n
            //if true -> check n + 1 and then n - 1
            //if false -> check n + 2
            
            
            //start with death check
            /*
            if ttype == DEATH and GetTerrainType(x, y + tOFFSET) == DEATH and GetTerrainType(x + tOFFSET, y) == DEATH and GetTerrainType(x, y - tOFFSET) == DEATH and GetTerrainType(x - tOFFSET, y) == DEATH and GetTerrainType(x + tOFFSET * .75, y + tOFFSET * .75) == DEATH and GetTerrainType(x + tOFFSET * .75, y - tOFFSET * .75) == DEATH and GetTerrainType(x - tOFFSET * .75, y - tOFFSET * .75) == DEATH and GetTerrainType(x - tOFFSET * .75, y + tOFFSET * .75) == DEATH then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Dead")
                //handled in stop platforming
                //call .RemoveTerrainEffect()
                //call .RemoveXSurfaceTerrainEffect()
                //call .RemoveYSurfaceTerrainEffect()
                
                call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", .XPosition, .YPosition))
                call .KillPlatformer()
                
                return
            endif
            */
            
            if ttype == DEATH then
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Dead")
                //handled in stop platforming
                //call .RemoveTerrainEffect()
                //call .RemoveXSurfaceTerrainEffect()
                //call .RemoveYSurfaceTerrainEffect()
                
                //call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", .XPosition, .YPosition))
                //call .KillPlatformer()
                
                return
            endif
            
            //apply any differences in terrain that platformer is being pushed against
            //effects from terrain the platformer is pushed against should be multiplicative so that they're compatible with the main terrain effects, and anything else that effects physic variables
            if .XTerrainPushedAgainst != .XAppliedTerrainPushedAgainst then
                static if DEBUG_TERRAIN_CHANGE then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removing X terrain: " + TerrainID2S(.XAppliedTerrainPushedAgainst) + ", applying terrain: " + TerrainID2S(.XTerrainPushedAgainst))
                endif
                
                call .RemoveXSurfaceTerrainEffect()
                
                //apply any new effects from current pushed against x terrain
                if .XTerrainPushedAgainst == SAND then
                    call .YFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SAND, SAND_FALLOFF)
                    set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                    //set .YFalloff = .YFalloff * SAND_FALLOFF
                elseif .XTerrainPushedAgainst == DGRASS then
                    //set .GravitationalAccel = .GravitationalAccel * .1
                elseif .XTerrainPushedAgainst == SLOWICE then
                    call .YFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE, PlatformerIce_SLOW_YFALLOFF)
					set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                    
                    call PlatformerIce_Add(this)
                elseif .XTerrainPushedAgainst == FASTICE then
                    call .YFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE, PlatformerIce_FAST_YFALLOFF)
                    set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                    
                    call PlatformerIce_Add(this)
                endif
                
                //update currently applied x terrain
                set .XAppliedTerrainPushedAgainst = XTerrainPushedAgainst
            endif
            
            if .YTerrainPushedAgainst != .YAppliedTerrainPushedAgainst then
                static if DEBUG_TERRAIN_CHANGE then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removing Y terrain: " + TerrainID2S(.YAppliedTerrainPushedAgainst) + ", applying terrain: " + TerrainID2S(.YTerrainPushedAgainst))
                endif
                
                call .RemoveYSurfaceTerrainEffect()
                
                //apply any new effects from current pushed against y terrain
                if .YTerrainPushedAgainst == SAND then
                    call .XFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SAND, SAND_FALLOFF)
                    set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                    //set .XFalloff = .XFalloff * SAND_FALLOFF
				elseif .YTerrainPushedAgainst == GRASS then
					call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRASS, GRASS_MS)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
					
                    if (.GravitationalAccel > 0 and (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW)) or (.GravitationalAccel < 0 and (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW)) then
						call .TVYEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, GRASS, GRASS_TVY)
                        set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
						
						static if DEBUG_GRASS_GRAVITY then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Grass adding terminal velocity adjustment, new value: " + R2S(.TerminalVelocityY))
						endif
                    endif
                elseif .YTerrainPushedAgainst == DGRASS then
                    call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, DGRASS, DGRASS_MS)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
					//set .MoveSpeed = .MoveSpeed * DGRASS_MS
					
                    if (.GravitationalAccel > 0 and (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW)) or (.GravitationalAccel < 0 and (.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE or .DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW)) then
                        call .TVYEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, DGRASS, DGRASS_TVY)
                        set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
						
						static if DEBUG_GRASS_GRAVITY then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Grass adding terminal velocity adjustment, new value: " + R2S(.TerminalVelocityY))
						endif
                    endif
                elseif .YTerrainPushedAgainst == SLOWICE then
                    call .XFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE, PlatformerIce_SLOW_XFALLOFF)
                    set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                    
                    call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLOWICE, PlatformerIce_SLOW_MS)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                    
                    call PlatformerIce_Add(this)
                elseif .YTerrainPushedAgainst == FASTICE then
                    call .XFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE, PlatformerIce_FAST_XFALLOFF)
                    set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                    
                    call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, FASTICE, PlatformerIce_FAST_MS)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                    
                    call PlatformerIce_Add(this)
                endif
                
                //update currently applied y terrain
                set .YAppliedTerrainPushedAgainst = YTerrainPushedAgainst
            endif
            
            if ttype == DEATH or TerrainGlobals_IsTerrainDiagonal(ttype) then
                //don't update regular .TerrainDX when on either death or a diagonal (those use .XAppliedTerrainPushedAgainst and .YAppliedTerrainPushedAgainst)
                return
            elseif ttype != .TerrainDX then
                static if DEBUG_TERRAIN_CHANGE then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removing terrain: " + TerrainID2S(.TerrainDX) + ", applying terrain: " + TerrainID2S(ttype))
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "-----")
                endif
                
                //remove old effect
                call .RemoveTerrainEffect()
				
				set .TerrainDX = ttype
                
                //add new effect
                if ttype == OCEAN then
                    //apply starting velocity depending on previous properties, mostly aesthetic
                    if .XVelocity == 0 then
                        //convert a small amount of old movespeed in current key direction to new x velocity
                        set .XVelocity = .XVelocity + .MoveSpeed * .25 * .HorizontalAxisState
                    else
                        //reduce current velocity by around half
                        set .XVelocity = .XVelocity * PlatformerOcean_ENTRANCE_VEL
                    endif
                    
                    set .YVelocity = .YVelocity * PlatformerOcean_ENTRANCE_VEL
                    
                    //set .GravitationalAccel = .GravitationalAccel * PlatformerOcean_GRAVITYPERCENT
                    //set .MoveSpeed = .MoveSpeed * PlatformerOcean_MS
                    set .hJumpSpeed = .hJumpSpeed * PlatformerOcean_HJUMP
                    set .vJumpSpeed = .vJumpSpeed * PlatformerOcean_VJUMP
                    set .v2hJumpRatio = .v2hJumpRatio * PlatformerOcean_V2H
                    //set .TerminalVelocityY = .TerminalVelocityY * PlatformerOcean_TVX
                    //set .TerminalVelocityX = .TerminalVelocityX * PlatformerOcean_TVY
                    //set .XFalloff = .XFalloff * PlatformerOcean_XFALLOFF
                    //set .YFalloff = .YFalloff * PlatformerOcean_YFALLOFF
                    set .MoveSpeedVelOffset = .MoveSpeedVelOffset * PlatformerOcean_MSOFF
                    
                    call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN, PlatformerOcean_MS)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                    
                    call .GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN, PlatformerOcean_GRAVITYPERCENT)
                    set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                    
                    call .XFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN, PlatformerOcean_XFALLOFF)
                    set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
                    
                    call .YFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN, PlatformerOcean_YFALLOFF)
                    set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                                        
                    call .TVYEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, OCEAN, PlatformerOcean_TVY)
                    set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Ocean base gravity: " + R2S(.BaseProfile.GravitationalAccel) + ", new gravity: " + R2S(.GravitationalAccel))
                    
                    //set .FX = AddSpecialEffect(OCEAN_JUMP_FX, x, y)
                    //call DestroyEffect(.FX)
					//set .FX = null
					call DestroyEffect(AddSpecialEffect(OCEAN_JUMP_FX, x, y))
                    
                    call PlatformerOcean_Add(this)
                elseif ttype == VINES then
                    //set .GravitationalAccel = VINES_SLOWDOWNPERCENT * .GravitationalAccel
                    //set .TerminalVelocityY = VINES_SLOWDOWNPERCENT * .TerminalVelocityY
                    //set .MoveSpeed = VINES_MOVESPEEDPERCENT * .MoveSpeed
                    set .XVelocity = VINES_SLOWDOWNPERCENT * .XVelocity
                    set .YVelocity = VINES_SLOWDOWNPERCENT * .YVelocity
                    
                    call .MSEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES, VINES_MOVESPEEDPERCENT)
                    set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)
                    
                    call .GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES, VINES_SLOWDOWNPERCENT)
                    set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                    
                    call .TVYEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, VINES, VINES_SLOWDOWNPERCENT)
                    set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
                    
					call DestroyEffect(AddSpecialEffect(TERRAIN_VINES_FX, x, y))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "On vines, grav is: " + R2S(.GravitationalAccel))
                elseif ttype == BOOST then
					//this is too inconsistent inside this loop, will need to move it out to its own timer after all...
                    if .GravitationalAccel > 0 then
                        set .YVelocity = -BOOST_SPEED
                    elseif .GravitationalAccel < 0 then
                        set .YVelocity = BOOST_SPEED
                    endif
					
					call PlatformerBounce.Add(this)
                elseif ttype == SLIPSTREAM then
                    call .GravityEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM, 0)
                    set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
                    
                    //call .TVYEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM, 10)
                    //set .TerminalVelocityY = .GravityEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
                    
                    call .YFalloffEquation.addAdjustment(PlatformerPropertyEquation_MULTIPLY_ADJUSTMENT, SLIPSTREAM, .1)
                    set .YFalloff = .GravityEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
                    //set .GravitationalAccel = .GravitationalAccel * .1
                    
                    call PlatformerSlipStream_Add(this)
                elseif ttype == PLATFORMING then
					set terrainCenter = GetTerrainCenterpoint(x, y)
					
					if terrainCenter.x > x then
						set x = x + wOFFSET
					else
						set x = x - wOFFSET
					endif
					if terrainCenter.y > y then
						set y = y + wOFFSET
					else
						set y = y - wOFFSET
					endif
					
					call terrainCenter.destroy()
					
					call User(.PID).SwitchGameModes(Teams_GAMEMODE_STANDARD, x, y)
					call User(.PID).ApplyDefaultCameras(1.)
                    // call SetDefaultCameraForPlayer(.PID, .5)
					set PreviousTerrainTypedx[.PID] = PLATFORMING
					call DestroyEffect(AddSpecialEffect(TERRAIN_STANDARD_FX, x, y))
					
                    return
                endif
			elseif .TerrainDX == BOOST then
				//this is too inconsistent inside this loop, will need to move it out to its own timer after all...
				if .GravitationalAccel > 0 then
					set .YVelocity = -BOOST_SPEED
				elseif .GravitationalAccel < 0 then
					set .YVelocity = BOOST_SPEED
				endif
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished updating terrain")
        endmethod
        
        private static method GameloopListIteration takes nothing returns nothing
            local SimpleList_ListNode p = thistype.ActivePlatformers.first
            
            loop
            exitwhen p == 0
                call Platformer(p.value).ApplyPhysics()
                set p = p.next
            endloop
        endmethod
        
        private static method TerrainloopListIteration takes nothing returns nothing
			local SimpleList_ListNode p = thistype.ActivePlatformers.first
            
            loop
            exitwhen p == 0
                call Platformer(p.value).UpdateTerrain()
                set p = p.next
            endloop
        endmethod
        
        public method SetPhysicsToProfile takes nothing returns nothing
            //.BaseProfile refers to the default values (without any effects) for the platformer, on the current "world"
            set .GravitationalAccel = .GravityEquation.calculateAdjustedValue(.BaseProfile.GravitationalAccel)
            set .MoveSpeed = .MSEquation.calculateAdjustedValue(.BaseProfile.MoveSpeed)            
            set .XFalloff = .XFalloffEquation.calculateAdjustedValue(.BaseProfile.XFalloff)
            set .YFalloff = .YFalloffEquation.calculateAdjustedValue(.BaseProfile.YFalloff)
            set .TerminalVelocityY = .TVYEquation.calculateAdjustedValue(.BaseProfile.TerminalVelocityY)
            
            //set .GravitationalAccel = .BaseProfile.GravitationalAccel
            set .vJumpSpeed = .BaseProfile.vJumpSpeed
            set .hJumpSpeed = .BaseProfile.hJumpSpeed
            //set .MoveSpeed = .BaseProfile.MoveSpeed
            //set .TerminalVelocityX = .BaseProfile.TerminalVelocityX
            //set .TerminalVelocityY = .BaseProfile.TerminalVelocityY
            //set .XFalloff = .BaseProfile.XFalloff
            //set .YFalloff = .BaseProfile.YFalloff
            
            set .MoveSpeedVelOffset = .BaseProfile.MoveSpeedVelOffset
            set .v2hJumpRatio = .BaseProfile.v2hJumpRatio
        endmethod
        
        public method ApplyCamera takes nothing returns nothing
			if GetLocalPlayer() == Player(.PID) and GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK) != 270 then
                call CameraSetupApply(thistype.PlatformingCamera, true, true) //orients the camera to face down from above
				call SetCameraTargetController(.Unit, 0, 0, false) //fixes the camera to platforming unit
            endif
        endmethod
		private static method ApplyAllCameras takes nothing returns nothing
			local SimpleList_ListNode p = thistype.ActivePlatformers.first
            
            loop
            exitwhen p == 0
                call Platformer(p.value).ApplyCamera()
			set p = p.next
            endloop
		endmethod
        
        public method StartPlatforming takes real x, real y returns nothing
            if not .IsPlatforming then
                set .IsPlatforming = true
                set .TerrainDX = PLATFORMING
                
                set .OnDiagonal = false
                if .DiagonalPathing != 0 then
                    call .DiagonalPathing.destroy()
                    set .DiagonalPathing = 0
                endif
                
                set .XPosition = x
                set .YPosition = y
                set .YVelocity = 0
                set .XVelocity = 0
				
				set .PhysicsLoopDeltaApplied = 0.
                
                call SetPhysicsToProfile()
                
                if thistype.ActivePlatformers.count == 0 then
                    call TimerStart(.GameloopTimer, PlatformerGlobals_GAMELOOP_TIMESTEP, true, function Platformer.GameloopListIteration)
                    call TimerStart(.TerrainloopTimer, PlatformerGlobals_TERRAINLOOP_TIMESTEP, true, function Platformer.TerrainloopListIteration)
                    call TimerStart(.CameraTimer, CAMERA_APPLY_TIMESTEP, true, function Platformer.ApplyAllCameras)
                endif
                
                call SetUnitPosition(.Unit, x, y)
                call ShowUnit(.Unit, true)

                call thistype.ActivePlatformers.add(this)
                
				static if DEBUG_CAMERA then
					if GetLocalPlayer() == Player(0) then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before plat apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
					endif
                endif
				
                call this.ApplyCamera()
                
				static if DEBUG_CAMERA then
					if GetLocalPlayer() == Player(0) then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "After plat apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
					endif
                endif
				
                static if DEBUG_GAMEMODE then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started platforming")
                endif
            endif
        endmethod
        
        public method StopPlatforming takes nothing returns nothing
            if .IsPlatforming then
                call .RemoveTerrainEffect()
                call .RemoveXSurfaceTerrainEffect()
                call .RemoveYSurfaceTerrainEffect()
                
                set .IsPlatforming = false
                set .HorizontalAxisState = 0
                set .LeftKey = false
                set .RightKey = false
                call thistype.ActivePlatformers.remove(this)
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Start clearing adjustments")
                call .MSEquation.clearAdjustments()
                call .GravityEquation.clearAdjustments()
                call .XFalloffEquation.clearAdjustments()
                call .YFalloffEquation.clearAdjustments()
                call .TVYEquation.clearAdjustments()
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "End clearing adjustments")
                
                if thistype.ActivePlatformers.count == 0 then
                    call PauseTimer(.GameloopTimer)
                    call PauseTimer(.TerrainloopTimer)
					call PauseTimer(.CameraTimer)
                endif
                
				static if DEBUG_CAMERA then
					if GetLocalPlayer() == Player(0) then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before plat reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
					endif
                endif
				
				call User(.PID).ResetDefaultCamera(0.)
				
				call ShowUnit(.Unit, false)
				//call SetUnitPosition(.Unit, PlatformerGlobals_SAFE_X, PlatformerGlobals_SAFE_Y)
				
				static if DEBUG_CAMERA then
					if GetLocalPlayer() == Player(0) then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "After plat reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
					endif
                endif                
                
                static if DEBUG_GAMEMODE then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stopped platforming")
                endif
            endif
        endmethod
        
        //! textmacro horizontal_toggles takes PRESSED
        private static method Left_$PRESSED$ takes nothing returns boolean
            local integer pID = GetPlayerId(GetTriggerPlayer())
            local Platformer p = User(pID).Platformer
            local integer ttype
            local real newX
            
            set p.LeftKey = $PRESSED$
            
            if p.IsPlatforming then
                static if $PRESSED$ then //left was pressed
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left key pressed")
                    if not p.RightKey then //and right key not down
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And right not down")
                        set p.HorizontalAxisState = -1
                        set p.LastHorizontalKey = -1
                        
						call p.ApplyPhysics()
						
						/*                        
                        //do left down actions -- move unit a bit
                        if p.OnDiagonal then
                            //test what happens if we just move the unit a tiny bit in the correct direction, without doing any complicated checks
                            
                            //ie just take the movementspeed effect section and see what happens
                            //hopefully x, y position will be somewhat visual in a way. the quadrant change will still be detected in the physics loop and then the next diagonal returned will still be relevant
                            //then maybe the only thing effected will be when we switched equations
                        else
                            set newX = p.XPosition - p.MoveSpeed * INSTANT_MS
                            set ttype = GetTerrainType(newX - wOFFSET, p.YPosition)
                            if TerrainGlobals_IsTerrainPathable(ttype) then
                                call SetUnitX(p.Unit, newX)
                                set p.XPosition = newX
                            endif
                        endif
						*/
                    endif
                else //left was released
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left key released")
                    if p.RightKey then
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And right down")
                        //set axis state towards right and move unit a bit
                        set p.HorizontalAxisState = 1
                        set p.LastHorizontalKey = 1
                        
						call p.ApplyPhysics()
						
						/*                        
                        //do right down actions -- move unit a bit
                        if p.OnDiagonal then
                        
                        else
                            set newX = p.XPosition - p.MoveSpeed * INSTANT_MS
                            set ttype = GetTerrainType(newX - wOFFSET, p.YPosition)
                            if TerrainGlobals_IsTerrainPathable(ttype) then
                                call SetUnitX(p.Unit, newX)
                                set p.XPosition = newX
                            endif
                        endif
						*/
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And right not down")
                        //set axis state to neutral
                        set p.HorizontalAxisState = 0
                    endif
                endif
            endif
            
            return false
        endmethod
        
        private static method Right_$PRESSED$ takes nothing returns boolean
            local integer pID = GetPlayerId(GetTriggerPlayer())
            local Platformer p = User(pID).Platformer
            local integer ttype
            local real newX
            
            set p.RightKey = $PRESSED$
            
            if p.IsPlatforming then
                static if $PRESSED$ then //right was pressed
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right key pressed")
                    if not p.LeftKey then //and left key down
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And left not down")
                        set p.HorizontalAxisState = 1
                        set p.LastHorizontalKey = 1
                        
						call p.ApplyPhysics()
						
						/*                        
                        //do right down actions -- move unit a bit
                        if p.OnDiagonal then
                        
                        else
                            set newX = p.XPosition + p.MoveSpeed * INSTANT_MS
                            set ttype = GetTerrainType(newX + wOFFSET, p.YPosition)
                            if TerrainGlobals_IsTerrainPathable(ttype) then
                                call SetUnitX(p.Unit, newX)
                                set p.XPosition = newX
                            endif
                        endif
						*/
                    endif
                else //right was released
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right key released")
                    if p.LeftKey then
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And left down")
                        //set axis state towards left and move unit a bit
                        set p.HorizontalAxisState = -1
                        set p.LastHorizontalKey = -1
						
						call p.ApplyPhysics()
						
						/*                        
                        //do left down actions -- move unit a bit
                        if p.OnDiagonal then
                        
                        else
                            set newX = p.XPosition + p.MoveSpeed * INSTANT_MS
                            set ttype = GetTerrainType(newX + wOFFSET, p.YPosition)
                            if TerrainGlobals_IsTerrainPathable(ttype) then
                                call SetUnitX(p.Unit, newX)
                                set p.XPosition = newX
                            endif
                        endif
						*/
                    else
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "And left not down")
                        //set axis state to neutral
                        set p.HorizontalAxisState = 0
                    endif
                endif
            endif
            
            return false
        endmethod
        //! endtextmacro
        
        //! runtextmacro horizontal_toggles("PRESSED")
        //! runtextmacro horizontal_toggles("RELEASED")
        
        private static method OceanJumpCB takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local Platformer p = GetTimerData(t)
            
            set p.CanOceanJump = true
            
            call ReleaseTimer(t)
            set t = null
        endmethod
        
        private static method Up_PRESSED takes nothing returns boolean
            local integer pID = GetPlayerId(GetTriggerPlayer())
            local Platformer p = User(pID).Platformer
			local ComplexTerrainPathingResult pathingResult
			//ComplexTerrainPathing_GetPathingForPoint(.XPosition + newX, .YPosition + newY)
            local real l
            
            static if DEBUG_JUMPING then
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Pressed up")
            endif
            
            //only apply logic if player is platforming
            if p.IsPlatforming then                
                static if DEBUG_JUMPING then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Push vector: " + p.PushedAgainstVector.toString())
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Y Terrain: " + I2S(p.YTerrainPushedAgainst))
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Terrain: " + I2S(p.XTerrainPushedAgainst))
                endif
                
                if p.OnDiagonal or p.PushedAgainstVector != 0 then
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Diagonal jump!")
                    
                    if p.PushedAgainstVector == ComplexTerrainPathing_NE_UnitVector then
                        set l = p.hJumpSpeed * p.PushedAgainstVector.x + p.vJumpSpeed * p.PushedAgainstVector.y
                        
                        set p.XVelocity = p.XVelocity + l * p.PushedAgainstVector.x
                        set p.YVelocity = p.YVelocity + l * p.PushedAgainstVector.y
                        
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
						
						call p.ApplyPhysics()
						
                        return false
                    elseif p.PushedAgainstVector == ComplexTerrainPathing_SW_UnitVector then
                        set l = -p.hJumpSpeed * p.PushedAgainstVector.x + -p.vJumpSpeed * p.PushedAgainstVector.y
                        
                        set p.XVelocity = p.XVelocity + l * p.PushedAgainstVector.x
                        set p.YVelocity = p.YVelocity + l * p.PushedAgainstVector.y
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
						
						call p.ApplyPhysics()
						
						return false
                    elseif p.PushedAgainstVector == ComplexTerrainPathing_SE_UnitVector then
                        set l = p.hJumpSpeed * p.PushedAgainstVector.x + -p.vJumpSpeed * p.PushedAgainstVector.y
                        
                        set p.XVelocity = p.XVelocity + l * p.PushedAgainstVector.x
                        set p.YVelocity = p.YVelocity + l * p.PushedAgainstVector.y
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                        
						call p.ApplyPhysics()
						
                        return false
                    elseif p.PushedAgainstVector == ComplexTerrainPathing_NW_UnitVector then
                        set l = -p.hJumpSpeed * p.PushedAgainstVector.x + p.vJumpSpeed * p.PushedAgainstVector.y
                        
                        set p.XVelocity = p.XVelocity + l * p.PushedAgainstVector.x
                        set p.YVelocity = p.YVelocity + l * p.PushedAgainstVector.y
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                        
						call p.ApplyPhysics()
						
                        static if DEBUG_VELOCITY then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Velocity: " + R2S(p.XVelocity) + ", Y Velocity: " + R2S(p.YVelocity) + ", L: " + R2S(l))
                        endif
                        
                        return false
                    elseif p.PushedAgainstVector == ComplexTerrainPathing_Up_UnitVector or p.PushedAgainstVector == ComplexTerrainPathing_Down_UnitVector and TerrainGlobals_IsTerrainJumpable(p.YTerrainPushedAgainst) then
                        set p.YVelocity = p.vJumpSpeed * p.PushedAgainstVector.y
                        
                        //experimental
                        //set p.XVelocity = 0
                        
                        call DestroyEffect(AddSpecialEffect(VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
						
						static if DEBUG_VELOCITY then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Velocity: " + R2S(p.XVelocity) + ", Y Velocity: " + R2S(p.YVelocity))
                        endif
						
						call p.ApplyPhysics()
                        
                        return false
                    elseif p.PushedAgainstVector == ComplexTerrainPathing_Left_UnitVector or p.PushedAgainstVector == ComplexTerrainPathing_Right_UnitVector and TerrainGlobals_IsTerrainWallJumpable(p.XTerrainPushedAgainst) then
                        set p.XVelocity = p.hJumpSpeed * p.PushedAgainstVector.x
                        
						if TerrainGlobals_IsTerrainGoodFooting(p.XTerrainPushedAgainst) then
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = -p.vJumpSpeed * p.v2hJumpRatio
							endif
						else
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.YVelocity + p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = p.YVelocity + -p.vJumpSpeed * p.v2hJumpRatio
							endif
						endif
						
						static if DEBUG_VELOCITY then
                            call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Velocity: " + R2S(p.XVelocity) + ", Y Velocity: " + R2S(p.YVelocity))
                        endif
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                        
						call p.ApplyPhysics()
						
                        return false
                    endif
                else
                    //double check that there's nothing close by for the sake of playability -- this only applies when not on a diagonal
                    //physics loop lags behind key event too much
                    
                    //check below or above y, assuming 
                    //p.YPosition
					static if DEBUG_JUMPING then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Not on diagonal, checking for jump opposition elsewhere")
					endif
					
                    if (p.YVelocity == 0 and p.GravitationalAccel > 0) or p.YVelocity > 0 then
                        set pathingResult = ComplexTerrainPathing_GetPathingForPoint(p.XPosition, p.YPosition + vjBUFFER)
						
						if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Bottom) and TerrainGlobals_IsTerrainJumpable(pathingResult.GetYTerrainType()) then
							set p.YVelocity = -p.vJumpSpeed
                            
                            //Objects\Spawnmodels\Other\ToonBoom\ToonBoom.mdl
                            call DestroyEffect(AddSpecialEffect(VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Vert jump " + R2S(p.YVelocity))
                            
							static if DEBUG_JUMPING then
								call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found vertical opposition above")
							endif
							
							call pathingResult.destroy()
							return false
						endif
						
						call pathingResult.destroy()
						
						// if TerrainGlobals_IsTerrainJumpable(GetTerrainType(p.XPosition, p.YPosition + vjBUFFER)) then
                            // set p.YVelocity = -p.vJumpSpeed
                            
                            // //Objects\Spawnmodels\Other\ToonBoom\ToonBoom.mdl
                            // call DestroyEffect(AddSpecialEffect(VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                            // //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Vert jump " + R2S(p.YVelocity))
                            
							// static if DEBUG_JUMPING then
								// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found vertical opposition above")
							// endif
							
                            // return false
                        // endif
                    elseif (p.YVelocity == 0 and p.GravitationalAccel < 0) or p.YVelocity < 0 then
                        set pathingResult = ComplexTerrainPathing_GetPathingForPoint(p.XPosition, p.YPosition - vjBUFFER)
						// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Pathing below: " + I2S(pathingResult.TerrainPathingForPoint))
						
						if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Top) and TerrainGlobals_IsTerrainJumpable(pathingResult.GetYTerrainType()) then
							set p.YVelocity = p.vJumpSpeed
                            
                            //Objects\Spawnmodels\Other\ToonBoom\ToonBoom.mdl
                            call DestroyEffect(AddSpecialEffect(VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Vert jump " + R2S(p.YVelocity))
                            
							static if DEBUG_JUMPING then
								call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found vertical opposition below")
							endif
							
							call pathingResult.destroy()
							return false
						endif
						
						call pathingResult.destroy()
						
						// if TerrainGlobals_IsTerrainJumpable(GetTerrainType(p.XPosition, p.YPosition - vjBUFFER)) then                    
                            // set p.YVelocity = p.vJumpSpeed
                        
                            // call DestroyEffect(AddSpecialEffect(VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                            // //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Vert jump " + R2S(p.YVelocity))
                            
							// static if DEBUG_JUMPING then
								// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found vertical opposition below")
							// endif
							
                            // return false
                        // endif
                    endif
                    
                    //check left of x
					set pathingResult = ComplexTerrainPathing_GetPathingForPoint(p.XPosition - hjBUFFER, p.YPosition)
						
					if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Right) and TerrainGlobals_IsTerrainWallJumpable(pathingResult.GetXTerrainType()) then
						//apply a percentage, given by v2hJumpRatio, of vJumpSpeed as immediate YVelocity
                        if TerrainGlobals_IsTerrainGoodFooting(pathingResult.GetXTerrainType()) then
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = -p.vJumpSpeed * p.v2hJumpRatio
							endif
						else
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.YVelocity + p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = p.YVelocity + -p.vJumpSpeed * p.v2hJumpRatio
							endif
						endif
                        
						static if DEBUG_JUMPING then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found horizontal opposition left")
						endif
						
                        //apply full horizontal jump speed (this is the only use for it)
                        set p.XVelocity = p.hJumpSpeed
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
						
						call pathingResult.destroy()
						return false
					endif
					
					call pathingResult.destroy()
					
					//check right of x
					set pathingResult = ComplexTerrainPathing_GetPathingForPoint(p.XPosition + hjBUFFER, p.YPosition)
						
					if (pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Square or pathingResult.TerrainPathingForPoint == ComplexTerrainPathing_Left) and TerrainGlobals_IsTerrainWallJumpable(pathingResult.GetXTerrainType()) then
						//apply a percentage, given by v2hJumpRatio, of vJumpSpeed as immediate YVelocity
						if TerrainGlobals_IsTerrainGoodFooting(pathingResult.GetXTerrainType()) then
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = -p.vJumpSpeed * p.v2hJumpRatio
							endif
						else
							if p.GravitationalAccel < 0 then
								set p.YVelocity = p.YVelocity + p.vJumpSpeed * p.v2hJumpRatio
							elseif p.GravitationalAccel > 0 then
								set p.YVelocity = p.YVelocity + -p.vJumpSpeed * p.v2hJumpRatio
							endif
						endif
                        
						static if DEBUG_JUMPING then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found horizontal opposition right")
						endif
						
                        //apply full horizontal jump speed (this is the only use for it)
                        set p.XVelocity = -p.hJumpSpeed
                        
                        call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
						
						call pathingResult.destroy()
						return false
					endif
					
					call pathingResult.destroy()
										
                    // if TerrainGlobals_IsTerrainWallJumpable(GetTerrainType(p.XPosition - hjBUFFER, p.YPosition)) and TerrainGlobals_IsTerrainSquare(GetTerrainType(p.XPosition - hjBUFFER, p.YPosition)) then
                        // //apply a percentage, given by v2hJumpRatio, of vJumpSpeed as immediate YVelocity
                        // if TerrainGlobals_IsTerrainGoodFooting(GetTerrainType(p.XPosition - hjBUFFER, p.YPosition)) then
							// if p.GravitationalAccel < 0 then
								// set p.YVelocity = p.vJumpSpeed * p.v2hJumpRatio
							// elseif p.GravitationalAccel > 0 then
								// set p.YVelocity = -p.vJumpSpeed * p.v2hJumpRatio
							// endif
						// else
							// if p.GravitationalAccel < 0 then
								// set p.YVelocity = p.YVelocity + p.vJumpSpeed * p.v2hJumpRatio
							// elseif p.GravitationalAccel > 0 then
								// set p.YVelocity = p.YVelocity + -p.vJumpSpeed * p.v2hJumpRatio
							// endif
						// endif
                        
						// static if DEBUG_JUMPING then
							// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found horizontal opposition left")
						// endif
						
                        // //apply full horizontal jump speed (this is the only use for it)
                        // set p.XVelocity = p.hJumpSpeed
                        
                        // call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                        // //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Left wall jump " + R2S(p.YVelocity) + ", " + R2S(p.XVelocity))
                        
                        // return false
                    // endif
                    
                    //otherwise check if can right wall jump
                    // if TerrainGlobals_IsTerrainWallJumpable(GetTerrainType(p.XPosition + hjBUFFER, p.YPosition)) and TerrainGlobals_IsTerrainSquare(GetTerrainType(p.XPosition + hjBUFFER, p.YPosition)) then
                        // //apply a percentage, given by v2hJumpRatio, of vJumpSpeed as immediate YVelocity
						// if TerrainGlobals_IsTerrainGoodFooting(GetTerrainType(p.XPosition + hjBUFFER, p.YPosition)) then
							// if p.GravitationalAccel < 0 then
								// set p.YVelocity = p.vJumpSpeed * p.v2hJumpRatio
							// elseif p.GravitationalAccel > 0 then
								// set p.YVelocity = -p.vJumpSpeed * p.v2hJumpRatio
							// endif
						// else
							// if p.GravitationalAccel < 0 then
								// set p.YVelocity = p.YVelocity + p.vJumpSpeed * p.v2hJumpRatio
							// elseif p.GravitationalAccel > 0 then
								// set p.YVelocity = p.YVelocity + -p.vJumpSpeed * p.v2hJumpRatio
							// endif
						// endif
                        
						// static if DEBUG_JUMPING then
							// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Found horizontal opposition right")
						// endif
						
                        // //apply full horizontal jump speed (this is the only use for it)
                        // set p.XVelocity = -p.hJumpSpeed
                        
                        // call DestroyEffect(AddSpecialEffect(NON_VERTICAL_JUMP_FX, p.XPosition, p.YPosition))
                        // //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Right wall jump " + R2S(p.YVelocity) + ", " + R2S(p.XVelocity))
                        
                        // return false
                    // endif
                endif
                
                if p.TerrainDX == OCEAN and p.CanOceanJump then
                    set p.CanOceanJump = false
                    call TimerStart(NewTimerEx(p), OCEAN_JUMP_COOLDOWN, false, function thistype.OceanJumpCB)
                    //TODO give platformer unit an abil to show jump CD
                    
                    if p.GravitationalAccel < 0 then
                        set p.YVelocity = JUMPHEIGHTINOCEAN
                    elseif p.GravitationalAccel > 0 then
                        set p.YVelocity = -JUMPHEIGHTINOCEAN
                    endif
                    
                    //remove some of the x velocity
                    set p.XVelocity = p.XVelocity * PlatformerOcean_XVELOCITYONJUMP
                    
                    //set e = AddSpecialEffect("Doodads\\Icecrown\\Water\\BubbleGeyserSteam\\BubbleGeyserSteam.mdl", x, y)
                    call DestroyEffect(AddSpecialEffect(OCEAN_JUMP_FX, p.XPosition, p.YPosition))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Vert jump " + R2S(p.YVelocity))
                    
                    return false
                endif
            endif
            
            return false
        endmethod
        
        
        public static method create takes integer pID returns thistype
            local thistype new = thistype.allocate()
			
            static if DEBUG_CREATE then
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Starting to create platformer for player " + I2S(pID))
            endif
            
            set new.PID = pID
            
            set new.LeftKey = false
            set new.RightKey = false
            set new.LastHorizontalKey = 0 //none since last death
            set new.HorizontalAxisState = 0 //none
            
            set new.CanOceanJump = true
            
            set new.BaseProfile = PlatformerProfile_DefaultProfileID
            
            set new.MSEquation = PlatformerPropertyEquation.create()
            set new.GravityEquation = PlatformerPropertyEquation.create()
            set new.XFalloffEquation = PlatformerPropertyEquation.create()
            set new.YFalloffEquation = PlatformerPropertyEquation.create()
            set new.TVYEquation = PlatformerPropertyEquation.create()
            
            set new.Unit = CreateUnit(Player(pID), PLATFORMERWISP, PlatformerGlobals_SAFE_X, PlatformerGlobals_SAFE_Y, 0)
            call UnitAddAbility(new.Unit, 'Aloc')
            call ShowUnit(new.Unit, false)
			call UnitRemoveAbility(new.Unit, 'Aloc')
            //sets the directions the unit is allowed to turn in, 0 means it move in no direction
            call SetUnitPropWindow(new.Unit, 0)
            
            set new.IsPlatforming = false
            
                        
            call TriggerRegisterPlayerEvent(thistype.ArrowKeyTriggers[0], Player(pID), EVENT_PLAYER_ARROW_LEFT_DOWN)
            call TriggerRegisterPlayerEvent(thistype.ArrowKeyTriggers[1], Player(pID), EVENT_PLAYER_ARROW_LEFT_UP)
            call TriggerRegisterPlayerEvent(thistype.ArrowKeyTriggers[2], Player(pID), EVENT_PLAYER_ARROW_RIGHT_DOWN)
            call TriggerRegisterPlayerEvent(thistype.ArrowKeyTriggers[3], Player(pID), EVENT_PLAYER_ARROW_RIGHT_UP)
            call TriggerRegisterPlayerEvent(thistype.ArrowKeyTriggers[4], Player(pID), EVENT_PLAYER_ARROW_UP_DOWN)
                                    
            static if DEBUG_CREATE then
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished creating platformer")
            endif
                        
            return new
        endmethod
        
		private static method OnUnitDamaged takes nothing returns boolean
			local unit source = GetEventDamageSource()
			local unit target = GetTriggerUnit()
			
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "damage taken somewhere!")
			
			if GetUnitTypeId(source) == SMLMORT and GetUnitTypeId(target) == PLATFORMERWISP then
				call User(GetPlayerId(GetOwningPlayer(target))).Platformer.KillPlatformer()
			endif
			
			set source = null
			set target = null
			return false
		endmethod
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local Platformer p
			local trigger damageEvent = CreateTrigger()
            
			set thistype.PlatformingCamera = CreateCameraSetup()
            call CameraSetupSetField(thistype.PlatformingCamera, CAMERA_FIELD_ANGLE_OF_ATTACK, 270, 0)
            call CameraSetupSetField(thistype.PlatformingCamera, CAMERA_FIELD_TARGET_DISTANCE, 2200, 0)
			
			set thistype.ArrowKeyTriggers[0] = CreateTrigger()
            set thistype.ArrowKeyTriggers[1] = CreateTrigger()
            set thistype.ArrowKeyTriggers[2] = CreateTrigger()
            set thistype.ArrowKeyTriggers[3] = CreateTrigger()
            set thistype.ArrowKeyTriggers[4] = CreateTrigger()
			
			call TriggerAddCondition(thistype.ArrowKeyTriggers[0], Condition(function Platformer.Left_PRESSED))
            call TriggerAddCondition(thistype.ArrowKeyTriggers[1], Condition(function Platformer.Left_RELEASED))
            call TriggerAddCondition(thistype.ArrowKeyTriggers[2], Condition(function Platformer.Right_PRESSED))
            call TriggerAddCondition(thistype.ArrowKeyTriggers[3], Condition(function Platformer.Right_RELEASED))
            call TriggerAddCondition(thistype.ArrowKeyTriggers[4], Condition(function Platformer.Up_PRESSED))
			
			set .ActivePlatformers = SimpleList_List.create()
			
            set .GameloopTimer = CreateTimer()
            set .TerrainloopTimer = CreateTimer()
			set .CameraTimer = CreateTimer()
			
			//TODO, depending on the number of damage events that are fired during gameplay, it might be more performant to declare a global trigger for plat damage and register each individual wisp with a damaged event
			//Currently, there are very few damage events resolving
			call TriggerRegisterAnyUnitEventBJ(damageEvent, EVENT_PLAYER_UNIT_DAMAGED)
			call TriggerAddCondition(damageEvent, Condition(function thistype.OnUnitDamaged))
			set damageEvent = null
        endmethod
    endstruct
endlibrary