library GroupUtils initializer init requires Table
    globals
        private constant integer MAX_RECYCLE_COUNT = 10
        private constant integer PRELOAD_COUNT = 5
        private group array recycle
        private integer count
		
		private Table ht
    endglobals
    
	function SetGroupData takes group g, integer data returns nothing
        set ht[GetHandleId(g)] = data
    endfunction
	function GetGroupData takes group g returns integer
		return ht[GetHandleId(g)]
	endfunction
	
	private function init takes nothing returns nothing
        set count = 0
        loop
        exitwhen count == PRELOAD_COUNT
            set recycle[count] = CreateGroup()
			call SetGroupData(recycle[count], 0)
        set count = count + 1
        endloop
		
		set ht = Table.create()
    endfunction
	
    function NewGroup takes nothing returns group
		if count == 0 then
			call init()
        endif
		
		set count = count - 1
		return recycle[count]
    endfunction
	function NewGroupEx takes integer data returns group
		if count == 0 then
			call init()
        endif
		
		set count = count - 1
		call SetGroupData(recycle[count], data)
		return recycle[count]
	endfunction
    	
    function ReleaseGroup takes group g returns nothing
        call GroupClear(g)
		call SetGroupData(g, 0)
        set recycle[count] = g
        set count = count + 1
    endfunction
endlibrary