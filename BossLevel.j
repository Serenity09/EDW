library BossLevel requires Levels
globals
	private constant real BOSS_BEHAVIOR_TIMEOUT = .5
endglobals

	function interface BossBehavior takes BossLevel bossLevel returns nothing
	
	struct Boss extends array
		public integer UnitID
		public unit Unit
		public BossBehavior Behavior
		
		//use unit object for all possible properties
		
		implement Alloc
		
		public method destroy takes nothing returns nothing
			call RemoveUnit(.Unit)
			set .Unit = null
			
			set .Behavior = 0
			
			call .deallocate()
		endmethod
	endstruct
		
	struct BossLevel extends array
		//public SimpleList_List TeamQueue
		public Boss Boss
		public integer OnCheckpoint
		public SimpleList_List CurrentTargets
		
		public integer CurrentState	//0, wandering; 1, charging an ability; 2 channeling an ability
		
		private static timer BehaviorTimer = CreateTimer()
		private static SimpleList_List ActiveBosses
		
		private method ResetTargets takes nothing returns nothing
			local SimpleList_ListNode curTeam = Levels_Level(this).ActiveTeams.first
			local SimpleList_ListNode curUser
			
			loop
			exitwhen curTeam == 0
				if Teams_MazingTeam(curTeam.value).OnCheckpoint == .OnCheckpoint then
					set curUser = Teams_MazingTeam(curTeam.value).FirstUser
				
					loop
					exitwhen curUser == 0
						call .CurrentTargets.addEnd(curUser.value)
					set curUser = curUser.next
					endloop
				endif
			set curTeam = curTeam.next
			endloop
		endmethod
		private method ResetBoss takes nothing returns nothing
			
		endmethod
				
		//give a user who just died a temporary reprieve
		private method OnPlayerDeath takes nothing returns nothing
			//.remove only does anything to the first match
			//if .CurrentTargets.contains(TriggerUser) then
				call .CurrentTargets.remove(TriggerUser)
			//endif
		endmethod
		private method OnLevelChange takes nothing returns nothing
			/*
			if TriggerCurrentLevel == this then
				if Levels_Level(this).ActiveTeams.count == 1 then
					
				endif
			elseif TriggerPreviousLevel == this then
				call .Boss.destroy()
			endif
			*/
		endmethod
		private method OnCheckpointChange takes nothing returns nothing
			
		endmethod
		
		private static method RunBossBehavior takes nothing returns nothing
			local SimpleList_ListNode curBossLevel = thistype.ActiveBosses.first
			local BossLevel bossLevel
			
			loop
			exitwhen curBossLevel == 0
				set bossLevel = BossLevel(curBossLevel.value)
				
				
			set curBossLevel = curBossLevel.next
			endloop
		endmethod
				
		private method Start takes nothing returns nothing
			if not .ActiveBosses.contains(this) then
				call .ActiveBosses.addEnd(this)
				
				if .ActiveBosses.count == 1 then
					call TimerStart(BehaviorTimer, BOSS_BEHAVIOR_TIMEOUT, true, function thistype.RunBossBehavior)
				endif
			endif
		endmethod
		private method Stop takes nothing returns nothing
			
		endmethod
		
		public static method create takes integer bossLevelID, string bossName, integer rawContinues, integer rawScore, string startFunction, string stopFunction, rect startspawn, rect vision, Levels_Level previousLevel returns BossLevel
			local thistype new = Levels_Level.create(bossLevelID, bossName, rawContinues, rawScore, startFunction, stopFunction, startspawn, vision, null, previousLevel)
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			//listen to LevelChange, CheckpointChange, and PlayerDeath events
		endmethod
	endstruct

endlibrary