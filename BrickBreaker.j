library BrickBreaker requires Recycle
	globals
		real BRICK_WIDTH = 200.
		real BRICK_HALF_WIDTH = BRICK_WIDTH / 2.
		real BRICK_HEIGHT = 32.
		
		real BRICK_BUFFER = 16.
		real BRICK_HALF_BUFFER = BRICK_BUFFER / 2.
		
		real PADDLE_WIDTH = 420.
		real PADDLE_HEIGHT = 72.
	endglobals
	
	struct BrickBreaker extends array
	
	endstruct
	
	function MakeBricks takes real x, real y, integer rowCount, integer columnCount, integer expectedGoldCount returns nothing
		local integer iRow = 0
		local boolean iRowEven
		local integer iColumn
		
		local integer rowGoldCount = 0
		
		local integer brickID
				
		loop
		exitwhen iRow == rowCount
			if rowCount > 2 then
				if iRow == 0 or iRow == rowCount - 1 then
					set rowGoldCount = expectedGoldCount
				else
					set rowGoldCount = 0
				endif
			else
				if iRow == 0 then
					set rowGoldCount = 0
				else
					set rowGoldCount = expectedGoldCount
				endif
			endif
			
			if (iRow / 2) - (iRow / 2.) == 0 then
				set iRowEven = true
			else
				set iRowEven = false
			endif
			
			set iColumn = 0
			loop
			if iRowEven then
			exitwhen iColumn == columnCount
			else
			exitwhen iColumn == columnCount - 1
			endif
			
				if rowGoldCount < expectedGoldCount then
					if iColumn != 0 and iColumn != columnCount - 1 and GetRandomInt(0, 2) == 0 then
						set brickID = GOLD_BRICK
						
						set rowGoldCount = rowGoldCount + 1
					else
						set brickID = BRICK
					endif
				else
					set brickID = BRICK
				endif
				
				if iRowEven then
					call Recycle_MakeUnit(brickID, x + iColumn * (BRICK_WIDTH + BRICK_BUFFER), y - iRow * (BRICK_HEIGHT + BRICK_BUFFER))
				else
					call Recycle_MakeUnit(brickID, x + BRICK_HALF_WIDTH + BRICK_HALF_BUFFER + iColumn * (BRICK_WIDTH + BRICK_BUFFER), y - iRow * (BRICK_HEIGHT + BRICK_BUFFER))
				endif
				
			set iColumn = iColumn + 1
			endloop
			
		set iRow = iRow + 1
		endloop
	endfunction
	
	function BrickBreakStart takes nothing returns nothing
		call MakeBricks(GetRectCenterX(gg_rct_BB_Bricks1), GetRectCenterY(gg_rct_BB_Bricks1), 5, 7, 2)
	endfunction
	function BrickBreakStop takes nothing returns nothing
	
	endfunction
endlibrary