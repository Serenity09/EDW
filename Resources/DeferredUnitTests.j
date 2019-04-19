library DeferredUnitTests initializer init requires Deferred, Any, All
	globals
		Deferred Defer1
		Deferred Defer2
		
		Deferred Defer3
		Deferred Defer4
		Deferred Defer5
		
		Deferred Defer6
		Deferred Defer7
		Deferred Defer8
		All All1
		
		Deferred Defer9
		Deferred Defer10
		Deferred Defer11
		Any Any1
	endglobals
	
	private function deferNull takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer null executing - " + I2S(result))
		
		return 0
	endfunction
	
	private function deferCB1Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 1 timer")
		
		call Defer2.Resolve(2)
	endfunction
	private function deferCB1 takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 1 executing - " + I2S(result))
		
		call TimerStart(CreateTimer(), 2, false, function deferCB1Timer)
		
		return 0
	endfunction
	private function deferCB2 takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 2 executing - " + I2S(result))
		
		return 0
	endfunction
	
	private function deferCB3Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 3 timer")
		
		call Defer3.Resolve(3)
	endfunction
	private function deferCB3 takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 3 executing - " + I2S(result))
				
		return 4
	endfunction
	private function deferCB4 takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 4 executing - " + I2S(result))
		
		call Defer5.Resolve(5)
		
		return 4
	endfunction
	private function deferCB5 takes integer result, integer callbackData returns integer		
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 5 executing - " + I2S(result))
		
		return 5
	endfunction
	
	private function deferCB7Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 7 timer")
		
		call Defer7.Resolve(0)
	endfunction
	private function deferCB8Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 8 timer")
		
		call Defer8.Resolve(0)
	endfunction
	private function allCB1 takes integer result, integer callbackData returns integer
		call DisplayTextToPlayer(Player(0), 0, 0, "All CB 1 executing - " + I2S(result))
		
		return 0
	endfunction
	
	private function deferCB11Timer takes nothing returns nothing
		call DisplayTextToPlayer(Player(0), 0, 0, "Defer CB 11 timer")
		
		call Defer11.Resolve(0)
	endfunction
	private function anyCB1 takes integer result, integer callbackData returns integer
		call DisplayTextToPlayer(Player(0), 0, 0, "Any CB 1 executing - " + I2S(result))
		
		return 0
	endfunction
	
	//tests null/0 callbacks
	private function testNullCallback takes nothing returns nothing
		set Defer1 = Deferred.create()
		call Defer1.Then(0, 0, 0)
		call Defer1.Then(deferNull, 0, 0)
		
		call Defer1.Resolve(0)
	endfunction
	//tests a simple chain of deferreds resolving, with an async timer inbetween
	private function testSimpleChain takes nothing returns nothing
		set Defer1 = Deferred.create()
		call Defer1.Then(deferCB1, 0, 0)
		
		set Defer2 = Deferred.create()
		call Defer2.Then(deferCB2, 0, 0)
		
		call Defer1.Resolve(1)
	endfunction
	//tests a complex chain where one of the deferreds is constructed from another one's Then cascade
	private function testComplexChain takes nothing returns nothing
		set Defer3 = Deferred.create()
		set Defer4 = Defer3.Then(deferCB3, 0, 0).Promise
		call Defer4.Then(deferCB4, 0, 0)
		
		set Defer5 = Deferred.create()
		call Defer5.Then(deferCB5, 0, 0)
		
		call TimerStart(CreateTimer(), 2, false, function deferCB3Timer)
	endfunction
	//tests all wrapper
	private function testAll takes nothing returns nothing
		local SimpleList_List promiseList = SimpleList_List.create()
		
		set Defer6 = Deferred.create()
		call Defer6.Resolve(0)
		call promiseList.addEnd(Defer6)
		
		set Defer7 = Deferred.create()
		call TimerStart(CreateTimer(), 2, false, function deferCB7Timer)
		call promiseList.addEnd(Defer7)
		
		set Defer8 = Deferred.create()
		call TimerStart(CreateTimer(), 4, false, function deferCB8Timer)
		call promiseList.addEnd(Defer8)
		
		set All1 = All.create(promiseList)
		call All1.Promise.Then(allCB1, 0, 0)
		
		call promiseList.destroy()
	endfunction
	//tests any wrapper
	private function testAny takes nothing returns nothing
		local SimpleList_List promiseList = SimpleList_List.create()
		
		set Defer9 = Deferred.create()
		//call Defer9.Resolve(0)
		call promiseList.addEnd(Defer9)
		
		set Defer10 = Deferred.create()
		call promiseList.addEnd(Defer10)
		
		set Defer11 = Deferred.create()
		call TimerStart(CreateTimer(), 4, false, function deferCB11Timer)
		call promiseList.addEnd(Defer11)
		
		set Any1 = Any.create(promiseList)
		call Any1.Promise.Then(anyCB1, 0, 0)
		
		call promiseList.destroy()
	endfunction
	private function init takes nothing returns nothing
		//call testNullCallback()
		//call testSimpleChain()
		//call testComplexChain()
		//call testAll()
		call testAny()
	endfunction
endlibrary