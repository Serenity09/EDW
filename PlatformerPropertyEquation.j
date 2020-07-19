library PlatformerPropertyEquation requires Alloc, SimpleList
    globals
        public constant boolean ADD_ADJUSTMENT = true
        public constant boolean MULTIPLY_ADJUSTMENT = false
    endglobals
    
    
    struct PlatformerPropertyAdjustment extends array
        public integer TerrainID
        public real Value
        
        implement Alloc
        
        public static method create takes integer ttype, real value returns thistype
            local thistype new = thistype.allocate()
            
            set new.TerrainID = ttype
            set new.Value = value
            
            return new
        endmethod
    endstruct
    struct PlatformerPropertyEquation extends array        
        public SimpleList_List AdditiveAdjustments
        public SimpleList_List MultiplicativeAdjustments
        
        implement Alloc
        
        public method calculateAdjustedValue takes real baseValue returns real
            local SimpleList_ListNode adjustment = .MultiplicativeAdjustments.first
            
            loop
            exitwhen adjustment == 0
                set baseValue = baseValue * PlatformerPropertyAdjustment(adjustment.value).Value
            set adjustment = adjustment.next
            endloop
            
            set adjustment = .AdditiveAdjustments.first
			
            loop
            exitwhen adjustment == 0
                set baseValue = baseValue + PlatformerPropertyAdjustment(adjustment.value).Value
            set adjustment = adjustment.next
            endloop
            
            return baseValue
        endmethod
        
        public method getAdjustment takes boolean addOrMultiply, integer ttype returns PlatformerPropertyAdjustment
            local SimpleList_ListNode adjustmentNode
            local PlatformerPropertyAdjustment adjustment
            
            if addOrMultiply == ADD_ADJUSTMENT then
                set adjustmentNode = .AdditiveAdjustments.first
                
                loop
                exitwhen adjustmentNode == 0
                    set adjustment = PlatformerPropertyAdjustment(adjustmentNode.value)
                    
                    if adjustment.TerrainID == ttype then
                        return adjustment
                    endif
                set adjustmentNode = adjustmentNode.next
                endloop
            elseif addOrMultiply == MULTIPLY_ADJUSTMENT then
                set adjustmentNode = .MultiplicativeAdjustments.first
                
                loop
                exitwhen adjustmentNode == 0
                    set adjustment = PlatformerPropertyAdjustment(adjustmentNode.value)
                    
                    if adjustment.TerrainID == ttype then
                        return adjustment
                    endif
                set adjustmentNode = adjustmentNode.next
                endloop
            endif
            
            return 0
        endmethod

        public method clearAdjustments takes nothing returns nothing
            local SimpleList_ListNode adjustment = .AdditiveAdjustments.first
            
            loop
            exitwhen adjustment == 0
                call PlatformerPropertyAdjustment(adjustment.value).deallocate()
            set adjustment = adjustment.next
            endloop
            
            set adjustment = .MultiplicativeAdjustments.first
            loop
            exitwhen adjustment == 0
                call PlatformerPropertyAdjustment(adjustment.value).deallocate()
            set adjustment = adjustment.next
            endloop
            
            call .AdditiveAdjustments.clear()
            call .MultiplicativeAdjustments.clear()
        endmethod
        
        public method removeAdjustment takes boolean addOrMultiply, integer ttype returns nothing
            local SimpleList_ListNode adjustmentNode
            local PlatformerPropertyAdjustment adjustment
            
            if addOrMultiply == ADD_ADJUSTMENT then
                set adjustmentNode = .AdditiveAdjustments.first
                
                loop
                exitwhen adjustmentNode == 0
                    set adjustment = PlatformerPropertyAdjustment(adjustmentNode.value)
                    
                    if adjustment.TerrainID == ttype then
                        call adjustment.deallocate()
                        call .AdditiveAdjustments.removeNode(adjustmentNode)
                        //call .AdditiveAdjustments.remove(adjustment.value)
                    endif
                set adjustmentNode = adjustmentNode.next
                endloop
            elseif addOrMultiply == MULTIPLY_ADJUSTMENT then
                set adjustmentNode = .MultiplicativeAdjustments.first
                
                loop
                exitwhen adjustmentNode == 0
                    set adjustment = PlatformerPropertyAdjustment(adjustmentNode.value)
                    
                    if adjustment.TerrainID == ttype then
                        call adjustment.deallocate()
                        call .MultiplicativeAdjustments.removeNode(adjustmentNode)
                    endif
                set adjustmentNode = adjustmentNode.next
                endloop
            endif
        endmethod
        
        public method addAdjustment takes boolean addOrMultiply, integer ttype, real value returns nothing
            call this.removeAdjustment(addOrMultiply, ttype)
            
            //debug call .AdditiveAdjustments.print(0)
            //debug call .MultiplicativeAdjustments.print(0)
            
            if addOrMultiply == ADD_ADJUSTMENT then
                call .AdditiveAdjustments.addEnd(PlatformerPropertyAdjustment.create(ttype, value))
                //debug call .AdditiveAdjustments.print(0)
            elseif addOrMultiply == MULTIPLY_ADJUSTMENT then
                call .MultiplicativeAdjustments.addEnd(PlatformerPropertyAdjustment.create(ttype, value))
                //debug call .MultiplicativeAdjustments.print(0)
            endif
        endmethod
                
        public method destroy takes nothing returns nothing
            call this.clearAdjustments()
            
            call .AdditiveAdjustments.destroy()
            call .MultiplicativeAdjustments.destroy()
            
            call this.deallocate()
        endmethod
        
        public static method create takes nothing returns thistype
            local thistype new = thistype.allocate()
            
            set new.AdditiveAdjustments = SimpleList_List.create()
            set new.MultiplicativeAdjustments = SimpleList_List.create()
            
            return new
        endmethod
    endstruct
endlibrary