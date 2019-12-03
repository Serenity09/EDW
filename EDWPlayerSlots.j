library EDWPlayerSlots requires MazerGlobals, User, PlayerUtils, VisualVote, Teams, CameraTrackingEvents
	function EDWPlayerSlotsInit takes nothing returns nothing
		local integer i = 0
		// local trigger playerLeaves = CreateTrigger()
		// local trigger visualVoteSelected = CreateTrigger()
        
		//TODO remove -- functionality deprecated / replaced by User
		//initialize player utility collection
		// call PlayerUtils_Init()
		
		//initialize visual vote selection events
		call VisualVote_Init()
		
		//initialize teams
		call Teams_Init()
		
        //loop which adds playing mazing units to a group and removes the units which are not playing from the game
        loop
        exitwhen i >= NumberPlayers
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
				set User(i).IsPlaying = true
				set User.ActivePlayers = User.ActivePlayers + 1
				
				set User(i).ActiveUnit = MazersArray[i]
				
				set PlayerReviveCircles[i] = CreateUnit(Player(i), TEAM_REVIVE_UNIT_ID, MazerGlobals_REVIVE_CIRCLE_SAFE_X, MazerGlobals_REVIVE_CIRCLE_SAFE_Y, 0)
				call SetUnitPropWindow(PlayerReviveCircles[i], 0)
				call AddUnitLocust(PlayerReviveCircles[i])
				call IndexedUnit.create(PlayerReviveCircles[i])
				call ShowUnit(PlayerReviveCircles[i], false)
                
                //(integer camOwner, unit camUnit, boolean altDir, boolean rotASAP, boolean PauseResets, real minSpd, real maxSpd, integer minTck, integer maxTck)
                set DefaultCamera[i] = CreateCameraSetup()
                
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_TARGET_DISTANCE, 1800, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_FARZ, 5000, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_FIELD_OF_VIEW, 70, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ROLL, 0, 0)
                call CameraSetupSetField(DefaultCamera[i], CAMERA_FIELD_ROTATION, 90, 0)
                
                //assumes all units will start in standard gamemode
                set NumberMazing = NumberMazing + 1
				
				//register click events used for standard mazing
				call IsMoving.RegisterMazingClickEvents(i)
				
				//register camera toggle events
				set DefaultCameraTracking[i] = false
				call RegisterCameraToggleEvents(i)
			else
				set User(i).IsPlaying = false
				
				call RemoveUnit(MazersArray[i])
                set MazersArray[i] = null
			endif
		set i = i + 1
		endloop		
	endfunction
endlibrary