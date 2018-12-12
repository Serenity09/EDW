library TerrainCenterHelpers requires TimerUtils, TerrainCenter, TerrainAlgorithmTests
	globals
		private constant real MEASURE_WAIT_TIME = 1.
	endglobals
	
	private function cb takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local TerrainTileSizeUnitTest test = GetTimerData(t)
				
		call CheckAlgorithms(test)
				
		call ReleaseTimer(t)
		set t = null
	endfunction
		
	function EasyAssertTerrainCenter takes real x, real y returns nothing
		call TimerStart(NewTimerEx(TerrainTileSizeUnitTest.create(x, y)), MEASURE_WAIT_TIME, false, function cb)
	endfunction
endlibrary