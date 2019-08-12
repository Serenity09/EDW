library TeamSaveLocation initializer Init requires Alloc, SimpleList 

globals
    public SimpleList_List ActiveSaves
endglobals

struct PlayerSaveLocation extends array
    public integer PlayerID
    public integer GameMode
    public real LocationX
    public real LocationY
    public integer KeyColor
    
    implement Alloc
    
    public static method create takes User u returns thistype
        local thistype new = thistype.allocate()
        
        if u.GameMode == Teams_GAMEMODE_PLATFORMING then
            set new.LocationX = u.Platformer.XPosition
            set new.LocationY = u.Platformer.YPosition
        else
            set new.LocationX = GetUnitX(u.ActiveUnit)
            set new.LocationY = GetUnitY(u.ActiveUnit)
        endif
        
        set new.PlayerID = u
        set new.GameMode = u.GameMode
        set new.KeyColor = MazerColor[u]
        
        return new
    endmethod
endstruct

struct TeamSaveLocation extends array
    public string SaveName
    public integer TeamID
    public integer LevelID
    public integer CheckpointID
    //public rect Revive
    public integer ContinueCount
    //can default game mode ever change mid level?
    //public integer DefaultGameMode
    
    public SimpleList_List PlayerSaves
    
    implement Alloc
    
	private static method RemoveInvulnCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local Teams_MazingTeam invulnTeam = GetTimerData(t)
		local SimpleList_ListNode invulnPlayer = invulnTeam.FirstUser
		
		loop
		exitwhen invulnPlayer == null
			set MobImmune[invulnPlayer.value] = false
			set CanReviveOthers[invulnPlayer.value] = true
			
		set invulnPlayer = invulnPlayer.next
		endloop
		
		call ReleaseTimer(t)
		set t = null
	endmethod
	private static method UnpauseUnitCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local Teams_MazingTeam pausedTeam = GetTimerData(t)
		local SimpleList_ListNode pausedPlayer = pausedTeam.FirstUser
		
		loop
		exitwhen pausedPlayer == null
			if User(pausedPlayer.value).GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
				//set immune for  sec and create effect
				call DummyCaster['A006'].castTarget(Player(pausedPlayer.value), 1, OrderId("bloodlust"), User(pausedPlayer.value).ActiveUnit)
				set MobImmune[pausedPlayer.value] = true
				set CanReviveOthers[pausedPlayer.value] = false
			
				call User(pausedPlayer.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
			elseif User(pausedPlayer.value).GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
				//set immune for  sec and create effect
				call DummyCaster['A006'].castTarget(Player(pausedPlayer.value), 1, OrderId("bloodlust"), User(pausedPlayer.value).ActiveUnit)
				set MobImmune[pausedPlayer.value] = true
				set CanReviveOthers[pausedPlayer.value] = false
				
				call User(pausedPlayer.value).SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
			endif
		set pausedPlayer = pausedPlayer.next
		endloop
		
		call TimerStart(t, 2, false, function thistype.RemoveInvulnCB)
		set t = null
	endmethod
	public method Restore takes nothing returns nothing
		local SimpleList_ListNode pSaveNode = this.PlayerSaves.first
		local PlayerSaveLocation pSave
		local User u
		
		// call Teams_MazingTeam(this.TeamID).OnLevel.SwitchLevelsAnimated(this.TeamID, this.LevelID, false)
		call Teams_MazingTeam(this.TeamID).OnLevel.SwitchLevels(this.TeamID, this.LevelID, 0, false)
		//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "2 Team on level " + I2S(Teams_MazingTeam(this.TeamID).OnLevel))
		call Teams_MazingTeam(this.TeamID).OnLevel.SetCheckpointForTeam(this.TeamID, this.CheckpointID)
		//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team on checkpoint " + I2S(Teams_MazingTeam(this.TeamID).OnCheckpoint))
		
		call Teams_MazingTeam(this.TeamID).SetContinueCount(this.ContinueCount)
		
		//reset player locations and statuses
		loop
		exitwhen pSaveNode == null
			set pSave = PlayerSaveLocation(pSaveNode.value)
			set u = User(pSave.PlayerID)
			
			if pSave.GameMode == Teams_GAMEMODE_STANDARD or pSave.GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
				call u.SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, pSave.LocationX, pSave.LocationY)
				
				// call SetDefaultCameraForPlayer(u, .5)
				call u.ApplyDefaultCameras(.5)
			elseif pSave.GameMode == Teams_GAMEMODE_PLATFORMING or pSave.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
				call u.SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, pSave.LocationX, pSave.LocationY)
			elseif pSave.GameMode == Teams_GAMEMODE_DYING or pSave.GameMode == Teams_GAMEMODE_DEAD then
				call u.SwitchGameModes(Teams_GAMEMODE_DEAD, pSave.LocationX, pSave.LocationY)
				
				//reset camera to death location
				/*if GetLocalPlayer() == Player(u) then
					call ClearSelection()
					
					call PanCameraToTimed(pSave.LocationX, pSave.LocationY, .5)                
				endif*/
				// call SetDefaultCameraForPlayer(u, .5)
				call u.ApplyDefaultCameras(.5)
			endif
			
			call u.SetKeyColor(pSave.KeyColor)
		set pSaveNode = pSaveNode.next
		endloop
		
		// debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Restore Team - Finished updating players and team")
		
		//multiboard update
		call Teams_MazingTeam(this.TeamID).UpdateMultiboard()
		
		call TimerStart(NewTimerEx(this.TeamID), 2, false, function thistype.UnpauseUnitCB)
	endmethod
	
    public static method GetFirstSave takes string saveName returns thistype
        local SimpleList_ListNode iSave = ActiveSaves.first
        
        loop
        exitwhen iSave == null
            if TeamSaveLocation(iSave.value).SaveName == saveName then
                return iSave.value
            endif
        set iSave = iSave.next
        endloop
        
        return 0
    endmethod
    public static method GetFirstSaveForTeam takes string saveName, integer teamID returns thistype
        local SimpleList_ListNode iSave = ActiveSaves.first
        
        loop
        exitwhen iSave == null
            if TeamSaveLocation(iSave.value).SaveName == saveName and TeamSaveLocation(iSave.value).TeamID == teamID then
                return iSave.value
            endif
        set iSave = iSave.next
        endloop
        
        return 0
    endmethod
    
    public method destroy takes nothing returns nothing
        local SimpleList_ListNode curPlayerNode
        
        loop
		set curPlayerNode = this.PlayerSaves.pop()
        exitwhen curPlayerNode == null
            call PlayerSaveLocation(curPlayerNode.value).deallocate()
        call curPlayerNode.deallocate()
        endloop
		
		set this.SaveName = null
		call this.PlayerSaves.destroy()
        
        call ActiveSaves.remove(this)
    endmethod
    
    public static method create takes string saveName, Teams_MazingTeam team returns thistype
        local thistype new = thistype.allocate()
        local SimpleList_ListNode curPlayerNode = team.FirstUser
        
        set new.SaveName = saveName
        set new.TeamID = team
        set new.LevelID = team.OnLevel
        set new.CheckpointID = team.OnCheckpoint
        set new.ContinueCount = team.ContinueCount
        //set new.TeamID = teamID
        
        set new.PlayerSaves = SimpleList_List.create()
        loop
        exitwhen curPlayerNode == null
            call new.PlayerSaves.add(PlayerSaveLocation.create(User(curPlayerNode.value)))
        set curPlayerNode = curPlayerNode.next
        endloop
        
        //this is a queue
        call ActiveSaves.addEnd(new)
        
        return new
    endmethod
endstruct

private function Init takes nothing returns nothing
    set ActiveSaves = SimpleList_List.create()
endfunction
endlibrary