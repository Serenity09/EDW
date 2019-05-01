library FastLoad requires IStartable, SimpleList, RelayGenerator, SimpleGenerator, Levels, Teams
	globals
		private constant integer UNLOADED = 0
		private constant integer LOADING = 1
		private constant integer LOADED = 2
	endglobals
	
	struct FastLoad extends IStartable
		
		private Checkpoint Checkpoint
		
		public real OverclockFactor
		public real FastLoadTime
		
		public integer LoadState
		
		private SimpleList_List RelayGenerators
		private SimpleList_List SimpleGenerators
		
		private static SimpleList_List ActiveLoaders
		
		public method AddRelayGenerator takes RelayGenerator generator returns nothing
			if this.RelayGenerators == 0 then
				set this.RelayGenerators = SimpleList_List.create()
			endif
			
			call this.RelayGenerators.addEnd(generator)
		endmethod
		public method AddSimpleGenerator takes SimpleGenerator generator returns nothing
			if this.SimpleGenerators == 0 then
				set this.SimpleGenerators = SimpleList_List.create()
			endif
			
			call this.SimpleGenerators.addEnd(generator)
		endmethod
		
		private method SetOverclockFactor takes real overclockFactor returns nothing
			local SimpleList_ListNode curNode
			
			if this.RelayGenerators != 0 then
				set curNode = this.RelayGenerators.first
				loop
				exitwhen curNode == 0
					call RelayGenerator(curNode.value).SetOverclockFactor(overclockFactor)
				set curNode = curNode.next
				endloop
			endif
			if this.SimpleGenerators != 0 then
				set curNode = this.SimpleGenerators.first
				loop
				exitwhen curNode == 0
					//TODO
					//call SimpleGenerators(curNode.value).SetOverclockFactor(overclockFactor)
				set curNode = curNode.next
				endloop
			endif
		endmethod
		private static method OverclockLoadCB takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype fastLoad = GetTimerData(t)
			local SimpleList_ListNode curNode
			local Checkpoint checkpoint
			
			set fastLoad.LoadState = LOADED
			
			call fastLoad.SetOverclockFactor(1.0)
			
			set curNode = fastLoad.ParentLevel.ActiveTeams.first
			loop
			exitwhen curNode == 0
				set checkpoint = fastLoad.ParentLevel.Checkpoints.get(Teams_MazingTeam(curNode.value).OnCheckpoint).value
				if checkpoint == fastLoad.Checkpoint then
					call Teams_MazingTeam(curNode.value).PauseTeam(false)
				endif
			set curNode = curNode.next
			endloop
			
			call ReleaseTimer(t)
			set t = null
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
						
			if fastLoad != 0 and fastLoad.LoadState != LOADED then
				call Levels_Level.CBTeam.CancelAutoUnpauseForTeam()
				call Levels_Level.CBTeam.PauseTeam(true)
			endif
		endmethod
		
		public method Start takes nothing returns nothing
			if not thistype.ActiveLoaders.contains(this) then
				if this.LoadState == UNLOADED then
					set this.LoadState = LOADING
					
					call this.SetOverclockFactor(this.OverclockFactor)
					
					if (this.RelayGenerators != 0 and this.RelayGenerators.count > 0) or (this.SimpleGenerators != 0 and this.SimpleGenerators.count > 0) then
						call TimerStart(NewTimerEx(this), this.FastLoadTime, false, function thistype.OverclockLoadCB)
					endif
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
			
			call parentLevel.AddCheckpointChangeCB(Condition(function thistype.CheckpointChangeCB))
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveLoaders = SimpleList_List.create()
		endmethod
	endstruct
endlibrary