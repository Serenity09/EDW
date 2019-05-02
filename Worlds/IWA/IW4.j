library IW4 requires easyPatrols, DrunkWalker

function IW4Start takes nothing returns nothing   
    call CreateAndPatrolCenterReal(6911, 9602, 7553, 9602, LGUARD)
    call CreateAndPatrolCenterReal(7553, 9472, 6911, 9472, LGUARD)
    call CreateAndPatrolCenterReal(7170, 8961, 7546, 9222, LGUARD)
    
    call CreateAndPatrolCenterReal(5758, 6918, 5758, 6405, GUARD)
endfunction

function IW4Stop takes nothing returns nothing
endfunction
endlibrary