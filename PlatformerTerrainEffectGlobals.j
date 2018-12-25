library PlatformerTerrainEffectGlobals requires PlatformerGlobals, TerrainGlobals
    globals

        constant real VINES_SLOWDOWNPERCENT = .2
        constant real VINES_MOVESPEEDPERCENT = .75
        
        constant real BOOST_SPEED = 1300 * PlatformerGlobals_GAMELOOP_TIMESTEP
        
        constant real SAND_FALLOFF = 3
        
        constant real GRASS_MS = 1.25
        constant real GRASS_TVY = .25
        constant real DGRASS_MS = 1.5
        constant real DGRASS_TVY = .4

        //TODO make constant once default jump is finalized
        real JUMPHEIGHTINOCEAN = 440 * PlatformerGlobals_GAMELOOP_TIMESTEP
        constant real OCEAN_JUMP_COOLDOWN = .50
        
        
        //needs to be compatible with GetNextDiagonal assumptions -- namely won't change more than 1 quadrant per loop
        //constant real DIAGONAL_MAXCHANGE = TERRAIN_QUADRANT_SIZE - 4
        constant real PLATFORMING_MAXCHANGE = 42 //point in diagonal assumes that the test point is within 2*sqrt(16*16 + 16*16) = 45.25...
        constant boolean PLATFORMING_CHECK_HALFWAY = false //should be true if PLATFORMING_MAXCHANGE > TERRAIN_QUADRANT_SIZE (64)
        
		constant real DIAGONAL_ESCAPEDISTANCE = 10 //should allow the player to freely escape by pressing arrow keys or jumping
        constant real DIAGONAL_STICKYDISTANCE = PLATFORMING_MAXCHANGE - 10 //amount of stickyness when transitioning between diagonals -- pretty sticky = fun

        //used to sample multiple points when the player is moving very fast
        //constant real PATHING_SEGMENT_SIZE = 30
        //constant real DIAGONAL_NOMANUALESCAPEDISTANCE = 30
        
        constant real   IN_DIAGONAL_OFFSET=64.00000      //distance platformer is kept from the centerpoint, also used for generating the b component of y = mx + b
        constant real   LEAVE_DIAGONAL_OFFSET=1.5		//0 to disable
        constant real   DIAGONAL_TERRAIN_CHECK_OFFSET = TERRAIN_QUADRANT_SIZE / 4
        //constant real   TERRAIN_DEADZONE_OFFSET=.51
    endglobals
endlibrary

-ga 1.225