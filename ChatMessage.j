library GameMessage
	globals
        constant string SPEAKER_COLOR = "FFFFBD33"
        constant string DEFAULT_TEXT_COLOR = null
        constant string HAPPY_TEXT_COLOR = null
        constant string SAD_TEXT_COLOR = null
        constant string ANGRY_TEXT_COLOR = null
        constant string STERN_TEXT_COLOR = null
        
        constant string PRIMARY_SPEAKER_NAME = "SARGE"
        constant string SECONDARY_SPEAKER_NAME = "Cupcake"
        
        constant string FINAL_BOSS_PRE_REVEAL = "???"
        constant string FINAL_BOSS_NAME = "???" //??? no, seriously, what's the final boss?
        
        constant real DEFAULT_TINY_TEXT_SPEED = 1.0
        constant real DEFAULT_SHORT_TEXT_SPEED = 3.0
        constant real DEFAULT_MEDIUM_TEXT_SPEED = 5.0
        constant real DEFAULT_LONG_TEXT_SPEED = 8.0
    endglobals
	
	function GetEDWSpeakerMessage takes string speaker, string message, string messageColor returns string
        if messageColor == null then
            return "|c" + SPEAKER_COLOR + speaker + "|r" + ": " + message
        else
            return "|c" + SPEAKER_COLOR + speaker + "|r" + ": " + "|c" + messageColor + message + "|r"
        endif
    endfunction
endlibrary