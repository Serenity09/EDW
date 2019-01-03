library Blackhole requires ListModule, SimpleList, User, locust, MazerGlobals, IStartable
    globals
        constant player BLACKHOLE_PLAYER = Player(11)
        
        public constant real TIMESTEP = .1
        private timer t = CreateTimer()
        
		private constant real BLACKHOLE_MAXRADIUS = 5 * 128 //this might make lag with multiple players
        public constant real BLACKHOLE_MAX_STRENGTH = 1.5 * TIMESTEP
        public constant real BLACKHOLE_EVENT_HORIZON = 96
		
		private constant boolean DEBUG = false
    endglobals
    
    
    struct Blackhole extends IStartable
        readonly unit BlackholeUnit
        readonly SimpleList_List PlayersInRange
		
		private static SimpleList_List ActiveBlackholes
                
        public static method GetActiveBlackholeFromUnit takes unit b returns thistype
            local SimpleList_ListNode e = ActiveBlackholes.first
            
            loop
            exitwhen e == 0
                if Blackhole(e.value).BlackholeUnit == b then
                    return e.value
                endif
            set e = e.next
            endloop
            
            return 0
        endmethod
        
        public static method GetMaxStrength takes integer ttype, real dist, integer gameMode returns real
            if gameMode == Teams_GAMEMODE_STANDARD then
                if ttype == ABYSS then
                    //takes effect in terms of velocity
                    return 15. * TIMESTEP
                elseif ttype == SNOW or ttype == RSNOW or ttype == SAND then
                    //takes effect in terms of velocity
                    return 10. * TIMESTEP
                elseif ttype == FASTICE or ttype == MEDIUMICE or ttype == SLOWICE then
                    return 8. * TIMESTEP
                else
                    //takes effect in terms of position
                    if dist < .5 * BLACKHOLE_MAXRADIUS then
                        return 200. * TIMESTEP
                    else
                        return 100. * TIMESTEP
                    endif
                endif
            elseif gameMode == Teams_GAMEMODE_PLATFORMING then
                if ttype == ABYSS or ttype == LAVA then
                    return 100. * TIMESTEP
                else
                    return 100. * TIMESTEP
                endif
            else
                return 50. * TIMESTEP
            endif
        endmethod
		
		private method CheckUsers takes nothing returns nothing
			local SimpleList_ListNode curBlackhole = .ActiveBlackholes.first
			
			local integer i = 0
			local SimpleList_ListNode curUser
			local real x
			local real y
			local real distance
			
			loop
			exitwhen curBlackhole == 0
				loop
				exitwhen i >= Teams_MazingTeam.NumberTeams
					set curUser = Teams_MazingTeam.AllTeams[i].FirstUser
					
					loop
					exitwhen curUser == 0
						if not PlayersInRange.contains(curUser.value) then
							set x = GetUnitX(User(curUser.value).ActiveUnit) - GetUnitX(Blackhole(curBlackhole.value).BlackholeUnit)
							set y = GetUnitY(User(curUser.value).ActiveUnit) - GetUnitY(Blackhole(curBlackhole.value).BlackholeUnit)
							set distance = SquareRoot(x*x + y*y)
							
							static if DEBUG then
								call DisplayTextToForce(bj_FORCE_PLAYER[0], "Blackhole distance: " + R2S(distance))
							endif
							
							if distance <= BLACKHOLE_MAXRADIUS then
								call .WatchPlayer(curUser.value)
							endif
						endif
					set curUser = curUser.next
					endloop
				set i = i + 1
				endloop
			set curBlackhole = curBlackhole.next
			endloop
		endmethod
        
        private method PullNearbyUnits takes nothing returns nothing
            local SimpleList_ListNode curNode = .PlayersInRange.first
            local User nearbyUser
            local real nearbyX
            local real nearbyY
            
            local real dx
            local real dy
            local real dist
            
            local real angle
            
            local integer ttype
            loop
            exitwhen curNode == 0
                set nearbyUser = User(curNode.value)
                set nearbyX = GetUnitX(nearbyUser.ActiveUnit)
                set nearbyY = GetUnitY(nearbyUser.ActiveUnit)
                
                set dx = GetUnitX(.BlackholeUnit) - nearbyX
                set dy = GetUnitY(.BlackholeUnit) - nearbyY
                                
                set dist = SquareRoot(dx*dx+dy*dy)
                if dist < BLACKHOLE_EVENT_HORIZON then
                    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", nearbyX, nearbyY))
                    //call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl", nearbyX, nearbyY))
                    //call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", nearbyX, nearbyY))
                    
					if nearbyUser.GameMode != Teams_GAMEMODE_DEAD then
						call nearbyUser.SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
					else
						static if DEBUG then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Blackhole absorbed revive circle")
						endif
						//call SetUnitX(nearbyUser.ActiveUnit, MazerGlobals_SAFE_X)
						//call SetUnitY(nearbyUser.ActiveUnit, MazerGlobals_SAFE_Y)
						call SetUnitPosition(nearbyUser.ActiveUnit, MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
						call ShowUnit(nearbyUser.ActiveUnit, false)
					endif
                elseif dist >= BLACKHOLE_MAXRADIUS then
                    //escaped blackhole, stop watching unit... for now...
                    static if DEBUG then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "No longer watching: " + I2S(nearbyUser))
					endif
                    call .PlayersInRange.remove(nearbyUser)
                else
                    //returns angle in radians
                    set angle = Atan2(dy, dx)
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "angle " + R2S(angle))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "angle deg " + R2S(angle * 180 / bj_PI))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "angle rad " + R2S(angle / 180 * bj_PI))

                    //repurpose dx to measure strength
                    
					set ttype = GetTerrainType(nearbyX, nearbyY)
                    set dx = (BLACKHOLE_MAXRADIUS - dist) / BLACKHOLE_MAXRADIUS * .GetMaxStrength(ttype, dist, nearbyUser.GameMode)
                    if nearbyUser.GameMode == Teams_GAMEMODE_STANDARD then
                        static if DEBUG then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Standard scaled strength " + R2S(dx))
                        endif
						
                        if ttype == ABYSS or ttype == SNOW or ttype == RSNOW or ttype == SAND then
                            set VelocityX[nearbyUser] = VelocityX[nearbyUser] + Cos(angle) * dx
                            set VelocityY[nearbyUser] = VelocityY[nearbyUser] + Sin(angle) * dx
                        else
                            call SetUnitX(nearbyUser.ActiveUnit, nearbyX + Cos(angle) * dx)
                            call SetUnitY(nearbyUser.ActiveUnit, nearbyY + Sin(angle) * dx)
                        endif
                    elseif nearbyUser.GameMode == Teams_GAMEMODE_PLATFORMING then
                        static if DEBUG then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Platforming scaled strength " + R2S(dx))
						endif
                                                
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before Velocity: " + R2S(nearbyUser.Platformer.XVelocity) + "," + R2S(nearbyUser.Platformer.YVelocity))
                        
                        set nearbyUser.Platformer.XVelocity = nearbyUser.Platformer.XVelocity + Cos(angle) * dx
                        set nearbyUser.Platformer.YVelocity = nearbyUser.Platformer.YVelocity + Sin(angle) * dx
                        
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "After Velocity: " + R2S(nearbyUser.Platformer.XVelocity) + "," + R2S(nearbyUser.Platformer.YVelocity))
                    elseif nearbyUser.GameMode == Teams_GAMEMODE_DEAD and nearbyUser.ActiveUnit != null then
						static if DEBUG then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Blackhole moving revive circle")
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Revive scaled strength " + R2S(dx))
						endif
						
						call SetUnitX(nearbyUser.ActiveUnit, nearbyX + Cos(angle) * dx)
						call SetUnitY(nearbyUser.ActiveUnit, nearbyY + Sin(angle) * dx)
					endif
                endif
            set curNode = curNode.next
            endloop            
        endmethod
        
        private static method Periodic takes nothing returns nothing
            //use of thistype because it might not be called by a simple wheel
            local SimpleList_ListNode e = .ActiveBlackholes.first
            
            loop
            exitwhen e == 0
				call Blackhole(e.value).CheckUsers()
                call Blackhole(e.value).PullNearbyUnits()
            set e = e.next
            endloop
            
        endmethod
        
        public method UnwatchPlayer takes integer pID returns nothing
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "No longer watching: " + I2S(pID))
            call .PlayersInRange.remove(pID)
        endmethod
        
        public method WatchPlayer takes integer pID returns nothing
            if not .PlayersInRange.contains(pID) then
                //debug call .PlayersInRange.print(0)
                static if DEBUG then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Now watching: " + I2S(pID))
				endif
				
                call .PlayersInRange.add(pID)
            endif
        endmethod
        
        public method Start takes nothing returns nothing
            if .ActiveBlackholes.count == 0 then
                call TimerStart(t, TIMESTEP, true, function Blackhole.Periodic)
            endif
			
            call .ActiveBlackholes.add(this)
        endmethod
        
        public method Stop takes nothing returns nothing
            call IssueImmediateOrder(.BlackholeUnit, "stop")
            call .PlayersInRange.clear()
            
            call .ActiveBlackholes.remove(this)
			if .ActiveBlackholes.count == 0 then
				call PauseTimer(t)
			endif
        endmethod

            
        public method destroy takes nothing returns nothing
			call .Stop()
			
            call RemoveUnit(.BlackholeUnit)
            call .PlayersInRange.destroy()
            
            set .BlackholeUnit = null
        endmethod
    
        static method create takes real x, real y returns thistype
            local thistype new = thistype.allocate()
            
            set new.BlackholeUnit = CreateUnit(BLACKHOLE_PLAYER, BLACKHOLE, x, y, 0)
            call AddUnitLocust(new.BlackholeUnit)
            set new.PlayersInRange = SimpleList_List.create()
            
            return new
        endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveBlackholes = SimpleList_List.create()
		endmethod
    endstruct
endlibrary