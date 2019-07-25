library PlatformerGlobals
globals
    public constant real RADIUS    = 22.
    public constant real SAFE_X    = -12000.0 //x where to store the .Unit when not in use
    public constant real SAFE_Y    = 12000.0 //y where to store the .Unit when not in use
        
    public constant real GAMELOOP_TIMESTEP     = .0350 //.031250000
    //private constant real GAMELOOP_TIMESTEP     = .0500 //.031250000
    public constant real TERRAINLOOP_TIMESTEP  = .0700 //how often to iterate the Terrain loop
    
    //TODO 1-2 timers for handling gravity and x/y falloff (friction)
endglobals
endlibrary
