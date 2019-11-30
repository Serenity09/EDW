library Minigame requires SimpleList, Levels, TeamSaveLocation
	globals
		private constant string MINIGAME_SAVE_NAME = "MINI"
	endglobals
	
	struct Minigame extends array
		readonly static leaderboard Scores
		readonly string Name
		
		public method TransferAllTeams takes nothing returns nothing
			local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
			local TeamSaveLocation save
			
			loop
			exitwhen curTeamNode == 0
				set save = TeamSaveLocation.GetFirstSaveForTeam(MINIGAME_SAVE_NAME, curTeamNode.value)
				if save != 0 then
					call save.destroy()
				endif
				
				//save original location
				call TeamSaveLocation.create(MINIGAME_SAVE_NAME, curTeamNode.value)
				
				//switch to minigame
				call Teams_MazingTeam(curTeamNode.value).OnLevel.SwitchLevels(this, curTeamNode.value, 0, false)
			set curTeamNode = curTeamNode.next
			endloop
			
			//hide multiboard
			call MultiboardDisplay(Teams_MazingTeam.PlayerStats, false)
			//show leaderboard with level name as title
			call LeaderboardSetLabel(thistype.Scores, this.Name)
			call LeaderboardDisplay(thistype.Scores, true)
		endmethod
		public method ResetAllTeams takes nothing returns nothing
			local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
			local TeamSaveLocation save
			
			loop
			exitwhen curTeamNode == 0
				set save = TeamSaveLocation.GetFirstSaveForTeam(MINIGAME_SAVE_NAME, curTeamNode.value)
				if save != 0 then
					call save.Restore()
					
					call save.destroy()
				endif				
			set curTeamNode = curTeamNode.next
			endloop
			
			//show multiboard
			call MultiboardDisplay(Teams_MazingTeam.PlayerStats, true)
			//hide leaderboard
			call LeaderboardDisplay(thistype.Scores, false)
		endmethod
		
		public static method create takes integer levelID, string name, string startFunction, string stopFunction, rect revive, rect vision returns thistype
			//default parameters in order: rawContinues, rawScore, levelEnd, previousLevel
			local thistype new = Levels_Level.create(levelID, 0, 0, startFunction, stopFunction, revive, vision, null, 0)
			
			set new.Name = name
			
			return new
		endmethod
		
		public static method onInit takes nothing returns nothing
			set thistype.Scores = CreateLeaderboard()
		endmethod
	endstruct
endlibrary