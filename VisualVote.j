library VisualVote initializer Init requires Vector2, Alloc, Table, PlayerUtils, SimpleList, locust, TimerUtils
    globals
        public constant real    MENU_DESTROY_TIMEOUT = .5
        public constant integer CONTAINER_BORDER_MARGIN = 64
        
        public constant integer COLUMN_MARGIN_RIGHT = 128
        public constant integer COLUMN_MARGIN_BOTTOM = 128
        
        public constant integer DISABLED_PLAYER_ID = 8
        public constant integer VOTE_PLAYER_ID = 10
        public constant integer VOTE_UNIT_ID = 'eVOT'
        public constant integer PLAYER_VOTE_UNIT_ID = 'eVOT'
        public constant integer VOTE_UNIT_OFFSET = -64
        public constant integer PLAYER_VOTE_UNIT_OFFSET = -32
        
        public constant real TEXT_OFFSET_HEIGHT = 0
        public constant real TEXT_HEIGHT = 4
        public constant integer TEXT_OPTION_SIZE = 14
        public constant integer TEXT_HEADER1_SIZE = 20
        public constant integer TEXT_HEADER2_SIZE = 16
        
        public VisualVote_voteMenu LastFinishedMenu
    endglobals
        
    public struct voteBorder extends array
        public static constant integer LIGHTNING_BLUE = 0
    endstruct
        
    public struct voteInfo extends array
        public VisualVote_voteOption parent
        
        public unit playerVoteUnit
        
        public method destroy takes nothing returns nothing
            call RemoveUnit(playerVoteUnit)
            set playerVoteUnit = null
        endmethod
        
        implement Alloc
    endstruct
    
    public struct voteOption extends array
        public VisualVote_voteContainer parent
        
        public texttag gameText
        public string text
        public boolean enabled
        public string onVoteWinCallback
        
        
        public SimpleList_List playerVotesKeys
        public Table playerVotes
        //public UnitStack playerVoteUnits
        
        public unit voteUnit
        
        implement Alloc
        
        public static method setColorDisabled takes texttag tt returns nothing
            call SetTextTagColor(tt, 128, 128, 128, 50)
        endmethod
        
        public method didPlayerVoteYes takes integer pID returns boolean
            return .playerVotes.has(pID)
        endmethod
        
        public method removePlayerVote takes integer pID returns nothing
            local SimpleList_ListNode cur = playerVotesKeys.first
            local integer siFound
            
            local voteInfo info
            
            //call playerVotesKeys.print(pID)
            
            //call DisplayTextToPlayer(Player(pID), 0, 0, "Searching for player: " + I2S(pID))
            
            //iterate till we find our player
            loop
            exitwhen cur == 0 or cur.value == pID
                //call DisplayTextToPlayer(Player(pID), 0, 0, "cur: " + I2S(cur.value))
            set cur = cur.next
            endloop
            
            if cur > 0 then
                //call DisplayTextToPlayer(Player(pID), 0, 0, "Found: " + I2S(cur.value))
                
                //iterate the remaining items in the stack, shifting the matching unit up 1 space
                set cur = cur.next
                
                loop
                exitwhen cur == 0
                    set info = playerVotes[cur.value]
                    //call DisplayTextToPlayer(Player(0), 0, 0, "Shifting player: " + I2S(cur.value))
                    //call DisplayTextToPlayer(Player(0), 0, 0, "From: " + R2S(GetUnitX(info.playerVoteUnit)) + ", to: " + R2S(GetUnitX(info.playerVoteUnit) - PLAYER_VOTE_UNIT_OFFSET))
                    call SetUnitPosition(info.playerVoteUnit, GetUnitX(info.playerVoteUnit) - PLAYER_VOTE_UNIT_OFFSET, GetUnitY(info.playerVoteUnit))
                set cur = cur.next
                endloop
                
                //remove the player from the stack, stack shifts automatically
                call playerVotesKeys.remove(pID)
                
                //finally deallocate the info object, and all child properties
                set info = playerVotes[pID]
                
                call RemoveUnit(info.playerVoteUnit)
                set info.playerVoteUnit = null
                
                call info.destroy()
                call playerVotes.remove(pID)
                
                //call DisplayTextToPlayer(Player(pID), 0, 0, "Finished removing player vote")
            endif            
        endmethod
        
        public method addPlayerVote takes integer pID returns nothing
            local voteInfo info = voteInfo.allocate()
            
            //select this option
            //need to push player ID + 1 so it doesn't conflict with stack returning 0 to mark the end of a stack (otherwise player 1 is seen as end of stack)
            //call playerVotesKeys.push(pID + 1)
            call playerVotesKeys.addEnd(pID)
            
            //put vote into Table
            set info.playerVoteUnit = CreateUnit(Player(pID), PLAYER_VOTE_UNIT_ID, GetUnitX(.voteUnit) + playerVotesKeys.count * PLAYER_VOTE_UNIT_OFFSET, GetUnitY(.voteUnit), 0)
            call AddUnitLocust(info.playerVoteUnit)
            
            set playerVotes[pID] = info      
        endmethod
        
        //providing the function here guarantees that the option is only the default for its parent, and that there is only 1 default at a time
        public method setDefault takes nothing returns nothing
            set parent.defaultOption = this
        endmethod
        
        public method onSelect takes player p returns nothing
            
            local integer pID = GetPlayerId(p)
            
            if .enabled then
                if .parent.multipick then
                    //allow de-selection for multipicks
                    if this.didPlayerVoteYes(pID) then
                        call .removePlayerVote(pID)
                    else
                        call .addPlayerVote(pID)
                    endif
                else
                    //only one vote selection allowed for this category
                    //check that this player hasn't already voted for this option
                    if this.didPlayerVoteYes(pID) then
                        if .parent.allowDeselect then
                            call .removePlayerVote(pID)
                        else
                            call DisplayTextToPlayer(p, 0, 0, "Already voted yes!")
                        endif
                        return
                    endif
                    
                    //call DisplayTextToPlayer(p, 0, 0, "Clearing")
                    //check the other options and remove the player's vote from any they've voted on
                    call .parent.clearVoteOptionsForPlayer(pID)
                    //call DisplayTextToPlayer(p, 0, 0, "Cleared")
                    
                    //call DisplayTextToPlayer(p, 0, 0, "Adding")
                    //select this option
                    call .addPlayerVote(pID)
                    //call DisplayTextToPlayer(p, 0, 0, "Added")
                    
                    //call playerVotesKeys.print(pID)
                endif
                
                //TODO check if all players have finished voting
                //1st parent: container
                //2nd parent: column
                //3rd parent: menu
                //call .parent.parent.parent.checkAndApplyPlayersFinishedVoting()
                
                if .parent.parent.parent.checkPlayersFinishedVoting() then
                    call .parent.parent.parent.applyPlayerVote()
                endif
            else
                call DisplayTextToPlayer(p, 0, 0, .parent.text + ": " + .text + " is not available yet, check back soon!")
            endif
        endmethod
        
        public method render takes real x, real y returns real
            set .gameText = CreateTextTag()
            
            if voteUnit == null then
                
                if .enabled then
                    set voteUnit = CreateUnit(Player(VOTE_PLAYER_ID), VOTE_UNIT_ID, x + VOTE_UNIT_OFFSET, y, 0)
                else
                    set voteUnit = CreateUnit(Player(DISABLED_PLAYER_ID), VOTE_UNIT_ID, x + VOTE_UNIT_OFFSET, y, 0)
                endif
            endif
            
            call SetTextTagText(.gameText, .text, TextTagSize2Height(TEXT_OPTION_SIZE))
            call SetTextTagPermanent(.gameText, true)
            call SetTextTagPos(.gameText, x, y, TEXT_OFFSET_HEIGHT)
            
            //call DisplayTextToPlayer(Player(0), 0, 0, "Rendering option text: " + .text)
            
            if .enabled then
                
            else
                call setColorDisabled(.gameText)
            endif
            
            //call DisplayTextToPlayer(Player(0), 0, 0, "Finished rendering option text")
            
            call SetTextTagVisibility(.gameText, true)
            
            return y - TEXT_OPTION_SIZE * TEXT_HEIGHT
                        
            //display the container header
//            set .gameText = CreateTextTag()
//            
//            call SetTextTagText(.gameText, .text, TextTagSize2Height(TEXT_HEADER2_SIZE))
//            call SetTextTagPermanent(.gameText, true)
//            call SetTextTagPos(.gameText, x, y, TEXT_OFFSET_HEIGHT)
//            
//            call SetTextTagVisibility(.gameText, true)
//            
//            return y - TEXT_HEADER2_SIZE * TEXT_HEIGHT
        endmethod
              
        public method destroy takes nothing returns nothing
            local integer iP = 0
            local SimpleList_ListNode cur = .playerVotesKeys.first
            
            loop
            exitwhen cur == 0
                call voteInfo(.playerVotes[cur.value]).destroy()
            set cur = cur.next
            endloop
            
            
            call .playerVotes.destroy()
            call .playerVotesKeys.destroy()
            
            call DestroyTextTag(.gameText)
            set .gameText = null
            
            call RemoveUnit(voteUnit)
            set voteUnit = null
            
//            loop
//            exitwhen iP >= NUMBER_PLAYERS
//                if playerVoteUnits[iP] != null then
//                    call RemoveUnit(playerVoteUnits[iP])
//                    set playerVoteUnits[iP] = null
//                endif
//            set iP = iP + 1
//            endloop
        endmethod
        
        public static method create takes string text, string callback returns thistype
            local thistype new = thistype.allocate()
            
            set new.playerVotes = Table.create()
            set new.playerVotesKeys = SimpleList_List.create()
            
            set new.enabled = true
            
            set new.text = text
            set new.onVoteWinCallback = callback
            
            return new
        endmethod
    endstruct
    
    public struct voteContainer extends array
        public VisualVote_voteColumn parent
        public Table options
        public integer optionCount
        
        public texttag gameText
        public string text
        
        public boolean multipick
        public boolean allowDeselect
        public boolean required
        public boolean enabled
        
        public real marginTop
        public real marginBottom
        
        //private static trigger theExecutioner
        
        public voteOption defaultOption
        
        implement Alloc
        
        public method render takes real x, real y returns real
            local integer iVO = 0
            local voteOption vo
            
            local real curY = y
            
            //display the container header
            set .gameText = CreateTextTag()
            
            call SetTextTagText(.gameText, .text, TextTagSize2Height(TEXT_HEADER2_SIZE))
            call SetTextTagPermanent(.gameText, true)
            call SetTextTagPos(.gameText, x, curY, TEXT_OFFSET_HEIGHT)
            
            call SetTextTagVisibility(.gameText, true)
            
            set curY = curY - TEXT_HEADER2_SIZE * TEXT_HEIGHT
            
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "rendered container header")
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                
                //call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,Fields.lastError)
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "rendering option: " + I2S(iVO))
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "x: " + R2S(x) + ", y: " + R2S(curY))
                
                set curY = vo.render(x, curY)
            set iVO = iVO + 1
            endloop
            
            return curY
        endmethod
        
        public method clearVoteOptionsForPlayer takes integer pID returns nothing
            local integer iVO = 0
            local voteOption vo
            
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                                    
                if vo.didPlayerVoteYes(pID) then
                    //call DisplayTextToPlayer(Player(pID), 0, 0, "Removing: " + vo.text)
                    
                    call vo.removePlayerVote(pID)
                    
                    //can only vote on one thing at a time
                    return
                endif
            set iVO = iVO + 1
            endloop
        endmethod
        
        public method getVoteOptionFromSelectedUnit takes unit selectedUnit returns voteOption
            local integer iVO = 0
            local voteOption vo
            
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                                    
                if vo.voteUnit == selectedUnit then
                    return vo
                endif
            set iVO = iVO + 1
            endloop
            
            return 0
        endmethod
                
        public method addOption takes string text, string callback returns voteOption
            local voteOption option = voteOption.create(text, callback)
            set option.parent = this
            set option.enabled = this.enabled
            
            set .options[.optionCount] = option
            set .optionCount = .optionCount + 1
            
            return option
        endmethod
        
        public method getMajorityOption takes nothing returns voteOption
            local integer iVO = 0
            local Table leaders = Table.create()
            local integer leaderOptionCount = 0
            local integer leaderVoteCount = 0
            local voteOption vo
            
            //get the set of options with the most votes
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                
                //call DisplayTextToPlayer(Player(0), 0, 0, "current leader: " + I2S(leaderVoteCount) + ", current option: " + I2S(vo.playerVotesKeys.count))
                //set tally = tally + vo.playerVotes.count
                if vo.playerVotesKeys.count > leaderVoteCount then
                    //clear any existing leaders and update the counts
                    call leaders.flush()
                    
                    set leaderVoteCount = vo.playerVotesKeys.count
                    set leaders[0] = vo
                    set leaderOptionCount = 1
                elseif vo.playerVotesKeys.count == leaderVoteCount then
                    //call DisplayTextToPlayer(Player(0), 0, 0, "current leader count: " + I2S(leaderOptionCount))
                    set leaders[leaderOptionCount] = vo
                    set leaderOptionCount = leaderOptionCount + 1
                    //call DisplayTextToPlayer(Player(0), 0, 0, "new leader count: " + I2S(leaderOptionCount))
                endif
            set iVO = iVO + 1
            endloop
            
            //either take the leader or, in the case of a tie, make a random roll selection from all leaders
            if leaderOptionCount == 1 then
                return voteOption(leaders[0])
            elseif leaderOptionCount > 1 then
                //check if the default option is among the leaders and pick it if it is, otherwise take a random choice among the leaders
                if .defaultOption != 0 then
                    set iVO = 0
                    loop
                    exitwhen iVO >= leaderOptionCount
                        if .defaultOption == leaders[iVO] then
                            return .defaultOption
                        endif
                    set iVO = iVO + 1
                    endloop
                endif
                
                //default option not present or not defined, pick a random option from among the leaders
                //reuse iVO
                return voteOption(leaders[GetRandomInt(0, leaderOptionCount - 1)])
            else
                //not sure what this case is, no one votes should be a tie for 0 votes, but just in case either return the default option if defined or a random option if not
                if .defaultOption != 0 then
                    return .defaultOption
                else
                    return voteOption(.options[GetRandomInt(0, .optionCount - 1)])
                endif
            endif
            
            call leaders.destroy()
            
            return 0
        endmethod
        public method executeMajorityOption takes nothing returns nothing
            local voteOption majority
            
            if .enabled then
                set majority = .getMajorityOption()
                
                if majority != 0 then
                    //execute vote option, on vote succeed function
                    //call TriggerAddAction(theExecutioner, majority.onVoteWinCallback)
                    //debug call DisplayTextToPlayer(Player(0), 0, 0, "Executing callback: " + majority.onVoteWinCallback)
                    if majority.onVoteWinCallback != null and majority.onVoteWinCallback != "" then
                        call ExecuteFunc(majority.onVoteWinCallback)
                    endif
                endif
            endif
        endmethod
        
        public method tallyNumberVotes takes nothing returns integer
            local integer iVO = 0
            local integer tally = 0
            local voteOption vo
            
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                
                //set tally = tally + vo.playerVotes.count
                set tally = tally + vo.playerVotesKeys.count
            set iVO = iVO + 1
            endloop
            
            return tally
        endmethod
        
        static if DEBUG_MODE then
        public method printResults takes integer pID returns nothing
            local voteOption vo = .getMajorityOption()
            if vo != 0 then
                call DisplayTextToPlayer(Player(pID), 0, 0, "Container: " + .text + ", majority: " + vo.text)
            else
                call DisplayTextToPlayer(Player(pID), 0, 0, "Container: " + .text + ", has no votes and no default")
            endif
        endmethod
        endif
        
        public method destroy takes nothing returns nothing
            local integer iVO = 0
            local voteOption vo
            
            loop
            exitwhen iVO >= .optionCount
                set vo = .options[iVO]
                                    
                call vo.destroy()
            set iVO = iVO + 1
            endloop
                        
            call .options.destroy()
            
            call DestroyTextTag(.gameText)
            set .gameText = null
            
            call this.deallocate()
        endmethod
        
        public static method create takes string text returns thistype
            local thistype new = thistype.allocate()
            
            set new.options = Table.create()
            set new.optionCount = 0
            set new.defaultOption = 0
            
            set new.enabled = true
            set new.multipick = false
            set new.allowDeselect = false
            set new.required = true
            
            set new.text = text
            
            return new
        endmethod
    
//        public static method onInit takes nothing returns nothing
//            set voteContainer.theExecutioner = CreateTrigger()
//        endmethod
    endstruct
    
    public struct voteColumn extends array
        public real columnWidth
        public VisualVote_voteMenu parent
        public Table voteContainers
        public integer voteContainerCount
        
        public vector2 topLeft
        public vector2 botRight
        
        implement Alloc
        
        public method render takes vector2 topLeft returns vector2
            local integer iVC = 0
            local voteContainer vc
            
            set topLeft = vector2.create(topLeft.x, topLeft.y)
            set botRight = vector2.create(topLeft.x + columnWidth, topLeft.y)
            
            loop
            exitwhen iVC >= voteContainerCount
                set vc = voteContainers[iVC]
                
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "rendering container: " + I2S(iVC))
                set botRight.y = vc.render(topLeft.x, botRight.y) - COLUMN_MARGIN_BOTTOM
            set iVC = iVC + 1
            endloop
            
            return botRight
        endmethod
        
        //TODO implement
        //ideally this would happen during render, but that would mean storing the border type, and i don't think that's necessary
        public method setBorder takes integer borderType returns nothing
        
        endmethod
        
        public method havePlayersFinishedVoting takes integer playerCount returns boolean
            local integer iVC = 0
            local voteContainer vc
            
            //check that all voting categories have had all players vote
            loop
            exitwhen iVC >= voteContainerCount
                set vc = voteContainers[iVC]
                
                if vc.required and vc.tallyNumberVotes() != playerCount then
                    return false
                endif
            set iVC = iVC + 1
            endloop
            
            return true
        endmethod
        
        public method getVoteOptionFromSelectedUnit takes unit selectedUnit returns voteOption
            local integer iVC = 0
            local voteContainer vc
            local voteOption vo
            
            loop
            exitwhen iVC >= voteContainerCount
                set vc = voteContainers[iVC]
                
                set vo = vc.getVoteOptionFromSelectedUnit(selectedUnit)
                if vo != 0 then
                    return vo
                endif                
            set iVC = iVC + 1
            endloop
            
            return 0
        endmethod
        
        public method addContainer takes string containerText returns voteContainer
            local voteContainer container = voteContainer.create(containerText)
            set container.parent = this
            
            set voteContainers[voteContainerCount] = container
            set voteContainerCount = voteContainerCount + 1
            
            return container
        endmethod
        
        static if DEBUG_MODE then
        public method printResults takes integer pID returns nothing
            local integer iVC = 0
            local voteContainer vc
            
            loop
            exitwhen iVC >= voteContainerCount
                set vc = voteContainers[iVC]
                
                call vc.printResults(pID)
            set iVC = iVC + 1
            endloop
        endmethod
        endif
        
        public method destroy takes nothing returns nothing
            local integer iVC = 0
            local voteContainer vc
            
            loop
            exitwhen iVC >= voteContainerCount
                set vc = voteContainers[iVC]
                
                call vc.destroy()
            set iVC = iVC + 1
            endloop
            
            call .voteContainers.destroy()
            //call .topLeft.destroy()
            call .botRight.destroy()
            
            call this.deallocate()
        endmethod
        
        public static method create takes real width returns thistype
            local thistype new = thistype.allocate()
            
            set new.voteContainers = Table.create()
            set new.voteContainerCount = 0
            
            set new.columnWidth = width
            
            return new
        endmethod
    endstruct
    
    public struct voteMenu        
        public vector2 topLeft
        public vector2 botRight
        
        public SimpleList_List forPlayers
        public string onOptionExecuteFinish
        
        public string onDestroyFinish
        
        public Table voteColumns
        public integer voteColumnCount
        
        public boolean rendered
        public boolean enabled
        
        private real initialTime
        private timerdialog td
                
        //implement Alloc
        implement List
        
        public method render takes nothing returns nothing
            local integer iVC = 0
            local voteColumn vc
            
            local real curX = topLeft.x
            local vector2 colBotRight
            
            if not .rendered then
                set .rendered = true
                
                loop
                exitwhen iVC >= voteColumnCount
                    set vc = voteColumns[iVC]
                    
                    //render from the top left of the full menu, offset for whatever column we're on
                    //set botRight to the bottom right of the column we just rendered
                    set colBotRight = vc.render(vector2.create(curX, topLeft.y))
                    
                    //update the full vote menu's bottom to be the column we just made, if it's bigger than any before (columns always gain negative y as they increase in size)
                    if RAbsBJ(colBotRight.y) < RAbsBJ(.botRight.y) then
                        set .botRight.y = colBotRight.y
                    endif
                    
                    //i don't think i destroy colBotRight here, because it should be a pointer to the columns actual botRight property
                    
                    //update top left X for constant column width
                    set curX = curX + vc.columnWidth + COLUMN_MARGIN_RIGHT
                set iVC = iVC + 1
                endloop
                
                //the last column rendered will always be the furthest right
                set .botRight.x = colBotRight.x
                
                //menu should be usable after rendering (by default)
                set .enabled = true
            endif
        endmethod
        
        private static method onTimerExpire takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype menu = GetTimerData(t)
            
            //this automatically destroys the menu (and all components) after a bit
            call menu.applyPlayerVote()
            
            call ReleaseTimer(t)
            set t = null
        endmethod
        
        public method enforceVoteMode takes nothing returns nothing
            local SimpleList_ListNode fp
            local timer t
            
            if rendered then
                set fp = forPlayers.first
                
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "enforcing top left x: " + R2S(topLeft.x) + ", y: " + R2S(topLeft.y))
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "enforcing bot right x: " + R2S(botRight.x) + ", y: " + R2S(botRight.y))
                
                //create expiration timer
                set t = NewTimerEx(this)
                call TimerStart(t, .initialTime, false, function thistype.onTimerExpire)
                
                set .td = CreateTimerDialog(t)
                call TimerDialogSetTitle(.td, "Game Mode Selection:")
                
                loop
                exitwhen fp == 0
                    if GetLocalPlayer() == Player(fp.value) then
                        //only show timer dialog for players it effects
                        call TimerDialogDisplay(.td, true)
                        
						set User(fp.value).Vision = CreateFogModifierRect(Player(fp.value), FOG_OF_WAR_VISIBLE, Rect(topLeft.x, botRight.y, botRight.x, topLeft.y), false, true)
						call FogModifierStart(User(fp.value).Vision)
						
                        call SetCameraBounds(topLeft.x, topLeft.y, topLeft.x, botRight.y, botRight.x, botRight.y, botRight.x, topLeft.y)
                        call PanCameraToTimed((topLeft.x + botRight.x) / 2, (topLeft.y + botRight.y) / 2, 0.01)
                        
                        //pivot camera to top down view
                        //static if Library_Platformer then
                            call CameraSetupApply(User(fp.value).Platformer.PlatformingCamera, false, false)
                        //endif
                    endif
                set fp = fp.next
                endloop
                
                set t = null
            debug else
                debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Remember to render menu before enforcing it!")
            endif
        endmethod
        
        private static method destroyMenuCallback takes nothing returns nothing
            local timer expired = GetExpiredTimer()
            local voteMenu menuExpired = GetTimerData(expired)
            
            debug call DisplayTextToPlayer(Player(0), 0, 0, "Menu started destroying")
            
            call menuExpired.destroy()
            call ReleaseTimer(expired)
            set expired = null
            
            debug call DisplayTextToPlayer(Player(0), 0, 0, "Menu finished destroying")
        endmethod
        
        public method applyPlayerVote takes nothing returns nothing
            local SimpleList_ListNode fp
            
            local integer iVC = 0
            local voteColumn vc
            local integer iVCont
            local voteContainer vCont
            
            if .enabled then
                //menu should be unusable after voting is finished
                set .enabled = false
                
                //unrestrict the camera view
                set fp = forPlayers.first
                loop
                exitwhen fp == 0
                    if GetLocalPlayer() == Player(fp.value) then
                        //call SetCameraBounds(GetCameraBoundMinX(), GetCameraBoundMinY(), GetCameraBoundMinX(), GetCameraBoundMaxY(), GetCameraBoundMaxX(), GetCameraBoundMaxY(), GetCameraBoundMaxX(), GetCameraBoundMinY())
                        call TimerDialogDisplay(.td, false)
                        call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
                    endif
                set fp = fp.next
                endloop
                
                //execute majority option for each container, regardless of if everyones voted or not
                set iVC = 0
                loop
                exitwhen iVC >= .voteColumnCount
                    set vc = .voteColumns[iVC]
                    set iVCont = 0
                    
                    loop
                    exitwhen iVCont > vc.voteContainerCount
                        set vCont = vc.voteContainers[iVCont]
                        
                        call vCont.executeMajorityOption()
                    set iVCont = iVCont + 1
                    endloop
                set iVC = iVC + 1
                endloop
                
                //callback for after options have been applied -- mostly useful for when logic requires all options to be decided first
                set LastFinishedMenu = this
				
				if .onOptionExecuteFinish != null then
					call ExecuteFunc(.onOptionExecuteFinish)
                endif
				
                //create a timer to expire in a little bit to clean up the vote menu struct
                //don't do it right away in case any selection events are finishing up
                call TimerStart(NewTimerEx(this), MENU_DESTROY_TIMEOUT, false, function voteMenu.destroyMenuCallback)
            endif
        endmethod
        
        public method checkPlayersFinishedVoting takes nothing returns boolean
            local integer iVC = 0
            
            if .enabled then
                //check that all voting categories have had all players vote
                loop
                exitwhen iVC >= voteColumnCount
                    if not voteColumn(voteColumns[iVC]).havePlayersFinishedVoting(forPlayers.count) then
                        return false
                    endif
                set iVC = iVC + 1
                endloop
                
                return true
            endif
            
            return false
        endmethod
        
        public method addAllPlayersToMenu takes nothing returns nothing
            local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
            
            call forPlayers.clear()
            
            loop
            exitwhen fp == 0
                call forPlayers.addEnd(fp.value)
            set fp = fp.next
            endloop
        endmethod
        
        public method getVoteOptionFromSelectedUnit takes unit selectedUnit returns voteOption
            local integer iVC = 0
            local voteColumn vc
            local voteOption vo
            
            loop
            exitwhen iVC >= voteColumnCount
                set vc = voteColumns[iVC]
                
                set vo = vc.getVoteOptionFromSelectedUnit(selectedUnit)
                if vo != 0 then
                    return vo
                endif
            set iVC = iVC + 1
            endloop
            
            return 0
        endmethod
        public static method globalGetVoteOptionFromSelectedUnit takes unit selectedUnit returns voteOption
            local thistype vm = VisualVote_voteMenu.first
            local voteOption vo
            
            loop
            exitwhen vm == 0
                if vm.enabled then
                    set vo = vm.getVoteOptionFromSelectedUnit(selectedUnit)
                    if vo != 0 then
                        return vo
                    endif
                endif
            set vm = vm.next
            endloop
            
            return 0
        endmethod
        
        public method addColumn takes real columnWidth returns voteColumn
            local voteColumn column = voteColumn.create(columnWidth)
            set column.parent = this
            
            set voteColumns[voteColumnCount] = column
            set voteColumnCount = voteColumnCount + 1
            
            return column
        endmethod
        
        static if DEBUG_MODE then
        public method printResults takes integer pID returns nothing
            local integer iVC = 0
            local voteColumn vc
            
            loop
            exitwhen iVC >= voteColumnCount
                set vc = voteColumns[iVC]
                
                call vc.printResults(pID)
            set iVC = iVC + 1
            endloop
        endmethod
        endif
        
        public method destroy takes nothing returns nothing
            local integer iVC = 0
            local voteColumn vc
            
            call .listRemove()
            
            loop
            exitwhen iVC >= voteColumnCount
                set vc = voteColumns[iVC]
                
                call vc.destroy()
            set iVC = iVC + 1
            endloop
            
            call DestroyTimerDialog(.td)
            set .td = null
            
            call .voteColumns.destroy()
            call .forPlayers.destroy()
            call .topLeft.destroy()
            call .botRight.destroy()
            
            call this.deallocate()
            
            if .onDestroyFinish != null then
                call ExecuteFunc(.onDestroyFinish)
            endif
        endmethod
        
        public static method create takes real topLeftX, real topLeftY, real time, string onOptionFinishCallback returns thistype
            local thistype new = thistype.allocate()
            
            call new.listAdd()
            
            set new.voteColumns = Table.create()
            set new.voteColumnCount = 0
            
            set new.forPlayers = SimpleList_List.create()
            
            set new.onDestroyFinish = null
            set new.rendered = false
            set new.enabled = true
            
            set new.topLeft = vector2.create(topLeftX, topLeftY)
            set new.botRight = vector2.create(topLeftX, topLeftY)
            set new.initialTime = time
            set new.onOptionExecuteFinish = onOptionFinishCallback
            
            return new
        endmethod        
    endstruct
    
    public function OnVisualVoteSelection takes nothing returns nothing
        local unit selected = GetTriggerUnit()
        local player p = GetTriggerPlayer()
        
        local voteOption vo = voteMenu.globalGetVoteOptionFromSelectedUnit(selected)
        
        //check that this player is a member of the menu
        if vo != 0 and vo.parent.parent.parent.forPlayers.contains(GetPlayerId(p)) then
            //debug call DisplayTextToPlayer(p, 0, 0, "Selection Found")
            call vo.onSelect(p)
        else
            debug call DisplayTextToPlayer(p, 0, 0, "ERROR: Option not found!!")
        endif
    endfunction
    
    public function FilterVisualVoteSelection takes nothing returns boolean
        return GetUnitTypeId(GetFilterUnit()) == VOTE_UNIT_ID
    endfunction
    
    public function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local SimpleList_ListNode pn = PlayerUtils_FirstPlayer
        
        loop
        exitwhen pn == 0
            if GetPlayerSlotState(Player(pn.value)) == PLAYER_SLOT_STATE_PLAYING then
                call TriggerRegisterPlayerUnitEvent(t, Player(pn.value), EVENT_PLAYER_UNIT_SELECTED, function FilterVisualVoteSelection)
            endif
        set pn = pn.next
        endloop
        
        call TriggerAddAction(t, function OnVisualVoteSelection)
    endfunction
endlibrary