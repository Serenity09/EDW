library EDWLevelPaths requires LevelIDGlobals, EDWLevels, SimpleList, Teams, Levels, LevelPath
	public function Initialize takes nothing returns nothing
		local Levels_Level l
		local Checkpoint cp
        
		local LevelPath path
		local LevelPathNode pathNodeA
		local LevelPathNode pathNodeB
		local LevelPathNode pathNodeC
				
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
		
		call path.Finalize()
		
		//Checkpoint 1
		set path = l.GetCheckpoint(1).Path
		
		call path.Finalize()
        
        //LEVEL 2
        set l = Levels_Level(IW2_LEVEL_ID)
        
		
        
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