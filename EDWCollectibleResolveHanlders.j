library EDWCollectibleResolveHandlers requires TimerUtils, User
	globals
		private constant real ADVANCE_LEVEL_PAN_CAMERA_DURATION = 1.
		private constant real ADVANCE_LEVEL_FROGGER_SFX_DURATION = 2.5
	endglobals
	
	private function AdvanceLevelSwitchLevel takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local Teams_MazingTeam team = User(GetTimerData(t)).Team
		local Levels_Level nextLevel
		
		//call DisplayTextToPlayer(Player(0), 0, 0, "Default advance level resolved by active team " + I2S(team))
		
		if team.OnLevel.NextLevel == 0 then
			set nextLevel = Levels_Level(DOORS_LEVEL_ID)
		else
			set nextLevel = team.OnLevel.NextLevel
		endif
		
		call team.OnLevel.SwitchLevelsAnimated(team, nextLevel, true)
		
		call ReleaseTimer(t)
		set t = null
	endfunction
	
	private function AdvanceLevelPlaySFX takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local User user = GetTimerData(t)
			
		//play frogger sfx
		call AttachSoundToUnit(gg_snd_FroggerPS1Victory_EDW, user.ActiveUnit)
		//call StartSound(gg_snd_FroggerPS1Victory_EDW)
		call user.Team.PlaySoundForTeam(gg_snd_FroggerPS1Victory_EDW)
		
		if user.Team.Users.count > 1 then
			set user.Team.LastEventUser = -1
			
			// call user.Team.PrintMessage("Your team has cleared the level!")
			call user.Team.LocalizeMessage('ECGG')
		else
			set user.Team.LastEventUser = user
		endif
		
		call TimerStart(t, ADVANCE_LEVEL_FROGGER_SFX_DURATION, false, function AdvanceLevelSwitchLevel)
		set t = null
	endfunction
	
	public function AdvanceLevel takes User user, CollectibleTeam activeTeam returns integer		
		//pause team
		call activeTeam.Team.PauseTeam(true)
		
		//pan team's cameras to last collected
		call activeTeam.Team.PanCameraForTeam(GetUnitX(user.ActiveUnit), GetUnitY(user.ActiveUnit), ADVANCE_LEVEL_PAN_CAMERA_DURATION)
		
		call TimerStart(NewTimerEx(user), ADVANCE_LEVEL_PAN_CAMERA_DURATION, false, function AdvanceLevelPlaySFX)
		
		return 0
	endfunction
	public function AdvanceCheckpoint takes integer result, CollectibleTeam activeTeam returns integer
		//call DisplayTextToPlayer(Player(0), 0, 0, "Default advance checkpoint resolved by active team " + I2S(activeTeam))
		
		if activeTeam.Team.OnCheckpoint >= activeTeam.Team.OnLevel.Checkpoints.count then
			call AdvanceLevel(result, activeTeam)
		else
			call activeTeam.Team.OnLevel.AnimatedSetCheckpointForTeam(activeTeam.Team, activeTeam.Team.OnCheckpoint + 1)
		endif
		
		return 0
	endfunction
endlibrary