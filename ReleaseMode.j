library ConfigurationMode requires GameModesGlobals
	globals
		constant integer DEV = 0
		constant integer TEST = 1
		constant integer RELEASE = 2
		
		constant integer CONFIGURATION_PROFILE = 0
		
		//the below globals are only relevant when CONFIGURATION_PROFILE != RELEASE
		constant boolean FORCE_SETTING_MENU = false //when true, the initial visual vote menu will always be visible, even when CONFIGURATION_PROFILE != RELEASE
		
		constant integer DEBUG_DIFFICULTY_MODE = GameModesGlobals_HARD //the difficulty mode will automatically be set to this value (only when CONFIGURATION_PROFILE != RELEASE)
		constant integer DEBUG_TEAM_MODE = GameModesGlobals_SOLO	//the team mode will automatically be set to this value (only when CONFIGURATION_PROFILE != RELEASE)
		constant boolean DEBUG_USE_FULL_VISIBILITY = true	//the entire maps visibility will be enabled or disabled depending on this value (only when CONFIGURATION_PROFILE != RELEASE)
	endglobals
	
	function GetFirstLevelID takes nothing returns Levels_Level
        if DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
            //3 == first ice level
            //24/31 == last ice levels
            //9 == first platforming level
            
            //66 == debug platform testing
            return 1
        else
            return 1
        endif
    endfunction
	function GetFirstCheckpoint takes nothing returns integer
		if DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
            return 0
        else
            return 0
        endif
	endfunction
	
	function ShouldShowSettingVoteMenu takes nothing returns boolean
		return CONFIGURATION_PROFILE == RELEASE or FORCE_SETTING_MENU
	endfunction
endlibrary