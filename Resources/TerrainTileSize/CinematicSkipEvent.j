library DebugTerrainTileSize initializer init requires TimerUtils, TerrainCenter, TerrainAlgorithmTests, TerrainCenterHelpers
	globals
		private constant real MEASURE_WAIT_TIME = 1.
	endglobals
	
	private function cb2 takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local TerrainTileSizeUnitTest test = GetTimerData(t)
				
		call CheckAlgorithms(test)
				
		call ReleaseTimer(t)
		set t = null
	endfunction
	
	private function cb takes nothing returns nothing
		//call TimerStart(NewTimerEx(TerrainTileSizeUnitTest.create(GetRandomReal(GetRectMinX(bj_mapInitialPlayableArea), GetRectMaxX(bj_mapInitialPlayableArea)), GetRandomReal(GetRectMinY(bj_mapInitialPlayableArea), GetRectMaxY(bj_mapInitialPlayableArea)))), MEASURE_WAIT_TIME, false, function cb2)
		call EasyAssertTerrainCenter(GetRandomReal(GetRectMinX(bj_mapInitialPlayableArea), GetRectMaxX(bj_mapInitialPlayableArea)), GetRandomReal(GetRectMinY(bj_mapInitialPlayableArea), GetRectMaxY(bj_mapInitialPlayableArea)))
	endfunction
	
	private function init takes nothing returns nothing
		local trigger t = CreateTrigger()
		
		call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
		call TriggerAddAction(t, function cb)
	endfunction
endlibrary