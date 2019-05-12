library Wheel requires Alloc, SimpleList, locust, UnitWrapper
    globals
        public constant player WISP_WHEEL_PLAYER = Player(11)
        
        public constant real TIMEOUT = .1
        private constant real DEFAULT_ROTATION_SPEED = bj_PI / 50 * TIMEOUT //1.8 degrees per sec
    endglobals
        
    struct Wheel extends IStartable
        public integer SpokeCount
        public integer LayerCount
        public real AngleBetween //between spokes
        public real DistanceBetween //between layers
        public real InitialOffset
        
        public real RotationSpeed //in terms of radians per second
        
        //TODO convert to unit if ever want to make wheel move
        public vector2 Center
        
        public real CurrentAngle
        public SimpleList_List Units
        
        private static timer Timer
        private static SimpleList_List ActiveWheels
        
        private stub method Rotate takes nothing returns nothing
            local SimpleList_ListNode wUnitNode = this.Units.first
            
            //R2I translates to Math.floor
            local integer iLayer = 0
            local integer iSpoke = 0
            local real x
            local real y
            
            local real theta
            
            loop
            exitwhen wUnitNode == 0
                if iSpoke == this.SpokeCount then
                    set iSpoke = 0
                    set iLayer = iLayer + 1
                    
                    set theta = 0
                endif
                
                if wUnitNode.value != 0 then
                    set theta = this.CurrentAngle + iSpoke * this.AngleBetween
                    set x = this.Center.x + this.InitialOffset * Cos(theta) + (iLayer + 1) * this.DistanceBetween * Cos(theta)
                    set y = this.Center.y + this.InitialOffset * Sin(theta) + (iLayer + 1) * this.DistanceBetween * Sin(theta)
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y))
                    
                    //call SetUnitX(UnitWrapper(wUnitNode).u, x)
                    //call SetUnitY(UnitWrapper(wUnitNode).u, y)
                    call SetUnitPosition(UnitWrapper(wUnitNode.value).u, x, y)
                //else
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Empty unit")
                endif
                
                
            set iSpoke = iSpoke + 1
            set wUnitNode = wUnitNode.next
            endloop
            
            set this.CurrentAngle = this.CurrentAngle + this.RotationSpeed
            if this.CurrentAngle >= 2*bj_PI then
                set this.CurrentAngle = this.CurrentAngle - 2*bj_PI
            endif
        endmethod
        
        private static method Periodic takes nothing returns nothing
            local SimpleList_ListNode curWheel = thistype.ActiveWheels.first
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Wheel periodic!")
            
            loop
            exitwhen curWheel == 0
                call thistype(curWheel.value).Rotate()
            set curWheel = curWheel.next
            endloop
        endmethod
        
        public method Stop takes nothing returns nothing
            call thistype.ActiveWheels.remove(this)
            
            if thistype.ActiveWheels.count == 0 then
                call PauseTimer(thistype.Timer)
            endif
            
            //TODO hide all wheel units
        endmethod
        
        public method Start takes nothing returns nothing
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Starting wheel")
            
            if thistype.ActiveWheels.count == 0 then
                call TimerStart(thistype.Timer, TIMEOUT, true, function thistype.Periodic)
            endif
            
            call thistype.ActiveWheels.addEnd(this)
            
            //TODO show all wheel units
        endmethod
        
        //adds units to spokes
        public method AddUnits takes integer unitID, integer count returns nothing
            local integer iUnit = 0
            local UnitWrapper wu
            
            //R2I translates to Math.floor
            local integer iLayer
            local integer iSpoke
            local real x
            local real y
            
            local real theta
            
            loop
            exitwhen iUnit >= count
                set iLayer = this.Units.count / this.SpokeCount
                set iSpoke = this.Units.count - iLayer * this.SpokeCount
                
                set wu = UnitWrapper.allocate()
                
                set theta = this.CurrentAngle + iSpoke * this.AngleBetween
                set x = this.Center.x + this.InitialOffset * Cos(theta) + (iLayer + 1) * this.DistanceBetween * Cos(theta)
                set y = this.Center.y + this.InitialOffset * Sin(theta) + (iLayer + 1) * this.DistanceBetween * Sin(theta)
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y))
                
                set wu.u = CreateUnit(WISP_WHEEL_PLAYER, unitID, x, y, 0)
                call AddUnitLocust(wu.u)
                
                call this.Units.addEnd(wu)
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

        public method AddLayer takes integer unitID returns nothing
            local integer iUnit = 0
            local integer remainingInLayer = this.SpokeCount - ModuloInteger(this.Units.count, this.SpokeCount)
            
            if remainingInLayer == 0 then
                set remainingInLayer = this.SpokeCount
            endif
            
            if unitID != 0 then
                call this.AddUnits(unitID, remainingInLayer)
            else
                call this.AddEmptySpace(remainingInLayer)
            endif
        endmethod
        
        public static method onInit takes nothing returns nothing
            set thistype.ActiveWheels = SimpleList_List.create()
            set thistype.Timer = CreateTimer()
        endmethod
        
        public static method create takes real x, real y returns thistype
            local thistype new = thistype.allocate()
            
            set new.Center = vector2.create(x, y)
            
            set new.LayerCount = 1
            set new.InitialOffset = 0
            set new.RotationSpeed = DEFAULT_ROTATION_SPEED
            set new.CurrentAngle = 0
            set new.Units = SimpleList_List.create()
            
            return new
        endmethod
		public static method createFromPoint takes rect point returns thistype
			return thistype.create(GetRectCenterX(point), GetRectCenterY(point))
		endmethod
    endstruct
endlibrary