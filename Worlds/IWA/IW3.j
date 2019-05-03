library IW3 requires Recycle, Levels
	function IW3Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(IW3_LEVEL_ID)
		
		//patrols
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_124, gg_rct_Rect_125)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_126, gg_rct_Rect_127)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_128, gg_rct_Rect_129)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_130, gg_rct_Rect_131)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_132, gg_rct_Rect_133)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_135, gg_rct_Rect_134)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_136, gg_rct_Rect_137)
		
		//P2
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_138, gg_rct_Rect_139)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_140, gg_rct_Rect_141)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_142, gg_rct_Rect_143)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_144, gg_rct_Rect_145)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_146, gg_rct_Rect_147)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_148, gg_rct_Rect_149)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_150, gg_rct_Rect_151)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_152, gg_rct_Rect_153)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_154, gg_rct_Rect_155)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_156, gg_rct_Rect_157)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_158, gg_rct_Rect_159)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_160, gg_rct_Rect_161)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_162, gg_rct_Rect_163)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_164, gg_rct_Rect_165)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_166, gg_rct_Rect_167)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_168, gg_rct_Rect_169)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_170, gg_rct_Rect_171)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_172, gg_rct_Rect_173)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_174, gg_rct_Rect_175)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_176, gg_rct_Rect_177)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_178, gg_rct_Rect_179)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_180, gg_rct_Rect_181)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_182, gg_rct_Rect_183)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_184, gg_rct_Rect_185)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_186, gg_rct_Rect_187)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_188, gg_rct_Rect_189)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_190, gg_rct_Rect_191)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_192, gg_rct_Rect_193)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_194, gg_rct_Rect_195)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_196, gg_rct_Rect_197)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_198, gg_rct_Rect_199)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_200, gg_rct_Rect_201)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_207, gg_rct_Rect_208)
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_202, gg_rct_Rect_203)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_204, gg_rct_Rect_205)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_280, gg_rct_Rect_281)    
	endfunction

	function IW3Stop takes nothing returns nothing
	endfunction
endlibrary