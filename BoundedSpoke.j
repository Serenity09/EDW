library BoundedSpoke requires Alloc, SimpleList, locust
    globals
        public constant player SPOKE_PLAYER = Player(11)
        
        public constant real TIMESTEP = .1
        private constant real DEFAULT_ROTATION_SPEED = bj_PI / 10 * TIMESTEP //18 degrees per sec
    endglobals
        
    struct BoundedSpoke extends IStartable
        public real LayerOffset
        public real InitialOffset
        public real MinAngle
        public real MaxAngle
        
        public real CurrentRotationSpeed //in terms of radians per second
        
        public vector2 Center
        
        public real CurrentAngle
        public SimpleList_List Units
        
        private static timer Timer
        private static SimpleList_List ActiveSpokes
        
		public method Print takes nothing returns nothing
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Min angle: " + R2S(.MinAngle) + ", Max angle: " + R2S(.MaxAngle))
		endmethod
		
        private method Rotate takes nothing returns nothing
            local SimpleList_ListNode wUnitNode = this.Units.first
            
            //R2I translates to Math.floor
            local integer iLayer = 0
            local real x
            local real y
            
            local real theta = this.CurrentAngle + this.CurrentRotationSpeed
            
			if this.MaxAngle != 0 then
				if theta >= this.MaxAngle then
					set this.CurrentAngle = this.MaxAngle
					
					set this.CurrentRotationSpeed = -this.CurrentRotationSpeed
					set theta = this.CurrentAngle + this.CurrentRotationSpeed
				elseif theta <= this.MinAngle then
					set this.CurrentAngle = this.MinAngle
					
					set this.CurrentRotationSpeed = -this.CurrentRotationSpeed
					set theta = this.CurrentAngle + this.CurrentRotationSpeed
				endif
			endif
            
            loop
            exitwhen wUnitNode == 0
                if wUnitNode.value != 0 then
                    set x = this.Center.x + this.InitialOffset * Cos(theta) + iLayer * this.LayerOffset * Cos(theta)
                    set y = this.Center.y + this.InitialOffset * Sin(theta) + iLayer * this.LayerOffset * Sin(theta)
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y))
                    
                    call SetUnitPosition(IndexedUnit(wUnitNode.value).Unit, x, y)
                endif
                
            set iLayer = iLayer + 1
            set wUnitNode = wUnitNode.next
            endloop
            
            set this.CurrentAngle = this.CurrentAngle + this.CurrentRotationSpeed
            if this.CurrentAngle >= 2*bj_PI then
                set this.CurrentAngle = this.CurrentAngle - 2*bj_PI
            endif
        endmethod
        
        private static method Periodic takes nothing returns nothing
            local SimpleList_ListNode curSpoke = thistype.ActiveSpokes.first
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Wheel periodic!")
            
            loop
            exitwhen curSpoke == 0
                call thistype(curSpoke.value).Rotate()
            set curSpoke = curSpoke.next
            endloop
        endmethod
        
        public method Stop takes nothing returns nothing
            call thistype.ActiveSpokes.remove(this)
            
            if thistype.ActiveSpokes.count == 0 then
                call PauseTimer(thistype.Timer)
            endif
            
            //TODO hide all wheel units
        endmethod
        
        public method Start takes nothing returns nothing
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Starting wheel")
            
            if thistype.ActiveSpokes.count == 0 then
                call TimerStart(thistype.Timer, TIMESTEP, true, function thistype.Periodic)
            endif
            
            call thistype.ActiveSpokes.addEnd(this)
            
            //TODO show all wheel units
        endmethod
        
        //adds units to spokes
        public method AddUnits takes integer unitID, integer count returns nothing
            local integer iUnit = 0
			local unit u
            
            //R2I translates to Math.floor
            local integer iLayer
            local real x
            local real y
            
            local real theta
            
            loop
            exitwhen iUnit >= count
                set iLayer = this.Units.count
                                
                set x = this.Center.x + this.InitialOffset * Cos(this.CurrentAngle) + iLayer * this.LayerOffset * Cos(this.CurrentAngle)
                set y = this.Center.y + this.InitialOffset * Sin(this.CurrentAngle) + iLayer * this.LayerOffset * Sin(this.CurrentAngle)
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y))
                
                set u = CreateUnit(SPOKE_PLAYER, unitID, x, y, 0)
				call IndexedUnit.create(u)
                call AddUnitLocust(u)
                
                call this.Units.addEnd(GetUnitUserData(u))
            set iUnit = iUnit + 1
            endloop
        endmethod
        
        public method AddEmptySpace takes integer count returns nothing
            local integer iUnit = 0
            loop
            exitwhen iUnit >= count                
                call this.Units.addEnd(0)
            set iUnit = iUnit + 1
            endloop
        endmethod
        
        public method SetAngleBounds takes real min, real max returns nothing
            set this.MinAngle = min
            set this.MaxAngle = max
            
            set this.CurrentAngle = min
        endmethod
        
        public static method onInit takes nothing returns nothing
            set thistype.ActiveSpokes = SimpleList_List.create()
            set thistype.Timer = CreateTimer()
        endmethod
        
        public static method create takes real x, real y returns thistype
            local thistype new = thistype.allocate()
            
            set new.Center = vector2.create(x, y)
            
            set new.InitialOffset = 0
            
            set new.CurrentAngle = 0
            set new.CurrentRotationSpeed = DEFAULT_ROTATION_SPEED
            set new.MinAngle = 0
            set new.MaxAngle = 0
            
            set new.Units = SimpleList_List.create()
            
            return new
        endmethod
    endstruct
endlibrary