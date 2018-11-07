library PlatformerOcean initializer Init requires Stack, TerrainGlobals
    globals
        public constant real GRAVITYPERCENT = .35
        
        private constant real OPPOSITIONDIFFERENCE = .9
        public real OCEAN_MOTION = 2
        public constant real XVELOCITYONJUMP = .7
        public constant real V2H = 0.1
        public constant real VJUMP = 1
        public constant real HJUMP = .7
        public constant real MS = .15
        public constant real XFALLOFF = .12
        public constant real YFALLOFF = 1.
        public constant real TVX = .75
        public constant real TVY = .6
        public constant real MSOFF = 0.1
        public constant real ENTRANCE_VEL = .4
        
        private constant real MAX_VELOCITY = TERRAIN_QUADRANT_SIZE/4
        
        public constant real TIMESTEP = .25
        
        private timer Timer
        public SimpleList_List Platformers
    endglobals
    
    private function Loop takes Platformer p returns nothing        
        /*
        if p.HorizontalAxisState != 0 then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity + p.MoveSpeed * p.HorizontalAxisState * OCEAN_MOTION))
            set p.XVelocity = p.XVelocity + p.MoveSpeed * p.HorizontalAxisState * OCEAN_MOTION
        endif
        */
        //design concept:
        //movement left and right should be entirely velocity based, with the platformer gaining a boost going in the same direction of their velocity
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Ocean loop plat " + I2S(p) + " axis state " + I2S(p.HorizontalAxisState))
        
        //going right
        if p.HorizontalAxisState == 1 then
            if p.XVelocity < 0 then //velocity left
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "(opp) before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity + p.MoveSpeed * .5))
                set p.XVelocity = p.XVelocity + p.MoveSpeed * OCEAN_MOTION * OPPOSITIONDIFFERENCE
                    
                set p.FX = AddSpecialEffect("Doodads\\Icecrown\\Water\\BubbleGeyserSteam\\BubbleGeyserSteam.mdl", GetUnitX(p.Unit), GetUnitY(p.Unit))
                call DestroyEffect(p.FX)
                set p.FX = null
            elseif p.XVelocity == MAX_VELOCITY then
                //no change, still maxed
            elseif p.XVelocity + p.MoveSpeed*OCEAN_MOTION >= MAX_VELOCITY then
                set p.XVelocity = MAX_VELOCITY
            else
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "(same) before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity + p.MoveSpeed * OCEAN_MOTION))
                set p.XVelocity = p.XVelocity + p.MoveSpeed * OCEAN_MOTION
            endif
        elseif p.HorizontalAxisState == -1 then
            if p.XVelocity > 0 then //velocity right
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "(opp) before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity - p.MoveSpeed * .5))
                set p.XVelocity = p.XVelocity - p.MoveSpeed * OCEAN_MOTION * OPPOSITIONDIFFERENCE
                
                set p.FX = AddSpecialEffect("Doodads\\Icecrown\\Water\\BubbleGeyserSteam\\BubbleGeyserSteam.mdl", GetUnitX(p.Unit), GetUnitY(p.Unit))
                call DestroyEffect(p.FX)
                set p.FX = null
            elseif p.XVelocity == -MAX_VELOCITY then
                //no change, still maxed
            elseif p.XVelocity - p.MoveSpeed*OCEAN_MOTION <= -MAX_VELOCITY then
                set p.XVelocity = -MAX_VELOCITY
            else
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "(same) before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity - p.MoveSpeed * OCEAN_MOTION))
                set p.XVelocity = p.XVelocity - p.MoveSpeed * OCEAN_MOTION
            endif
        endif
    endfunction
    
    private function Loop_Init takes nothing returns nothing
        local SimpleList_ListNode cur = Platformers.first
        
        if cur != 0 then
            loop
            exitwhen cur == 0
                call Loop(cur.value)
            set cur = cur.next
            endloop
        endif
    endfunction
    
    public function Add takes Platformer p returns nothing
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Ocean adding platformer " + I2S(p) + " count " + I2S(Platformers.count))
        
        if Platformers.count == 0 then
            call TimerStart(Timer, TIMESTEP, true, function Loop_Init)
        endif
        call Platformers.add(p)
    endfunction
    
    public function Remove takes Platformer p returns nothing
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Ocean removing platformer " + I2S(p) + " count " + I2S(Platformers.count))
        
        call Platformers.remove(p)
        if Platformers.count == 0 then
            call PauseTimer(Timer)
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        set Platformers = SimpleList_List.create()
        set Timer = CreateTimer()
    endfunction
endlibrary
