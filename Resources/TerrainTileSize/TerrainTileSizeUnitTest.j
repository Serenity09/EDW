library TerrainTileSizeUnitTest requires TimerUtils, TerrainGlobals
	globals
		private constant real TERRAIN_DELTA = .005
		
		private constant integer LOOP_OP_COUNT = 8
		private constant integer WC3_OP_LIMIT = 1555555
		
		private constant integer BORDER_TERRAIN_ID = FASTICE
		private constant integer CHECK_TERRAIN_ID = SLOWICE
		
		private constant integer bj_TERRAIN_SHAPE_SQUARE = 1
		private constant integer bj_TERRAIN_SHAPE_CIRCLE = 0
	endglobals
	
	struct TerrainTileSizeUnitTest
		public real InputX
		public real InputY
		
		public real LeftX
		public real RightX
		public real BottomY
		public real TopY
		
		public real RawCenterX
		public real RawCenterY
		public real CalculatedCenterX
		public real CalculatedCenterY
		
		public method ValidateUnitTestInput takes nothing returns boolean
			if GetTerrainType(.InputX, .InputY) != CHECK_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid center terrain")
				
				return false
			endif
			
			if GetTerrainType(.InputX - TERRAIN_TILE_SIZE, .InputY) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid left terrain")
				
				return false
			endif
			if GetTerrainType(.InputX + TERRAIN_TILE_SIZE, .InputY) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid right terrain")
				
				return false
			endif
			if GetTerrainType(.InputX, .InputY - TERRAIN_TILE_SIZE) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid bottom terrain")
				
				return false
			endif
			if GetTerrainType(.InputX, .InputY + TERRAIN_TILE_SIZE) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid top terrain")
				
				return false
			endif
			
			return true
		endmethod
		
		public method ValidateUnitTestResult takes nothing returns boolean
			if GetTerrainType(.LeftX, .TopY) != CHECK_TERRAIN_ID or GetTerrainType(.LeftX - TERRAIN_DELTA, .TopY) != BORDER_TERRAIN_ID or GetTerrainType(.LeftX, .TopY + TERRAIN_DELTA) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid top left result")
				return false
			endif
			
			if GetTerrainType(.LeftX, .TopY) != CHECK_TERRAIN_ID or GetTerrainType(.LeftX - TERRAIN_DELTA, .TopY) != BORDER_TERRAIN_ID or GetTerrainType(.LeftX, .TopY + TERRAIN_DELTA) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid top left result")
				return false
			endif
			
			if GetTerrainType(.RightX, .TopY) != CHECK_TERRAIN_ID or GetTerrainType(.RightX + TERRAIN_DELTA, .TopY) != BORDER_TERRAIN_ID or GetTerrainType(.RightX, .TopY + TERRAIN_DELTA) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid top right result")
				return false
			endif
			
			if GetTerrainType(.RightX, .BottomY) != CHECK_TERRAIN_ID or GetTerrainType(.RightX + TERRAIN_DELTA, .BottomY) != BORDER_TERRAIN_ID or GetTerrainType(.RightX, .BottomY - TERRAIN_DELTA) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid bottom right result")
				return false
			endif
			
			if GetTerrainType(.LeftX, .BottomY) != CHECK_TERRAIN_ID or GetTerrainType(.LeftX - TERRAIN_DELTA, .BottomY) != BORDER_TERRAIN_ID or GetTerrainType(.LeftX, .BottomY - TERRAIN_DELTA) != BORDER_TERRAIN_ID then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid bottom left result")
				return false
			endif
			
			return true
		endmethod
		
		public method Print takes nothing returns nothing
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Printing unit test: " + I2S(this) + "  --------")
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Raw x, y: " + R2SW(.InputX, 6, 10) + ", " + R2SW(.InputY, 6, 10))
			
			if .ValidateUnitTestInput() then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Top left x, y: " + R2S(.LeftX) + ", " + R2S(.TopY))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Bottom right x, y: " + R2S(.RightX) + ", " + R2S(.BottomY))
				
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "X ranges from: " + R2S(.LeftX) + ", " + R2S(.RightX) + ", (" + R2S(.RightX - .LeftX) + ")")
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Y ranges from: " + R2S(.BottomY) + ", " + R2S(.TopY) + ", (" + R2S(.TopY - .BottomY) + ")")
				
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Estimated center x, y: " + R2S(.RawCenterX) + ", " + R2S(.RawCenterY))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Calculated center x, y: " + R2S(.CalculatedCenterX) + ", " + R2S(.CalculatedCenterY))
								
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "")
				
				if .ValidateUnitTestResult() then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit test results match GetTerrainType for corner edge conditions!")
				endif
			else
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit test initialized in an invalid state")
			endif
			
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "--------------------------------")
		endmethod
		
		private static method CheckDirections takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype ut = GetTimerData(t)
						
			local integer opCount = 10 //approx
			
			loop
			exitwhen GetTerrainType(ut.InputX, ut.BottomY - TERRAIN_DELTA) == BORDER_TERRAIN_ID or opCount >= WC3_OP_LIMIT
				
			set ut.BottomY = ut.BottomY - TERRAIN_DELTA
			set opCount = opCount + LOOP_OP_COUNT
			endloop
			
			loop
			exitwhen GetTerrainType(ut.InputX, ut.TopY + TERRAIN_DELTA) == BORDER_TERRAIN_ID or opCount >= WC3_OP_LIMIT
				
			set ut.TopY = ut.TopY + TERRAIN_DELTA
			set opCount = opCount + LOOP_OP_COUNT
			endloop
			
			loop
			exitwhen GetTerrainType(ut.LeftX - TERRAIN_DELTA, ut.InputY) == BORDER_TERRAIN_ID or opCount >= WC3_OP_LIMIT
				
			set ut.LeftX = ut.LeftX - TERRAIN_DELTA
			set opCount = opCount + LOOP_OP_COUNT
			endloop
			
			loop
			exitwhen GetTerrainType(ut.RightX + TERRAIN_DELTA, ut.InputY) == BORDER_TERRAIN_ID or opCount >= WC3_OP_LIMIT
				
			set ut.RightX = ut.RightX + TERRAIN_DELTA
			set opCount = opCount + LOOP_OP_COUNT
			endloop
						
			if opCount >= WC3_OP_LIMIT then
				call TimerStart(t, .1, false, function thistype.CheckDirections)
			else
				set ut.RawCenterX = (ut.LeftX + ut.RightX) / 2.
				set ut.RawCenterY = (ut.BottomY + ut.TopY) / 2.
				
				if ut.RawCenterX > 0 then
					set ut.CalculatedCenterX = R2I(ut.RawCenterX / 128. + .500) * 128
				else
					set ut.CalculatedCenterX = R2I(ut.RawCenterX / 128. - .500) * 128
				endif
				if ut.RawCenterY > 0 then
					set ut.CalculatedCenterY = R2I(ut.RawCenterY / 128. + .500) * 128
				else
					set ut.CalculatedCenterY = R2I(ut.RawCenterY / 128. - .500) * 128
				endif
				
				call ut.Print()
			endif
		endmethod
		
		public static method create takes real x, real y returns thistype
			local thistype new = thistype.allocate()
			
			set new.InputX = x
			set new.InputY = y
			
			set new.LeftX = x
			set new.RightX = x
			set new.BottomY = y
			set new.TopY = y
			
			call SetTerrainType(x, y, BORDER_TERRAIN_ID, -1, 2, bj_TERRAIN_SHAPE_SQUARE)
			call SetTerrainType(x, y, CHECK_TERRAIN_ID, -1, 1, bj_TERRAIN_SHAPE_SQUARE)
			
			if new.ValidateUnitTestInput() then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit test: " + I2S(new) + " initialized in a valid state")
				call TimerStart(NewTimerEx(new), 0, false, function thistype.CheckDirections)
			endif
			
			return new
		endmethod
	endstruct
endlibrary