library PW3 requires Recycle, DrunkWalker, SimpleList, IStartable
    
globals
endglobals

function PW3TeamStart takes nothing returns nothing
    //local Teams_MazingTeam mt = Levels_Level.CBTeam
    
    //call mt.SetPlatformerProfile(PlatformerProfile_CrazyIceProfileID)
endfunction

function PW3TeamStop takes nothing returns nothing
    //local Teams_MazingTeam mt = Levels_Level.CBTeam
    
    //call mt.SetPlatformerProfile(PlatformerProfile_DefaultProfileID)
endfunction

function PW3Start takes nothing returns nothing
    call Recycle_MakeUnitAndPatrol(BOUNCER, 1472, -7168, 1792, -7168)
    
    //call Recycle_MakeUnitAndPatrol(BOUNCER, 1536, -7040, 2048, -7040)
    //call Recycle_MakeUnitAndPatrol(BOUNCER, 2048, -7040, 1536, -7040)
    call Recycle_MakeUnitAndPatrol(BOUNCER, 1536, -6912, 2048, -6912)

    call Recycle_MakeUnitAndPatrol(GRAVITY, 2304, -9592, 2564, -9592)

    call Recycle_MakeUnitAndPatrol(BOUNCER, 2654, -4864, 2816, -4728)
endfunction

function PW3Stop takes nothing returns nothing

endfunction

endlibrary