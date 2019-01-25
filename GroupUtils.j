library GroupUtils initializer init
    globals
        private constant integer MAX_RECYCLE_COUNT = 100
        private constant integer PRELOAD_COUNT = 5
        private group array recycle
        private integer count
    endglobals
    
	private function initStack takes nothing returns nothing
		set count = 0
        loop
        exitwhen count == PRELOAD_COUNT
            set recycle[count] = CreateGroup()
        set count = count + 1
        endloop
    endfunction
	private function init takes nothing returns nothing
		call initStack()
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
	
	//oddly not a native and the only near equivalent bj, IsUnitGroupEmptyBJ, is wonky
	function IsGroupEmpty takes group g returns boolean
		return FirstOfGroup(g) == null
	endfunction
	//much faster than GroupAddGroup and doesn't have weird extras. leaves mergeGroup equivalent to its original state/order
	function MergeGroups takes group mergeTo, group mergeFrom returns nothing
		local unit u
		local group temp = NewGroup()
		
		loop
		set u = FirstOfGroup(mergeFrom)
		exitwhen u == null
			call GroupAddUnit(mergeTo, u)
		call GroupAddUnit(temp, u)
		call GroupRemoveUnit(mergeFrom, u)
		endloop
		
		//can't release a group and then update its external reference to local group temp
		//call ReleaseGroup(mergeFrom)
		set mergeFrom = temp
		
		set temp = null
		set u = null
	endfunction
	
	//! textmacro MergeGroups takes MERGE_TO, MERGE_FROM, U, G
		set $G$ = NewGroup()
		
		loop
		set $U$ = FirstOfGroup($MERGE_FROM$)
		exitwhen $U$ == null
			call GroupAddUnit($MERGE_TO$, $U$)
		call GroupAddUnit($G$, $U$)
		call GroupRemoveUnit($MERGE_FROM$, $U$)
		endloop
		
		call ReleaseGroup($MERGE_FROM$)
		set $MERGE_FROM$ = $G$
		
		set $G$ = null
		set $U$ = null
	//! endtextmacro
endlibrary