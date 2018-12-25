library GameModesGlobals requires GameGlobalConstants
globals
    public constant integer SOLO = 0
    public constant integer TEAMALL = 1
    public constant integer TEAMRANDOM = 2

    public constant integer EASY = 0
    public constant integer HARD = 1
    public constant integer CHEAT = 2
	
	constant integer VICTORY_SCORE_15 = 0
	constant integer VICTORY_SCORE_25 = 1
	constant integer VICTORY_TIME_20 = 2
	constant integer VICTORY_TIME_30 = 3
	
    integer     GameMode        = SOLO     //0 = solo, 1 = all on 1 team, 2 = random teams
    integer     RewardMode      = EASY     //0 = standard rewards, 1 = challenge, 2 = start with 99
    boolean     MinigamesMode   = false //Whether minigames are enabled
    boolean     RespawnASAPMode = false  //true = respawn ASAP, false = wait for full team's death
    
	integer		VictoryTime		= 45 * 60
	integer		VictoryScore	= 20
endglobals
endlibrary