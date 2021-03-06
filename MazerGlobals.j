library MazerGlobals initializer Init requires GameGlobalConstants, LocationGlobals, ContinueGlobals, PlayerUtils, SimpleList
    globals
        //group of the playing mazers
		SimpleList_List StandardMazingUsers
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
		       
        //number of regular mazers
        integer NumberMazing = 0
        		
		private constant boolean FORCE_DEBUG_TELE = false
		private constant integer DEBUG_TELE_ITEM_ID = 'I001'
    endglobals
            
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
		
		set StandardMazingUsers = SimpleList_List.create()
        
        //loop which adds playing mazing units to a group and removes the units which are not playing from the game
        loop
        exitwhen i >= NumberPlayers
            ////only mazers who are not playing will be on level -1... level -1 does not exist
            //set MazerOnLevel[i] = -1
            set MazerColor[i] = 0
            //set Score[i] = 0
            set AbyssImmune[i] = false
            set isMoving[i] = false
            set UseTeleportMovement[i] = false
            
            set CanReviveOthers[i] = true
            set MobImmune[i] = false
			
			set MazerOnLevel[i] = 0
            
			//call AddUnitLocust(MazersArray[i])
			call PauseUnit(MazersArray[i], true)
			call SetUnitInvulnerable(MazersArray[i], false)
			
			if FORCE_DEBUG_TELE or DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
				call UnitAddItemById(MazersArray[i], DEBUG_TELE_ITEM_ID)
			endif
			            
            set i = i + 1
        endloop
    endfunction
endlibrary