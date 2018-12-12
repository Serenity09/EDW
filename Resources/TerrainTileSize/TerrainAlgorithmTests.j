library TerrainAlgorithmTests initializer init requires TerrainCenter, Vector2
	globals
		SimpleList_List Algorithms
	endglobals
	
	private function originalTest takes real x, real y returns vector2
		local real terrainCenterX
		local real terrainCenterY
		
		if x >= 0 then
			set terrainCenterX = R2I((x + 64.500) / 128.) * 128.
		else
			set terrainCenterX = R2I((x - 63.499) / 128.) * 128.
		endif
		if y >= 0 then
			set terrainCenterY = R2I((y + 64.500) / 128.) * 128.
		else
			set terrainCenterY = R2I((y - 63.499) / 128.) * 128.
		endif
		
		return vector2.create(terrainCenterX, terrainCenterY)
	endfunction
	
	private function wurstTest takes real x, real y returns vector2
		local real terrainCenterX
		local real terrainCenterY
		
		if x > 0 then
			set terrainCenterX = R2I(x / 128. + .5) * 128.
		else
			set terrainCenterX = R2I(x / 128. - .5) * 128.
		endif
		if y > 0 then
			set terrainCenterY = R2I(y / 128. + .5) * 128.
		else
			set terrainCenterY = R2I(y / 128. - .5) * 128.
		endif
		
		return vector2.create(terrainCenterX, terrainCenterY)
	endfunction
	
	
	private function test1 takes real x, real y returns vector2
		return 0
	endfunction
	private function test2 takes real x, real y returns vector2
		return 0
	endfunction
	private function test3 takes real x, real y returns vector2
		return 0
	endfunction
	private function test4 takes real x, real y returns vector2
		return 0
	endfunction
	private function test5 takes real x, real y returns vector2
		return 0
	endfunction
	private function test6 takes real x, real y returns vector2
		return 0
	endfunction
	
	function CheckAlgorithms takes TerrainTileSizeUnitTest terrainMetadata returns nothing
		local SimpleList_ListNode curAlgorithm = Algorithms.first
		
		loop
		exitwhen curAlgorithm == 0
			call UnitTestTerrainCenterAlgorithm(curAlgorithm.value).AssertAlgorithm(terrainMetadata)
		set curAlgorithm = curAlgorithm.next
		endloop
	endfunction
	
	private function init takes nothing returns nothing
		set Algorithms = SimpleList_List.create()
		call Algorithms.addEnd(UnitTestTerrainCenterAlgorithm.create("original", originalTest))
		//call Algorithms.addEnd(UnitTestTerrainCenterAlgorithm.create("wurst", wurstTest))
		
		//call Algorithms.addEnd(UnitTestTerrainCenterAlgorithm.create("test1", test1))
	endfunction
endlibrary