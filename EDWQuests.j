library EDWQuests initializer init requires LocalizationData, SimpleList, PlayerUtils
	globals
		public quest OBSTACLE
		public quest FIRE
		public quest SKATING
		public quest PLATFORMING
		public quest COMMANDS
		
		private constant boolean DEBUG_QUESTS = false
	endglobals
	
	function LocalizeQuestDescription takes player p, quest q, string localizedDescription returns nothing
		// call DisplayTextToPlayer(Player(0), 0, 0, "Localized text: " + localizedDescription)
		if GetLocalPlayer() == p then
			call QuestSetDescription(q, localizedDescription)
		endif
	endfunction
	function LocalizeQuestTitle takes player p, quest q, string localizedTitle returns nothing
		// call DisplayTextToPlayer(Player(0), 0, 0, "Localized text: " + localizedTitle)
		if GetLocalPlayer() == p then
			call QuestSetTitle(q, localizedTitle)
		endif
	endfunction
	
	function LocalizeAllQuestsForPlayer takes User user returns nothing	
		call LocalizeQuestDescription(Player(user), OBSTACLE, LocalizeContent('TQ1A', user.LanguageCode))
		
		call LocalizeQuestDescription(Player(user), FIRE, LocalizeContent('TQ2A', user.LanguageCode) /*
		*/ + "\n\n\n" + LocalizeContent('TQ2B', user.LanguageCode))
		
		call LocalizeQuestDescription(Player(user), SKATING, LocalizeContent('TQ3A', user.LanguageCode) /*
		*/ + "\n\n" + LocalizeContent('TQ3B', user.LanguageCode) /*
		*/ + "\n\n" + LocalizeContent('TQ3C', user.LanguageCode) /*
		*/ + "\n" + LocalizeContent('TQ3D', user.LanguageCode))
		
		call LocalizeQuestDescription(Player(user), PLATFORMING, LocalizeContent('TQ4A', user.LanguageCode) /*
		*/ + "\n\n" + LocalizeContent('TQ4B', user.LanguageCode) /*
		*/ + "\n" + LocalizeContent('TQ4C', user.LanguageCode))
		
		call LocalizeQuestDescription(Player(user), COMMANDS, LocalizeContent('TQ5A', user.LanguageCode) /*
		*/ + "\n\n" + StringFormat1("-{0}", LocalizeContent('CAFK', user.LanguageCode)) /*
		*/ + "\n" + LocalizeContent('TQ5B', user.LanguageCode) /*
		*/ + "\n\n" + StringFormat1("-{0}", LocalizeContent('LTIT', user.LanguageCode)) /*
		*/ + "\n" + LocalizeContent('TQ5C', user.LanguageCode) /*
		*/ + "\n\n" + LocalizeContent('TQ5D', user.LanguageCode))
			
		if GetLocalPlayer() == Player(user) then
			call QuestSetTitle(OBSTACLE, LocalizeContent('TQ10', user.LanguageCode))
			call QuestSetTitle(FIRE, LocalizeContent('TQ20', user.LanguageCode))
			call QuestSetTitle(SKATING, LocalizeContent('TQ30', user.LanguageCode))
			call QuestSetTitle(PLATFORMING, LocalizeContent('TQ40', user.LanguageCode))
			call QuestSetTitle(COMMANDS, LocalizeContent('TQ50', user.LanguageCode))
		endif
	endfunction
	function LocalizeAllQuestsForAllPlayers takes nothing returns nothing
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		loop
		exitwhen curUserNode == 0
			call LocalizeAllQuestsForPlayer(curUserNode.value)
		set curUserNode = curUserNode.next
		endloop
	endfunction
	
	private function initCB takes nothing returns nothing
		call ReleaseTimer(GetExpiredTimer())
		
		call LocalizeAllQuestsForAllPlayers()
	endfunction
	
	private function init takes nothing returns nothing
		local quest q 
		
		//***********
		//Credits
		set q = CreateQuest()
		call QuestSetTitle(q, "Credits")
		call QuestSetDescription(q, "Thanks to my partner, who's endured this map's development." /*
		*/ + "\n\nShout out to the old WC3 crew, whose names will be forever ideal: Pat1487, Achilles.42, Mazemasta77, Amazin[G], FFSlayer, Olonavy, hlw_rocer, popartica., Eat_Bacon_Daily, marksoccer, monkeys-forever, DoughnutMuffin, God[A]nt69, Makshak" /*
		*/ + "\n\nFull credits for the map can be found at https://www.hiveworkshop.com/")
		call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNBookOfTheDead.blp")
		call QuestSetRequired(q, true)
		call QuestSetDiscovered(q, true)
		call QuestSetCompleted(q, true)
		
		//tutorials
		set OBSTACLE = CreateQuest()
		// call QuestSetTitle(OBSTACLE, "Tutorial - Obstacles")
		// call QuestSetDescription(OBSTACLE, "Avoid the darkness, nobody likes the emo kid, and treat anything that moves like its got a gun. Hell, even treat the things that don't move like they may have a gun (they might).")
		call QuestSetIconPath(OBSTACLE, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(OBSTACLE, false)
		call QuestSetDiscovered(OBSTACLE, DEBUG_QUESTS)
		call QuestSetCompleted(OBSTACLE, false)
		
		set FIRE = CreateQuest()
		// call QuestSetTitle(FIRE, "Tutorial - Fire")
		// call QuestSetDescription(FIRE, "In one of the most recent physics findings to date, fire is actually super racist. Only approach a fire if you look the same as that fire (and don't assume it'll always be red, that's racist), or else it may pull a knife on you." /*
		// */ + "\n\n\nEditor's note: This tutorial originally had a red fire icon, but, due to lawsuit filed by blue fire, we would like to summon our most sincere apology to all those excluded by the picture that our intern picked. We can assure you that he is no longer with the firm, though this is primarily due to his 6 month internship ending.")
		call QuestSetIconPath(FIRE, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScrollPurple.tga")
		call QuestSetRequired(FIRE, false)
		call QuestSetDiscovered(FIRE, DEBUG_QUESTS)
		call QuestSetCompleted(FIRE, false)
		
		set SKATING = CreateQuest()
		// call QuestSetTitle(SKATING, "Tutorial - Ice Skating")
		// call QuestSetDescription(SKATING, "Walk on any ice to start ice skating! While skating, you'll always move forward in the direction you're facing, but you can click to turn." /*
		// */ + "\n\nPress the 'escape' key to toggle camera tracking however you find most helpful." /* 
		// */ + "\n\nSnow is similar to ice, where you gradually gain (and lose) speed depending on your current speed and the direction you're facing." /*
		// */ + "\nRocky snow is the same deal as regular snow, except you can't change your direction once you start sliding!")
		call QuestSetIconPath(SKATING, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(SKATING, false)
		call QuestSetDiscovered(SKATING, DEBUG_QUESTS)
		call QuestSetCompleted(SKATING, false)
		
		set PLATFORMING = CreateQuest()
		// call QuestSetTitle(PLATFORMING, "Tutorial - 2D")
		// call QuestSetDescription(PLATFORMING, "You'll switch between existing in three dimensions and two dimensions just by touching the mossy brick tile (like how it usually works). Expect everything to be similar to regular ol' 3D mode, but different! Confusing!" /* 
		// */ + "\n\nWhile in the 2D mode, you won't use your mouse at all! Instead use your left and right arrow keys to move, and the up arrow key to jump." /*
		// */ + "\nThere are 1 or 2 more differences, but the only important one for now is that touching Lava means sudden/painful death in this mode, and the darkness is now open real-estate for your circular self.")
		call QuestSetIconPath(PLATFORMING, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(PLATFORMING, false)
		call QuestSetDiscovered(PLATFORMING, DEBUG_QUESTS)
		call QuestSetCompleted(PLATFORMING, false)
		
		set COMMANDS = CreateQuest()
		call QuestSetIconPath(COMMANDS, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(COMMANDS, false)
		call QuestSetDiscovered(COMMANDS, DEBUG_QUESTS)
		call QuestSetCompleted(COMMANDS, false)
		
		// call DisplayTextToPlayer(Player(0), 0, 0, LocalizeContent('TQ1A', User(curUserNode.value).LanguageCode))
		//localize all quest descriptions for all players
		call TimerStart(NewTimer(), .5, false, function initCB)
	endfunction
endlibrary