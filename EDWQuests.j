library EDWQuests initializer init
	globals
		public quest OBSTACLE
		public quest FIRE
		public quest SKATING
		public quest PLATFORMING
		
		private constant boolean DEBUG_QUESTS = false
	endglobals
	
	private function init takes nothing returns nothing
		local quest q 
		
		//***********
		//Credits
		set q = CreateQuest()
		call QuestSetTitle(q, "Credits")
		call QuestSetDescription(q, "Thanks to my partner, who's endured this map's development." /*
		*/ + "\n\nShout out to the old WC3 crew, whose names will be forever ideal: Pat1487, Achilles.42, Mazemasta77, Amazin[G], FFSlayer, Olonavy, hlw_rocer, popartica., Eat_Bacon_Daily, marksoccer, monkeys-forever, DoughnutMuffin, God[A]nt69, Makshak" /*
		*/ + "\n\nFull credits for the map can be found at: ")
		call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNBookOfTheDead.blp")
		call QuestSetRequired(q, true)
		call QuestSetDiscovered(q, true)
		call QuestSetCompleted(q, true)
		
		//tutorials
		set OBSTACLE = CreateQuest()
		call QuestSetTitle(OBSTACLE, "Tutorial - Obstacles")
		call QuestSetDescription(OBSTACLE, "Avoid the darkness, nobody likes the emo kid, and treat anything that moves like its got a gun. Hell, even treat the things that don't move like they may have a gun (they might).")
		call QuestSetIconPath(OBSTACLE, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(OBSTACLE, false)
		call QuestSetDiscovered(OBSTACLE, DEBUG_QUESTS)
		call QuestSetCompleted(OBSTACLE, false)
		
		set FIRE = CreateQuest()
		call QuestSetTitle(FIRE, "Tutorial - Fire")
		call QuestSetDescription(FIRE, "In one of the most recent physics findings to date, fire is actually super racist. Only approach a fire if you look the same as that fire (and don't assume it'll always be red, that's racist), or else it may pull a knife on you." /*
		*/ + "\n\n\nEditor's note: This tutorial originally had a red fire icon, but, due to lawsuit filed by blue fire, we would like to summon our most sincere apology to all those excluded by the picture that our intern picked. We can assure you that he is no longer with the firm, though this is primarily due to his 6 month internship ending.")
		call QuestSetIconPath(FIRE, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScrollPurple.tga")
		call QuestSetRequired(FIRE, false)
		call QuestSetDiscovered(FIRE, DEBUG_QUESTS)
		call QuestSetCompleted(FIRE, false)
		
		set SKATING = CreateQuest()
		call QuestSetTitle(SKATING, "Tutorial - Ice Skating")
		call QuestSetDescription(SKATING, "Walk on any ice to start ice skating! While skating, you'll always move forward in the direction you're facing, but you can click to turn." /*
		*/ + "\n\nPress the 'escape' key to toggle camera tracking however you find most helpful." /* 
		*/ + "\n\nSnow is similar to ice, where you gradually gain (and lose) speed depending on your current speed and the direction you're facing." /*
		*/ + "\nRocky snow is the same deal as regular snow, except you can't change your direction once you start sliding!")
		call QuestSetIconPath(SKATING, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(SKATING, false)
		call QuestSetDiscovered(SKATING, DEBUG_QUESTS)
		call QuestSetCompleted(SKATING, false)
		
		set PLATFORMING = CreateQuest()
		call QuestSetTitle(PLATFORMING, "Tutorial - 2D")
		call QuestSetDescription(PLATFORMING, "You'll switch between existing in three dimensions and two dimensions just by touching the mossy brick tile (like how it usually works). Expect everything to be similar to regular ol' 3D mode, but different! Confusing!" /* 
		*/ + "\n\nWhile in the 2D mode, you won't use your mouse at all! Instead use your left and right arrow keys to move, and the up arrow key to jump." /*
		*/ + "\nThere are 1 or 2 more differences, but the only important one for now is that touching Lava means sudden/painful death in this mode, and the darkness is now open real-estate for your circular self.")
		call QuestSetIconPath(PLATFORMING, "ReplaceableTextures\\CommandButtons\\BTNSnazzyScroll.tga")
		call QuestSetRequired(PLATFORMING, false)
		call QuestSetDiscovered(PLATFORMING, DEBUG_QUESTS)
		call QuestSetCompleted(PLATFORMING, false)
	endfunction
endlibrary