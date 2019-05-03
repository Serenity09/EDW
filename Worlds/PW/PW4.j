library PW4 requires Recycle, Levels
	function PW4TeamStart takes nothing returns nothing
		local Teams_MazingTeam mt = Levels_Level.CBTeam
		
		call mt.SetPlatformerProfile(PlatformerProfile_MoonProfileID)
	endfunction

	function PW4TeamStop takes nothing returns nothing
		local Teams_MazingTeam mt = Levels_Level.CBTeam
		
		call mt.SetPlatformerProfile(PlatformerProfile_DefaultProfileID)
	endfunction

	function PW4Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(PW4_LEVEL_ID)
		
		
	endfunction

	function PW4Stop takes nothing returns nothing

	endfunction
endlibrary