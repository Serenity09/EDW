//shows/hides a unit's model for the specified player only via VertexColor. works separately from native ShowUnit/HideUnit. does NOT hide particle effects
//the unit can still be selected by players it has been locally hidden for. you can permanently give the unit the locust ability (outside of a local block) to prevent any selection
library UnitLocalVisibility
	function SetUnitLocalOpacity takes unit u, integer playerID, integer opacity returns nothing
		if GetLocalPlayer() == Player(playerID) then
			call SetUnitVertexColor(u, 255, 255, 255, opacity)
		endif
	endfunction
	function SetUnitLocalVisibility takes unit u, integer playerID, boolean visible returns nothing
		if GetLocalPlayer() == Player(playerID) then
			if visible then
				call SetUnitVertexColor(u, 255, 255, 255, 255)
			else	
				call SetUnitVertexColor(u, 255, 255, 255, 0)
			endif
		endif
	endfunction
endlibrary