library GroupUtils initializer init
    globals
        private constant integer MAX_RECYCLE_COUNT = 100
        private constant integer PRELOAD_COUNT = 5
        private group array recycle
        private integer count
    endglobals
    
	function IsGroupEmpty takes group g returns boolean
		return FirstOfGroup(g) == null
	endfunction
	
	private function initStack takes nothing returns nothing
		set count = 0
        loop
        exitwhen count == PRELOAD_COUNT
            set recycle[count] = CreateGroup()
        set count = count + 1
        endloop
    endfunction
	
    function NewGroup takes nothing returns group
		if count == 0 then
			call initStack()
        endif
		
		set count = count - 1
		return recycle[count]
    endfunction
    	
    function ReleaseGroup takes group g returns nothing
        call GroupClear(g)
		
		if count == MAX_RECYCLE_COUNT then
			call DestroyGroup(g)
		else
			set recycle[count] = g
			set count = count + 1
		endif
    endfunction
	
	private function init takes nothing returns nothing
		call initStack()
	endfunction
endlibrary