library Alloc /* v1.3.1.1
*************************************************************************************
*
*	*/ uses /*
*
*		*/ optional ErrorMessage	/*		github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage
*		*/ optional MemoryAnalysis	/*		
*
*************************************************************************************
*
*	Minimizes code generation and global variables while maintaining
*	excellent performance.
*
*		local thistype this = recycler[0]
*
*		if (recycler[this] == 0) then
*			set recycler[0] = this + 1
*		else
*			set recycler[0] = recycler[this]
*		endif
*
************************************************************************************
*
*	module Alloc
*
*		static method allocate takes nothing returns thistype
*		method deallocate takes nothing returns nothing
*
*		The Following Require Error Message To Be In The Map
*		--------------------------------------------------------
*
*			debug readonly boolean allocated
*
*		The Following Require Memory Analysis To Be In The Map
*		--------------------------------------------------------
*
*			readonly integer monitorCount
*			-	the amount of global memory being monitored by this
*			readonly integer monitorString
*			-	gets a string representation of all global memory being monitored by this
*			readonly integer address
*			-	global memory address for debugging
*			-	used with monitor and stopMonitor
*
*			static method calculateMemoryUsage takes nothing returns integer
*			static method getAllocatedMemoryAsString takes nothing returns string
*
*			method monitor takes string label, integer address returns nothing
*			-	monitor a global memory address with a label
*			-	used to identify memory leaks
*			-	should be memory that ought to be destroyed by the time this is destroyed
*			method stopMonitor takes integer address returns nothing
*			-	stops monitoring global memory
*			method stopMonitorValue takes handle monitoredHandle returns nothing
*			-	stops monitoring handle values
*
*			The Following Are Used To Monitor Handle Values
*
*				method monitor_widget				takes string label, widget				handleToTrack returns nothing
*				method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
*				method monitor_item				takes string label, item				handleToTrack returns nothing
*				method monitor_unit				takes string label, unit				handleToTrack returns nothing
*				method monitor_timer				takes string label, timer				handleToTrack returns nothing
*				method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
*				method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
*				method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
*				method monitor_force				takes string label, force				handleToTrack returns nothing
*				method monitor_group				takes string label, group				handleToTrack returns nothing
*				method monitor_location			takes string label, location			handleToTrack returns nothing
*				method monitor_rect				takes string label, rect				handleToTrack returns nothing
*				method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
*				method monitor_effect				takes string label, effect				handleToTrack returns nothing
*				method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
*				method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
*				method monitor_quest				takes string label, quest				handleToTrack returns nothing
*				method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
*				method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
*				method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
*				method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
*				method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
*				method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
*				method monitor_button				takes string label, button				handleToTrack returns nothing
*				method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
*				method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
*				method monitor_image				takes string label, image				handleToTrack returns nothing
*				method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
*				method monitor_region				takes string label, region				handleToTrack returns nothing
*				method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
*				method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
*
*
* Thanks to Ruke for the algorithm
************************************************************************************/
	module Alloc
		/*
		*	stack
		*/
		private static integer array recycler
		
		static if MemoryAnalysis_ENABLED then
			private MemoryMonitor globalAddress
			
			method operator address takes nothing returns integer
				call ThrowError(recycler[this] != -1, "Alloc", "address", "thistype", this, "Attempted To Access Null Instance.")
				return globalAddress
			endmethod
		endif
		
		/*
		*	allocation
		*/
		static method allocate takes nothing returns thistype
			local thistype this = recycler[0]
			
			static if LIBRARY_ErrorMessage then
				call ThrowError(this == 8192, "Alloc", "allocate", "thistype", 0, "Overflow.")
			endif
			
			if (recycler[this] == 0) then
				set recycler[0] = this + 1
			else
				set recycler[0] = recycler[this]
			endif
			
			static if LIBRARY_ErrorMessage then
				set recycler[this] = -1
			endif
			
			static if MemoryAnalysis_ENABLED then
				set globalAddress = MemoryMonitor.allocate("thistype")
			endif
			
			return this
		endmethod
		
		method deallocate takes nothing returns nothing
			static if LIBRARY_ErrorMessage then
				call ThrowError(recycler[this] != -1, "Alloc", "deallocate", "thistype", this, "Attempted To Deallocate Null Instance.")
			endif
			
			static if MemoryAnalysis_ENABLED then
				call globalAddress.deallocate()
				set globalAddress = 0
			endif
			
			set recycler[this] = recycler[0]
			set recycler[0] = this
		endmethod
		
		static if MemoryAnalysis_ENABLED then
			method monitor takes string label, integer address returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor(label, address)
			endmethod
			method stopMonitor takes integer address returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "stopMonitor", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.stopMonitor(address)
			endmethod
			method stopMonitorValue takes handle monitoredHandle returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "stopMonitorValue", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.stopMonitorValue(monitoredHandle)
			endmethod
			
			method operator monitorCount takes nothing returns integer
				call ThrowError(recycler[this] != -1, "Alloc", "monitorCount", "thistype", this, "Attempted To Access Null Instance.")
				return globalAddress.monitorCount
			endmethod
			method operator monitorString takes nothing returns string
				call ThrowError(recycler[this] != -1, "Alloc", "monitorString", "thistype", this, "Attempted To Access Null Instance.")
				return globalAddress.monitorString
			endmethod
			
			method monitor_widget				takes string label, widget				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_widget", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_widget(label, handleToTrack)
			endmethod
			method monitor_destructable		takes string label, destructable		handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_destructable", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_destructable(label, handleToTrack)
			endmethod
			method monitor_item				takes string label, item				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_item", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_item(label, handleToTrack)
			endmethod
			method monitor_unit				takes string label, unit				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_unit", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_unit(label, handleToTrack)
			endmethod
			method monitor_timer				takes string label, timer				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_timer", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_timer(label, handleToTrack)
			endmethod
			method monitor_trigger			takes string label, trigger				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_trigger", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_trigger(label, handleToTrack)
			endmethod
			method monitor_triggercondition	takes string label, triggercondition	handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_triggercondition", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_triggercondition(label, handleToTrack)
			endmethod
			method monitor_triggeraction		takes string label, triggeraction		handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_triggeraction", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_triggeraction(label, handleToTrack)
			endmethod
			method monitor_force				takes string label, force				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_force", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_force(label, handleToTrack)
			endmethod
			method monitor_group				takes string label, group				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_group", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_group(label, handleToTrack)
			endmethod
			method monitor_location			takes string label, location			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_location", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_location(label, handleToTrack)
			endmethod
			method monitor_rect				takes string label, rect				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_rect", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_rect(label, handleToTrack)
			endmethod
			method monitor_boolexpr			takes string label, boolexpr			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_boolexpr", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_boolexpr(label, handleToTrack)
			endmethod
			method monitor_effect				takes string label, effect				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_effect", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_effect(label, handleToTrack)
			endmethod
			method monitor_unitpool			takes string label, unitpool			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_unitpool", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_unitpool(label, handleToTrack)
			endmethod
			method monitor_itempool			takes string label, itempool			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_itempool", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_itempool(label, handleToTrack)
			endmethod
			method monitor_quest				takes string label, quest				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_quest", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_quest(label, handleToTrack)
			endmethod
			method monitor_defeatcondition	takes string label, defeatcondition		handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_defeatcondition", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_defeatcondition(label, handleToTrack)
			endmethod
			method monitor_timerdialog		takes string label, timerdialog			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_timerdialog", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_timerdialog(label, handleToTrack)
			endmethod
			method monitor_leaderboard		takes string label, leaderboard			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_leaderboard", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_leaderboard(label, handleToTrack)
			endmethod
			method monitor_multiboard			takes string label, multiboard			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_multiboard", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_multiboard(label, handleToTrack)
			endmethod
			method monitor_multiboarditem		takes string label, multiboarditem		handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_multiboarditem", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_multiboarditem(label, handleToTrack)
			endmethod
			method monitor_dialog				takes string label, dialog				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_dialog", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_dialog(label, handleToTrack)
			endmethod
			method monitor_button				takes string label, button				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_button", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_button(label, handleToTrack)
			endmethod
			method monitor_texttag			takes string label, texttag				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_texttag", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_texttag(label, handleToTrack)
			endmethod
			method monitor_lightning			takes string label, lightning			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_lightning", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_lightning(label, handleToTrack)
			endmethod
			method monitor_image				takes string label, image				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_image", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_image(label, handleToTrack)
			endmethod
			method monitor_ubersplat			takes string label, ubersplat			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_ubersplat", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_ubersplat(label, handleToTrack)
			endmethod
			method monitor_region				takes string label, region				handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_region", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_region(label, handleToTrack)
			endmethod
			method monitor_fogmodifier		takes string label, fogmodifier			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_fogmodifier", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_fogmodifier(label, handleToTrack)
			endmethod
			method monitor_hashtable			takes string label, hashtable			handleToTrack returns nothing
				call ThrowError(recycler[this] != -1, "Alloc", "monitor_hashtable", "thistype", this, "Attempted To Access Null Instance.")
				call globalAddress.monitor_hashtable(label, handleToTrack)
			endmethod
			
			static if MemoryAnalysis_ENABLED then
				//! runtextmacro MEMORY_ANALYSIS_STATIC_FIELD_NEW("recycler")
				
				static method calculateMemoryUsage takes nothing returns integer
					return calculateAllocatedMemory__recycler()
				endmethod
				
				static method getAllocatedMemoryAsString takes nothing returns string
					return allocatedMemoryString__recycler()
				endmethod
			endif
		endif
		
		/*
		*	analysis
		*/
		static if LIBRARY_ErrorMessage then
			method operator allocated takes nothing returns boolean
				return recycler[this] == -1
			endmethod
		endif
		
		/*
		*	initialization
		*/
		private static method onInit takes nothing returns nothing
			set recycler[0] = 1
		endmethod
	endmodule
endlibrary
