library PlatformerAutoAFK requires User, SimpleList, IStartable
	globals
		private constant real TIMEOUT = 1.
	endglobals
	struct PlatformerAutoAFK extends IStartable
		public rect Area
		
		private static SimpleList_List Active
		private static timer Timer
		
		private static method Periodic takes nothing returns nothing
			local SimpleList_ListNode curActiveAutoAFK = thistype.Active.first
			
			local group inAreaGroup = NewGroup()
			local unit inAreaUnit
			local User inAreaUser
			
			loop
			exitwhen curActiveAutoAFK == 0
				call GroupEnumUnitsInRect(inAreaGroup, thistype(curActiveAutoAFK.value).Area, null)
				
				loop
				set inAreaUnit = FirstOfGroup(inAreaGroup)
				exitwhen inAreaUnit == null
					if GetUnitTypeId(inAreaUnit) == PLATFORMERWISP then
						set inAreaUser = GetPlayerId(GetOwningPlayer(inAreaUnit))
						
						if inAreaUser.IsAFK and inAreaUser.Team.Users.count > 1 then
							call inAreaUser.SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
						endif
					endif
					
				call GroupRemoveUnit(inAreaGroup, inAreaUnit)
				endloop
			set curActiveAutoAFK = curActiveAutoAFK.next
			endloop
			
			call ReleaseGroup(inAreaGroup)
			set inAreaGroup = null
		endmethod
		
		public method Start takes nothing returns nothing
			if thistype.Active.count == 0 then
				set thistype.Timer = NewTimer()
				call TimerStart(thistype.Timer, TIMEOUT, true, function thistype.Periodic)
			endif
			
			call thistype.Active.addEnd(this)
		endmethod
		public method Stop takes nothing returns nothing
			call thistype.Active.remove(this)
			
			if thistype.Active.count == 0 then
				call ReleaseTimer(thistype.Timer)
			endif
		endmethod
		
		public static method create takes rect area returns thistype
			local thistype new = thistype.allocate()
			
			set new.Area = area
			
			return new
		endmethod
		private static method onInit takes nothing returns nothing
			set thistype.Active = SimpleList_List.create()
		endmethod
	endstruct
endlibrary