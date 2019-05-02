library IW2 requires easyPatrols, DrunkWalker, SimpleList, IStartable

function IW2Start takes nothing returns nothing    
    //patrols
    //P1
    call CreateAndPatrolRandomRect(gg_rct_Rect_071, gg_rct_Rect_072, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_073, gg_rct_Rect_074, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_075, gg_rct_Rect_076, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_077, gg_rct_Rect_078, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_079, gg_rct_Rect_080, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_081, gg_rct_Rect_082, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_083, gg_rct_Rect_084, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_085, gg_rct_Rect_086, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_087, gg_rct_Rect_088, LGUARD, Player(10))
    
    //P3
    call CreateAndPatrolCenterRect(gg_rct_Rect_095, gg_rct_Rect_096, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_097, gg_rct_Rect_098, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_099, gg_rct_Rect_100, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_101, gg_rct_Rect_102, GUARD, Player(10))
    //call CreateAndPatrolCenterRect(gg_rct_Rect_103, gg_rct_Rect_104, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_105, gg_rct_Rect_106, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_107, gg_rct_Rect_108, LGUARD, Player(10))
        
    //turn on periodic functions
endfunction

function IW2Stop takes nothing returns nothing

endfunction
endlibrary