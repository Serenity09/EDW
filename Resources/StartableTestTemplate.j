library StartableTest initializer Init
	globals
		private IStartable startable
		private integer loopcount = 0
		private constant integer MAXLOOPCOUNT = 8
	endglobals
	
	private function CB2 takes nothing returns nothing
		call startable.Start()
	endfunction
	
	private function CBLoop takes nothing returns nothing
		local IceSkater test = IceSkater.create(vector2.create(-7500, -1400), vector2.create(-7400, -4900), ICETROLL, GetRandomReal(0, 60), GetRandomReal(5, 20))
		call test.Start()
		
		set loopcount = loopcount + 1
		
		if loopcount < MAXLOOPCOUNT then
			call TimerStart(GetExpiredTimer(), GetRandomReal(1, 4), false, function CBLoop)
		endif
	endfunction
	
	private function CB takes nothing returns nothing
		//local IceSkater test = IceSkater.create(vector2.create(-6770, 1024), vector2.create(-7976, 2390), ICETROLL, 0, 0)
		local IceSkater test = IceSkater.create(vector2.create(-6770, 1024), vector2.create(-7976, 2390), ICETROLL, 40, 15)
		call test.AddDestination(vector2.create(-9221, 1162))
		call test.AddDestination(vector2.create(-7896, 90))
		
		//call test.print()
		call test.ConnectEnds()
		
		set startable = test
		call startable.Start()
		
		set test = IceSkater.create(vector2.create(-7200, -1500), vector2.create(-8200, -3000), ICETROLL, 30, 10)
		call test.AddDestination(vector2.create(-7600, -3500))
		call test.AddDestination(vector2.create(-7000, -4000))
		call test.AddDestination(vector2.create(-7500, -4900))
		call test.AddDestination(vector2.create(-7520, -5600))
		call test.Start()
		
		//call test.print()
		
		call TimerStart(GetExpiredTimer(), 0, false, function CBLoop)
		
		//call TimerStart(CreateTimer(), 3, false, function CB2)
	endfunction
	
	private function Init takes nothing returns nothing
		local timer t = CreateTimer()
		call TimerStart(t, 0.01, false, function CB)
		set t = null
	endfunction
endlibrary