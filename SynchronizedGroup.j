library SynchronizedGroup requires Alloc, SimpleList, Vector2, Recycle
	globals
		private constant real TIMESTEP = .2
		private constant real DESTINATION_TOLERANCE = 32.		
	endglobals
	
	struct SynchronizedUnit extends array
		public unit Unit
		readonly integer UnitID
		public boolean Ready
				
		public SimpleList_ListNode CurrentOrder
		public SimpleList_List AllOrders
		public SynchronizedGroup ParentGroup
		
		implement Alloc
				
		public method Stop takes nothing returns nothing
			if .Unit != null then
				call Recycle_ReleaseUnit(.Unit)
				set .Unit = null
			endif
		endmethod
		public method Start takes nothing returns nothing
			if .AllOrders.first != 0 then
				set .CurrentOrder = .AllOrders.first
				
				set .Unit = Recycle_MakeUnit(.UnitID, vector2(.CurrentOrder.value).x, vector2(.CurrentOrder.value).y)
				set .Ready = false
				set .CurrentOrder = .CurrentOrder.next
				
				call IssuePointOrder(.Unit, "move", vector2(.CurrentOrder.value).x, vector2(.CurrentOrder.value).y)
			endif
		endmethod
		
		public static method create takes integer unitID, SynchronizedGroup parent returns thistype
			local thistype new = thistype.allocate()
			
			set new.UnitID = unitID
			set new.ParentGroup = parent
			
			set new.Ready = false
			set new.CurrentOrder = 0
			set new.AllOrders = SimpleList_List.create()
			
			
			return new
		endmethod
	endstruct
	
	struct SynchronizedGroup extends IStartable
		public SimpleList_List AllUnits
		
		private static SimpleList_List ActiveGroups
		private static timer t
		
		private static method Periodic takes nothing returns nothing
			local SimpleList_ListNode curGroup = thistype.ActiveGroups.first
			local SimpleList_ListNode curUnit
			local boolean allReady
			
			loop
			exitwhen curGroup == 0
				set curUnit = thistype(curGroup.value).AllUnits.first
				set allReady = true
				
				loop
				exitwhen curUnit == 0
					if not SynchronizedUnit(curUnit.value).Ready then
						if SynchronizedUnit(curUnit.value).CurrentOrder.value == 0 or ((RAbsBJ(vector2(SynchronizedUnit(curUnit.value).CurrentOrder.value).x - GetUnitX(SynchronizedUnit(curUnit.value).Unit)) < DESTINATION_TOLERANCE) and (RAbsBJ(vector2(SynchronizedUnit(curUnit.value).CurrentOrder.value).y - GetUnitY(SynchronizedUnit(curUnit.value).Unit)) < DESTINATION_TOLERANCE)) then
							set SynchronizedUnit(curUnit.value).Ready = true
						else
							set allReady = false
						endif
					endif
				set curUnit = curUnit.next
				endloop
				
				if allReady then
					set curUnit = thistype(curGroup.value).AllUnits.first
					loop
					exitwhen curUnit == 0
						if SynchronizedUnit(curUnit.value).CurrentOrder.next != 0 then
							set SynchronizedUnit(curUnit.value).CurrentOrder = SynchronizedUnit(curUnit.value).CurrentOrder.next
							set SynchronizedUnit(curUnit.value).Ready = false
							
							call IssuePointOrder(SynchronizedUnit(curUnit.value).Unit, "move", vector2(SynchronizedUnit(curUnit.value).CurrentOrder.value).x, vector2(SynchronizedUnit(curUnit.value).CurrentOrder.value).y)
						//else //just leave unit in ready state
						endif
					set curUnit = curUnit.next
					endloop
				endif
			set curGroup = curGroup.next
			endloop
		endmethod
		
		public method Stop takes nothing returns nothing
			local SimpleList_ListNode curUnit = .AllUnits.first
			
			//timer is only active when there are any active groups
			call thistype.ActiveGroups.remove(this)
			if thistype.ActiveGroups.count == 0 then
				call PauseTimer(thistype.t)
			endif
			
			//units in group are also unloaded when paused
			loop
			exitwhen curUnit == 0
				call SynchronizedUnit(curUnit.value).Stop()
			set curUnit = curUnit.next
			endloop
		endmethod
		public method Start takes nothing returns nothing
			local SimpleList_ListNode curUnit = .AllUnits.first
			
			//timer is only active when there are any active groups
			if thistype.ActiveGroups.count == 0 then
				call TimerStart(thistype.t, TIMESTEP, true, function thistype.Periodic)
			endif
			call thistype.ActiveGroups.add(this)
			
			//units in group are also unloaded when paused
			loop
			exitwhen curUnit == 0
				call SynchronizedUnit(curUnit.value).Start()
			set curUnit = curUnit.next
			endloop
		endmethod
		
		public method AddUnit takes integer unitID returns SynchronizedUnit
			local SynchronizedUnit su = SynchronizedUnit.create(unitID, this)
			
			call this.AllUnits.add(su)
			
			return su
		endmethod
		
		public static method create takes nothing returns thistype
			local thistype new = thistype.allocate()
			
			set new.AllUnits = SimpleList_List.create()
			
			return new
		endmethod
		
		public static method onInit takes nothing returns nothing
			set thistype.ActiveGroups = SimpleList_List.create()
			set thistype.t = CreateTimer()
		endmethod
	endstruct
endlibrary