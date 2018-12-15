library EDWQuests initializer init
	
	private function init takes nothing returns nothing
		local quest q = CreateQuest()
		
		//***********
		//Credits
		call QuestSetTitle(q, "Credits")
		call QuestSetDescription(q, "Endless thanks to my partner, who's endured this map's development. I don't know why I've enjoyed making it so much, but I have." /*
		*/ + "\n\nShout out to the old WC3 crew, whose names will be forever ideal: Pat1487, Achilles.42, Mazemasta77, Amazin[G], FFSlayer, Olonavy, hlw_rocer, popartica., Eat_Bacon_Daily, marksoccer, monkeys-forever, DoughnutMuffin, God[A]nt69, Makshak" /*
		*/ + "\n\nTo Pat1487 and Anitarf for scripting ideas. To Pat (locust) and Anitarf (vector) again, along with Vexorian (vJASS, TimerUtils), Bribe (Table), Alain.Mark (PlayerUtils), Nestheasarus (Alloc, DummyCaster, Event), and TriggerHappy (PreventSave), for so many of the scripting resources I wanted" /*
		*/ + "\n\nAnd to the MC ! for the Blackhole model and an anonymous author for the beautiful loading screen art")
		call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNBookOfTheDead.blp")
		call QuestSetRequired(q, true)
		call QuestSetDiscovered(q, true)
		call QuestSetCompleted(q, true)
	endfunction
endlibrary