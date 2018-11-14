library Cinema requires SimpleList, Alloc, Event

globals
    //amount of time before the message should start fading
    //WC3 implements a positive buffer of about 3 seconds under the hood of this function
    //probably should not cause a negative result -- see the shortest message time in GameStart
    constant real MESSAGE_ALIVE_BUFFER = -2.
    constant real CONVERSATION_BUFFER = 2.
    
    Cinematic EventCinematic
    User EventUser
endglobals

function interface CinemaUserConditional takes User user returns boolean

//allows a single integer ID to lookup fields for the cinema's callback function (which only gives you a single int to work with)
struct CinemaCallbackModel extends array
    public Cinematic Cinematic
    public SimpleList_ListNode CurrentMessage
    public User User
    
    implement Alloc
    
    public static method create takes Cinematic cinematic, SimpleList_ListNode currentMessage, User user returns thistype
        local thistype new = thistype.allocate()
        
        set new.Cinematic = cinematic
        set new.CurrentMessage = currentMessage
        set new.User = user
        
        return new
    endmethod
endstruct

struct CinemaMessage extends array
    public unit Source
    public string Text
    public real Time
        
    implement Alloc
    
    public method destroy takes nothing returns nothing
        set .Source = null
        set .Text = null
        
        call .deallocate()
    endmethod
    
    public static method create takes unit source, string text, real time returns thistype
        local thistype new = thistype.allocate()
        
        set new.Source = source
        set new.Text = text
        set new.Time = time
        
        return new
    endmethod
endstruct

struct Cinematic extends array
    public rect ActivationArea
    public CinemaUserConditional ActivationCondition
    public boolean Individual
    public boolean PauseViewers
    public SimpleList_List PreviousViewers //list of Users (do not destroy User instances, just the list)
    public SimpleList_List CinemaMessages //list of Cinema Messages (cascade destroy)
    
    //TODO move into CinemaMessage for at least equal, but ideally greater control
    //public CinemaCallback OnCinemaStart
    //public CinemaCallback OnCinemaEnd
    //public SimpleList_List OnCinemaEndCBs //list of integers representing a function interface -- can only recycle the list
    public static Event OnCinemaEnd
    // public Event OnDestroy
    public Levels_Level ParentLevel
    
    implement Alloc
    
    public method HasUserViewed takes User user returns boolean
        local SimpleList_ListNode cur = .PreviousViewers.first
        
        loop
        exitwhen cur == 0
            if cur.value == user then
                return true
            endif
        set cur = cur.next
        endloop
        
        return false
    endmethod
    
    public method AddMessage takes unit u, string text, real timeout returns nothing
        call .CinemaMessages.addEnd(CinemaMessage.create(u, text, timeout))
    endmethod
    
    private static method PlayMessageCallback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local CinemaCallbackModel cinemaCBModel = GetTimerData(t)
        local real messageTime
        local SimpleList_ListNode curEndCB
        
        if cinemaCBModel.CurrentMessage == 0 then
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "No more messages for CB Model " + I2S(cinemaCBModel))

            if cinemaCBModel.Cinematic.PauseViewers then
                call cinemaCBModel.User.Pause(false)
            endif
            
            call ReleaseTimer(t)
            
            set EventCinematic = cinemaCBModel.Cinematic
            set EventUser = cinemaCBModel.User
            call thistype.OnCinemaEnd.fire()
            
            //reached last message in cinematic, recycle CB object and release viewers
            call cinemaCBModel.deallocate()
        else
            set messageTime = CinemaMessage(cinemaCBModel.CurrentMessage.value).Time
            call cinemaCBModel.User.DisplayMessage(CinemaMessage(cinemaCBModel.CurrentMessage.value).Text, messageTime + MESSAGE_ALIVE_BUFFER)
            
            //finished current message in cinematic but there's still more
            set cinemaCBModel.CurrentMessage = cinemaCBModel.CurrentMessage.next
            //call SetTimerData(t, cinemaCBModel) //re-using same model, so original ID attached to timer is still applicable
            
            //if this is the very last message give an extra buffer after it (to offset any following conversations)
            if cinemaCBModel.CurrentMessage == 0 then
                set messageTime = messageTime + CONVERSATION_BUFFER
            endif
            
            call TimerStart(t, messageTime, false, function thistype.PlayMessageCallback)
        endif
        
        set t = null
    endmethod
    
    public method CanUserActivate takes User user returns boolean
        return not .HasUserViewed(user) and user.IsActiveUnitInRect(.ActivationArea) and (.ActivationCondition == 0 or .ActivationCondition.evaluate(user))
    endmethod
    
    public method Activate takes User user returns nothing
        local CinemaCallbackModel cbModel = CinemaCallbackModel.create(this, .CinemaMessages.first, user)
        local timer t = NewTimerEx(cbModel)
        
        if .PauseViewers then
            call user.Pause(true)
        endif
                
        call TimerStart(t, .0, false, function thistype.PlayMessageCallback)
        set t = null
    endmethod
    
    public method destroy takes nothing returns nothing
        local SimpleList_ListNode curCinemaMessage
        
        //alert any dependent functionality of the cinematic being destroyed
        // set EventCinematic = this
        // call .OnDestroy.fire()
        //right now, this is just the level, so hard-coding that dependency may be enough
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destroying cinematic " + I2S(this) + ", total count: " + I2S(.ParentLevel.Cinematics.count))
        if .ParentLevel != 0 then
            call .ParentLevel.Cinematics.remove(this)
        endif
        
        loop
        set curCinemaMessage = .CinemaMessages.pop()
        exitwhen curCinemaMessage == 0
            call CinemaMessage(curCinemaMessage.value).destroy()
        endloop
        
        call .PreviousViewers.destroy()
        call .CinemaMessages.destroy()
        
        set .ActivationArea = null
        
        call .deallocate()
    endmethod
    
    private static method CheckAllWatched takes nothing returns boolean
        local Cinematic cinema = EventCinematic
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Cinema count " + I2S(cinema.PreviousViewers.count) + ", active player count " + I2S(User.ActivePlayers))
        
        if cinema.PreviousViewers.count == User.ActivePlayers then
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "All players have watched, so destroying cinema " + I2S(cinema))
            call cinema.destroy()
        endif
        
        return false
    endmethod
    
    public static method create takes rect activationArea, boolean individual, boolean pause, CinemaMessage firstMessage returns thistype
        local thistype new = thistype.allocate()
        
        set new.ActivationArea = activationArea
        set new.Individual = individual
        set new.PauseViewers = pause
        
        set new.ActivationCondition = 0
        //set new.OnCinemaStart = 0
        //set new.OnCinemaEnd = 0
        //set new.OnCinemaEnd = Event.create()
        //call new.OnCinemaEnd.register(Condition(function thistype.CheckAllWatched))
        
        set new.ParentLevel = 0
        
        //set new.OnDestroy = Event.create()
        //set new.OnCinemaEndCBs = SimpleList_List.create()
        //call new.OnCinemaEndCBs.add(CheckAllWatched)
        
        set new.PreviousViewers = SimpleList_List.create()
        set new.CinemaMessages = SimpleList_List.create()
        
        call new.CinemaMessages.add(firstMessage)
        
        return new
    endmethod
    
    public static method onInit takes nothing returns nothing
        set thistype.OnCinemaEnd = Event.create()
        call thistype.OnCinemaEnd.register(Condition(function thistype.CheckAllWatched))
    endmethod
endstruct
endlibrary