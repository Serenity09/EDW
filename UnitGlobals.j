library UnitGlobals
    globals
        //mazer type
        constant integer MAZER = 'Edem'
        constant integer TEAM_REVIVE_UNIT_ID = 'rTEM'
        
        //patrols
        //should be filtered in (does collide)
        constant integer LGUARD = 'e002'
        constant integer GUARD = 'e000'
        
        constant integer ICETROLL = 'n002'
		
		constant integer SPIRITWALKER = 'o002'
		
		constant integer CLAWMAN = 'e00U'
        
		constant integer TANK = 'h001'
		
        //attacking units
        //should be filtered out (not collide)
        constant integer ROGTHT = 'n000'
        
        //unmoving obstacles
        //should be filtered in (does collide)
        constant integer REGRET = 'e003'
        constant integer LMEMORY = 'e004'
        constant integer GUILT = 'e005'
		
		constant integer FROG = 'n003'
        
        //mortars
        //should be filtered out (not collide)
        constant integer SMLMORT = 'h000'
        
        //targets
        //should be filtered out (not collide)
        constant integer SMLTARG = 'e006'
        constant integer MEDTARG = 'e007'
        constant integer LRGTARG = 'e008'
        
        //wisp wheel wisps
        //case to case on whether or not to filter
        constant integer WWWISP = 'e009'
        constant integer WWSKUL = 'e00A'
        
        //keys and barriers
        constant integer KEYR = 'e00D' //red fire key
        constant integer RKEY = 'e00C' //removes all keys from mazer
        constant integer RFIRE = 'e00B' //red fire
        constant integer BKEY = 'e00F' //blue fire key
        constant integer BFIRE = 'e00E' //blue fire
        constant integer GKEY = 'e00H' //green fire key
        constant integer GFIRE = 'e00G' //green fire
        
        constant integer BLACKHOLE = 's666'
        constant real BLACKHOLE_TIMESTEP = 1.5
        constant real BLACKHOLE_MAXRADIUS = 5 * 128 //this might make lag with multiple players
        
        debug constant integer DEBUG_UNIT = 'eTST' //NOT USED FOR ANYTHING IN RELEASE MODE
    endglobals
endlibrary