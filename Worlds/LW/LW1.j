function LW1Start takes nothing returns nothing
    //patrols
    //P1
    call CreateAndPatrolRandomRect(gg_rct_Rect_209, gg_rct_Rect_210, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_212, gg_rct_Rect_211, LGUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_213, gg_rct_Rect_214, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_216, gg_rct_Rect_215, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_217, gg_rct_Rect_218, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_219, gg_rct_Rect_220, GUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_221, gg_rct_Rect_222, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_224, gg_rct_Rect_223, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_225, gg_rct_Rect_226, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_228, gg_rct_Rect_227, GUARD, Player(10))
    
    //call CreateMortarCenterRect(SMLMORT, Player(10), gg_rct_Rect_247, gg_rct_Rect_246)
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_237, gg_rct_Rect_238, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_239, gg_rct_Rect_240, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_241, gg_rct_Rect_242, GUARD, Player(10))
    
    
    //create single units
    
    //create regular mortars
    
    //unpause MnT's
    
    //unpause wisp wheels
    
    //turn on periodic functions
    //call EnableTrigger(gg_trg_LW1_MassCreate)
endfunction

function LW1Stop takes nothing returns nothing
	//call DisableTrigger(gg_trg_LW1_MassCreate)
endfunction