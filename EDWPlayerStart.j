library EDWPlayerStart requires ConfigurationMode, Levels
	function GetFirstLevel takes nothing returns Levels_Level
        if DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
            //3 == first ice level
            //24/31 == last ice levels
            //9 == first platforming level
            
            //66 == debug platform testing
            return Levels_Level(1)
        else
            return Levels_Level(1)
        endif
    endfunction
	function GetFirstCheckpoint takes nothing returns integer
		if DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
            return 0
        else
            return 0
        endif
	endfunction
endlibrary