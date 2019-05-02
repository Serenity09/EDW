library IntroWorld requires easyPatrols, DrunkWalker, SimpleList, IStartable
function IntroWorldLevelStart takes nothing returns nothing
    //patrols
    call CreateAndPatrolCenterRect(gg_rct_Rect_012, gg_rct_Rect_013, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Region_332, gg_rct_Region_331, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_014, gg_rct_Rect_015, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_016, gg_rct_Rect_017, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_049, gg_rct_Rect_050, LGUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_027, gg_rct_Rect_028, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_029, gg_rct_Rect_030, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_031, gg_rct_Rect_032, LGUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_041, gg_rct_Rect_042, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_040, gg_rct_Rect_043, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_039, gg_rct_Rect_044, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_038, gg_rct_Rect_045, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_037, gg_rct_Rect_046, GUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_275, gg_rct_Rect_276, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_277, gg_rct_Rect_278, ICETROLL, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_271, gg_rct_Rect_272, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_273, gg_rct_Rect_274, LGUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_047, gg_rct_Rect_048, LGUARD, Player(10))
    
    //create single units
    
        
    //create regular mortars
    //call CreateMortarCenterRect(SMLMORT, Player(10), gg_rct_Rect_053, gg_rct_Rect_054)
    
    //unpause mortars
    call IntroWorld_MnT.Start()
    
    //unpause wisp wheels
    
    //turn on periodic functions
endfunction

function IntroWorldLevelStop takes nothing returns nothing
    //disable periodic functions
    
    //pause mortar n targets
    call IntroWorld_MnT.Stop()
    
    //pause wisp wheels
endfunction

endlibrary