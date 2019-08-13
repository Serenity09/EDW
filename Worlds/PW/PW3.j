library PW3 requires Recycle, Levels
	function PW3TeamStart takes nothing returns nothing
		//local Teams_MazingTeam mt = Levels_Level.CBTeam
		
		//call mt.SetPlatformerProfile(PlatformerProfile_CrazyIceProfileID)
	endfunction

	function PW3TeamStop takes nothing returns nothing
		//local Teams_MazingTeam mt = Levels_Level.CBTeam
		
		//call mt.SetPlatformerProfile(PlatformerProfile_DefaultProfileID)
	endfunction

	function PW3Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(PW3_LEVEL_ID)
		
	endfunction

	function PW3Stop takes nothing returns nothing

	endfunction
endlibrary