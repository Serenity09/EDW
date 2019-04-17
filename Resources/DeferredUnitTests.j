library DeferredUnitTests initializer init requires Deferred
	globals
		Deferred Defer1
		Deferred Defer2
	endglobals
	
	private function deferCB1Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 1 timer")
		
		Defer2.Resolve(2)
	endfunction
	private function deferCB1 takes integer result returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 1 executing")
		
		call TimerStart(CreateTimer(), 2, false, function DeferredUnitTests.deferCB1Timer)
	endfunction
	
	private function deferCB2 takes integer result returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 2 executing")
	endfunction
	
	private function init takes nothing returns nothing
		Set Defer1 = Deferred.create()
		call Defer1.Then(0, 0)
		call Defer1.Then(deferCB1, 0)
		
		Set Defer2 = Deferred.create()
		call Defer2.Then(deferCB2, 0)
	endfunction
endlibrary