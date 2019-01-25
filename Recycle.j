library Recycle requires UnitGlobals
    globals
        public constant integer MAX_SINGLE_INSTANCE_COUNT = 100
        public constant real SAFE_X = -15000
        public constant real SAFE_Y = 15000
        public integer BufferUnitCount = 25
    endglobals
    
    
    
    public function MakeUnit takes integer uID, real x, real y returns unit
        return Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID)).Make(x, y)
    endfunction
    
    public function MakeUnitWithFacing takes integer uID, real x, real y, real angle returns unit
        return Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID)).MakeWithFacing(x, y, angle)
    endfunction
    
    public function MakeUnitForPlayer takes integer uID, real x, real y, player p returns unit
        local Recycle_UnitRecycler r = Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID))
        local unit u
        
        if r.defaultOwner == p then
            return r.Make(x, y)
        else
            set u = r.Make(SAFE_X, SAFE_Y)
            call SetUnitOwner(u, p, true)
            call SetUnitPosition(u, x, y)
            return u
        endif
    endfunction
    
    public function ReleaseUnit takes unit u returns nothing
        call Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, GetUnitTypeId(u))).Release(u)
    endfunction
    
    public function MakeUnitAndPatrol takes integer uID, real x1, real y1, real x2, real y2 returns nothing        
        call IssuePointOrder(MakeUnit(uID, x1, y1), "patrol", x2, y2)
    endfunction
    
    public function MakeUnitAndPatrolRect takes integer uID, rect r1, rect r2 returns nothing
        call IssuePointOrder(MakeUnit(uID, GetRectCenterX(r1), GetRectCenterY(r1)), "patrol", GetRectCenterX(r2), GetRectCenterY(r2))
    endfunction
    
    public function MakeUnitAndProjectRandom takes integer uID, rect create, real angle, real dist returns nothing
        local real x = GetRandomReal(GetRectMinX(create), GetRectMaxX(create))
        local real y = GetRandomReal(GetRectMinY(create), GetRectMaxY(create))
        //unit faces away from the direction it will travel
        local real moveAngleRad = (angle / 180) * bj_PI
        
        call IssuePointOrder(MakeUnitWithFacing(uID, x, y, angle + 180), "move", x + dist * Cos(moveAngleRad), y + dist * Sin(moveAngleRad))
    endfunction
    
    public struct UnitRecycler
        readonly integer uID
        readonly unit array uStack[MAX_SINGLE_INSTANCE_COUNT]
        readonly integer count
        public player defaultOwner
        public real facing
        readonly static hashtable Recyclers = InitHashtable()
        readonly static unit MostRecent //"static" may be removed with no issues -- unless later functionality uses UnitRecycler.MostRecent
                
        //overrides default facing of the unit
        
        public method MakeWithFacing takes real x, real y, real angle returns unit
            local unit u
            
            if this == 0 or this.count <= BufferUnitCount then //either no recycler for unit type or not very many units in stack
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "creating new")
                set u = CreateUnit(this.defaultOwner, uID, x, y, angle)
                
                call UnitAddAbility(u, 'Aloc')
                call ShowUnit(u, false)
                call ShowUnit(u, true)
                
                set this.MostRecent = u
                set u = null
                return this.MostRecent
            endif
            
            set this.count = this.count - 1 //pop the top unit off stack
            call SetUnitPosition(this.uStack[this.count], x, y)
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "recycling with n left:" + I2S(r.count))
            return this.uStack[this.count]
        endmethod
        
        public method Make takes real x, real y returns unit
            local unit u
            
            if this.count == 0 then //either no recycler for unit type or no units in stack
                set u = CreateUnit(this.defaultOwner, this.uID, x, y, this.facing)
                
                call UnitAddAbility(u, 'Aloc')
                call ShowUnit(u, false)
                call ShowUnit(u, true)
                
                set this.MostRecent = u
                set u = null
                return this.MostRecent
            endif
            
            set this.count = this.count - 1 //pop the top unit off stack
            call SetUnitPosition(this.uStack[this.count], x, y)
            return this.uStack[this.count]
        endmethod
        
        //returns last created unit
        public method Preload takes integer count, boolean exceedBuffer returns unit
            local unit u
            local integer i = 0
            
            loop
            exitwhen i >= count or (not exceedBuffer and this.count >= BufferUnitCount)
                set u = this.Make(SAFE_X + this.count, SAFE_Y + this.count)
                set this.uStack[this.count] = u
                set this.count = this.count + 1
                
            set i = i + 1
            endloop
                
            return u
        endmethod
        
        public method Release takes unit u returns nothing
            if this == 0 or this.count == MAX_SINGLE_INSTANCE_COUNT then
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "no recycler exists for uid: " + I2S(GetUnitTypeId(u)) + " " + I2S(Levels_ticker))
                call RemoveUnit(u)
                return
            else
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "releasing total stack size: " + I2S(r.count + 1) + " key: " + I2S(Levels_ticker))
                set this.uStack[this.count] = u
                //moving/hiding units via these functions results in buggy recycles
                //call SetUnitX(u, SAFE_X + r.count)
                //call SetUnitY(u, SAFE_Y + r.count)
                //call ShowUnit(u, false)
                
                //this function is safe for recycling
                call SetUnitPosition(this.uStack[this.count], SAFE_X + this.count, SAFE_Y + this.count)
                
                set this.count = this.count + 1
            endif
        endmethod
        
        private static method onInit takes nothing returns nothing
            call thistype.create(LGUARD, 0, Player(10)).Preload(25, true)
            call thistype.create(GUARD, 0, Player(10)).Preload(25, true)
            
            call thistype.create(ICETROLL, 0, Player(10)).Preload(1, true)

            call thistype.create(GRAVITY, 0, Player(10)).Preload(3, true)
			
			call thistype.create(BOUNCER, 0, Player(10)).Preload(10, true)
            call thistype.create(UBOUNCE, 90, Player(11)).Preload(5, true)
            call thistype.create(LBOUNCE, 180, Player(11)).Preload(5, true)
            call thistype.create(DBOUNCE, 270, Player(11)).Preload(5, true)
            call thistype.create(RBOUNCE, 0, Player(11)).Preload(5, true)
			
			call thistype.create(BLACKHOLE, 0, Player(11)).Preload(3, true)
			
			call thistype.create(RFIRE, 0, Player(11)).Preload(3, true)
			call thistype.create(BFIRE, 0, Player(11)).Preload(3, true)
            
            call thistype.create(WWWISP, 0, Player(11))//.Preload(10, true)
            
            debug call thistype.create(DEBUG_UNIT, 0, Player(11)).Preload(25, true)
        endmethod
        
        public method destroy takes nothing returns nothing
            //call this.deallocate() //recyclers should never be destroyed
        endmethod
        
        public static method create takes integer UID, real DefaultFacing, player Owner returns thistype
            local thistype new = thistype.allocate()
            
            set new.count = 0
            set new.uID = UID
            set new.facing = DefaultFacing
            set new.defaultOwner = Owner
            call SaveInteger(.Recyclers, 0, UID, new)
                        
            return new
        endmethod
    endstruct
endlibrary
