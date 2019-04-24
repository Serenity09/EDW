//alternate version of Alloc for designs that I want struct syntax for, but do not really need to take advantage of dynamic allocation/deallocation & index recycling
library PermanentAlloc
	module PermanentAlloc
		private static integer c = 1
		
		static method allocate takes nothing returns thistype
			local thistype new = c
			
			set c = c + 1
			
			return new
		endmethod
		//no deallocate for this module, use vanilla Alloc if you need that functionality
	endmodule
endlibrary