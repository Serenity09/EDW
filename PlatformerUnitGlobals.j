library PlatformerUnitGlobals requires PlatformerGlobals
globals
    constant integer GRAVITY = 'e00J' //gravity change totem
    constant integer BOUNCER = 'e00K' //continual bouncing totem
    constant integer UBOUNCE = 'e00L' //single bounce totem
    constant integer RBOUNCE = 'e00M'
    constant integer DBOUNCE = 'e00N'
    constant integer LBOUNCE = 'e00O'
    
    constant integer SUPERSPEED = 'e00Q'
    
    constant real BOUNCER_SPEED = 800 * PlatformerGlobals_GAMELOOP_TIMESTEP
    constant real BOUNCER_MAX_SPEED = 2. * BOUNCER_SPEED
    constant real DIR_BOUNCER_SPEED = 1000 * PlatformerGlobals_GAMELOOP_TIMESTEP
    
    constant real SUPERSPEED_SPEED = 5000 * PlatformerGlobals_GAMELOOP_TIMESTEP
endglobals
endlibrary