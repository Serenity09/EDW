library PW2 requires Recycle, DrunkWalker, SimpleList, IStartable
    
globals
endglobals

function PW2Start takes nothing returns nothing
    call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_357, gg_rct_Rect_360)
    call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_358, gg_rct_Rect_359)
endfunction

function PW2Stop takes nothing returns nothing
endfunction
endlibrary