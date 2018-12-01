library StartableTest initializer Init
	globals
		private IStartable startable
	endglobals
	
	private function CB2 takes nothing returns nothing
		call startable.Start()
	endfunction
	
	private function CB takes nothing returns nothing
		local IceSkater test = IceSkater.create(vector2.create(-6770, 1024), vector2.create(-7976, 2390), GUARD, 10, 1)
		call test.AddDestination(vector2.create(-9221, 1162))
		call test.AddDestination(vector2.create(-7896, -7.2))
		
		set startable = test
		
		call TimerStart(CreateTimer(), 5, function CB2)
	endfunction
	
	private function Init takes nothing returns nothing
		local timer t = CreateTimer()
		call TimerStart(t, 0.01, false, function CB)
		set t = null
	endfunction
endlibrary