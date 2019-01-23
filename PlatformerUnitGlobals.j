library PlatformerUnitGlobals requires PlatformerGlobals
globals
    constant integer GRAVITY = 'e00J' //gravity change totem
    constant integer BOUNCER = 'e00K' //continual bouncing totem
    constant integer UBOUNCE = 'e00L' //single bounce totem
    constant integer RBOUNCE = 'e00M'
    constant integer DBOUNCE = 'e00N'
    constant integer LBOUNCE = 'e00O'
    
    constant integer SUPERSPEED = 'e00Q'
    
    constant real BOUNCER_SPEED = 925 * PlatformerGlobals_GAMELOOP_TIMESTEP
    constant real BOUNCER_MAX_SPEED = 1600 * PlatformerGlobals_GAMELOOP_TIMESTEP
    constant real DIR_BOUNCER_SPEED = 1000 * PlatformerGlobals_GAMELOOP_TIMESTEP
	constant real DIR_BOUNCER_RESPAWN_TIME = 3.
    
    constant real SUPERSPEED_SPEED = 5000 * PlatformerGlobals_GAMELOOP_TIMESTEP
endglobals
endlibrary