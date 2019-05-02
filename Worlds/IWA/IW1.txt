library IW1 requires easyPatrols, DrunkWalker, SimpleList, IStartable

function IW1Start takes nothing returns nothing    
    //patrols
    call CreateAndPatrolCenterRect(gg_rct_Rect_056, gg_rct_Rect_057, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_058, gg_rct_Rect_059, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_060, gg_rct_Rect_061, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_062, gg_rct_Rect_063, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_064, gg_rct_Rect_065, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_066, gg_rct_Rect_067, LGUARD, Player(10))
endfunction

function IW1Stop takes nothing returns nothing

endfunction
endlibrary