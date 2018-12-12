library TerrainCenter requires Vector2, SimpleList
	function interface TerrainCenterAlgorithm takes real x, real y returns vector2
	
	struct UnitTestTerrainCenterAlgorithm
		public string Name
		public TerrainCenterAlgorithm Algorithm
		
		private method AssertCenter takes TerrainTileSizeUnitTest test, vector2 center, string position returns nothing
			if center.x == test.CalculatedCenterX and center.y == test.CalculatedCenterY then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Assert center succeeded for " + position + " position")
			else
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Assert center failed for " + position + " position")
			endif
			
			call center.deallocate()
		endmethod
		
		public method AssertAlgorithm takes TerrainTileSizeUnitTest test returns nothing
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Asserting algorithm " + .Name)
			
			call .AssertCenter(test, .Algorithm.evaluate(test.CalculatedCenterX, test.CalculatedCenterY), "center")
			
			call .AssertCenter(test, .Algorithm.evaluate(test.LeftX, test.CalculatedCenterY), "left center")
			call .AssertCenter(test, .Algorithm.evaluate(test.RightX, test.CalculatedCenterY), "right center")
			call .AssertCenter(test, .Algorithm.evaluate(test.CalculatedCenterX, test.BottomY), "center bottom")
			call .AssertCenter(test, .Algorithm.evaluate(test.CalculatedCenterX, test.TopY), "center top")
			
			call .AssertCenter(test, .Algorithm.evaluate(test.LeftX, test.BottomY), "left bottom")
			call .AssertCenter(test, .Algorithm.evaluate(test.LeftX, test.TopY), "left top")
			call .AssertCenter(test, .Algorithm.evaluate(test.RightX, test.BottomY), "right bottom")
			call .AssertCenter(test, .Algorithm.evaluate(test.RightX, test.TopY), "right top")
			
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished assertions for algorithm " + .Name)
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "----------------------------------")
		endmethod
				
		public static method create takes string name, TerrainCenterAlgorithm algorithm returns thistype
			local thistype new = thistype.allocate()
			
			set new.Name = name
			set new.Algorithm = algorithm
			
			return new
		endmethod
	endstruct
endlibrary