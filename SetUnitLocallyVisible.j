library SetUnitLocallyVisible
	function SetUnitLocallyVisible takes unit u, integer playerID, boolean visible returns nothing
		if GetLocalPlayer() == Player(playerID) then
			if visible then
				call SetUnitVertexColor(u, 255, 255, 255, 255)
			else	
				call SetUnitVertexColor(u, 255, 255, 255, 0)
			endif
		endif
	endfunction
endlibrary