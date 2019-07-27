library PlatformerSlipStream initializer Init requires SimpleList
    globals
        private SimpleList_List l
        private timer t = CreateTimer()
        
        public constant real TIMEOUT = .08
        public constant real OFFSET = 30 * TIMEOUT
    endglobals

    private function SlipStream takes nothing returns nothing
        local SimpleList_ListNode cur = l.first
        local Platformer p
        local vector2 platformerTerrainCenter
        local real yMin
        local real yMax
        local real halfLength
        local real distFromMiddle
        local real percentFromCenter
        local real multiplier
        local real offset
        
        loop
        exitwhen cur == 0
            set p = cur.value
            
            set platformerTerrainCenter = GetTerrainCenterpoint(p.XPosition, p.YPosition)
            
            set yMin = platformerTerrainCenter.y
            set yMax = platformerTerrainCenter.y
            
            loop
            exitwhen GetTerrainType(p.XPosition, yMin - TERRAIN_TILE_SIZE) != SLIPSTREAM
                set yMin = yMin - TERRAIN_TILE_SIZE
            endloop
            loop
            exitwhen GetTerrainType(p.XPosition, yMax + TERRAIN_TILE_SIZE) != SLIPSTREAM
                set yMax = yMax + TERRAIN_TILE_SIZE
            endloop
            //recycling yMin to avoid declaring another local... a more accurate name would be yMiddle
            set yMin = (yMin + yMax) / 2
            
            //halfLength = yMax - yMin(yMiddle)
            //percentFromCenter <-1,1> = (p.YPosition - yMin(yMiddle)) / halfLength 
            set halfLength = yMax - yMin
            set distFromMiddle = p.YPosition - yMin
            set percentFromCenter = distFromMiddle / halfLength
            set multiplier = -Sin(percentFromCenter * bj_PI / 2)
            //set multiplier = Sin(((p.YPosition - yMin) / (yMax - yMin)) * -bj_PI / 2)
            set offset = OFFSET * multiplier
            
            /*
            if RAbsBJ(distFromMiddle) < 10 then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Y Position: " + R2S(p.YPosition))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Slipstream middle: " + R2S(yMin))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Half Length: " + R2S(halfLength))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Dist from middle: " + R2S(distFromMiddle))
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Percent From Center: " + R2S(percentFromCenter))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Multiplier: " + R2S(multiplier))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Multiplier: " + R2S(multiplier))
                debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Y velocity: " + R2S(p.YVelocity))
            endif
            */
            
            set p.YVelocity = p.YVelocity + offset
            
            //this only works perfectly if the unit starts at the bottom or the top. it would be better to compute their expected velocity and set towards that
            /*
            if p.YPosition < yMin then
                set p.YVelocity = p.YVelocity + offset //push unit towards center of the slip stream
            elseif p.YPosition > yMin then
                set p.YVelocity = p.YVelocity - offset
            endif
            */
            
        set cur = cur.next
        endloop
    endfunction
    
    public function Add takes Platformer p returns nothing
        call l.addEnd(p)
        
        if l.count == 1 then
            call TimerStart(t, TIMEOUT, true, function SlipStream)
        endif
    endfunction
    
    public function Remove takes Platformer p returns nothing
        call l.remove(p)
        
        if l.count == 0 then
            call PauseTimer(t)
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        set l = SimpleList_List.create()
    endfunction
endlibrary