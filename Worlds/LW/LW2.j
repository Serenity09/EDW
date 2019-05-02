function LW2Start takes nothing returns nothing
    //patrols
    //P1
    //call CreateAndPatrolRandomRect(gg_rct_Rect_209, gg_rct_Rect_210, LGUARD, Player(10))
    //call CreateAndPatrolCenterRect(gg_rct_Rect_212, gg_rct_Rect_211, LGUARD, Player(10))
    
    
    //create single units
    call CreateUnitCenterRect(GUARD, Player(10), gg_rct_Rect_018)
    call CreateUnitCenterRect(GUARD, Player(10), gg_rct_Rect_020)
    call CreateUnitCenterRect(LGUARD, Player(10), gg_rct_Rect_023)

    //create regular mortars
    
    //unpause MnT's
    
    //unpause wisp wheels
    
    //turn on periodic functions
    
endfunction

function LW2Stop takes nothing returns nothing

endfunction