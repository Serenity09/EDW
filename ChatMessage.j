library GameMessage
	globals
        constant string SPEAKER_COLOR = "FFBD33"
        constant string DEFAULT_TEXT_COLOR = "fcf0e5"
		constant string STERN_TEXT_COLOR = "4f4f4f"
        constant string HAPPY_TEXT_COLOR = "dcefd5"
        constant string SAD_TEXT_COLOR = "c1c9ff"
        constant string ANGRY_TEXT_COLOR = "772929"
		
		constant string INTRO_TEXT_COLOR = HAPPY_TEXT_COLOR
		constant string DOORS_TEXT_COLOR = HAPPY_TEXT_COLOR
		constant string EASY_ICE_WORLD_COLOR = "a7abf2"
		constant string HARD_ICE_WORLD_COLOR = "bdd3f0"
		constant string PLATFORMING_WORLD_COLOR = "f7870f"
		constant string FOUR_SEASONS_WORLD_COLOR = HAPPY_TEXT_COLOR
		constant string LAND_WORLD_COLOR = "67e676"
		
		constant string TOGGLE_ON_COLOR = "5cb85c"
		constant string TOGGLE_OFF_COLOR = "d9534f"
		
		constant string DISABLED_COLOR = "bbbbbb"
        
        constant string PRIMARY_SPEAKER_NAME = "SARGE"
        constant string SECONDARY_SPEAKER_NAME = "Cupcake"
        
        constant string FINAL_BOSS_PRE_REVEAL = "???"
        constant string FINAL_BOSS_NAME = "???" //??? no, seriously, what's the final boss?
        
        constant real DEFAULT_TINY_TEXT_SPEED = 1.0
        constant real DEFAULT_SHORT_TEXT_SPEED = 3.0
        constant real DEFAULT_MEDIUM_TEXT_SPEED = 5.0
        constant real DEFAULT_LONG_TEXT_SPEED = 8.0
    endglobals
	
	function ColorMessage takes string message, string hexColor returns string
		return "|cFF" + hexColor + message + "|r"
	endfunction
	function ColorValue takes string value returns string
		return ColorMessage(value, SPEAKER_COLOR)
	endfunction
	
	function GetEDWSpeakerMessage takes string speaker, string message, string messageColor returns string
        if messageColor == null then
            return "|cFF" + SPEAKER_COLOR + speaker + "|r" + ": " + message
        else
            return "|cFF" + SPEAKER_COLOR + speaker + "|r" + ": " + "|cFF" + messageColor + message + "|r"
        endif
    endfunction
endlibrary