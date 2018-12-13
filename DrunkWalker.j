library DrunkWalker requires Recycle, TimerUtils, IStartable
    globals
        public constant integer MAXIMUM_VALID_LOCATION_ATTEMPTS = 400
    endglobals
    
	public keyword DrunkWalkerSpawn
	
	//create takes rect spawn, real timeBetweenSpawns, real timeBetweenMoves, integer spawnedUnit, real spawnedUnitApproxLifespan returns thistype
    public struct DrunkWalker extends array
        public DrunkWalkerSpawn Parent
		
		readonly real TimeAlive
        readonly unit Walker
        
        public  real minDist
        //public  real maxDist
        
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
            local real dist //approx dist we dont need perfection here boys
			local integer destinationAttempt = 0
                        
            call DestroyEffect(dw.beer)
            set dw.beer = null
            
            //TODO get random point in ring around unit -- generate a random for radius, and a random for angle and then check that the point is legal afterwards
            loop
                set newX = GetRandomReal(GetRectMinX(dw.Parent.SpawnArea), GetRectMaxX(dw.Parent.SpawnArea))
                set newY = GetRandomReal(GetRectMinY(dw.Parent.SpawnArea), GetRectMaxY(dw.Parent.SpawnArea))
                
                set dist = (newX - curX) * (newY - curY) / 2 //good nuff
                set destinationAttempt = destinationAttempt + 1
                
				exitwhen destinationAttempt > MAXIMUM_VALID_LOCATION_ATTEMPTS or (dist > dw.minDist and GetTerrainType(newX, newY) != ABYSS and GetTerrainType(newX, newY) != LAVA)
			endloop
            
            call IssuePointOrder(dw.Walker, "move", newX, newY)
            
            set dw.TimeAlive = dw.TimeAlive + dw.lastTimeoutRand + dw.Parent.WalkerTimeout
            
            call TimerStart(t, dw.Parent.WalkerTimeout, false, function DrunkWalker.drinkEffect)
            
            set t = null
        endmethod
        
        private static method drinkEffect takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype dw = thistype(GetTimerData(t))
            
            if dw.TimeAlive < dw.Parent.WalkerLife then
                set dw.beer = AddSpecialEffectTarget("Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdl", dw.Walker, "overhead")
                
                set dw.lastTimeoutRand = GetRandomReal(0.05, 3)
                if dw.lastTimeoutRand < .35 then
                    call DestroyEffect(dw.beer)
                    set dw.beer = AddSpecialEffectTarget("Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl", dw.Walker, "chest")
                    call SetUnitVertexColor(dw.Walker, 255, 0, 0, 255)
                    call SetUnitMoveSpeed(dw.Walker, GetUnitDefaultMoveSpeed(dw.Walker) * 1.5)
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
			call SetUnitMoveSpeed(.Walker, GetUnitDefaultMoveSpeed(.Walker))
			
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
			            
            set new.minDist = ((GetRectMaxX(parent.SpawnArea) - GetRectMinX(parent.SpawnArea)) * (GetRectMaxY(parent.SpawnArea) - GetRectMinY(parent.SpawnArea))) / 100
            
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
        public real WalkerTimeout
        public real WalkerLife
        public integer uID
		
		private boolean Active
        private timer t
		
        public static method periodic takes nothing returns nothing
            local thistype dws = thistype(GetTimerData(GetExpiredTimer()))
            if dws != 0 then
                call DrunkWalker.create(dws)
            endif
        endmethod
        
        public method Stop takes nothing returns nothing			
			if .Active then
				loop
				exitwhen .Drunks.first == 0
					call DrunkWalker(.Drunks.first.value).destroy()
				endloop
			
                set .Active = false
                //call PauseTimer(.t)
                call ReleaseTimer(.t)
                set .t = null
            endif
        endmethod
        
        public method Start takes nothing returns nothing
            if not .Active then
                set .Active = true
                set .t = NewTimerEx(this)
                call TimerStart(t, .SpawnTimeout, true, function DrunkWalkerSpawn.periodic)
            endif
        endmethod
        
        public static method create takes rect spawn, real spawntimeout, real walktimeout, integer uid, real lifespan returns thistype
            local thistype new = thistype.allocate()
            
			set new.Drunks = SimpleList_List.create()
			
            set new.SpawnArea = spawn
            set new.SpawnTimeout = spawntimeout
            set new.WalkerTimeout = walktimeout
            set new.uID = uid
            set new.WalkerLife = lifespan
            
            set new.Active = false
            
            return new
        endmethod
    endstruct
endlibrary
