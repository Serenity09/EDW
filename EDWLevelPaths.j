library EDWLevelPaths requires LevelIDGlobals, EDWLevels, SimpleList, Teams, Levels, LevelPath
	globals
		private constant boolean FINALIZE_PATHS = false
	endglobals
	
	public function Initialize takes nothing returns nothing
		local Levels_Level l
		local Checkpoint cp
        
		local LevelPath path
		local LevelPathNode pathNodeA
		local LevelPathNode pathNodeB
		local LevelPathNode pathNodeC
		
		local LevelPathNode pathNodeStart
		local LevelPathNode pathNodeEnd
				
		//FIRST LEVEL INITS HARD CODED
        set l = Levels_Level(INTRO_LEVEL_ID)
		
        //DOORS HARD CODED
        //currently no start or stop logic
        
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level(IW1_LEVEL_ID)
		call l.InitializeDefaultLevelPaths()
        //Checkpoint 0
		set path = l.GetCheckpoint(0).Path
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P1)
		call path.Start.AddNextNode(pathNodeA)
		set pathNodeB = LevelPathNode.createFromRect(gg_rct_IW1_P2)
		call path.Start.AddNextNode(pathNodeB)
				
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P3)
		call pathNodeA.AddNextNode(pathNodeC)
		call pathNodeB.AddNextNode(pathNodeC)
				
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P4)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P5)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P6)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P7)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P8)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P9)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P10)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P11)
		call pathNodeA.AddNextNode(pathNodeC)

		call pathNodeC.AddNextNode(path.End)
		
		static if FINALIZE_PATHS then
			call path.Finalize()
		endif
		
		//Checkpoint 1
		set path = l.GetCheckpoint(1).Path
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P12)
		call path.Start.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P13)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P14)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P15)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P16)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P17)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P18)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P19)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P20)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P21)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P22)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P23)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P24)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P25)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P26)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P27)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P28)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P29)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P30)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeB = LevelPathNode.createFromRect(gg_rct_IW1_P31)
		call pathNodeC.AddNextNode(pathNodeB)
		call pathNodeB.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P32)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P33)
		call pathNodeC.AddNextNode(pathNodeA)
		
		set pathNodeC = LevelPathNode.createFromRect(gg_rct_IW1_P34)
		call pathNodeA.AddNextNode(pathNodeC)
		
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_IW1_P35)
		call pathNodeC.AddNextNode(pathNodeA)
		
		call pathNodeA.AddNextNode(path.End)
		
		static if FINALIZE_PATHS then
			call path.Finalize()
		endif
        
        //LEVEL 2
        set l = Levels_Level(IW2_LEVEL_ID)
		call l.InitializeDefaultLevelPaths()
        //Checkpoint 0
		set path = l.GetCheckpoint(0).Path
		        
		set pathNodeStart = LevelPathNode.createFromRect(gg_rct_IW2_P1)
		call path.Start.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P2)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P3)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P4)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P5)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P6)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P7)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P8)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P9)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P10)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P11)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P12)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P13)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		call pathNodeStart.AddNextNode(path.End)
		
		static if FINALIZE_PATHS then
			call path.Finalize()
		endif
		
		//Checkpoint 1
		set path = l.GetCheckpoint(1).Path
		
		set pathNodeStart = LevelPathNode.createFromRect(gg_rct_IW2_P14)
		call path.Start.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P15)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		set pathNodeA = pathNodeStart

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P16)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P17)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		call pathNodeA.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P18)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P19)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P20)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P21)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P22)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P23)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P24)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P25)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P26)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P27)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P28)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P29)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P30)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P31)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P32)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P33)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P34)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P35)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P36)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		set pathNodeA = pathNodeStart

		//branch A
		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P37)
		call pathNodeA.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		set pathNodeB = pathNodeStart

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P38)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		
		call pathNodeStart.AddNextNode(path.End)
		
		//branch B
		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P39)
		call pathNodeA.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		//loop back
		call pathNodeStart.AddNextNode(pathNodeB)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P40)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P41)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_IW2_P42)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		call pathNodeStart.AddNextNode(path.End)
		
		static if FINALIZE_PATHS then
			call path.Finalize()
		endif
		
		//checkpoint 2
		set path = l.GetCheckpoint(2).Path
		
		set pathNodeStart = LevelPathNode.createFromRect(gg_rct_Region_619)
		call path.Start.AddNextNode(pathNodeStart)
		set pathNodeB = pathNodeStart
		
		//alt route
		set pathNodeA = LevelPathNode.createFromRect(gg_rct_Region_667)
		call path.Start.AddNextNode(pathNodeA)
		call pathNodeA.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_620)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_621)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		set pathNodeC = pathNodeStart

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_622)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		//shortcut
		call pathNodeB.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_623)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_624)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		//shortcut
		call pathNodeC.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_625)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_626)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_627)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_628)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_629)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_630)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_631)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_632)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_633)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_634)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_635)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_636)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_637)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_638)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_639)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_640)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_641)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_642)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_643)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_644)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_645)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_646)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_647)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_648)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_649)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_650)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_651)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_652)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_653)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_654)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_655)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_656)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_657)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_658)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_659)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_660)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_661)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		set pathNodeA = pathNodeStart

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_662)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_663)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_664)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd
		//shortcut
		call pathNodeA.AddNextNode(pathNodeStart)

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_665)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		set pathNodeEnd = LevelPathNode.createFromRect(gg_rct_Region_666)
		call pathNodeStart.AddNextNode(pathNodeEnd)
		set pathNodeStart = pathNodeEnd

		call pathNodeStart.AddNextNode(path.End)
		
		static if FINALIZE_PATHS then
			call path.Finalize()
		endif
		call path.Finalize()
        
        //LEVEL 3
        set l = Levels_Level(IW3_LEVEL_ID)
        
		
        //LEVEL 4
        set l = Levels_Level(IW4_LEVEL_ID)
        
                
        //LEVEL 5
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level(IW5_LEVEL_ID)
						
        endif
				
		//ICE WORLD B
		//LEVEL 1
		set l = Levels_Level(IWB1_LEVEL_ID)
				
		//LAND WORLD A
		//LEVEL 1

		//LEVEL 2
		
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level(PW1_LEVEL_ID)
		
        //LEVEL 2
        set l = Levels_Level(PW2_LEVEL_ID)
        
        //LEVEL 3
        set l = Levels_Level(PW3_LEVEL_ID)
		
        //Justine's Four Seasons
		set l = Levels_Level(FS1_LEVEL_ID)

	endfunction
endlibrary