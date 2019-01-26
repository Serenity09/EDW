library Recycle requires UnitGlobals, DisposableUnit
    globals
        public constant integer MAX_SINGLE_INSTANCE_COUNT = 100
        public constant real SAFE_X = -15000
        public constant real SAFE_Y = 15000
		private constant real SAFE_TYPE_OFFSET = 64.
		
		public constant integer BUFFER_UNIT_COUNT = 5 //whenever an existing recycler calls make with 0 units on the stack, this is the number of units that will be simulataneously preloaded
		private constant boolean HIDE_RECYCLED_UNITS = true
	endglobals
    
    /*
	* The unit recycler is responsible for creating and temporarily removing units. The main purpose of the recycler is to minimize long-term overhead and computation swaps in a game that will create and remove many units, many times
	* The recycler expects the units size to remain constant, but allows for both player owner and movespeed to change
	* It may be worth making the recycler always assume a single player, which would work well with EDWs default Start/Stop Level logic
	* The recycler is compatible with temporary IStartable structures, via the DisposableUnit struct. This is useful for dynamic content
	*/
	
	public function MakeUnit takes integer uID, real x, real y returns unit
        return Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID)).Make(x, y)
    endfunction
    
    public function MakeUnitWithFacing takes integer uID, real x, real y, real angle returns unit
        return Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID)).MakeWithFacing(x, y, angle)
    endfunction
    
	//TODO remove, basically useless
    public function MakeUnitForPlayer takes integer uID, real x, real y, player p returns unit
        local Recycle_UnitRecycler r = Recycle_UnitRecycler(LoadInteger(Recycle_UnitRecycler.Recyclers, 0, uID))
        local unit u
        
        if r.defaultOwner == p then
            return r.Make(x, y)
        else
            set u = r.Make(x, y)
            call SetUnitOwner(u, p, true)
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
        local real moveAngleRad = angle / 180 * bj_PI
        
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
                
        public method Preload takes integer count returns nothing
            local unit u
            local integer i = 0
            
            loop
            exitwhen i >= count
				set u = CreateUnit(this.defaultOwner, this.uID, SAFE_X + this.count, SAFE_Y + this*SAFE_TYPE_OFFSET + this.count, this.facing)
                
                call UnitAddAbility(u, 'Aloc')
				static if HIDE_RECYCLED_UNITS then
					call ShowUnit(u, false)
				else
					call ShowUnit(u, false)
					call ShowUnit(u, true)
				endif
				
				set this.uStack[this.count] = u
				set this.count = this.count + 1
            set i = i + 1
            endloop
			
			set u = null
        endmethod
        
        public method destroy takes nothing returns nothing
            static if DEBUG_MODE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "WARNING! Destroying unit recyclers is unsupported!")
			endif
			
			//call this.deallocate()
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
		
		//ONLY WORKS FOR STATIC UNITS, IE PLACED AND THEN NEVER ORDERED
		public method MakeWithFacing takes real x, real y, real angle returns unit
			if this.count == 0 then
				call this.Preload(BUFFER_UNIT_COUNT)
			endif
			
			set this.count = this.count - 1 //pop the top unit off stack
			
			static if HIDE_RECYCLED_UNITS then
				call ShowUnit(this.uStack[this.count], true)
			endif
			call SetUnitPosition(this.uStack[this.count], x, y)
			call SetUnitFacing(this.uStack[this.count], angle)
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "recycling with n left:" + I2S(r.count))
			return this.uStack[this.count]
        endmethod
        public method Make takes real x, real y returns unit
            if this.count == 0 then //either no recycler for unit type or no units in stack
                call this.Preload(BUFFER_UNIT_COUNT)
			endif
			
			set this.count = this.count - 1 //pop the top unit off stack
			
			static if HIDE_RECYCLED_UNITS then
				call ShowUnit(this.uStack[this.count], true)
			endif
			call SetUnitPosition(this.uStack[this.count], x, y)
			
			return this.uStack[this.count]
        endmethod
		
        public method Release takes unit u returns nothing
			if GetUnitId(u) != 0 and DisposableUnit.IsUnitDisposable(u) then
				call DisposableUnit(GetUnitId(u)).dispose()
			endif
			
			if this == 0 or this.count == MAX_SINGLE_INSTANCE_COUNT then
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "no recycler exists for uid: " + I2S(GetUnitTypeId(u)) + " " + I2S(Levels_ticker))
                call RemoveUnit(u)
            else
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "releasing total stack size: " + I2S(r.count + 1) + " key: " + I2S(Levels_ticker))
                set this.uStack[this.count] = u
                
				//to trust that blizzard setters check for a different value before setting...
				if GetOwningPlayer(u) != this.defaultOwner then
					call SetUnitOwner(u, this.defaultOwner, true)
				endif
				if GetUnitMoveSpeed(u) != GetDefaultMoveSpeed(GetUnitTypeId(u)) then
					call SetUnitMoveSpeed(u, GetDefaultMoveSpeed(GetUnitTypeId(u)))
				endif
				//moving/hiding units via these functions results in buggy recycles
                //call SetUnitX(u, SAFE_X + r.count)
                //call SetUnitY(u, SAFE_Y + r.count)
				static if HIDE_RECYCLED_UNITS then
					call ShowUnit(u, false)
                endif
				
                //this function is safe for recycling
                call SetUnitPosition(this.uStack[this.count], SAFE_X + this.count, SAFE_Y + this*SAFE_TYPE_OFFSET + this.count)
                
                set this.count = this.count + 1
            endif
        endmethod
		
		private static method onInit takes nothing returns nothing
            call thistype.create(LGUARD, 0, Player(10)).Preload(25)
            call thistype.create(GUARD, 0, Player(10)).Preload(25)
            
            call thistype.create(ICETROLL, 0, Player(10)).Preload(25)
			
			call thistype.create(SPIRITWALKER, 0, Player(10)).Preload(10)
			call thistype.create(CLAWMAN, 0, Player(10)).Preload(10)
			
            call thistype.create(GRAVITY, 0, Player(10)).Preload(3)
			
			call thistype.create(BOUNCER, 0, Player(10)).Preload(10)
            call thistype.create(UBOUNCE, 90, Player(11)).Preload(5)
            call thistype.create(LBOUNCE, 180, Player(11)).Preload(5)
            call thistype.create(DBOUNCE, 270, Player(11)).Preload(5)
            call thistype.create(RBOUNCE, 0, Player(11)).Preload(5)
			
			call thistype.create(BLACKHOLE, 0, Player(10)).Preload(3)
			
			call thistype.create(RFIRE, 0, Player(11)).Preload(3)
			call thistype.create(BFIRE, 0, Player(11)).Preload(3)
            
            call thistype.create(WWWISP, 0, Player(11))//.Preload(10)
            
            debug call thistype.create(DEBUG_UNIT, 0, Player(11)).Preload(25)
        endmethod
    endstruct
endlibrary
