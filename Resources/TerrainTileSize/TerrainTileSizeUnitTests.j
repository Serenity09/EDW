library TerrainTileSizeUnitTests initializer init requires TerrainTileSizeUnitTest, SimpleList
	globals
		private constant integer TEST_COUNT_QUADRANT = 4
		//private constant integer TEST_COUNT_TOTAL = TEST_COUNT_QUADRANT * 8 + 1
		public SimpleList_List Tests
		
		private constant boolean TEST_FIRST_QUADRANT = false
		private constant boolean TEST_SECOND_QUADRANT = false
		private constant boolean TEST_THIRD_QUADRANT = false
		private constant boolean TEST_FOURTH_QUADRANT = false
		
		private constant boolean TEST_AXIS = false
	endglobals
	
	private function init takes nothing returns nothing
		local integer i = 0
		local real prevX = 0
		local real prevY = 0

		set Tests = SimpleList_List.create()
		
		//this is too much work for unit tests...
		//test 1st quadrant
		static if TEST_FIRST_QUADRANT then
			loop
			exitwhen i >= TEST_COUNT_QUADRANT
				set prevX = GetRandomReal(prevX + 2, (GetRectMaxX(bj_mapInitialPlayableArea) - prevX) / 2)
				set prevY = GetRandomReal(prevY + 2, (GetRectMaxY(bj_mapInitialPlayableArea) - prevY) / 2)
				
				call Tests.add(TerrainTileSizeUnitTest.create(prevX, prevY))
			set i = i + 1
			endloop
		endif
		
		static if TEST_SECOND_QUADRANT then
			set i = 0
			set prevX = 0
			set prevY = 0
			
			loop
			exitwhen i >= TEST_COUNT_QUADRANT
				set prevX = GetRandomReal(GetRectMinX(bj_mapInitialPlayableArea), prevX - 2)
				set prevY = GetRandomReal(prevY + 2, GetRectMaxY(bj_mapInitialPlayableArea))
				
				call Tests.add(TerrainTileSizeUnitTest.create(prevX, prevY))
			set i = i + 1
			endloop
		endif
		
		static if TEST_THIRD_QUADRANT then
			set i = 0
			set prevX = 0
			set prevY = 0
			
			loop
			exitwhen i >= TEST_COUNT_QUADRANT
				set prevX = GetRandomReal(GetRectMinX(bj_mapInitialPlayableArea), prevX - 2)
				set prevY = GetRandomReal(GetRectMinY(bj_mapInitialPlayableArea), prevY - 2)
				
				call Tests.add(TerrainTileSizeUnitTest.create(prevX, prevY))
			set i = i + 1
			endloop
		endif
		
		static if TEST_FOURTH_QUADRANT then
			set i = 0
			set prevX = 0
			set prevY = 0
			
			loop
			exitwhen i >= TEST_COUNT_QUADRANT
				set prevX = GetRandomReal(prevX + 2, GetRectMaxX(bj_mapInitialPlayableArea))
				set prevY = GetRandomReal(GetRectMinY(bj_mapInitialPlayableArea), prevY - 2)
				
				call Tests.add(TerrainTileSizeUnitTest.create(prevX, prevY))
			set i = i + 1
			endloop
		endif
		
		//imma just hardcode em, all points should work now that the above has been proven
		call Tests.add(TerrainTileSizeUnitTest.create(0., 0.))
		
		call Tests.add(TerrainTileSizeUnitTest.create(2*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, 4*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		call Tests.add(TerrainTileSizeUnitTest.create(5*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, 9*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		
		call Tests.add(TerrainTileSizeUnitTest.create(-2*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, 4*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		call Tests.add(TerrainTileSizeUnitTest.create(-5*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, 9*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		
		call Tests.add(TerrainTileSizeUnitTest.create(-2*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, -4*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		call Tests.add(TerrainTileSizeUnitTest.create(-5*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, -9*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		
		call Tests.add(TerrainTileSizeUnitTest.create(2*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, -4*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		call Tests.add(TerrainTileSizeUnitTest.create(5*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE, -9*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE))
		
	endfunction
endlibrary