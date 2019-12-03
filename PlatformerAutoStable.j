library PlatformerAutoStable requires User, SimpleList, IStartable
	globals
		private constant real TIMEOUT = 1.
	endglobals
	struct PlatformerAutoStable extends IStartable
		public rect Area
		
		private static SimpleList_List Active
		private static timer Timer
		
		private static method Periodic takes nothing returns nothing
			local SimpleList_ListNode curActiveAutoAFK = thistype.Active.first
			
			local SimpleList_ListNode curTeamNode
			local SimpleList_ListNode curUserNode
			
			//TODO enum users.ActiveUnit on level rather than units in rect
			local User user
			
			loop
			exitwhen curActiveAutoAFK == 0
				set curTeamNode = thistype(curActiveAutoAFK.value).ParentLevel.ActiveTeams.first
				
				loop
				exitwhen curTeamNode == 0
					set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
					
					loop
					exitwhen curUserNode == 0
						set user = User(curUserNode.value)
						
						if user.GameMode == Teams_GAMEMODE_PLATFORMING and RectContainsCoords(thistype(curActiveAutoAFK.value).Area, GetUnitX(user.ActiveUnit), GetUnitY(user.ActiveUnit)) then
							set user.PlatformerStartStable = true
						endif
					set curUserNode = curUserNode.next
					endloop
					
				set curTeamNode = curTeamNode.next
				endloop
				
			set curActiveAutoAFK = curActiveAutoAFK.next
			endloop			
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