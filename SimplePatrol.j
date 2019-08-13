library SimplePatrol requires Vector2, IStartable, Recycle
	globals
		private real DESTINATION_FLEX = 16.
		private real DESTINATION_TIME_DELTA = .035
	endglobals
	
	struct SimplePatrol extends IStartable
		readonly unit Unit
		public integer UnitID
		private real MoveSpeed
		
		private vector2 OnDestination
		private real MoveAngle
		public vector2 DestinationA
		public vector2 DestinationB
		
		private static timer DestinationTimer
		private static SimpleList_List ActivePatrols
		
		private static method CheckDestinations takes nothing returns nothing
			local SimpleList_ListNode curActivePatrol = thistype.ActivePatrols.first
			// local vector2 nextDestination
			
			loop
			exitwhen curActivePatrol == 0
				//check if arrived at current destination
				if RAbsBJ(GetUnitX(thistype(curActivePatrol.value).Unit) - thistype(curActivePatrol.value).OnDestination.x) <= DESTINATION_FLEX and RAbsBJ(GetUnitY(thistype(curActivePatrol.value).Unit) - thistype(curActivePatrol.value).OnDestination.y) <= DESTINATION_FLEX then
					//update current destination to other destination
					if thistype(curActivePatrol.value).OnDestination == thistype(curActivePatrol.value).DestinationA then
						set thistype(curActivePatrol.value).OnDestination = thistype(curActivePatrol.value).DestinationB
						// set nextDestination = thistype(curActivePatrol.value).DestinationB
					else
						set thistype(curActivePatrol.value).OnDestination = thistype(curActivePatrol.value).DestinationA
						// set nextDestination = thistype(curActivePatrol.value).DestinationA
					endif
					
					//update internal and display move angle
					set thistype(curActivePatrol.value).MoveAngle = Atan2(thistype(curActivePatrol.value).OnDestination.y - GetUnitY(thistype(curActivePatrol.value).Unit), thistype(curActivePatrol.value).OnDestination.x - GetUnitX(thistype(curActivePatrol.value).Unit))
					// call SetUnitFacing(thistype(curActivePatrol.value).Unit, thistype(curActivePatrol.value).MoveAngle * bj_RADTODEG)
					
					// set thistype(curActivePatrol.value).OnDestination = nextDestination
				endif
				
				//move towards current destination
				call SetUnitX(thistype(curActivePatrol.value).Unit, GetUnitX(thistype(curActivePatrol.value).Unit) + Cos(thistype(curActivePatrol.value).MoveAngle) * IndexedUnit[thistype(curActivePatrol.value).Unit].MoveSpeed)
				call SetUnitY(thistype(curActivePatrol.value).Unit, GetUnitY(thistype(curActivePatrol.value).Unit) + Sin(thistype(curActivePatrol.value).MoveAngle) * IndexedUnit[thistype(curActivePatrol.value).Unit].MoveSpeed)
			set curActivePatrol = curActivePatrol.next
			endloop
		endmethod
		
		public method Start takes nothing returns nothing
			if thistype.ActivePatrols.count == 0 then
				call TimerStart(thistype.DestinationTimer, DESTINATION_TIME_DELTA, true, function thistype.CheckDestinations)
			endif
			
			set this.Unit = Recycle_MakeUnit(this.UnitID, this.DestinationA.x, this.DestinationA.y)
			if this.MoveSpeed != -1 then
				call IndexedUnit[this.Unit].SetMoveSpeed(this.MoveSpeed)
			endif
			
			set this.OnDestination = this.DestinationB
			set this.MoveAngle = Atan2(this.OnDestination.y - GetUnitY(this.Unit), this.OnDestination.x - GetUnitX(this.Unit))
			// call SetUnitFacing(this.Unit, this.MoveAngle * bj_RADTODEG)
			
			call thistype.ActivePatrols.add(this)
		endmethod
		public method Stop  takes nothing returns nothing
			call Recycle_ReleaseUnit(this.Unit)
			set this.Unit = null
			
			call thistype.ActivePatrols.remove(this)
			
			if thistype.ActivePatrols.count == 0 then
				call PauseTimer(thistype.DestinationTimer)
			endif
		endmethod
		
		public method SetMoveSpeed takes real moveSpeed returns nothing
			set this.MoveSpeed = moveSpeed * DESTINATION_TIME_DELTA
			
			if this.Unit != null then
				call IndexedUnit[this.Unit].SetMoveSpeed(moveSpeed)
			endif
		endmethod
		public static method create takes integer unitID, real x1, real y1, real x2, real y2 returns thistype
			local thistype new = thistype.allocate()
			
			set new.UnitID = unitID
			set new.DestinationA = vector2.create(x1, y1)
			set new.DestinationB = vector2.create(x2, y2)
			set new.MoveSpeed = GetDefaultMoveSpeed(unitID) * DESTINATION_TIME_DELTA
			
			return new
		endmethod
		private static method onInit takes nothing returns nothing
			set thistype.DestinationTimer = CreateTimer()
			set thistype.ActivePatrols = SimpleList_List.create()
		endmethod
	endstruct
endlibrary