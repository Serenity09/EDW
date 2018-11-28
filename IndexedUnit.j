library IndexedUnit initializer Init
    globals
        private integer AutoID
        
        private unit array IndexedUnits
        
        private integer array RecycledIDs
        private integer RecycledCount
    endglobals
    
    static if DEBUG_MODE then
        public function GetAutoId takes nothing returns integer
            return AutoID
        endfunction
        
        public function GetRecycleCount takes nothing returns integer
            return RecycledCount
        endfunction
    endif
    
    function GetUnitId takes unit u returns integer
        return GetUnitUserData(u)
    endfunction
    
    function GetUnitFromId takes integer id returns unit
        return IndexedUnits[id]
    endfunction
    
    function DeindexUnit takes unit u returns nothing
        local integer id = GetUnitUserData(u)
                
        if id != 0 then
            set RecycledIDs[RecycledCount] = id
            set RecycledCount = RecycledCount + 1
            
            set IndexedUnits[id] = null
            call SetUnitUserData(u, 0)
        endif
    endfunction
    
    function IndexUnit takes unit u returns integer
        local integer id
        
        if GetUnitUserData(u) != 0 then
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Indexing unit that has user data!")
            return GetUnitUserData(u)
        endif
        
        if RecycledCount == 0 then
            set id = AutoID
            set AutoID = AutoID + 1
        else
            set id = RecycledIDs[RecycledCount - 1]
            set RecycledCount = RecycledCount - 1
        endif
        
        set IndexedUnits[id] = u
        call SetUnitUserData(u, id)
                
        return id
    endfunction
    
    private function Init takes nothing returns nothing
        //ID = 0 represents null, so AutoID should start from 1
        set AutoID = 1
        
        set RecycledCount = 0
    endfunction
endlibrary