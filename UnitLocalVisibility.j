//shows/hides a unit's model for the specified player only via VertexColor. works separately from native ShowUnit/HideUnit. does NOT hide particle effects
//the unit can still be selected by players it has been locally hidden for. you can permanently give the unit the locust ability (outside of a local block) to prevent any selection
library UnitLocalVisibility requires IndexedUnit
	function SetUnitLocalOpacity takes unit u, integer playerID, integer opacity returns nothing
		local IndexedUnit uInfo = GetUnitUserData(u)
		
		if GetLocalPlayer() == Player(playerID) then
			if uInfo != 0 and uInfo.R != -1 then
				call uInfo.SetAlphaLocal(opacity)
			else
				call SetUnitVertexColor(u, 255, 255, 255, opacity)
			endif
		endif
	endfunction
	function SetUnitLocalVisibility takes unit u, integer playerID, boolean visible returns nothing
		local IndexedUnit uInfo = GetUnitUserData(u)
		
		if GetLocalPlayer() == Player(playerID) then
			if uInfo != 0 and uInfo.R != -1 then
				if visible then
					call uInfo.SetAlphaLocal(255)
				else
					call uInfo.SetAlphaLocal(0)
				endif
			else
				if visible then
					call SetUnitVertexColor(u, 255, 255, 255, 255)
				else	
					call SetUnitVertexColor(u, 255, 255, 255, 0)
				endif
			endif
		endif
	endfunction
endlibrary