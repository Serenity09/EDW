library Continues initializer Init requires Levels, Teams, GameModesGlobals, MazerGlobals

public function onPlayerUnitDiedCB takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    local User user = User.GetUserFromPlayerID(pID)
	
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
		if (level == Levels_INTRO_LEVEL_ID or level == Levels_DOORS_LEVEL_ID) then
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
			if mt.ContinueCount > 0 then
				set mt.ContinueCount = mt.ContinueCount - 1
				
				//how should that continue be used
				if RespawnASAPMode then
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Continues ASAP respawn")
					call user.RespawnAtRect(mt.Revive, false)
				else //mt.IsTeamDead()
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Continues Team respawn")
					call mt.RespawnTeamAtRect(mt.Revive, false)
				endif
			else
			call mt.PrintMessage("Your team ran out of lives!")
			call level.SwitchLevels(mt, Levels_Level(Levels_DOORS_LEVEL_ID))

				//if not in 99 and none mode, reset continues
				if RewardMode == 0 or RewardMode == 1 then //standard mode or challenge mode
					set mt.ContinueCount = mt.GetInitialContinues()
					call mt.RespawnTeamAtRect(mt.Revive, true)
				elseif RewardMode == 2 then
					//call RemoveUnit()
					//**************************************
					//no more continues in 99 and none mode -- team has lost!
					//**************************************
				endif
			endif
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
