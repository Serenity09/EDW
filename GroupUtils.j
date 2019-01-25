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
        static if DEBUG_MODE then
			if g==null then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "WARNING: Releasing null group!! All your problems start here!")
				return
			endif
		endif
		
		call GroupClear(g)
		/*
		loop
		exitwhen FirstOfGroup(g) == null
		call GroupRemoveUnit(g, FirstOfGroup(g))
		endloop
		*/
		
		if count == MAX_RECYCLE_COUNT then
			call DestroyGroup(g)
		else
			set recycle[count] = g
			set count = count + 1
		endif
    endfunction
	
	//breaks horribly
	/*
	function CountGroup takes group g returns integer
		local integer count
		local unit u
		local group temp = NewGroup()
		
		set count = 0
		
		loop
		set u = FirstOfGroup(g)
		exitwhen u == null
			set count = count + 1
		call GroupAddUnit(temp, u)
		call GroupRemoveUnit(g, u)
		endloop
		
		call ReleaseGroup(g)
		set g = temp
				
		return count
	endfunction
	*/
	//! textmacro CountGroup takes GROUP, U, COUNT, TEMP_GROUP
		set $TEMP_GROUP$ = NewGroup()
		set $COUNT$ = 0
		
		loop
		set $U$ = FirstOfGroup($GROUP$)
		exitwhen $U$ == null
			set $COUNT$ = $COUNT$ + 1
		call GroupAddUnit($TEMP_GROUP$, $U$)
		call GroupRemoveUnit($GROUP$, $U$)
		endloop
		
		call ReleaseGroup($GROUP$)
		set $GROUP$ = $TEMP_GROUP$
	//! endtextmacro
	
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
	
	//! textmacro MergeGroups takes MERGE_TO, MERGE_FROM, U, TEMP_GROUP
		set $TEMP_GROUP$ = NewGroup()
		
		loop
		set $U$ = FirstOfGroup($MERGE_FROM$)
		exitwhen $U$ == null
			call GroupAddUnit($MERGE_TO$, $U$)
		call GroupAddUnit($TEMP_GROUP$, $U$)
		call GroupRemoveUnit($MERGE_FROM$, $U$)
		endloop
		
		call ReleaseGroup($MERGE_FROM$)
		set $MERGE_FROM$ = $TEMP_GROUP$
	//! endtextmacro
endlibrary