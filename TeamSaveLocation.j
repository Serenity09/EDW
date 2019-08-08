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
        local SimpleList_ListNode iPlayer = PlayerSaves.first
                
        loop
        exitwhen iPlayer == null
            call PlayerSaveLocation(iPlayer.value).deallocate()
        set iPlayer = iPlayer.next
        endloop
        
        call ActiveSaves.remove(this)
    endmethod
    
    public static method create takes string saveName, Teams_MazingTeam team returns thistype
        local thistype new = thistype.allocate()
        local SimpleList_ListNode iPlayer = team.FirstUser
        
        set new.SaveName = saveName
        set new.TeamID = team
        set new.LevelID = team.OnLevel
        set new.CheckpointID = team.OnCheckpoint
        set new.ContinueCount = team.ContinueCount
        //set new.TeamID = teamID
        
        set new.PlayerSaves = SimpleList_List.create()
        loop
        exitwhen iPlayer == null
            call new.PlayerSaves.add(PlayerSaveLocation.create(User(iPlayer.value)))
        set iPlayer = iPlayer.next
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