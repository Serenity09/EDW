library DrunkWalker requires Recycle, TimerUtils, IStartable
    globals
        public constant integer MAXIMUM_VALID_LOCATION_ATTEMPTS = 12
		public constant real STOP_TIMEOUT_BUFFER_MINIMUM = .3
		public constant real STOP_TIMEOUT_BUFFER_MAXIMUM = .7
		
		private constant real IDEAL_BEER_MODEL_RADIUS = 80.
		private constant real STATIC_BEER_VFX_SCALE = 1.75
		private constant real STATIC_BEER_VFX_HEIGHT = 50.
		private constant real PCT_BEFORE_ANGRY = .75
		
		private constant boolean DEBUG_EXCEED_DESTINATION_ATTEMPT = false
    endglobals
    
	public keyword DrunkWalkerSpawn
	
	//create takes rect spawn, real timeBetweenSpawns, real timeBetweenMoves, integer spawnedUnit, real spawnedUnitApproxLifespan returns thistype
    public struct DrunkWalker extends array
        public DrunkWalkerSpawn Parent
		
		readonly real TimeAlive
        readonly unit Walker
                
        private real lastTimeoutRand
        private effect beer
        
        private timer t
        
		implement Alloc
		
        private static method move takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype dw = thistype(GetTimerData(t))
            
            local real curX = GetUnitX(dw.Walker)
            local real curY = GetUnitY(dw.Walker)
            
            local real newX
            local real newY
			
			local real dx
			local real dy
			
            local real dist //approx dist we dont need perfection here boys
			
			local integer destinationAttempt = 0
                        
            call DestroyEffect(dw.beer)
            set dw.beer = null
            
            //TODO get random point in ring around unit -- generate a random for radius, and a random for angle and then check that the point is legal afterwards
            loop
			set destinationAttempt = destinationAttempt + 1
                set newX = GetRandomReal(GetRectMinX(dw.Parent.SpawnArea), GetRectMaxX(dw.Parent.SpawnArea))
                set newY = GetRandomReal(GetRectMinY(dw.Parent.SpawnArea), GetRectMaxY(dw.Parent.SpawnArea))
				
                // set dist = (newX - curX) * (newY - curY) / 2 //good nuff
				set dx = newX - curX
				set dy = newY - curY
				set dist = SquareRoot(dx*dx + dy*dy)
			exitwhen destinationAttempt > MAXIMUM_VALID_LOCATION_ATTEMPTS or (dist > dw.Parent.MinDistance and GetTerrainType(newX, newY) != ABYSS and GetTerrainType(newX, newY) != LAVA)
			endloop
            
			static if DEBUG_EXCEED_DESTINATION_ATTEMPT then
				if destinationAttempt > MAXIMUM_VALID_LOCATION_ATTEMPTS then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Drunk (" + I2S(dw) + ") exceeded destination attempt check")
				endif
			endif
			
            call IssuePointOrder(dw.Walker, "move", newX, newY)
            
			set dx = (dist / IndexedUnit(GetUnitUserData(dw.Walker)).GetMoveSpeed()) + GetRandomReal(STOP_TIMEOUT_BUFFER_MINIMUM, STOP_TIMEOUT_BUFFER_MAXIMUM)
            set dw.TimeAlive = dw.TimeAlive + dx
            call TimerStart(t, dx, false, function DrunkWalker.drinkEffect)
            
            set t = null
        endmethod
        
        private static method drinkEffect takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype dw = thistype(GetTimerData(t))
            
            if dw.TimeAlive < dw.Parent.WalkerLife then
                //set dw.beer = AddSpecialEffectTarget("Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdl", dw.Walker, "overhead")
                set dw.beer = AddSpecialEffect("Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdl", GetUnitX(dw.Walker), GetUnitY(dw.Walker))
				call BlzSetSpecialEffectScale(dw.beer, STATIC_BEER_VFX_SCALE)
				call BlzSetSpecialEffectHeight(dw.beer, STATIC_BEER_VFX_HEIGHT)
				//call BlzSetSpecialEffectScale(dw.beer, IDEAL_BEER_MODEL_RADIUS / GetUnitDefaultRadius(dw.Parent.uID))
				
                set dw.lastTimeoutRand = GetRandomReal(1, 3)
				set dw.TimeAlive = dw.TimeAlive + dw.lastTimeoutRand
				
                if dw.TimeAlive / dw.Parent.WalkerLife >= PCT_BEFORE_ANGRY and GetRandomInt(0, 1) == 1 then
                    // call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl", dw.Walker, "chest"))
					//call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdl", dw.Walker, "chest"))
					call CreateTimedSpecialEffectTarget("Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdl", dw.Walker, SpecialEffect_ORIGIN, null, dw.lastTimeoutRand - .05)
					call SetUnitVertexColor(dw.Walker, 255, 0, 0, 255)
                    call IndexedUnit(GetUnitUserData(dw.Walker)).SetMoveSpeed(GetDefaultMoveSpeed(dw.Parent.uID) * 1.5)
					//call SetUnitMoveSpeed(dw.Walker, GetUnitDefaultMoveSpeed(dw.Walker) * 1.5)
                endif
                call TimerStart(t, dw.lastTimeoutRand, false, function DrunkWalker.move)
                set t = null
            else
                call dw.destroy()
            endif
        endmethod
		
		public method destroy takes nothing returns nothing
			if .beer != null then
				call DestroyEffect(.beer)
				set .beer = null
			endif
			
			call SetUnitVertexColor(.Walker, 255, 255, 255, 255)
			call IndexedUnit(GetUnitUserData(.Walker)).SetMoveSpeed(GetDefaultMoveSpeed(.Parent.uID))
			//call SetUnitMoveSpeed(.Walker, GetUnitDefaultMoveSpeed(.Walker))
			
			call Recycle_ReleaseUnit(.Walker)
			set .Walker = null
			
			//call PauseTimer(.t) //happens during release timer
			call ReleaseTimer(.t)
			set .t = null
			
			call .Parent.Drunks.remove(this)
			
			call .deallocate()
		endmethod
        
        public static method create takes DrunkWalkerSpawn parent returns thistype
            local thistype new = thistype.allocate()
            local real tempX
            local real tempY
            local integer ttype
			
			local integer destinationAttempt = 0
			
			call parent.Drunks.addEnd(new)
			set new.Parent = parent
			            
            loop
                set tempX = GetRandomReal(GetRectMinX(parent.SpawnArea), GetRectMaxX(parent.SpawnArea))
                set tempY = GetRandomReal(GetRectMinY(parent.SpawnArea), GetRectMaxY(parent.SpawnArea))
                
                set ttype = GetTerrainType(tempX, tempY)
				set destinationAttempt = destinationAttempt + 1
                exitwhen destinationAttempt > MAXIMUM_VALID_LOCATION_ATTEMPTS or ttype == ABYSS or ttype == LAVA
            endloop
            
            set new.Walker = Recycle_MakeUnit(parent.uID, tempX, tempY)
            set new.TimeAlive = GetRandomReal(.75, 2.25)
            set new.lastTimeoutRand = new.TimeAlive
            
            set new.t = NewTimerEx(new)
            call TimerStart(new.t, new.TimeAlive, false, function DrunkWalker.drinkEffect)
            
            return new
        endmethod
    endstruct
	
    public struct DrunkWalkerSpawn extends IStartable
        public SimpleList_List Drunks
		
		public rect SpawnArea
        public real SpawnTimeout
        public real WalkerLife
        public integer uID
		
		readonly real MinDistance
        private timer t
		
        public static method periodic takes nothing returns nothing
            local thistype dws = thistype(GetTimerData(GetExpiredTimer()))
            if dws != 0 then
                call DrunkWalker.create(dws)
            endif
        endmethod
        
        public method Stop takes nothing returns nothing			
			loop
			exitwhen .Drunks.first == 0
				call DrunkWalker(.Drunks.first.value).destroy()
			endloop
		
			//call PauseTimer(.t)
			call ReleaseTimer(.t)
			set .t = null
        endmethod
        
        public method Start takes nothing returns nothing
			set .t = NewTimerEx(this)
			call TimerStart(t, .SpawnTimeout, true, function DrunkWalkerSpawn.periodic)
        endmethod
        
        public static method create takes rect spawn, real spawntimeout, integer uid, real lifespan returns thistype
            local thistype new = thistype.allocate()
            
			set new.Drunks = SimpleList_List.create()
			
            set new.SpawnArea = spawn
            set new.SpawnTimeout = spawntimeout
            set new.uID = uid
            set new.WalkerLife = lifespan
            
			set new.MinDistance = RAbsBJ((GetRectMaxX(spawn) - GetRectMinX(spawn)))
			if RAbsBJ((GetRectMaxY(spawn) - GetRectMinY(spawn))) >= new.MinDistance then
				set new.MinDistance = RAbsBJ((GetRectMaxY(spawn) - GetRectMinY(spawn)))
			endif
			set new.MinDistance = new.MinDistance / 10.
            
            return new
        endmethod
    endstruct
endlibrary
