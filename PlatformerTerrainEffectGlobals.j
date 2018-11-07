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
        
        constant real DIAGONAL_MAXCHANGE = TERRAIN_QUADRANT_SIZE - 4
        
        constant real DIAGONAL_ESCAPEDISTANCE = 10
        constant real DIAGONAL_STICKYDISTANCE = 40
        //needs to be compatible with GetNextDiagonal assumptions -- namely won't change more than 1 quadrant per loop
        
        constant real PLATFORMING_MAXCHANGE = TERRAIN_QUADRANT_SIZE*.9
        constant boolean PLATFORMING_CHECK_HALFWAY = true //should be true if PLATFORMING_MAXCHANGE > TERRAIN_QUADRANT_SIZE (64)
        
        //used to sample multiple points when the player is moving very fast
        constant real PATHING_SEGMENT_SIZE = 30
        //constant real DIAGONAL_NOMANUALESCAPEDISTANCE = 30
        
        constant real   IN_DIAGONAL_OFFSET=64.00000      //distance platformer is kept from the centerpoint, also used for generating the b component of y = mx + b
        constant real   LEAVE_DIAGONAL_OFFSET=.51
        constant real   DIAGONAL_TERRAIN_CHECK_OFFSET = TERRAIN_QUADRANT_SIZE / 4
        //constant real   TERRAIN_DEADZONE_OFFSET=.51
    endglobals
endlibrary