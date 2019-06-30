library FastLoad requires IStartable, SimpleList, RelayGenerator, SimpleGenerator, Levels, Teams
	globals
		private constant integer UNLOADED = 0
		private constant integer LOADING = 1
		private constant integer LOADED = 2
		
		private constant real OVERCLOCK_LOADED_EXTRA_WAIT = 1.
		
		private constant boolean DEBUG_OVERCLOCK_PROGRESS = false
	endglobals
	
	struct FastLoad extends IStartable
		private Checkpoint Checkpoint
		
		private timer OverclockTimer
		
		public real OverclockFactor
		public real FastLoadTime
		
		public integer LoadState
		
		private SimpleList_List AwaitingTeams
		
		private static SimpleList_List ActiveLoaders
				
		private method BroadcastOverclockFactor takes real overclockFactor returns nothing
			local SimpleList_ListNode curNode = this.ParentLevel.Startables.first
			
			static if DEBUG_OVERCLOCK_PROGRESS then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Broadcasting overclock " + R2S(overclockFactor) + " for level " + I2S(this.ParentLevel))
			endif
			
			loop
			exitwhen curNode == 0
				if IStartable(curNode.value).getType() == RelayGenerator.typeid then					
					call RelayGenerator(curNode.value).SetOverclockFactor(overclockFactor)
				elseif IStartable(curNode.value).getType() == SimpleGenerator.typeid then
					call SimpleGenerator(curNode.value).SetOverclockFactor(overclockFactor)
				endif
			set curNode = curNode.next
			endloop	
			
			static if DEBUG_OVERCLOCK_PROGRESS then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished broadcast")
			endif
		endmethod
		
		private static method OverclockLoadPlayerCB takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype fastLoad = GetTimerData(t)
			local SimpleList_ListNode curNode
			// local Checkpoint checkpoint
			
			loop
			set curNode = fastLoad.AwaitingTeams.pop()
			exitwhen curNode == 0
				// set checkpoint = fastLoad.ParentLevel.Checkpoints.get(Teams_MazingTeam(curNode.value).OnCheckpoint).value
				// if checkpoint == fastLoad.Checkpoint then
					// call Teams_MazingTeam(curNode.value).PauseTeam(false)
				// endif
				call Teams_MazingTeam(curNode.value).PauseTeam(false)
			endloop
			
			call ReleaseTimer(t)
			set fastLoad.OverclockTimer = null
			set t = null
		endmethod
		private static method OverclockLoadCB takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype fastLoad = GetTimerData(t)
			local SimpleList_ListNode curNode
			
			set fastLoad.LoadState = LOADED
			call fastLoad.BroadcastOverclockFactor(1.0)
			
			call TimerStart(t, OVERCLOCK_LOADED_EXTRA_WAIT, false, function thistype.OverclockLoadPlayerCB)
		endmethod
		
		private static method GetCheckpointFastLoad takes Levels_Level level, Checkpoint checkpoint returns thistype
			local SimpleList_ListNode curActiveLoaderNode = thistype.ActiveLoaders.first
			local thistype fastLoad = 0
			
			loop
			exitwhen curActiveLoaderNode == 0 or fastLoad != 0
				if thistype(curActiveLoaderNode.value).ParentLevel == level and thistype(curActiveLoaderNode.value).Checkpoint == checkpoint then
					set fastLoad = curActiveLoaderNode.value
				endif
			set curActiveLoaderNode = curActiveLoaderNode.next
			endloop
			
			return fastLoad
		endmethod
		private static method CheckpointChangeCB takes nothing returns nothing
			local thistype fastLoad = thistype.GetCheckpointFastLoad(EventCurrentLevel, EventCheckpoint)
			local SimpleList_ListNode curNode
						
			if fastLoad != 0 and fastLoad.LoadState != LOADED and (TimerGetRemaining(fastLoad.OverclockTimer) + OVERCLOCK_LOADED_EXTRA_WAIT) > RespawnPauseTime then
				call fastLoad.AwaitingTeams.addEnd(Levels_Level.CBTeam)
				
				call Levels_Level.CBTeam.CancelAutoUnpauseForTeam()
				call Levels_Level.CBTeam.PauseTeam(true)
			endif
		endmethod
		
		public method Start takes nothing returns nothing
			if not thistype.ActiveLoaders.contains(this) then
				if this.LoadState == UNLOADED then
					set this.LoadState = LOADING
					call this.BroadcastOverclockFactor(this.OverclockFactor)
					
					set this.OverclockTimer = NewTimerEx(this)
					call TimerStart(this.OverclockTimer, this.FastLoadTime, false, function thistype.OverclockLoadCB)
				endif
				
				call thistype.ActiveLoaders.add(this)
            endif
		endmethod
		public method Stop takes nothing returns nothing
			if thistype.ActiveLoaders.contains(this) then				
				set this.LoadState = UNLOADED
				
                call thistype.ActiveLoaders.remove(this)                
            endif
		endmethod
		
		//registers a fast load event
		public static method create takes Levels_Level parentLevel, Checkpoint checkpoint, real overclockFactor, real fastLoadTime returns thistype
			local thistype new = thistype.allocate()
			call parentLevel.AddStartable(new)
			//TODO check that no other fast loads already exist in this level. ONE PER LEVEL
			
			set new.Checkpoint = checkpoint
			set new.OverclockFactor = overclockFactor
			set new.FastLoadTime = fastLoadTime
			
			set new.LoadState = UNLOADED
			set new.AwaitingTeams = SimpleList_List.create()
			
			call parentLevel.AddCheckpointChangeCB(Condition(function thistype.CheckpointChangeCB))
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveLoaders = SimpleList_List.create()
		endmethod
	endstruct
endlibrary