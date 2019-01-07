library PlatformerProfile initializer Init requires PlatformerGlobals
    globals        
        public constant integer             DefaultProfileID = 1
        //public constant integer             CrazyIceProfileID = 2
        public constant integer		    MoonProfileID = 2
        
        private constant integer   vJUMPSPEED      = 715      //default vertical jump speed
        private constant integer   hJUMPSPEED      = 785      //default horizontal jump speed
        private constant real   v2hJUMPSPEED       = .8500       //vWALLJUMP * vJUMPSPEED = vTOTALJUMPHEIGHT for wall jumps
        private constant integer   xFALLOFF        = 50       //linear rate horizontal speed falls off
        private constant integer   yFALLOFF        = 30       //linear rate vertical speed falls off
        //private constant integer   XTERMINAL       = 350      //default cap before x velocity starts falling off much faster
        private constant integer   YTERMINAL       = 515      //default cap before x velocity starts falling off much faster
        private constant integer   GRAVITYACCEL    = -35      //default acceleration due to gravity
        private constant integer   MOVESPEED       = 370      //default movespeed
        private constant real   MOVESPEEDOFFSET    = .07500   //default movespeed effect on x velocity when opposed
    endglobals
        
    struct PlatformerProfile extends array
        private static integer instanceCount = 0
        
        //all properties that support physics
        //public real          TerminalVelocityX    //this caps how fast a unit can go due to gravity, going faster in this will cause you to slow down to this over time
        public real          TerminalVelocityY    //this caps how fast a unit can go due to gravity, going faster in this will cause you to slow down to this over time
        //TODO replace X and Y falloff with references to easing functions
        public real          XFalloff             //how much to reduce XVelocity by when != 0
        public real          YFalloff             //how much to reduce YVelocity by when >= TerminalVelocityY (TODO change to be just != 0 like XFalloff)
        public real          MoveSpeed            //this determines how fast a unit moves left/right
        public real          MoveSpeedVelOffset   //how much moving in the opposite direction as your velocity decrements it. newXVeloc = oldXVeloc - .MoveSpeedVelOffset * .MoveSpeed
        public real          GravitationalAccel   //how strong the effect of gravity is
        public real          vJumpSpeed           //how fast a wall jump is vertically
        public real          v2hJumpRatio         //0-1 how much of vJumpSpeed is still applied (vertically) during a wall jump
        public real          hJumpSpeed           //how fast a wall jump is horizontally
        
        public static method create takes integer tvy, integer xf, integer yf, integer ms, real msoff, integer ga, integer vj, real v2h, integer hj returns PlatformerProfile
            local thistype new
            
            //first check to see if there are any structs waiting to be recycled
            set instanceCount = instanceCount + 1
            set new = instanceCount
            
            //calculate the base * TIMESTEP once, when created
            //set new.TerminalVelocityX = tvx * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.TerminalVelocityY = tvy * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.XFalloff = xf * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.YFalloff = yf * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.MoveSpeed = ms * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.GravitationalAccel = ga * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.vJumpSpeed = vj * PlatformerGlobals_GAMELOOP_TIMESTEP
            set new.hJumpSpeed = hj * PlatformerGlobals_GAMELOOP_TIMESTEP
            
            //ratios/percentages don't get effected by timestep length
            set new.MoveSpeedVelOffset = msoff
            set new.v2hJumpRatio = v2h

            
            return new
        endmethod        
    endstruct
    
    private function Init takes nothing returns nothing
        //create default profile
        local PlatformerProfile profile = PlatformerProfile.create(YTERMINAL, xFALLOFF, yFALLOFF, MOVESPEED, MOVESPEEDOFFSET, GRAVITYACCEL, vJUMPSPEED, v2hJUMPSPEED, hJUMPSPEED)
        if profile != DefaultProfileID then
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, another profile was created before the default profile! Platforming is going to crash and burn horribly!")
        endif
        
        
        //old profile to make ice feel better -- this caused everything to feel a bit off from what you'd just gotten used to
        /*
		set profile = PlatformerProfile.create(YTERMINAL*2, 0, 0, MOVESPEED, MOVESPEEDOFFSET, GRAVITYACCEL, vJUMPSPEED, v2hJUMPSPEED, hJUMPSPEED)
        if profile != CrazyIceProfileID then
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, another profile was created before the ice profile! Some ice worlds are going to crash and burn horribly!")
        endif
		*/
		
		//moon profile
        set profile = PlatformerProfile.create(R2I(YTERMINAL * .75), R2I(xFALLOFF * 0.1), R2I(yFALLOFF * 0.1), R2I(MOVESPEED * .9), MOVESPEEDOFFSET, 10, vJUMPSPEED, v2hJUMPSPEED, hJUMPSPEED)
    endfunction
endlibrary