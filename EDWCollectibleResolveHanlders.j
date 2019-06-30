library EDWCollectibleResolveHandlers
	public function AdvanceLevel takes integer result, CollectibleTeam activeTeam returns integer
		local Levels_Level nextLevel
		
		//call DisplayTextToPlayer(Player(0), 0, 0, "Default advance level resolved by active team " + I2S(activeTeam))
		
		if activeTeam.Team.OnLevel.NextLevel == 0 then
			set nextLevel = Levels_Level(DOORS_LEVEL_ID)
		else
			set nextLevel = activeTeam.Team.OnLevel.NextLevel
		endif
		
		call activeTeam.Team.OnLevel.SwitchLevels(activeTeam.Team, nextLevel, 0, true)
		
		return 0
	endfunction
	public function AdvanceCheckpoint takes integer result, CollectibleTeam activeTeam returns integer
		//call DisplayTextToPlayer(Player(0), 0, 0, "Default advance checkpoint resolved by active team " + I2S(activeTeam))
		
		if activeTeam.Team.OnCheckpoint >= activeTeam.Team.OnLevel.Checkpoints.count then
			call AdvanceLevel(result, activeTeam)
		else
			call activeTeam.Team.OnLevel.SetCheckpointForTeam(activeTeam.Team, activeTeam.Team.OnCheckpoint + 1)
		endif
		
		return 0
	endfunction
endlibrary