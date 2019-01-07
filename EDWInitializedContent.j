library EDWCinematics requires EDWLevels, Cinema, EDWGameTime
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
		call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I'm remembering something...", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Yeah, okay. You probably shouldn't get near those colorful dragons", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        //call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...I don't want to talk about it", SAD_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Whoa!", ANGRY_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFireWarning, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotRed
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Better stay clear of that fire, I don't think it likes the look of you", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
                
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Nice!", HAPPY_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFoundRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
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
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Remember to hold your head high, and always face towards your future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "There's no stopping, just relentless progress towards that future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Keep track of yourself using the arrow keys or mouse, or type '-track' or '-t'", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Another one of these shimmering portals...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeCheckpoint, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Stepping over them seems to give you a checkpoint, and bring back the souls of your friends", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "But are they the same friends?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageDefaults()
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Ahh, I'd know that mossy brick tile up ahead from anywhere", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingTile, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Brings me right back to my time in 'Nam", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Touch it and your world will change", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Pull yourself together soldier!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingMovement, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "You're a circle now!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Show some dignity, and use your arrow keys to move", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Jesus christ, no, not like that", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeJump, true, false, cineMsg)
        set cine.ActivationCondition = IsUserDying
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Press up to jump UP!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I swear, you're the reason I needed to add these tutorials", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.SetLastMessageBuffer(-1)
		call Levels_Level(1).AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Now, hold that wall close,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeWallJump, true, false, cineMsg)
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

library EDWLevels requires SimpleList, Teams, Levels
	private function FinishedIntro takes nothing returns nothing
		call TrackGameTime()
	endfunction
	
	public function Initialize takes nothing returns nothing
		local Levels_Level l
        local Checkpoint cp
        
        local SimpleList_List startables
        
        local BoundedSpoke boundedSpoke
        local Wheel wheel
        local BoundedWheel boundedWheel
        
        local SimpleGenerator sg
        local RelayGenerator rg
		
		local integer i
		
		//FIRST LEVEL INITS HARD CODED
        set l = Levels_Level.create(1, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, gg_rct_IntroWorld_End, 0)
        //1st level is now handled in EDWVisualVote vote finish callback
        //call l.StartLevel() //just start it, intro level vision handled by Reveal Intro World... i like the reveal effect
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_1, gg_rct_IntroWorld_R2)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2a, gg_rct_IntroWorld_R3a)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2, gg_rct_IntroWorld_R3)
		
        set startables = SimpleList_List.create()
        
        set boundedSpoke = BoundedSpoke.create(11970, 14465)
        set boundedSpoke.InitialOffset = 1*TERRAIN_TILE_SIZE
        set boundedSpoke.LayerOffset = 2.25*TERRAIN_QUADRANT_SIZE
        set boundedSpoke.CurrentRotationSpeed = bj_PI / 6. * BoundedSpoke_TIMESTEP
        call boundedSpoke.AddUnits('e00A', 3)
        // call boundedSpoke.SetAngleBounds(bj_PI/4, bj_PI*3./4.)
		call boundedSpoke.SetAngleBounds(55./180.*bj_PI, 125./180.*bj_PI)
        
        call startables.add(boundedSpoke)
        
        set l.Content.Startables = startables
		
		call l.AddLevelStopCB(Condition(function FinishedIntro))
                
        //DOORS HARD CODED
        //currently no start or stop logic
        call Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision)
        
        //REMAINING LEVELS
        //takes integer levelID, trigger start, trigger stop, trigger preload, trigger unload, boolean haspreload, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
        //config extension methods:
        //.setPreload(trigger preload, trigger unload) returns Levels_Level
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level.create(3, "Cruise Control", 3, 2, "IW1Start", "IW1Stop", gg_rct_IWR_1_1, gg_rct_IW1_Vision, gg_rct_IW1_End, 0)
        call l.AddCheckpoint(gg_rct_IWCP_1_1, gg_rct_IWR_1_2)
        
        set startables = SimpleList_List.create()
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        set l.Content.Startables = startables
        //call l.SetStartables(startables)
        
        //LEVEL 2
        set l = Levels_Level.create(10, "Jesus on Wheel", 4, 3, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW2_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_2_1, gg_rct_IWR_2_2)
        call l.AddCheckpoint(gg_rct_IWCP_2_2, gg_rct_IWR_2_3)
        
        set startables = SimpleList_List.create()
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        set l.Content.Startables = startables
        
        //LEVEL 3
        set l = Levels_Level.create(17, "Illidan Goes Skiing", 6, 6, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW3_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_3_1, gg_rct_IWR_3_2)
        call l.AddCheckpoint(gg_rct_IWCP_3_2, gg_rct_IWR_3_3)
        call l.AddCheckpoint(gg_rct_IWCP_3_3, gg_rct_IWR_3_4)
        
        set startables = SimpleList_List.create()
		
		call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		
		call startables.add(Blackhole.create(15000, 3330))
		
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_1, 6, 5, LGUARD, 24))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_2, 8, 6, LGUARD, 16))
        set l.Content.Startables = startables
        
        //LEVEL 4
        set l = Levels_Level.create(24, "Hard Angles", 6, 4, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW4_End, l)
        set cp = l.AddCheckpoint(gg_rct_IWCP_4_1, gg_rct_IWR_4_2)
        set cp.DefaultColor = KEY_RED
        call l.AddCheckpoint(gg_rct_IWCP_4_2, gg_rct_IWR_4_3)
        
        set startables = SimpleList_List.create()

        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW4_Drunks, 6, 5, LGUARD, 24))
        call startables.add(Blackhole.create(8958, 6400))
        //
        set rg = RelayGenerator.create(5373, 9984, 3, 6, 270, 0, LGUARD, 2.)
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(90, 0)
        call rg.EndTurns(90)
        
        call startables.add(rg)
        //
        set rg = RelayGenerator.create(6654, 6528, 3, 6, 90, 7, LGUARD, 1.5)
        call rg.AddTurnSimple(180, 7)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(0, 13)
        call rg.AddTurnSimple(90, 3)
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(90, 1)
        call rg.AddTurnSimple(0, 3)
        call rg.EndTurns(0)
        
        call startables.add(rg)
        //
        set rg = RelayGenerator.create(3830, 6278, 3, 6, 90, 3, GUARD, 3.)
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(270, 3)
        call rg.EndTurns(270)
        
        call startables.add(rg)
        
        set l.Content.Startables = startables
        
        //LEVEL 5
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(31, "Frosty", 4, 4, "IW5Start", "IW5Stop", gg_rct_IWR_5_1, gg_rct_IW5_Vision, gg_rct_IW5_End, l)
			call l.AddCheckpoint(gg_rct_IWCP_5_1, gg_rct_IWR_5_2)
			
			set startables = SimpleList_List.create()
			set l.Content.Startables = startables
			
			call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_3, 2, 2, GUARD, 12))
			call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_2, 6, 3.5, LGUARD, 16))
			call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_1, 10, 8, LGUARD, 60))
        endif
		
		//ICE WORLD B
		//LEVEL 1
		set l = Levels_Level.create(4, "Training Wheels", 4, 2, "IWB1Start", "IWB1Stop", gg_rct_EIWR_1_1, gg_rct_EIW1_Vision, gg_rct_EIW1_End, 0)
        call l.AddCheckpoint(gg_rct_EIWCP_1_1, gg_rct_EIWR_1_2)
		
		set startables = SimpleList_List.create()
		
		set rg = RelayGenerator.create(-5948, 10836, 4, 4, 270, 0, ICETROLL, 2.)
        call rg.AddTurnSimple(0, 12)
        call rg.AddTurnSimple(90, 11)
        call rg.EndTurns(90)
		        
        call startables.add(rg)
		
		
		set l.Content.Startables = startables
		
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level.create(9, "Perspective", 4, 2, "PW1Start", "PW1Stop", gg_rct_PWR_1_1, gg_rct_PW1_Vision, gg_rct_PW1_End, 0) //gg_rct_PW1_Vision
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_1, gg_rct_PWR_1_2)
		set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_2, gg_rct_PWR_1_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
		set cp = l.AddCheckpoint(gg_rct_PWCP_1_3, gg_rct_PWR_1_4)
		set cp.RequiresSameGameMode = true
        
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_352 , gg_rct_Rect_351))
        
        
        //LEVEL 2
        set l = Levels_Level.create(16, "Palindrome", 5, 5, "PW2Start", "PW2Stop", gg_rct_PWR_2_1, gg_rct_PW2_Vision, gg_rct_PW2_End, l) //gg_rct_PW1_Vision
        //set cpID = l.AddCheckpoint(gg_rct_PWCP_2_1, gg_rct_PWR_2_2)
        call l.AddCheckpoint(gg_rct_PWCP_2_2, gg_rct_PWR_2_3)
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_3, gg_rct_PWR_2_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_4, gg_rct_PWR_2_5)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        set cp.RequiresSameGameMode = true
                
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        
        //public static method create takes rect spawn, real spawntimeout, real walktimeout, integer uid, real lifespan returns thistype
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 4, 3, LGUARD, 17))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 10, 3, GUARD, 8))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_2, 6, 3, LGUARD, 8))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_3, 5, 2.5, LGUARD, 14))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_4, 4, 6, LGUARD, 10))
        
        set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, ICETROLL, 2.)
        call rg.AddTurnSimple(90, 4)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(180, 0)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(90, 3)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(180, 3)
        call rg.AddTurnSimple(90, 8)
        call rg.AddTurnSimple(0, 5)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(0, 3)
        call rg.AddTurnSimple(90, 0)
        call rg.AddTurnSimple(0, 12)
        call rg.EndTurns(0)
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "PW2 RG: " + rg.ToString())
        //debug call rg.DrawTurns()
        
        call startables.add(rg)
        
        //LEVEL 3
        set l = Levels_Level.create(23, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW3_End, l) //gg_rct_PW1_Vision
        set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_1, gg_rct_PWR_3_2)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_2, gg_rct_PWR_3_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_3, gg_rct_PWR_3_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(SimpleGenerator.create(gg_rct_PW3_MassCreate, 'e00K', 1.5, 180, 17, 100))
        
        /*
        set wheel = Wheel.create(-2904, -6765)
        set wheel.LayerCount = 3
        set wheel.SpokeCount = 12
        set wheel.AngleBetween = 30 * bj_PI / 180
        set wheel.RotationSpeed = bj_PI / 20 * Wheel_TIMEOUT
        set wheel.DistanceBetween = 2*TERRAIN_TILE_SIZE
        set wheel.InitialOffset = 2*TERRAIN_TILE_SIZE
        
        call wheel.AddUnits('e00A', 12)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(5)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddLayer(0)
        call wheel.AddUnits('e00J', 12)
        
        call startables.add(wheel)
        */
        //set wheel = Wheel.create(-2694, -9200)
        set boundedWheel = BoundedWheel.create(-2694, -9200)
        set boundedWheel.SpokeCount = 16
        set boundedWheel.AngleBetween = bj_PI / 8
        set boundedWheel.RotationSpeed = bj_PI / 20 * Wheel_TIMEOUT
        set boundedWheel.InitialOffset = 1.5*TERRAIN_TILE_SIZE
        set boundedWheel.DistanceBetween = 1*TERRAIN_QUADRANT_SIZE
        call boundedWheel.SetAngleBounds(bj_PI * 3/6,bj_PI * 5/6)
        
        /*
        call boundedWheel.AddUnits('e00A', 3)
        call boundedWheel.AddUnits('e00J', 1)
        call boundedWheel.AddUnits('e00A', 3)
        call boundedWheel.AddEmptySpace(1)
        */
        call boundedWheel.AddEmptySpace(1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddUnits('e00J', 1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddEmptySpace(2)
        
        /*
        set i = 0
        loop
        exitwhen i > 1
            call wheel.AddUnits('e00A', 3)
            call wheel.AddUnits('e00J', 1)
        set i = i + 1
        endloop
        */
        call startables.add(boundedWheel)
        
        call AddUnitLocust(CreateUnit(Player(11), 'e00K', -554, -4840, 0))
        set wheel = Wheel.create(-554, -4840)
        set wheel.SpokeCount = 4
        set wheel.AngleBetween = bj_PI / 2
        set wheel.RotationSpeed = bj_PI / 10 * Wheel_TIMEOUT
        set wheel.DistanceBetween = 2.25*TERRAIN_TILE_SIZE
        call wheel.AddUnits('e00K', 4)
        /*
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        
        
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        
        call wheel.AddUnits('e00K', 4)
        */
        call startables.add(wheel)
        
		//LEVEL 4
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(30, "Moon", 5, 4, "PW4Start", "PW4Stop", gg_rct_PWR_4_1, gg_rct_PW4_Vision, gg_rct_PW4_End, l) //gg_rct_PW1_Vision
			set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
			call l.AddLevelStartCB(Condition(function PW4TeamStart))
			call l.AddLevelStopCB(Condition(function PW4TeamStop))
			
			set startables = SimpleList_List.create()
			set l.Content.Startables = startables
			
			set wheel = Wheel.create(-7040, -2942)
			set wheel.LayerCount = 2
			set wheel.SpokeCount = 4
			set wheel.AngleBetween = 90 * bj_PI / 180.
			set wheel.RotationSpeed = bj_PI / 16. * Wheel_TIMEOUT
			set wheel.DistanceBetween = 3*TERRAIN_TILE_SIZE
			set wheel.InitialOffset = 2*TERRAIN_TILE_SIZE
			
			//layer 1
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			//layer 2
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			
			call startables.add(wheel)
		endif
		
        //Justine's Four Seasons
		set l = Levels_Level.create(7, "Spring", 3, 2, "FourSeason1Start", "FourSeason1Stop", gg_rct_FSR_1_1, gg_rct_FS1_Vision, gg_rct_FS1_End, 0)
		
		call l.AddCheckpoint(gg_rct_FSCP_1_1, gg_rct_FSR_1_2)
		
		set startables = SimpleList_List.create()
		set l.Content.Startables = startables

		call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_FS_1_Drunks, 3, 4, LGUARD, 16))
	
        //LANDWORLD / LUSTWORLD
        
        //Testing world / secret world
        set l = Levels_Level.create(66, "Test Platforming", 0, 0, null, null, gg_rct_SWR_1_1, null, null, 0)
        set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
        set l = Levels_Level.create(67, "Test Standard", 0, 0, null, null, gg_rct_SWR_2_1, null, null, l)
	endfunction
endlibrary