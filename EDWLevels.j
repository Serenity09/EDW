library EDWLevels requires LevelIDGlobals, Levels, PW4
	public function Initialize takes nothing returns nothing
		local Levels_Level l
		local Checkpoint cp
		
		//FIRST LEVEL INITS HARD CODED
        set l = Levels_Level.create(INTRO_LEVEL_ID, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, gg_rct_IntroWorld_End, 0)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_1, gg_rct_IntroWorld_R2)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2a, gg_rct_IntroWorld_R3a)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2, gg_rct_IntroWorld_R3)
		
		//DOORS HARD CODED
        set l = Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision)
		call l.Boundaries.addEnd(gg_rct_HubWorld_Vision2)
		call l.Boundaries.addEnd(gg_rct_HubWorld_Vision3)
		call l.Boundaries.addEnd(gg_rct_HubWorld_Vision4)
		call l.Boundaries.addEnd(gg_rct_HubWorld_Vision5)
        
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level.create(IW1_LEVEL_ID, "Cruise Control", 3, 2, "IW1Start", "IW1Stop", gg_rct_IWR_1_1, gg_rct_IW1_Vision, gg_rct_IW1_End, 0)
        call l.AddCheckpoint(gg_rct_IWCP_1_1, gg_rct_IWR_1_2)
		
		//LEVEL 2
        set l = Levels_Level.create(IW2_LEVEL_ID, "Jesus on Wheel", 4, 3, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW2_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_2_1, gg_rct_IWR_2_2)
        call l.AddCheckpoint(gg_rct_IWCP_2_2, gg_rct_IWR_2_3)
		
		//LEVEL 3
        set l = Levels_Level.create(IW3_LEVEL_ID, "Illidan Goes Skiing", 6, 6, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW3_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_3_1, gg_rct_IWR_3_2)
        call l.AddCheckpoint(gg_rct_IWCP_3_2, gg_rct_IWR_3_3)
        call l.AddCheckpoint(gg_rct_IWCP_3_3, gg_rct_IWR_3_4)
		
		//LEVEL 4
        set l = Levels_Level.create(IW4_LEVEL_ID, "Hard Angles", 6, 4, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW4_End, l)
        set cp = l.AddCheckpoint(gg_rct_IWCP_4_1, gg_rct_IWR_4_2)
        set cp.DefaultColor = KEY_RED
        call l.AddCheckpoint(gg_rct_IWCP_4_2, gg_rct_IWR_4_3)
		
		//LEVEL 5
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(IW5_LEVEL_ID, "Frosty", 4, 4, "IW5Start", "IW5Stop", gg_rct_IWR_5_1, gg_rct_IW5_Vision, gg_rct_IW5_End, l)
			call l.AddCheckpoint(gg_rct_IWCP_5_1, gg_rct_IWR_5_2)
        endif
		
		//ICE WORLD B
		//LEVEL 1
		set l = Levels_Level.create(IWB1_LEVEL_ID, "Training Wheels", 4, 2, "IWB1Start", "IWB1Stop", gg_rct_EIWR_1_1, gg_rct_EIW1_Vision, gg_rct_EIW1_End, 0)
        call l.AddCheckpoint(gg_rct_EIWCP_1_1, gg_rct_EIWR_1_2)
		
		//LAND WORLD A
		//LEVEL 1
		set l = Levels_Level.create(LW1_LEVEL_ID, "Need For Speed", 3, 3, "LW1Start", "LW1Stop", gg_rct_LWR_1_1, gg_rct_LW1_Vision, gg_rct_LW1_End, 0)
		call l.AddCheckpoint(gg_rct_LWCP_1_1, gg_rct_LWR_1_2)		
		
		//LEVEL 2
		set l = Levels_Level.create(LW2_LEVEL_ID, "Monday Commute", 3, 3, "LW2Start", "LW2Stop", gg_rct_LWR_2_1, gg_rct_LW2_Vision, gg_rct_LW2_End, l)
		set l.MaxCollisionSize = 300.
		
		//PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level.create(PW1_LEVEL_ID, "Perspective", 4, 2, "PW1Start", "PW1Stop", gg_rct_PWR_1_1, gg_rct_PW1_Vision, gg_rct_PW1_End, 0) //gg_rct_PW1_Vision
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_1, gg_rct_PWR_1_2)
		set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_2, gg_rct_PWR_1_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
		set cp = l.AddCheckpoint(gg_rct_PWCP_1_3, gg_rct_PWR_1_4)
		set cp.RequiresSameGameMode = true
		
		//LEVEL 2
        set l = Levels_Level.create(PW2_LEVEL_ID, "Palindrome", 5, 5, "PW2Start", "PW2Stop", gg_rct_PWR_2_1, gg_rct_PW2_Vision, gg_rct_PW2_End, l) //gg_rct_PW1_Vision
		//set cpID = l.AddCheckpoint(gg_rct_PWCP_2_1, gg_rct_PWR_2_2)
        call l.AddCheckpoint(gg_rct_PWCP_2_2, gg_rct_PWR_2_3)
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_3, gg_rct_PWR_2_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_4, gg_rct_PWR_2_5)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        set cp.RequiresSameGameMode = true
		
		//LEVEL 3
        set l = Levels_Level.create(PW3_LEVEL_ID, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW3_End, l) //gg_rct_PW1_Vision
        call l.Boundaries.addEnd(gg_rct_PW3_Vision2)
		set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_1, gg_rct_PWR_3_2)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_2, gg_rct_PWR_3_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_3, gg_rct_PWR_3_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
		//LEVEL 4
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(PW4_LEVEL_ID, "Moon", 5, 4, "PW4Start", "PW4Stop", gg_rct_PWR_4_1, gg_rct_PW4_Vision, gg_rct_PW4_End, l) //gg_rct_PW1_Vision
			call l.Boundaries.addEnd(gg_rct_PW4_Vision2)
			set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
			call l.AddLevelStartCB(Condition(function PW4TeamStart))
			call l.AddLevelStopCB(Condition(function PW4TeamStop))
		endif
		
        //Justine's Four Seasons
		set l = Levels_Level.create(FS1_LEVEL_ID, "Spring", 3, 2, "FourSeason1Start", "FourSeason1Stop", gg_rct_FSR_1_1, gg_rct_FS1_Vision, gg_rct_FS1_End, 0)
		call l.AddCheckpoint(gg_rct_FSCP_1_1, gg_rct_FSR_1_2)
			        
		
        //Testing worlds
        set l = Levels_Level.create(TESTDH_LEVEL_ID, "Test Standard", 0, 0, null, null, gg_rct_SWR_2_1, null, null, 0)
		
		set l = Levels_Level.create(TESTP_LEVEL_ID, "Test Platforming", 0, 0, null, null, gg_rct_SWR_1_1, null, null, 0)
        set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
	endfunction
endlibrary