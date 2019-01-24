library PlayerUtils requires SimpleList, GameGlobalConstants
//===========================================================================
// "PlayerUtils" by Alain.Mark
//
// -Info-
//  -The main purpose of this lib is to get rid of using the Player(...) function
//  and replace it with a faster array search instead. (also w/ added utilities)
//
// -API-
//  -function GetPlayerById takes integer id returns nothing
//  -function GetPlayersCount takes nothing returns integer
//  -function GetHumanPlayersCount takes nothing returns integer
//  -function GetComputerPlayersCount takes nothing returns integer
//
//===========================================================================

    //=======================================================================
        
    //=======================================================================
        globals
            private constant trigger LEAVER_SENTINEL = CreateTrigger()
            
            private player array IndexedPlayers
            private integer      ACTIVE_PLAYERS_COUNT          = 0
            private integer      ACTIVE_HUMAN_PLAYERS_COUNT    = 0
            private integer      ACTIVE_COMPUTER_PLAYERS_COUNT = 0
            
            //only really need the first player, will always iterate from there
            private SimpleList_List PlayerList                 = 0
            public SimpleList_ListNode FirstPlayer             = 0
        endglobals
        
    //=======================================================================
        function GetPlayerById takes integer id returns player
            return IndexedPlayers[id]
        endfunction
        
    //=======================================================================
        function GetPlayersCount takes nothing returns integer
            return ACTIVE_PLAYERS_COUNT
        endfunction
        
    //=======================================================================
        function GetHumanPlayersCount takes nothing returns integer
            return ACTIVE_HUMAN_PLAYERS_COUNT
        endfunction
        
    //=======================================================================
        function GetComputerPlayersCount takes nothing returns integer
            return ACTIVE_COMPUTER_PLAYERS_COUNT
        endfunction
        
    //=======================================================================
        private function DetectLeavers takes nothing returns nothing
            local integer pID = GetPlayerId(GetTriggerPlayer())
            
            set ACTIVE_PLAYERS_COUNT=ACTIVE_PLAYERS_COUNT-1
            set ACTIVE_HUMAN_PLAYERS_COUNT=ACTIVE_HUMAN_PLAYERS_COUNT-1
            
            call PlayerList.remove(pID)
        endfunction
        
    //=======================================================================
        public function Init takes nothing returns nothing
            local player  pl
            local integer n = 0
            
            set PlayerList = SimpleList_List.create()
            
            loop
                exitwhen n > NumberPlayers
                set pl=Player(n)
                if GetPlayerSlotState(pl)==PLAYER_SLOT_STATE_PLAYING then
                    if GetPlayerController(pl)==MAP_CONTROL_USER then
                        set ACTIVE_HUMAN_PLAYERS_COUNT=ACTIVE_HUMAN_PLAYERS_COUNT+1
                        call TriggerRegisterPlayerEvent(LEAVER_SENTINEL,pl,EVENT_PLAYER_LEAVE)
                        call PlayerList.addEnd(n)
                    endif
                    set IndexedPlayers[n]=pl
                    set ACTIVE_PLAYERS_COUNT=ACTIVE_PLAYERS_COUNT+1
                endif
                set n=n+1
            endloop
            
            set FirstPlayer = PlayerList.first
            set ACTIVE_COMPUTER_PLAYERS_COUNT=ACTIVE_PLAYERS_COUNT-ACTIVE_HUMAN_PLAYERS_COUNT
            
            call TriggerAddCondition(LEAVER_SENTINEL,Filter(function DetectLeavers))
        endfunction
        
//===========================================================================
endlibrary
