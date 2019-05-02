library IW5 requires easyPatrols, DrunkWalker

function IW5Start takes nothing returns nothing
    call CreateAndPatrolCenterReal(2432, 7043, 3072, 6915, LGUARD)
    call CreateAndPatrolCenterReal(2179, 6651, 2818, 6528, LGUARD)
endfunction

function IW5Stop takes nothing returns nothing
endfunction
endlibrary