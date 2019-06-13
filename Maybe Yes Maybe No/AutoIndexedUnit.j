library AutoIndexedUnit requires IndexedUnit initializer init
	globals
		private boolean INDEX_ON_LOAD = false
	endglobals
	
	private function init takes nothing returns nothing
		static if INDEX_ON_LOAD then
			local group g = CreateGroup()
			local unit u
			
			call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null)
			
			loop
			set u = FirstOfGroup(g)
			exitwhen u == null
				call IndexedUnit.create(u)
			call GroupRemoveUnit(g, u)
			endloop
			
			call DestroyGroup(g)
			set g = null
		endif
	endfunction
endlibrary