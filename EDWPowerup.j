library EDWPowerup requires Alloc, MazerGlobals, FilterFuncs, Table, PlayerUtils, DummyCaster
    globals
        constant player POWERUP_PLAYER = Player(9)
        
        
        constant integer POWERUP_MARKER = 'pMRK'
        
        constant integer POWERUP_SOLO_INVULN = 'pSIN'
        private constant real SOLO_INVULN_TIME = 5.0
        
        constant integer POWERUP_TEAM_INVULN = 'pTIN'
        private constant real TEAM_INVULN_TIME = 15.0
        
        constant integer POWERUP_TEAM_ADDCONT = 'pTCT'
        private constant integer TEAM_ADDCONT_COUNT = 2
		
		constant integer POWERUP_TEAM_STEALCONT = 'e00I'
		private constant integer TEAM_STEALCONT_COUNT = 1
		
		constant integer POWERUP_TEAM_ADDSCORE = 'e00P'
		private constant integer TEAM_ADDSCORE_COUNT = 2
		
		constant integer POWERUP_TEAM_STEALSCORE = 'e00T'
		private constant integer TEAM_STEALSCORE_COUNT = 1
    endglobals
    
    struct InWorldPowerup extends array        
        readonly unit Unit
        private SimpleList_List	TeamsUsed //change to be player based and add all players on a team to list if powerup is team oriented
        
        private static Table AllPowerups
        
        implement Alloc
        
        private static method SoloInvulnCB takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local User user = GetTimerData(t)
            
            set MobImmune[user] = false
            
            call ReleaseTimer(t)
            set t = null
        endmethod
        
        private static method TeamInvulnCB takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local Teams_MazingTeam team = GetTimerData(t)
            local SimpleList_ListNode cur = team.FirstUser
            
            loop
            exitwhen cur == 0
                set MobImmune[cur.value] = false
            set cur = cur.next
            endloop
            
            call ReleaseTimer(t)
            set t = null
        endmethod
        
		private static method LocalizeTeamInvulnerability takes User origin, User localizer returns string
			// return origin.GetLocalizedPlayerName(localizer) + " " + LocalizeContent('', localizer.LanguageCode)
			return StringFormat1(LocalizeContent('PUTI', localizer.LanguageCode), origin.GetLocalizedPlayerName(localizer))
		endmethod
		
		private static method LocalizeContinueGain takes User origin, User localizer returns string
			// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDCONT_COUNT) + " points")
			return StringFormat2(LocalizeContent('PUGC', localizer.LanguageCode), origin.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_ADDCONT_COUNT)))
		endmethod
		private static method LocalizeContinueStolen takes User origin, User localizer returns string
			//call team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALCONT_COUNT) + " point from your team!")
			return StringFormat2(LocalizeContent('PUsC', localizer.LanguageCode), origin.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_STEALCONT_COUNT)))
		endmethod
		private static method LocalizeContinueStolenFrom takes Teams_MazingTeam origin, User localizer returns string
			//call user.Team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALCONT_COUNT) + " point from team " + team.TeamName + "!")
			return StringFormat3(LocalizeContent('PUSC', localizer.LanguageCode), origin.LastEventUser.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_STEALCONT_COUNT)), origin.GetLocalizedTeamName(localizer))
		endmethod
		
		private static method LocalizeScoreGain takes User origin, User localizer returns string
			// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDSCORE_COUNT) + " points")
			return StringFormat2(LocalizeContent('PUGP', localizer.LanguageCode), origin.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_ADDSCORE_COUNT)))
		endmethod
		private static method LocalizeScoreStolen takes User origin, User localizer returns string
			//call team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALSCORE_COUNT) + " point from your team!")
			return StringFormat2(LocalizeContent('PUsP', localizer.LanguageCode), origin.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_STEALSCORE_COUNT)))
		endmethod
		private static method LocalizeScoreStolenFrom takes Teams_MazingTeam origin, User localizer returns string
			//call user.Team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALSCORE_COUNT) + " point from team " + team.TeamName + "!")
			return StringFormat3(LocalizeContent('PUSP', localizer.LanguageCode), origin.LastEventUser.GetLocalizedPlayerName(localizer), ColorValue(I2S(TEAM_STEALSCORE_COUNT)), origin.GetLocalizedTeamName(localizer))
		endmethod
		
        public method OnUserAcquire takes User user returns nothing            
            local SimpleList_ListNode cur
            local Teams_MazingTeam team
			
            if not .TeamsUsed.contains(user.Team) then
                call .TeamsUsed.add(user.Team)
				
				call user.Team.SetUnitLocalOpacityForTeam(.Unit, INACTIVE_UNIT_OPACITY)
            else
                return
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "User " + I2S(user) + " acquired powerup")
            
            if GetUnitTypeId(.Unit) == POWERUP_SOLO_INVULN then
                call DummyCaster['A001'].castTarget(Player(user), 1, OrderId("bloodlust"), user.ActiveUnit)
                
                set MobImmune[user] = true
                
				call user.DisplayLocalizedMessage('PUSI', 0)
                call TimerStart(NewTimerEx(user), SOLO_INVULN_TIME, false, function thistype.SoloInvulnCB)
            elseif GetUnitTypeId(.Unit) == POWERUP_TEAM_INVULN then
                // call user.Team.PrintMessage(user.GetStylizedPlayerName() + " picked up a team invulnerability powerup")
				call user.Team.DisplayDynamicContent(LocalizeTeamInvulnerability, user)
                
                set cur = user.Team.FirstUser
                
                loop
                exitwhen cur == 0
                    call DummyCaster['A002'].castTarget(Player(cur.value), 1, OrderId("bloodlust"), User(cur.value).ActiveUnit)
                    
                    set MobImmune[cur.value] = true
                set cur = cur.next
                endloop
                
                call TimerStart(NewTimerEx(user.Team), TEAM_INVULN_TIME, false, function thistype.TeamInvulnCB)
            elseif GetUnitTypeId(.Unit) == POWERUP_TEAM_ADDCONT then
                call AddContinueEffect(this, user)
				
				call user.Team.ChangeContinueCount(TEAM_ADDCONT_COUNT)
				// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDCONT_COUNT) + " continues")
				call user.Team.DisplayDynamicContent(LocalizeContinueGain, user)
			elseif GetUnitTypeId(.Unit) == POWERUP_TEAM_STEALCONT then
				set team = Teams_MazingTeam.GetRandomTeam(user.Team)
				
				if team != 0 then
					call team.ChangeContinueCount(-TEAM_STEALCONT_COUNT)
					// call team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALCONT_COUNT) + " continue from your team!")
					call team.DisplayDynamicContent(LocalizeContinueStolen, user)
					
					call StealContinueEffect(this, user)
					call user.Team.ChangeContinueCount(TEAM_STEALCONT_COUNT)
					
					// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALCONT_COUNT) + " continue from team " + team.TeamName + "!")
					set team.LastEventUser = user
					call user.Team.DisplayDynamicContent(LocalizeContinueStolenFrom, team)
					set team.LastEventUser = 0
				else
					call AddContinueEffect(this, user)
					
					call user.Team.ChangeContinueCount(TEAM_ADDCONT_COUNT)
					// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDCONT_COUNT) + " continues")
					call user.Team.DisplayDynamicContent(LocalizeContinueGain, user)
				endif
			elseif GetUnitTypeId(.Unit) == POWERUP_TEAM_ADDSCORE then
				call AddScoreEffect(this, user)
				
				call user.Team.ChangeScore(TEAM_ADDSCORE_COUNT)
				// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDSCORE_COUNT) + " points")
				call user.Team.DisplayDynamicContent(LocalizeScoreGain, user)
			elseif GetUnitTypeId(.Unit) == POWERUP_TEAM_STEALSCORE then
				set team = Teams_MazingTeam.GetRandomTeam(user.Team)
				
				if team != 0 then
					call team.ChangeScore(-TEAM_STEALSCORE_COUNT)
					// call team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALSCORE_COUNT) + " point from your team!")
					call team.DisplayDynamicContent(LocalizeScoreStolen, user)
					
					call StealScoreEffect(this, user)
					call user.Team.ChangeScore(TEAM_STEALSCORE_COUNT)
					
					// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " stole " + I2S(TEAM_STEALSCORE_COUNT) + " point from team " + team.TeamName + "!")
					set team.LastEventUser = user
					call user.Team.DisplayDynamicContent(LocalizeScoreStolenFrom, team)
					set team.LastEventUser = 0
				else
					call AddScoreEffect(this, user)
					
					call user.Team.ChangeScore(TEAM_ADDSCORE_COUNT)
					// call user.Team.PrintMessage(user.GetStylizedPlayerName() + " gained your team " + I2S(TEAM_ADDSCORE_COUNT) + " points")
					call user.Team.DisplayDynamicContent(LocalizeScoreGain, user)
				endif
            endif
            //call ExecuteFunc(.OnAcquireCB)
        endmethod
                
        public static method IsPowerupUnit takes integer unitTypeID returns boolean
            return unitTypeID == POWERUP_SOLO_INVULN or unitTypeID == POWERUP_TEAM_INVULN or unitTypeID == POWERUP_TEAM_ADDCONT or unitTypeID == POWERUP_TEAM_STEALCONT or unitTypeID == POWERUP_TEAM_ADDSCORE or unitTypeID == POWERUP_TEAM_STEALSCORE
        endmethod

        public static method GetFromUnit takes unit u returns thistype
            return AllPowerups[GetHandleId(u)]
        endmethod
        
        public static method CreateRandom takes real x, real y returns thistype
            local integer rand = GetRandomInt(0, 3)
            
            if rand == 0 then
				return thistype.create(POWERUP_TEAM_ADDCONT, x, y)
            elseif rand == 1 then
				return thistype.create(POWERUP_TEAM_STEALCONT, x, y)
            elseif rand == 2 then
				return thistype.create(POWERUP_TEAM_ADDSCORE, x, y)
            elseif rand == 3 then
				return thistype.create(POWERUP_TEAM_STEALSCORE, x, y)            
            endif
            
            return 0
        endmethod
        
        public static method create takes integer unitTypeID, real x, real y returns thistype
            local thistype new
			
			if IsPowerupUnit(unitTypeID) then
				set new = thistype.allocate()
				
				//defaults
				set new.TeamsUsed = SimpleList_List.create()
				
				//create item in game
				set new.Unit = CreateUnit(POWERUP_PLAYER, unitTypeID, x, y, 0)
				call IndexedUnit.create(new.Unit)
				
				call UnitAddAbility(new.Unit, 'Aloc')
				call ShowUnit(new.Unit, false)
				call ShowUnit(new.Unit, true)
				
				set AllPowerups[GetHandleId(new.Unit)] = new
				
				return new
			else
				return 0
			endif
        endmethod
        public static method CreateFromUnit takes unit u returns thistype
			local thistype new
			
			if GetUnitTypeId(u) == POWERUP_MARKER then
				set new = thistype.CreateRandom(GetUnitX(u), GetUnitY(u))
				call RemoveUnit(u)
				set u = null
			elseif IsPowerupUnit(GetUnitTypeId(u)) then
				set new = thistype.allocate()
				
				set new.TeamsUsed = SimpleList_List.create()
				
				set new.Unit = u
				call IndexedUnit.create(u)
				call UnitAddAbility(new.Unit, 'Aloc')
				call ShowUnit(new.Unit, false)
				call ShowUnit(new.Unit, true)
				call SetUnitOwner(new.Unit, POWERUP_PLAYER, true)
				
				set AllPowerups[GetHandleId(new.Unit)] = new
			else
				set new = 0
			endif
						
			return new
		endmethod
        
        public static method onInit takes nothing returns nothing
            local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
        
            loop
            exitwhen fp == 0                
                set MobImmune[fp] = false
                
                set fp = fp.next
            endloop
            
            set AllPowerups = Table.create()
        endmethod
    endstruct
endlibrary