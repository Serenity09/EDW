library MazerGlobals initializer Init requires GameGlobalConstants, ContinueGlobals, LevelGlobals, PlayerUtils, SimpleList
    globals
        //group of the playing mazers
        group MazersGroup = CreateGroup()
        //array of the playing mazers
        unit array MazersArray[NumberPlayers]
        //units that represents the revive circle
        unit array PlayerReviveCircles[NumberPlayers]
        //a player's score
        //integer array Score[NumberPlayers]
        //the current "color" the unit is, for passing through color gate purposes
        //0: none, 1: red, 2: blue, 3: green
        integer array MazerColor[NumberPlayers]
        constant integer KEY_NONE = 0
        constant integer KEY_RED = 1
        constant integer KEY_BLUE = 2
        constant integer KEY_GREEN = 3
        
        //level each mazer is on
        integer array MazerOnLevel[NumberPlayers]
        //can this unit be killed by abyss?
        boolean array AbyssImmune[NumberPlayers]
        //standard camera setup
        camerasetup array DefaultCamera[NumberPlayers]
        boolean array DefaultCameraTracking[NumberPlayers]
        
        boolean array MobImmune[NumberPlayers]
        boolean array CanReviveOthers[NumberPlayers]

        //array of rotation cameras
        //RotationCameraAdvanced array RotationCameras[NumberPlayers]
        
        boolean array isMoving[NumberPlayers]
        real array OrderDestinationX[NumberPlayers]
        real array OrderDestinationY[NumberPlayers]
        
        boolean array UseTeleportMovement[NumberPlayers]
        
        //keeps track of playername, level, continues and score
        multiboard PlayerStats
        //number of regular mazers
        integer NumberMazing = 0
        
        
        public constant real SAFE_X    = -12050.0 //x where to store the .Unit when not in use
        public constant real SAFE_Y    = 12050.0 //y where to store the .Unit when not in use
        
        public constant real REVIVE_CIRCLE_SAFE_X  = -15755
        public constant real REVIVE_CIRCLE_SAFE_Y  = 15505
		
		private constant boolean FORCE_DEBUG_TELE = false
		private constant integer DEBUG_TELE_ITEM_ID = 'I001'
    endglobals
    
    function SetDefaultCameraForPlayer takes integer pID, real panTime returns nothing
        if GetLocalPlayer() == Player(pID) then
            call ClearSelection()
            call SelectUnit(MazersArray[pID], true)
            
            if panTime >= 0 then
                call CameraSetupApplyForceDuration(DefaultCamera[pID], true, panTime)
                call PanCameraToTimed(GetUnitX(MazersArray[pID]), GetUnitY(MazersArray[pID]), panTime)
            else
                call CameraSetupApply(DefaultCamera[pID], false, false)
            endif
            
            if DefaultCameraTracking[pID] then
                call SetCameraTargetController(MazersArray[pID], 0, 0, false)
            endif
        endif
    endfunction
    
    function SetDefaultTracking takes integer pID, boolean flag returns nothing
        if flag != DefaultCameraTracking[pID] then
            if GetLocalPlayer() == Player(pID) then
                if flag then
                    //enable
                    call SetCameraTargetController(MazersArray[pID], 0, 0, false)
                else
                    //disable
                    call ResetToGameCamera(0)
                    call CameraSetupApply(DefaultCamera[pID], false, false)
                endif
            endif
            
            set DefaultCameraTracking[pID] = flag
        endif
    endfunction
    function ToggleDefaultTracking takes integer pID returns nothing
        call DisplayTextToPlayer(Player(pID), 0, 0, "Toggle tracking for " + I2S(pID))
        if GetLocalPlayer() == Player(pID) then
            if DefaultCameraTracking[pID] then
                call DisplayTextToPlayer(Player(pID), 0, 0, "Disable")
                //disable
                call ResetToGameCamera(0)
                call CameraSetupApply(DefaultCamera[pID], false, false)
            else
                call DisplayTextToPlayer(Player(pID), 0, 0, "Enable")
                //enable
                call SetCameraTargetController(MazersArray[pID], 0, 0, false)
            endif
        endif
        
        set DefaultCameraTracking[pID] = not DefaultCameraTracking[pID]
    endfunction
    
    public function Init takes nothing returns nothing
        local integer i = 0
        //local trigger t = CreateTrigger()
        
        //mazing unit array
        set MazersArray[0] = gg_unit_Edem_0001
        set MazersArray[1] = gg_unit_Edem_0002
        set MazersArray[2] = gg_unit_Edem_0014
        set MazersArray[3] = gg_unit_Edem_0015
        set MazersArray[4] = gg_unit_Edem_0016
        set MazersArray[5] = gg_unit_Edem_0017
        set MazersArray[6] = gg_unit_Edem_0018
        set MazersArray[7] = gg_unit_Edem_0019
        
        //loop which adds playing mazing units to a group and removes the units which are not playing from the game
        loop
        exitwhen i >= NumberPlayers
            //only mazers who are not playing will be on level -1... level -1 does not exist
            set MazerOnLevel[i] = -1
            set MazerColor[i] = 0
            //set Score[i] = 0
            set AbyssImmune[i] = false
            set isMoving[i] = false
            set UseTeleportMovement[i] = false
            
            set CanReviveOthers[i] = true
            set MobImmune[i] = false
            
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                if FORCE_DEBUG_TELE or DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
					call UnitAddItemById(MazersArray[i], DEBUG_TELE_ITEM_ID)
				endif
				
				set PlayerReviveCircles[i] = CreateUnit(Player(i), TEAM_REVIVE_UNIT_ID, MazerGlobals_REVIVE_CIRCLE_SAFE_X, MazerGlobals_REVIVE_CIRCLE_SAFE_Y, 0)
                call AddUnitLocust(PlayerReviveCircles[i])
				call ShowUnit(PlayerReviveCircles[i], false)
                
                //call AddUnitLocust(MazersArray[i])
                call SetUnitInvulnerable(MazersArray[i], false)
                
                set MazerOnLevel[i] = 0
                call GroupAddUnit(MazersGroup, MazersArray[i])
                //(integer camOwner, unit camUnit, boolean altDir, boolean rotASAP, boolean PauseResets, real minSpd, real maxSpd, integer minTck, integer maxTck)
                set DefaultCamera[i] = CreateCameraSetup()
                set DefaultCameraTracking[i] = false
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_TARGET_DISTANCE, 1800, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_FARZ, 5000, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_FIELD_OF_VIEW, 70, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ROLL, 0, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ROTATION, 90, 0)
                //visual vote callback should handle initial vision
                //if GetLocalPlayer() == Player(i) then
                //    call CameraSetupApply(DefaultCamera[i], false, false)
                //endif
                
                //set RotationCameras[i] = RotationCameraAdvanced.create(i, MazersArray[i], true, false, true, 0, 1, 100, 300)
                
                //assumes all units will start in standard gamemode
                set NumberMazing = NumberMazing + 1
				
				call RegisterMazingClickEvents(i)
                
                call PauseUnit(MazersArray[i], true)
            else 
                call RemoveUnit(MazersArray[i])
                set MazersArray[i] = null
            endif
            
            set i = i + 1
        endloop
    endfunction
endlibrary