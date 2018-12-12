library KnownProblemUnitTests initializer init requires TerrainCenterHelpers
	
	private function init takes nothing returns nothing
		//call EasyAssertTerrainCenter(-128, 128)
		//call EasyAssertTerrainCenter(-1024, -640)
		//call EasyAssertTerrainCenter(-1442.637, -872.518)
		call EasyAssertTerrainCenter(-2883.053955076, 2614.581542912)
	endfunction
endlibrary