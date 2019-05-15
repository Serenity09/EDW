library BoundedWheel requires Alloc, SimpleList, locust
    globals
        public constant player WISP_WHEEL_PLAYER = Player(10)
        
        public constant real TIMEOUT = .1
        private constant real DEFAULT_ROTATION_SPEED = bj_PI / 50 * TIMEOUT //1.8 degrees per sec
    endglobals
        
    struct BoundedWheel extends Wheel
        public real MinAngle
        public real MaxAngle
        
        private method Rotate takes nothing returns nothing
            local SimpleList_ListNode wUnitNode = this.Units.first
            
            //R2I translates to Math.floor
            local integer iLayer = 0
            local integer iSpoke = 0
            local real x
            local real y
            
            local real theta = this.CurrentAngle + this.RotationSpeed
            
            if theta >= this.MaxAngle then
                set this.CurrentAngle = this.MaxAngle
                
                set this.RotationSpeed = -this.RotationSpeed
            elseif theta <= this.MinAngle then
                set this.CurrentAngle = this.MinAngle
                
                set this.RotationSpeed = -this.RotationSpeed
            endif
            
            loop
            exitwhen wUnitNode == 0
                if iSpoke == this.SpokeCount then
                    set iSpoke = 0
                    set iLayer = iLayer + 1
                endif
                
                if wUnitNode.value != 0 then
                    set theta = this.CurrentAngle + iSpoke * this.AngleBetween
                    set x = this.Center.x + this.InitialOffset * Cos(theta) + (iLayer + 1) * this.DistanceBetween * Cos(theta)
                    set y = this.Center.y + this.InitialOffset * Sin(theta) + (iLayer + 1) * this.DistanceBetween * Sin(theta)
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x))
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "y: " + R2S(y))
                    
                    call SetUnitPosition(IndexedUnit(wUnitNode.value).Unit, x, y)
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
        
        public method SetAngleBounds takes real min, real max returns nothing
            set this.MinAngle = min
            set this.MaxAngle = max
            
            set this.CurrentAngle = min
        endmethod
        
        public static method create takes real x, real y returns thistype
            //calls super.create i think...
            local thistype new = thistype.allocate(x, y)
            
            return new
        endmethod
    endstruct
endlibrary