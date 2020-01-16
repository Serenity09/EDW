library EDWCinematicContent requires EDWLevelContent, Cinema, EDWGameTime
	globals
		public Cinematic OBSTACLE
		
		public Cinematic FIRE
		
		public Cinematic SKATING
		
		public Cinematic PLATFORMING
		public Cinematic PLATFORMING_DEATH
		
		private constant integer NEW_TUTORIAL_QUEST_ALERT = 'CiTA'
	endglobals
	
	private function IsUserRed takes User user returns boolean
        return MazerColor[user] == KEY_RED
    endfunction
    private function IsUserNotRed takes User user returns boolean
        return MazerColor[user] != KEY_RED
    endfunction
	private function IsUserBlue takes User user returns boolean
        return MazerColor[user] == KEY_BLUE
    endfunction
	private function IsUserPlayerOne takes User user returns boolean
        return user == 0
    endfunction
    private function IsUserPlayerTwo takes User user returns boolean
        return user == 1
    endfunction
    private function IsUserCinemaQueueBig takes User user returns boolean
        return user.CinematicQueue.count >= 3
    endfunction
    private function IsUserInCinema takes User user returns boolean
		return user.CinematicPlaying != 0
    endfunction
	private function IsUserNotInCinema takes User user returns boolean
		return user.CinematicPlaying == 0
	endfunction
	private function IsUserStandard takes User user returns boolean
		return user.GameMode == Teams_GAMEMODE_STANDARD or user.GameMode == Teams_GAMEMODE_STANDARD_PAUSED
	endfunction
	private function IsUserPlatforming takes User user returns boolean
		return user.GameMode == Teams_GAMEMODE_PLATFORMING or user.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED
	endfunction
    private function IsUserDying takes User user returns boolean
        return user.GameMode == Teams_GAMEMODE_DYING or user.GameMode == Teams_GAMEMODE_DEAD
    endfunction
	
	private function IsUserRedAndFree takes User user returns boolean
        return IsUserRed(user) and IsUserNotInCinema(user)
    endfunction
	
	public function Initialize takes nothing returns nothing
		local Cinematic cine
        local CinemaMessage cineMsg
		
		//FIRST LEVEL INITS
        //set l = Levels_Level.create(1, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, gg_rct_IntroWorld_End, 0)
		//1st level is now handled in EDWVisualVote vote finish callback
        //call l.StartLevel() //just start it, intro level vision handled by Reveal Intro World... i like the reveal effect

        
		//does Sarge even need to be introduced? if he does, he needs a better introduction
		/*
        set cineMsg = CinemaMessage.create(null, PRIMARY_SPEAKER_NAME, "Hey you!", DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeIntro1, false, false, cineMsg)
		call cine.AddMessage(CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Yeah, you", DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...Maggot", DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Sorry, but that just felt right", DEFAULT_SHORT_TEXT_SPEED))

		
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        */
		
        //set cineMsg = CinemaMessage.create(null, PRIMARY_SPEAKER_NAME, "Anyways, like I was saying, how'd we even get into this pit?", DEFAULT_SHORT_TEXT_SPEED)
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiO1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeIntro2, true, false, cineMsg)
        //call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "Oh man, I think I mighta had one too many last night", DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiO2', DEFAULT_TINY_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiO3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiO4', DEFAULT_SHORT_TEXT_SPEED))
        //call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "...I don't want to talk about it", DEFAULT_TINY_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
		
		set OBSTACLE = cine
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiF1', DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFireWarning, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotRed
		set cine.Priority = 5
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiF2', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiF3', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, null, NEW_TUTORIAL_QUEST_ALERT, DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
		
		set FIRE = cine
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cif1', DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFoundRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
		set cine.Priority = 2
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cif2', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cif3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cif4', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
		
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiRd', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeBeatRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRedAndFree
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Ciw1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeVines, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotInCinema
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Ciw2', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
                        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiS1', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IceTutorial, false, false, cineMsg)
		set cine.Priority = 3
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiS2', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiS3', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiS4', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
		
		set SKATING = cine
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiC1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeCheckpoint, true, false, cineMsg)
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiC2', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiC3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiM1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingTile, true, false, cineMsg)
        set cine.Priority = 2
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiM2', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiM3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
		
		set PLATFORMING = cine
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiA1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingMovement, true, false, cineMsg)
        set cine.Priority = 5
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiA2', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiA3', DEFAULT_SHORT_TEXT_SPEED))
		call Levels_Level(1).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiJp', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeJumpIntro, true, false, cineMsg)
		set cine.ActivationCondition = IsUserNotInCinema
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiJ1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeJump, true, false, cineMsg)
		set cine.ActivationCondition = IsUserDying
        set cine.Priority = 100
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiJ2', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CiJ3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, null, NEW_TUTORIAL_QUEST_ALERT, DEFAULT_MEDIUM_TEXT_SPEED))
		call Levels_Level(1).AddCinematic(cine)
		
		set PLATFORMING_DEATH = cine
        
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cij1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeWallJump, true, false, cineMsg)
		set cine.ActivationCondition = IsUserNotInCinema
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cij2', DEFAULT_TINY_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'Cij3', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
		
		/*
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "Here's a life lesson for you, son", DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeBlue, true, false, cineMsg)
        set cine.ActivationCondition = IsUserBlue
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "Everybody knows circles can't be blue", DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "But, when you turn back into a demon hunter,", DEFAULT_SHORT_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "You can take your trusty circle, and blue yourself with it!", DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "(this is true wisdom for all colors!)", DEFAULT_SHORT_TEXT_SPEED))
		call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        */
		
        //DOORS HARD CODED
        //currently no start or stop logic
        //call Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision)
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CDHU', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeHeart, true, false, cineMsg)
		call cine.SetLastMessageDefaults()
		call Levels_Level(2).AddCinematic(cine)
        
        //REMAINING LEVELS
        //takes integer levelID, trigger start, trigger stop, trigger preload, trigger unload, boolean haspreload, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
        //config extension methods:
        //.setPreload(trigger preload, trigger unload) returns Levels_Level
        
		//ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        //set l = Levels_Level.create(3, "Cruise Control", 3, 2, "IW1Start", "IW1Stop", gg_rct_IWR_1_1, gg_rct_IW1_Vision, gg_rct_IW1_End, 0)
        set cineMsg = CinemaMessage.createEx(gg_unit_nvil_0027, "Phil", 'I1P1', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Runes, true, true, cineMsg)
        call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvlw_0028, "Marge (lost forever to the Oblivion)", 'I1M2', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvil_0027, "Phil", 'I1P2', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Phil", 'I1P3', DEFAULT_SHORT_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(gg_unit_nvk2_0029, "Bobby", 'I1B1', DEFAULT_LONG_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Listen, true, true, cineMsg)
		call cine.AddMessage(CinemaMessage.createEx(null, "Bobby", 'I1B2', DEFAULT_MEDIUM_TEXT_SPEED))
        // call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvk2_0029, "Bobby", 'I1B3', DEFAULT_SHORT_TEXT_SPEED + .5))
		call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvlk_0030, "Little Timmy", 'I1T1', DEFAULT_TINY_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I1T2', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I1T3', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvlk_0030, "Little Timmy", 'I1T4', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I1T5', DEFAULT_LONG_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(gg_unit_nvlk_0026, GetEDWSpeakerMessage("Becky", "...", null), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Becky, true, true, cineMsg)
        call cine.AddMessage(CinemaMessage.createEx(null, "Becky", 'I1BE', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.AddMessage(CinemaMessage.create(null, GetEDWSpeakerMessage("Becky", "...", null), DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(gg_unit_nvlk_0031, "Bobby", 'I1b1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Cage, true, true, cineMsg)
		call cine.AddMessage(CinemaMessage.createEx(null, "Bobby", 'I1b2', DEFAULT_TINY_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Bobby", 'I1b3', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Bobby", 'I1b4', DEFAULT_MEDIUM_TEXT_SPEED))
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		
        //LEVEL 2
        //set l = Levels_Level.create(10, "Jesus on Wheel", 6, 4, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW2_End, l)
        set cineMsg = CinemaMessage.createEx(gg_unit_nvk2_0022, "Little Timmy", 'I2T1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW2Yikes, true, true, cineMsg)
        call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I2T2', DEFAULT_SHORT_TEXT_SPEED))
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(10).AddCinematic(cine)
		
        //LEVEL 3
        //set l = Levels_Level.create(17, "Illidan Goes Skiing", 8, 8, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW3_End, l)
		set cineMsg = CinemaMessage.createEx(null, "???", 'I3F1', DEFAULT_SHORT_TEXT_SPEED)
		//set cineMsg = CinemaMessage.createEx(null, "Little Timmy", "We had a deal you jive ass snowball", DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW3Deal, true, true, cineMsg)
        call cine.AddMessage(CinemaMessage.createEx(null, "???", 'I3F2', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvk2_0087, "Little Timmy", 'I3T1', DEFAULT_TINY_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I3T2', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(gg_unit_nvk2_0087, "Little Timmy", 'I3T3', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I3T4', DEFAULT_LONG_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, "Little Timmy", 'I3T5', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(17).AddCinematic(cine)
		
        //LEVEL 4
        //set l = Levels_Level.create(24, "Hard Angles", 6, 6, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW4_End, l)
        set cineMsg = CinemaMessage.createEx(null, "Rocco", 'I4R1', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW4QuestionMark, true, false, cineMsg)
		set cine.ActivationCondition = IsUserDying
		call cine.AddMessage(CinemaMessage.createEx(null, "Rocco", 'I4R2', DEFAULT_MEDIUM_TEXT_SPEED))
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(24).AddCinematic(cine)
		
		if CONFIGURATION_PROFILE == RELEASE then
			set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O1', DEFAULT_MEDIUM_TEXT_SPEED)
			set cine = Cinematic.create(gg_rct_IW4Performance, true, false, cineMsg)
			call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O2', DEFAULT_MEDIUM_TEXT_SPEED))
			call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O3', DEFAULT_MEDIUM_TEXT_SPEED))
			//call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "4 words:", DEFAULT_SHORT_TEXT_SPEED))
			call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O4', DEFAULT_TINY_TEXT_SPEED))
			call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O5', DEFAULT_TINY_TEXT_SPEED))
			call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'I4O6', DEFAULT_SHORT_TEXT_SPEED))
			//call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "Big. Ass. Optimization problems.", DEFAULT_MEDIUM_TEXT_SPEED))
			call cine.SetLastMessageBuffer(-1)
			call Levels_Level(24).AddCinematic(cine)
		endif
		
        //LEVEL 5
        //set l = Levels_Level.create(31, "TODO SHIIIIT", 4, 4, "IW5Start", "IW5Stop", gg_rct_IWR_5_1, gg_rct_IW5_Vision, gg_rct_IW5_End, l)
                
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        //set l = Levels_Level.create(9, "Perspective", 4, 2, "PW1Start", "PW1Stop", gg_rct_PWR_1_1, gg_rct_PW1_Vision, gg_rct_PW1_End, 0) //gg_rct_PW1_Vision
        
        //LEVEL 2
        //set l = Levels_Level.create(16, "Palindrome", 5, 5, "PW2Start", "PW2Stop", gg_rct_PWR_2_1, gg_rct_PW2_Vision, gg_rct_PW2_End, l) //gg_rct_PW1_Vision
        set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2E1', DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeInconvenient, true, false, cineMsg)
        set cine.ActivationCondition = IsUserStandard
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2E2', DEFAULT_SHORT_TEXT_SPEED))
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2E3', DEFAULT_SHORT_TEXT_SPEED))
		call cine.SetLastMessageDefaults()
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2O1', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_1, true, false, cineMsg)
        call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2O2', DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_2, true, false, cineMsg)
		//call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, "It's", DEFAULT_TINY_TEXT_SPEED)
		call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2O3', DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_3, true, false, cineMsg)
        call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2O4', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_4, true, false, cineMsg)
        set cine.ActivationCondition = IsUserPlatforming
		call cine.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'P2O5', DEFAULT_MEDIUM_TEXT_SPEED))
		//call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
        //LEVEL 3
        //set l = Levels_Level.create(23, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW3_End, l) //gg_rct_PW1_Vision
        set cineMsg = CinemaMessage.createEx(null, "Joe", 'P3SN', DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_PW3Sniff, true, false, cineMsg)
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(23).AddCinematic(cine)
		
        //Justine's Four Seasons
		//set l = Levels_Level.create(7, "Spring", 3, 2, "FourSeason1Start", "FourSeason1Stop", gg_rct_FSR_1_1, gg_rct_FS1_Vision, gg_rct_FS1_End, 0)
	
        //LANDWORLD / LUSTWORLD
        
	endfunction
endlibrary