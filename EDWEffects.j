library EDWEffects requires SpecialEffect
    function CPEffect takes integer i returns nothing
        call DestroyLightning(AddLightning("AFOD", false, GetUnitX(MazersArray[i]), GetUnitY(MazersArray[i]), 0, 0))
    endfunction
    
    function CollisionDeathEffect takes unit target, unit source returns nothing
		local integer sourceTypeID = GetUnitTypeId(source)
		call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target))
		
		if sourceTypeID == LGUARD or sourceTypeID == GUARD or sourceTypeID == WWWISP or sourceTypeID == WWSKUL then
			call CreateTimedSpecialEffectTarget("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", target, SpecialEffect_CHEST, 2.)
		elseif sourceTypeID == REGRET or sourceTypeID == LMEMORY or sourceTypeID == GUILT then
			call CreateTimedSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target), 2.)
		elseif sourceTypeID == ICETROLL or sourceTypeID == SPIRITWALKER or sourceTypeID == CLAWMAN or IndexedUnit(GetUnitUserData(source)).RectangularGeometry then
			call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target))
		endif
    endfunction
    
    function TerrainDeathEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
		call CreateInstantSpecialEffect("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction
        
    function RShieldEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction
	function RFireEffect takes unit target, unit source returns nothing
		local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireMissile.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target), 1.5)
		call BlzSetSpecialEffectYaw(fx, Atan2(GetUnitY(source) - GetUnitY(target), GetUnitX(source) - GetUnitX(target)) + bj_PI)
		set fx = null
    endfunction
    
    function BShieldEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction
	function BFireEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction
    
    function GShieldEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction
	function GFireEffect takes unit target, unit source returns nothing
		// local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmMissile.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target), 1.5)
		// call BlzSetSpecialEffectYaw(fx, Atan2(GetUnitY(source) - GetUnitY(target), GetUnitX(source) - GetUnitX(target)) + bj_PI)
		// set fx = null
		
		call CreateInstantSpecialEffect("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target))
    endfunction
    
    function ShieldRemoveEffect takes unit u returns nothing
		call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", GetUnitX(u), GetUnitY(u), GetOwningPlayer(u))
    endfunction    
endlibrary