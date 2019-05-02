library PW4 requires Recycle, DrunkWalker, SimpleList, IStartable
    
globals
endglobals

function PW4TeamStart takes nothing returns nothing
    local Teams_MazingTeam mt = Levels_Level.CBTeam
    
    call mt.SetPlatformerProfile(PlatformerProfile_MoonProfileID)
endfunction

function PW4TeamStop takes nothing returns nothing
    local Teams_MazingTeam mt = Levels_Level.CBTeam
    
    call mt.SetPlatformerProfile(PlatformerProfile_DefaultProfileID)
endfunction

function PW4Start takes nothing returns nothing

endfunction

function PW4Stop takes nothing returns nothing

endfunction

endlibrary