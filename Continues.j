library Continues initializer Init requires Levels, Teams, GameModesGlobals, MazerGlobals

public function onPlayerUnitDiedCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    local User user = User(pID)
	
    local Teams_MazingTeam mt = user.Team
    local Levels_Level level = mt.OnLevel
	
	//check that the user is still dying -- they might have been revived in the mean-time
	if user.IsAlive then
		//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "pID " + I2S(pID) + " died on level " + level.Name + ", on team: " + I2S(mt))
		//specifically refers to the PlayerUnitDied CB having executed
		set user.IsAlive = false
		
		//switch from any game mode to dead
		//unit should be dead at this point
		call user.SwitchGameModesDefaultLocation(Teams_GAMEMODE_DEAD)
		
		//can't lose continues in starting worlds
		if (level == INTRO_LEVEL_ID or level == DOORS_LEVEL_ID) then
			//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "no continues lost")
			//respawn players immediately if on intro or doors levels, regardless of other settings
			
			call user.RespawnAtRect(mt.Revive, false)
			
			//lets not keep track of deaths till everyone has a chance to learn from the first few levels
			return
		endif
		
		set user.Deaths = user.Deaths + 1
			
		//check if the team has any more continues AND needs to use one
		
		//should death cause a continue to be used
		if RespawnASAPMode or mt.IsTeamDead() then
			//can a continue be used
			if mt.GetContinueCount() > 0 then
				//how should that continue be used
				if RespawnASAPMode then
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Continues ASAP respawn")
					call user.RespawnAtRect(mt.Revive, false)
				else //mt.IsTeamDead()
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Continues Team respawn")
					call mt.RespawnTeamAtRect(mt.Revive, false)
				endif
			endif
			
			call mt.ChangeContinueCount(-1)
		endif
		
		call mt.UpdateMultiboard()
	endif
	    
    call ReleaseTimer(t)
    set t = null
endfunction

public function onPlayerUnitDied takes nothing returns nothing
    //call Continues_PlayerUnitDied(GetPlayerId(GetTriggerPlayer()))
    call TimerStart(NewTimerEx(GetPlayerId(GetTriggerPlayer())), REVIVE_WAIT_AFTER_DEATH, false, function onPlayerUnitDiedCB)
endfunction

private function Init takes nothing returns nothing
	local integer i = 0
    local trigger t = CreateTrigger()
    
    loop
    exitwhen i >= NumberPlayers
        call TriggerRegisterPlayerUnitEvent( t, Player(i), EVENT_PLAYER_UNIT_DEATH, null)
        
        set i = i + 1
    endloop
    
    call TriggerAddAction(t, function onPlayerUnitDied)
endfunction
endlibrary
