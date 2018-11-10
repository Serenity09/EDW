library Cinema requires User, SimpleList, Alloc

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
    
    /*
    public string OnMessagePlayStart
    public string OnMessagePlayEnd
    */
    
    implement Alloc
    
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
    public boolean Individual
    public boolean PauseViewers
    public SimpleList_List PreviousViewers
    public SimpleList_List CinemaMessages
    
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
        local SimpleList_ListNode curUser
        local real messageTime = CinemaMessage(cinemaCBModel.CurrentMessage.value).Time
        
        if cinemaCBModel.Cinematic.Individual then
            call cinemaCBModel.User.DisplayMessage(CinemaMessage(cinemaCBModel.CurrentMessage.value).Text)
        else
            call cinemaCBModel.User.Team.PrintMessage(CinemaMessage(cinemaCBModel.CurrentMessage.value).Text)
        endif
        
        if cinemaCBModel.CurrentMessage.next == 0 then
            //reached last message in cinematic, recycle CB object and release viewers
            call cinemaCBModel.deallocate()
            
            if cinemaCBModel.Cinematic.PauseViewers then
                if cinemaCBModel.Cinematic.Individual then
                    call cinemaCBModel.User.Pause(false)
                else
                    //TODO add users full team
                    set curUser = cinemaCBModel.User.Team.Users.first
                    
                    loop
                    exitwhen curUser == 0                    
                        call User(curUser.value).Pause(false)
                    set curUser = curUser.next
                    endloop
                endif
            endif
        else
            //finished current message in cinematic but there's still more
            set cinemaCBModel.CurrentMessage = cinemaCBModel.CurrentMessage.next
            //call SetTimerData(t, cinemaCBModel) //re-using same model, so original ID attached to timer is still applicable
            call TimerStart(t, messageTime, false, function thistype.PlayMessageCallback)
        endif
    endmethod
    
    public method Activate takes User user returns nothing
        local timer t
        local CinemaCallbackModel cbModel
        local SimpleList_ListNode curUser
        
        if not .HasUserViewed(user) then
            if .Individual then
                call .PreviousViewers.add(user)
                
                if .PauseViewers then
                    call user.Pause(true)
                endif
            else
                //TODO add users full team
                set curUser = user.Team.Users.first
                
                loop
                exitwhen curUser == 0
                    call .PreviousViewers.add(curUser.value)
                    
                    if .PauseViewers then
                        call User(curUser.value).Pause(true)
                    endif
                set curUser = curUser.next
                endloop
            endif
            
            set cbModel = CinemaCallbackModel.create(this, .CinemaMessages.first, user)
            set t = NewTimerEx(cbModel)
        endif
    endmethod
    
    public static method create takes rect activationArea, boolean individual, boolean pause, CinemaMessage firstMessage returns thistype
        local thistype new = thistype.allocate()
        
        set new.ActivationArea = activationArea
        set new.Individual = individual
        set new.PauseViewers = pause
        
        set new.PreviousViewers = SimpleList_List.create()
        set new.CinemaMessages = SimpleList_List.create()
        
        call new.CinemaMessages.add(firstMessage)
        
        return new
    endmethod
endstruct

endlibrary