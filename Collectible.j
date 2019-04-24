library Collectible requires Alloc, PermanentAlloc, SimpleList, Teams, IStartable, Levels, Deferred, All, TimerUtils, locust, SetUnitLocallyVisible, GetUnitDefaultRadius
	globals
		private constant real COLLECTIBLE_COLLISION_TIMEOUT = .15
		private constant player COLLECTIBLE_PLAYER = Player(9)
	endglobals
	
	//has two units in the same location
	//has functionality for displaying one unit while hiding the other PER TEAM
	//needs to use a unit so i can easily change visibility locally
	struct Collectible extends array
		readonly unit UncollectedUnit
		public real UncollectedUnitRadius
		readonly unit CollectedUnit
		public boolean ReturnToCheckpoint
		
		implement PermanentAlloc
		
		public static method create takes integer uncollectedUnitID, integer collectedUnitID, real x, real y, real facing returns thistype
			local thistype new = thistype.allocate()
						
			set new.UncollectedUnit = CreateUnit(COLLECTIBLE_PLAYER, uncollectedUnitID, x, y, facing)
			call AddUnitLocust(new.UncollectedUnit)
			set new.UncollectedUnitRadius = GetUnitDefaultRadius(uncollectedUnitID)
			
			if collectedUnitID != 0 then
				set new.CollectedUnit = CreateUnit(COLLECTIBLE_PLAYER, collectedUnitID, x, y, facing)
				call AddUnitLocust(new.CollectedUnit)
			else
				set new.CollectedUnit = null
			endif
			//hide the collected version of the unit on init or on level start
			
			//defaults
			set new.ReturnToCheckpoint = false
						
			return new
		endmethod
	endstruct
	
	//consists of:
	//either a doodad or a unit that can be shown to some players but not others. this object will be visually shown based on its properties, the user, and their team's having collected it
	//IStartable Start/Stop
	//a periodic check of the region around that unit for active player units
	//a callback for the first time a team activates a collectibe
	//a callback for when a team activates all collectibles on a level
	struct CollectibleTeam extends array
		public Teams_MazingTeam Team
		
		public SimpleList_List CollectibleDeferreds
		public All AllCollected
		
		implement Alloc
		
		// private static method OnAllCollected takes integer result, integer callbackData returns integer
			// call DisplayTextToPlayer(Player(0), 0, 0, "All collectibles found! Active Team ID: " + I2S(callbackData))
			
			// return 0
		// endmethod
				
		public static method create takes CollectibleSet parent, Teams_MazingTeam mt returns thistype
			local thistype new = thistype.allocate()
			local SimpleList_ListNode curCollectibleNode = parent.Collectibles.first
						
			set new.Team = mt
			
			//create one deferred per collectible, match order so that it can be used as the ID
			set new.CollectibleDeferreds = SimpleList_List.create()
			loop
			exitwhen curCollectibleNode == 0
				//show uncollected unit for local team only
				call mt.TeamSetUnitLocallyVisible(Collectible(curCollectibleNode.value).UncollectedUnit, true)
				
				//if exists, hide collected unit for local team only
				if Collectible(curCollectibleNode.value).CollectedUnit != null then
					call mt.TeamSetUnitLocallyVisible(Collectible(curCollectibleNode.value).CollectedUnit, false)
				endif
				
				//create a deferred to track collection state
				call new.CollectibleDeferreds.addEnd(Deferred.create())
			set curCollectibleNode = curCollectibleNode.next
			endloop
			
			set new.AllCollected = All.create(new.CollectibleDeferreds)
			//call new.AllCollected.Then(thistype.OnAllCollected, 0, new)
			call new.AllCollected.Then(parent.OnAllCollected, 0, new)
						
			return new
		endmethod
		public method destroy takes nothing returns nothing
			local SimpleList_ListNode curDeferredNode
			
			call this.AllCollected.destroy()
			
			loop
			set curDeferredNode = this.CollectibleDeferreds.pop()
			exitwhen curDeferredNode == 0
				call Deferred(curDeferredNode.value).destroy()
			endloop
			
			call this.CollectibleDeferreds.destroy()
			
			call this.deallocate()
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deallocated active team - " + I2S(this))
		endmethod
	endstruct
	
	struct CollectibleSet extends IStartable
		readonly static SimpleList_List ActiveCollectibles
		private static timer Timer
		
		readonly SimpleList_List Collectibles
		private SimpleList_List ActiveTeams
		
		public DeferredCallback OnAllCollected
		
		public method AddCollectible takes Collectible collectible returns nothing
			call this.Collectibles.addEnd(collectible)
		endmethod
		
		private static method InitializeTeam takes nothing returns nothing
			local SimpleList_ListNode curStartableNode = EventCurrentLevel.Content.Startables.first
			
			loop
			exitwhen curStartableNode == 0
				if IStartable(curStartableNode.value).getType() == CollectibleSet.typeid then										
					call CollectibleSet(curStartableNode.value).ActiveTeams.addEnd(CollectibleTeam.create(CollectibleSet(curStartableNode.value), Levels_Level.CBTeam))
				endif
			set curStartableNode = curStartableNode.next
			endloop
		endmethod
		private static method DeinitializeTeam takes nothing returns nothing
			local SimpleList_ListNode curStartableNode = EventPreviousLevel.Content.Startables.first
			local SimpleList_ListNode curActiveTeamNode
			local CollectibleTeam removedTeam
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deinitializing start for level: " + I2S(EventPreviousLevel))
			
			loop
			exitwhen curStartableNode == 0
				if IStartable(curStartableNode.value).getType() == CollectibleSet.typeid then										
					set curActiveTeamNode = CollectibleSet(curStartableNode.value).ActiveTeams.first
					
					//call DisplayTextToPlayer(Player(0), 0, 0, "Deinitializing active team: " + I2S(curActiveTeamNode.value))
					
					loop
					exitwhen curActiveTeamNode == 0
						if CollectibleTeam(curActiveTeamNode.value).Team == Levels_Level.CBTeam then
							call CollectibleTeam(curActiveTeamNode.value).destroy()
							call CollectibleSet(curStartableNode.value).ActiveTeams.removeNode(curActiveTeamNode)
						endif
					set curActiveTeamNode = curActiveTeamNode.next
					endloop
				endif
			set curStartableNode = curStartableNode.next
			endloop
		endmethod
		
		private static method CheckActiveCollectibles takes nothing returns nothing
			local SimpleList_ListNode curCollectibleSetNode = thistype.ActiveCollectibles.first
			local SimpleList_ListNode curTeamNode
			local SimpleList_ListNode curPlayerNode
			local SimpleList_ListNode curCollectibleNode
			local integer curCollectibleIndex
			local Deferred curCollectibleDeferred
			
			local real deltaX
			local real deltaY
			//local real distance
			
			loop
			exitwhen curCollectibleSetNode == 0
				set curTeamNode = CollectibleSet(curCollectibleSetNode.value).ActiveTeams.first
				
				loop
				exitwhen curTeamNode == 0
					set curPlayerNode = CollectibleTeam(curTeamNode.value).Team.FirstUser
					
					loop
					exitwhen curPlayerNode == 0
						set curCollectibleNode = CollectibleSet(curCollectibleSetNode.value).Collectibles.first
						set curCollectibleIndex = 0
						
						loop
						exitwhen curCollectibleNode == 0
							set curCollectibleDeferred = Deferred(CollectibleTeam(curTeamNode.value).CollectibleDeferreds.get(curCollectibleIndex).value)
							
							if not curCollectibleDeferred.Resolved then
								set deltaX = GetUnitX(User(curPlayerNode.value).ActiveUnit) - GetUnitX(Collectible(curCollectibleNode.value).UncollectedUnit)
								set deltaY = GetUnitY(User(curPlayerNode.value).ActiveUnit) - GetUnitY(Collectible(curCollectibleNode.value).UncollectedUnit)
								//set distance = SquareRoot(deltaX*deltaX + deltaY*deltaY)
								
								if SquareRoot(deltaX*deltaX + deltaY*deltaY) <= Collectible(curCollectibleNode.value).UncollectedUnitRadius + User(curPlayerNode.value).ActiveUnitRadius then
									call CollectibleTeam(curTeamNode.value).Team.TeamSetUnitLocallyVisible(Collectible(curCollectibleNode.value).UncollectedUnit, false)
									
									if Collectible(curCollectibleNode.value).CollectedUnit != null then
										call CollectibleTeam(curTeamNode.value).Team.TeamSetUnitLocallyVisible(Collectible(curCollectibleNode.value).CollectedUnit, true)
									endif
									
									call curCollectibleDeferred.Resolve(curPlayerNode.value)
								endif
							elseif Collectible(curCollectibleNode.value).ReturnToCheckpoint then
								call User(curPlayerNode.value).RespawnAtRect(CollectibleTeam(curTeamNode.value).Team.Revive, true)
							endif
						
						set curCollectibleNode = curCollectibleNode.next
						set curCollectibleIndex = curCollectibleIndex + 1
						endloop
					set curPlayerNode = curPlayerNode.next
					endloop
				set curTeamNode = curTeamNode.next
				endloop
			set curCollectibleSetNode = curCollectibleSetNode.next
			endloop
		endmethod
		
		//called when either the first team starts a level or the last team stops a level
		public method Start takes nothing returns nothing
			if thistype.ActiveCollectibles.count == 0 then
				set thistype.Timer = NewTimer()
				call TimerStart(thistype.Timer, COLLECTIBLE_COLLISION_TIMEOUT, true, function thistype.CheckActiveCollectibles)
			endif
			
			call thistype.ActiveCollectibles.addEnd(this)
		endmethod
		public method Stop takes nothing returns nothing
			call thistype.ActiveCollectibles.remove(this)
			
			if thistype.ActiveCollectibles.count == 0 then
				call ReleaseTimer(thistype.Timer)
				set thistype.Timer = null
			endif
		endmethod
		
		public static method create takes Levels_Level parentLevel, DeferredCallback onAllCollected returns thistype
			local integer tcsCountOnLevel = 0
			local SimpleList_ListNode curStartableNode = parentLevel.Content.Startables.first
			local thistype new = thistype.allocate()
			
			set new.OnAllCollected = onAllCollected
			
			set new.ActiveTeams = SimpleList_List.create()
			set new.Collectibles = SimpleList_List.create()
			
			loop
			exitwhen curStartableNode == 0 or tcsCountOnLevel != 0
				if IStartable(curStartableNode.value).getType() == CollectibleSet.typeid then
					set tcsCountOnLevel = tcsCountOnLevel + 1
				endif
			set curStartableNode = curStartableNode + 1
			endloop
			
			if tcsCountOnLevel == 0 then
				call parentLevel.AddLevelStartCB(Condition(function thistype.InitializeTeam))
				call parentLevel.AddLevelStopCB(Condition(function thistype.DeinitializeTeam))
			endif
			
			call parentLevel.AddStartable(new)
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveCollectibles = SimpleList_List.create()
		endmethod
	endstruct
endlibrary