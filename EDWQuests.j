library EDWQuests initializer init
	
	private function init takes nothing returns nothing
		local quest q = CreateQuest()
		
		//***********
		//Credits
		call QuestSetTitle(q, "Credits")
		call QuestSetDescription(q, "Thanks to my partner, who's endured this map's development." /*
		*/ + "\n\nShout out to the old WC3 crew, whose names will be forever ideal: Pat1487, Achilles.42, Mazemasta77, Amazin[G], FFSlayer, Olonavy, hlw_rocer, popartica., Eat_Bacon_Daily, marksoccer, monkeys-forever, DoughnutMuffin, God[A]nt69, Makshak" /*
		*/ + "\n\nFull credits for the map can be found at: ")
		call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNBookOfTheDead.blp")
		call QuestSetRequired(q, true)
		call QuestSetDiscovered(q, true)
		call QuestSetCompleted(q, true)
	endfunction
endlibrary