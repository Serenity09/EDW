library SimpleList requires Alloc, Table
    public struct ListNode extends array
        public integer value
        
        public thistype prev
        public thistype next
        
        implement Alloc
    endstruct
    
    public struct List extends array
        public integer count
        public ListNode first
        public ListNode last
                
        implement Alloc
        
        public method add takes integer value returns nothing
            local ListNode curHead = .first
            
            set .first = ListNode.allocate()
            set .first.value = value
            
            set .first.prev = 0
            set .first.next = curHead
            
            if curHead != 0 then
                set curHead.prev = .first
            else
                set .last = .first
            endif
            
            set .count = .count + 1            
        endmethod
        public method addEnd takes integer value returns nothing
            local ListNode curEnd = .last
            
            set .last = ListNode.allocate()
            set .last.value = value
            
            set .last.next = 0
            set .last.prev = curEnd
            
            if curEnd != 0 then
                set curEnd.next = .last
            else
                set .first = .last
            endif
            
            set .count = .count + 1
        endmethod
		public method insert takes integer value, integer position returns nothing
			local integer curPosition = 0
			local ListNode curNode
			local ListNode newNode
			
			if position <= 0 or .count == 0 then
				call .add(value)
			elseif position >= .count then
				call .addEnd(value)
			else
				set curNode = .first
				loop
				exitwhen curPosition == position
					
				set curNode = curNode.next
				set curPosition = curPosition + 1
				endloop
				
				set newNode = ListNode.allocate()
				set newNode.value = value
				set newNode.prev = curNode.prev
				set newNode.next = curNode
				
				set curNode.prev = newNode
				if newNode.prev != 0 then
					set newNode.prev.next = newNode
				endif
			endif
		endmethod
        
        //remove the first node and return it
		//remember to store or destroy the node when finished with it
        public method pop takes nothing returns ListNode
            //store the node that's being popped
            local ListNode pop = .first
            
            //check if popping an empty list
			if pop != 0 then
				//update the first node to the second node
				set .first = pop.next
				set .count = .count - 1
				
				if .count == 0 then
					set .last = 0
				else
					set .first.prev = 0
				endif
			endif
                        
            return pop
        endmethod
		public method get takes integer index returns ListNode
			local ListNode cur
            local integer i = 0
			
			if i >= .count then
				return 0
			else
				set cur = .first
				
				loop
				exitwhen i == index
				set i = i + 1
				set cur = cur.next
				endloop
				
				return cur
			endif
		endmethod
		
        public method remove takes integer value returns nothing
            local ListNode cur = .first
            
            loop
            exitwhen cur == 0
                if cur.value == value then
                    if cur.next != 0 then
                        set cur.next.prev = cur.prev
                    else
                        set .last = cur.prev
                    endif
                    
                    if cur.prev != 0 then
                        set cur.prev.next = cur.next
                    else
                        set .first = cur.next
                    endif
                    
                    call cur.deallocate()
                    
                    set .count = .count - 1
                    
                    return
                endif
            set cur = cur.next
            endloop
        endmethod
        public method removeNode takes ListNode node returns nothing
            if node.next != 0 then
                set node.next.prev = node.prev
            else
                set .last = node.prev
            endif
            
            if node.prev != 0 then
                set node.prev.next = node.next
            else
                set .first = node.next
            endif
            
            call node.deallocate()
            
            set .count = .count - 1            
        endmethod
        public method clear takes nothing returns nothing
            local ListNode cur
            
            //de-allocate all nodes in the list
            if .count > 0 then
                set cur = .first
                
                loop
                exitwhen cur.next == 0
                    set cur = cur.next
                    call cur.prev.deallocate()
                endloop
                
                call cur.deallocate()
            endif
            
            //reset list properties
            set .first = 0
            set .last = 0
            set .count = 0
        endmethod
        
//        public method insertAt takes integer value, integer position returns nothing
//            //TODO add an optional static table to make insert at efficient
//            
//            
//        endmethod
//        
        public method contains takes integer value returns boolean
            local ListNode cur = .first
            
            loop
            exitwhen cur == 0
                if cur.value == value then
                    return true
                endif
            set cur = cur.next
            endloop
            
            return false
        endmethod
        public method index takes integer value returns integer
            local ListNode cur = .first
            local integer i = 0
            
            loop
            exitwhen cur == 0
                if cur.value == value then
                    return i
                endif
            set i = i + 1
            set cur = cur.next
            endloop
            
            return -1
        endmethod
		
		
        
        public method checkCircular takes nothing returns boolean
            local ListNode cur 
            
            if .first != 0 and .first.next != 0 then
                set cur = .first.next
                
                loop
                exitwhen cur == 0
                    if cur == .first then
                        return true
                    endif
                set cur = cur.next
                endloop
            endif
            
            return false
        endmethod
        public method print takes integer pID returns nothing
            local ListNode cur
            if .count == 0 then
                call DisplayTextToPlayer(Player(0), 0, 0, "Empty List with ID " + I2S(this))
            else
                if this.checkCircular() then
                    call DisplayTextToPlayer(Player(0), 0, 0, "Circular List with ID " + I2S(this))
                else
                    call DisplayTextToPlayer(Player(0), 0, 0, "List with ID " + I2S(this))
                    
                    set cur = .first
                    loop
                    exitwhen cur == 0
                        call DisplayTextToPlayer(Player(0), 0, 0, I2S(cur) + ": " + I2S(cur.value))
                    set cur = cur.next
                    endloop
                endif
            endif
        endmethod
        
        public method destroy takes nothing returns nothing
            call this.clear()
            call this.deallocate()
        endmethod
        
        public static method create takes nothing returns thistype
            local thistype new = thistype.allocate()
            
            set new.count = 0
            set new.first = 0
            set new.last = 0
            
            return new
        endmethod
		public method clone takes nothing returns thistype
			local thistype new = thistype.create()
			local ListNode cur = .first
            
            loop
            exitwhen cur == 0
                call new.addEnd(cur.value)
            set cur = cur.next
            endloop
            			
			return new
		endmethod
    endstruct
	
	
	//Used to cache a stable-state list into something that can be accessed by index in constant time
	//this is a fragile design
	//indexes a list's state on create. does NOT update index as the list changes, since i can't imagine needing a dynamic indexed list for my scope -- its pretty much only useful for optimizing stable-state lists into something cacheable
	//because this extends the base lists ID, you can only have one index per list. creating more will just leak the originals
	struct IndexedListNode extends array
		public integer index
		private delegate ListNode base

		public static method create takes ListNode node, integer dex returns thistype
			set IndexedListNode(node).index = dex
			set IndexedListNode(node).base = node
			
			return node
		endmethod
	endstruct
	public function IndexList takes List list returns Table
		local ListNode curNode = list.first
		local integer curNodeIndex = 0
		local Table indexedList = Table.create()
		
		loop
		exitwhen curNode == 0
			set indexedList[curNodeIndex] = IndexedListNode.create(curNode, curNodeIndex)
		set curNodeIndex = curNodeIndex + 1
		set curNode = curNode.next
		endloop
		
		return indexedList
	endfunction
	struct IndexedList extends array
		public Table indexedNodes
		private delegate List base
		
		public method operator [] takes integer index returns IndexedListNode
			return this.indexedNodes[index]
		endmethod
		
		static if DEBUG_MODE then
        public method print takes integer pID returns nothing
            call DisplayTextToPlayer(Player(0), 0, 0, "Indexed List with ID " + I2S(this))
			call List(this).print(pID)
        endmethod
        endif
		
		public static method create takes List list returns thistype
			local thistype new = list			
			set new.indexedNodes = IndexList(list)
			set new.base = list
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			call this.indexedNodes.destroy()
			
			call List(this).destroy()
		endmethod
	endstruct
endlibrary