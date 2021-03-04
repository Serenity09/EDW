library ConfigurationMode requires GameModesGlobals
	globals
		constant integer DEV = 0
		constant integer TEST = 1
		constant integer RELEASE = 2
		
		constant integer CONFIGURATION_PROFILE = RELEASE
		
		//the below globals are only relevant when CONFIGURATION_PROFILE != RELEASE
		constant boolean FORCE_SETTING_MENU = false //when true, the initial visual vote menu will be visible, even when CONFIGURATION_PROFILE != RELEASE, unless FORCE_SETTING_MENU_SKIP is true
		constant boolean FORCE_INTRO_REVEAL = true

		constant integer DEBUG_DIFFICULTY_MODE = GameModesGlobals_EASY //the difficulty mode will automatically be set to this value (only when CONFIGURATION_PROFILE != RELEASE)
		constant integer DEBUG_TEAM_MODE = GameModesGlobals_TEAMALL 	//the team mode will automatically be set to this value (only when CONFIGURATION_PROFILE != RELEASE)
		constant boolean DEBUG_USE_FULL_VISIBILITY = false	//the entire maps visibility will be enabled or disabled depending on this value (only when CONFIGURATION_PROFILE != RELEASE)
	endglobals
endlibrary

library ConfigurationBehaviors requires GameModesGlobals, ConfigurationMode, PlayerUtils
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
            return 2
        else
            return 0
        endif
	endfunction
	
	function ShouldShowSettingVoteMenu takes nothing returns boolean
		return /* CONFIGURATION_PROFILE == RELEASE or */ FORCE_SETTING_MENU or (GetPlayersCount() == 1 and CONFIGURATION_PROFILE == RELEASE)
	endfunction
	function ShouldUse99Continues takes nothing returns boolean
		return CONFIGURATION_PROFILE == DEV or RewardMode == GameModesGlobals_CHEAT
	endfunction
endlibrary