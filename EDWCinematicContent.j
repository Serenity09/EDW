library EDWCinematicContent requires EDWLevelContent, Cinema, EDWGameTime
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
	
	public function Initialize takes nothing returns nothing
		local Cinematic cine
        local CinemaMessage cineMsg
		
		//FIRST LEVEL INITS
        //set l = Levels_Level.create(1, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, gg_rct_IntroWorld_End, 0)
		//1st level is now handled in EDWVisualVote vote finish callback
        //call l.StartLevel() //just start it, intro level vision handled by Reveal Intro World... i like the reveal effect
        
        /*
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Welcome", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_WelcomeMessage, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "To", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Dream World", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageDefaults(-1)
		call Levels_Level(1).AddCinematic(cine)
        */
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Hey you!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeIntro1, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Yeah, you", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...Maggot", ANGRY_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Sorry, but that just felt right", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
		
        //set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Anyways, like I was saying, how'd we even get into this pit?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Oh man, I think I mighta had one too many last night", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeIntro2, true, false, cineMsg)
        //call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Oh man, I think I mighta had one too many last night", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Wait...", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I'm remembering something...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Yeah, okay. You probably shouldn't get near those colorful dragons", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        //call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...I don't want to talk about it", SAD_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Whoa!", ANGRY_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFireWarning, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotRed
		set cine.Priority = 3
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Better stay clear of that fire", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I don't think it likes how you look", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
                
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Nice!", HAPPY_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFoundRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
		set cine.Priority = 2
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Your skin's glowing red!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I bet you could go through that fire now", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Everyone knows that the best color is the same color!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Hah, classic Red", HAPPY_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeBeatRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Wow...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeVines, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotInCinema
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "It's like a Special Ed class took a field trip to a Catholic Church", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
                        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I see that you, too, hold a secret passion for the elegant art of figure skating", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IceTutorial, false, false, cineMsg)
		set cine.Priority = 3
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Remember to hold your head high, and always face towards your future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "There's no stopping, just relentless progress towards that future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Keep track of yourself using the arrow keys or mouse, or press the 'escape' key", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Another one of these shimmering portals...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeCheckpoint, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Stepping over them seems to give you a checkpoint, and brings your friends back to life", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "But are they the same friends?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Ahh, I'd know that mossy brick tile up ahead from anywhere", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingTile, true, false, cineMsg)
        set cine.Priority = 2
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Brings me right back to my time in 'Nam", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Touch it and your world will change", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Pull yourself together soldier!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingMovement, true, false, cineMsg)
        set cine.Priority = 5
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "You're a circle now!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Show some dignity, and use your arrow keys to move", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Jesus christ, no, not like that", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeJump, true, false, cineMsg)
		set cine.ActivationCondition = IsUserDying
        set cine.Priority = 100
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Press up to jump UP!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I swear, you're the reason I needed to add these tutorials", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Now, hold that wall close,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeWallJump, true, false, cineMsg)
		set cine.ActivationCondition = IsUserNotInCinema
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Like it was your fiance who promised that you'd never be alone but died far too young in a horrible accident that was no ones fault but has still left you a soul-less husk", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "And then press the Up key to do a wall-jump!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Here's a life lesson for you, son", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeBlue, true, false, cineMsg)
        set cine.ActivationCondition = IsUserBlue
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Everybody knows circles can't be blue", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "But, when you turn back into a demon hunter,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "You can take your trusty circle, and blue yourself with it!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "(this is true wisdom for all colors!)", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        //DOORS HARD CODED
        //currently no start or stop logic
        //call Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision)
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Love hurts, son", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
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
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Phil", "I ain't never seen nothin like it, Marge", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Runes, true, true, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Marge (lost forever to the Oblivion)", "The runes... so pretty...", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Phil", "I'll tell you what though,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Phil", "Ain't never using no organic pesticides again", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Bobby", "Hey Little Timmy, I really appreciate you talking to me", DEFAULT_TEXT_COLOR), DEFAULT_LONG_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Listen, true, true, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Bobby", "Look, I know we both like Becky, let's face it who wouldn't", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "Bobby, pal, I'm going to have to cut you off right here,", DEFAULT_TEXT_COLOR), DEFAULT_LONG_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "Becky isn't even on my radar.", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "But, if you wanted to impress her,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "You'd grab her some of the flowers from inside the fake cage up on Hagatha Hill", DEFAULT_TEXT_COLOR), DEFAULT_LONG_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Becky", "...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Becky, true, true, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Becky", "*Eats 3 flowers at once*", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Becky", "...", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Bobby", "Wow...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW1Cage, true, true, cineMsg)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Bobby", "this", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Bobby", "THIS", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Bobby", "IS THE BEST FAKE CAGE EVERR!@!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(3).AddCinematic(cine)
		
		
        //LEVEL 2
        //set l = Levels_Level.create(10, "Jesus on Wheel", 6, 4, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW2_End, l)
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Little Timmy", "Uuhh", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW2Yikes, true, true, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "That's a yikes for me", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(10).AddCinematic(cine)
		
        //LEVEL 3
        //set l = Levels_Level.create(17, "Illidan Goes Skiing", 8, 8, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW3_End, l)
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("???", "Why, it's 'Little Timmy'!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		//set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Little Timmy", "We had a deal you jive ass snowball", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW3Deal, true, true, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage("???", "Now what seems to be the problem, my dear 'Little Timmy'?", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "Problem??", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "We had a deal you jive ass snowball", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "I get you out of the cage, you take care of my Bobby problem", DEFAULT_TEXT_COLOR), DEFAULT_LONG_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage("Little Timmy", "Now Sally is fucking dead, and it's all cuz of you", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(17).AddCinematic(cine)
		
        //LEVEL 4
        //set l = Levels_Level.create(24, "Hard Angles", 6, 6, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW4_End, l)
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Rocco", "Uhhhhhhhhhhh", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IW4QuestionMark, true, false, cineMsg)
		set cine.ActivationCondition = IsUserDying
		call cine.AddMessage(null, GetEDWSpeakerMessage("Rocco", "Quuuestion mark?", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(24).AddCinematic(cine)
		
		if CONFIGURATION_PROFILE == RELEASE then
			set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Haven't seen a tear in space this bad in awhile", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
			set cine = Cinematic.create(gg_rct_IW4Performance, true, false, cineMsg)
			call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "It's like the level was cut right down the middle", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
			call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Only one thing that could do this", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
			//call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "4 words:", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
			call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Big.", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
			call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Ass.", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
			call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Optimization problems.", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
			//call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Big. Ass. Optimization problems.", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
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
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Hmmm...", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeInconvenient, true, false, cineMsg)
        set cine.ActivationCondition = IsUserStandard
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "My expert opinion?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "'50% inconvenient.'", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		call cine.SetLastMessageDefaults()
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I hope you brought your floaties", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_1, true, false, cineMsg)
        call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Cuz", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_2, true, false, cineMsg)
		//call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "It's", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
		call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "It's", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_3, true, false, cineMsg)
        call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "tHHEEE OCCEEAANNN", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeOcean_4, true, false, cineMsg)
        set cine.ActivationCondition = IsUserPlatforming
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "*rapid-fire airhorn noises*", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		//call cine.SetLastMessageBuffer(-10)
		call Levels_Level(16).AddCinematic(cine)
		
        //LEVEL 3
        //set l = Levels_Level.create(23, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW3_End, l) //gg_rct_PW1_Vision
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage("Joe", "*sniff*", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_PW3Sniff, true, false, cineMsg)
		call cine.SetLastMessageBuffer(-1)
		call Levels_Level(23).AddCinematic(cine)
		
        //Justine's Four Seasons
		//set l = Levels_Level.create(7, "Spring", 3, 2, "FourSeason1Start", "FourSeason1Stop", gg_rct_FSR_1_1, gg_rct_FS1_Vision, gg_rct_FS1_End, 0)
	
        //LANDWORLD / LUSTWORLD
        
	endfunction
endlibrary