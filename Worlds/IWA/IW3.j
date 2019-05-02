library IW3 requires easyPatrols, DrunkWalker, SimpleList, IStartable

function IW3Start takes nothing returns nothing
    //patrols
    call CreateAndPatrolRandomRect(gg_rct_Rect_124, gg_rct_Rect_125, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_126, gg_rct_Rect_127, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_128, gg_rct_Rect_129, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_130, gg_rct_Rect_131, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_132, gg_rct_Rect_133, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_135, gg_rct_Rect_134, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_136, gg_rct_Rect_137, LGUARD, Player(10))
    
    //P2
    call CreateAndPatrolCenterRect(gg_rct_Rect_138, gg_rct_Rect_139, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_140, gg_rct_Rect_141, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_142, gg_rct_Rect_143, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_144, gg_rct_Rect_145, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_146, gg_rct_Rect_147, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_148, gg_rct_Rect_149, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_150, gg_rct_Rect_151, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_152, gg_rct_Rect_153, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_154, gg_rct_Rect_155, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_156, gg_rct_Rect_157, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_158, gg_rct_Rect_159, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_160, gg_rct_Rect_161, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_162, gg_rct_Rect_163, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_164, gg_rct_Rect_165, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_166, gg_rct_Rect_167, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_168, gg_rct_Rect_169, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_170, gg_rct_Rect_171, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_172, gg_rct_Rect_173, GUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_174, gg_rct_Rect_175, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_176, gg_rct_Rect_177, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_178, gg_rct_Rect_179, GUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_180, gg_rct_Rect_181, GUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_182, gg_rct_Rect_183, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_184, gg_rct_Rect_185, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_186, gg_rct_Rect_187, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_188, gg_rct_Rect_189, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_190, gg_rct_Rect_191, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_192, gg_rct_Rect_193, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_194, gg_rct_Rect_195, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_196, gg_rct_Rect_197, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_198, gg_rct_Rect_199, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_200, gg_rct_Rect_201, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_207, gg_rct_Rect_208, LGUARD, Player(10))
    
    call CreateAndPatrolCenterRect(gg_rct_Rect_202, gg_rct_Rect_203, LGUARD, Player(10))
    call CreateAndPatrolCenterRect(gg_rct_Rect_204, gg_rct_Rect_205, LGUARD, Player(10))
    call CreateAndPatrolRandomRect(gg_rct_Rect_280, gg_rct_Rect_281, LGUARD, Player(10))    
endfunction

function IW3Stop takes nothing returns nothing
endfunction
endlibrary