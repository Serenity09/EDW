library GroupUtils initializer init requires Table
    globals
        private constant integer MAX_RECYCLE_COUNT = 100
        private constant integer PRELOAD_COUNT = 10
        private group array recycle
        private integer count
    endglobals
        
    function NewGroup takes nothing returns group
        if count == 0 then
            return CreateGroup()
        else
            set count = count - 1
            return recycle[count]
        endif
    endfunction
    	
    function ReleaseGroup takes group g returns nothing
        call GroupClear(g)
        set recycle[count] = g
        set count = count + 1
    endfunction
    
    private function init takes nothing returns nothing
        set count = 0
        loop
        exitwhen count == PRELOAD_COUNT
            set recycle[count] = CreateGroup()
        set count = count + 1
        endloop
    endfunction
endlibrary