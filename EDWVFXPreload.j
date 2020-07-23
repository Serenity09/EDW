library EDWVFXPreload initializer init requires LocationGlobals, SpecialEffect, Platformer, SandMovement
	private function init takes nothing returns nothing
		//gamemode changes
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_PLATFORMING_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_STANDARD_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", DEBUG_X, DEBUG_Y))
		
		//collision effects
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireMissile.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\SunderingBlades\\SunderingBlades.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdl", DEBUG_X, DEBUG_Y))
		
		//standard mazing terrain effects
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_LAVA_MOVEMENT_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_VINES_MOVEMENT_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(SAND_MOVEMENT_FX, DEBUG_X, DEBUG_Y))
	
		//platforming terrain effects
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect("Doodads\\Icecrown\\Water\\BubbleGeyserSteam\\BubbleGeyserSteam.mdl", DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_VINES_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(PlatformerBounce_TERRAIN_SUPERBOUNCE_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_VERTICAL_JUMP_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_NON_VERTICAL_JUMP_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_OCEAN_JUMP_FX, DEBUG_X, DEBUG_Y))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_KILL_FX, DEBUG_X, DEBUG_Y))
		
	endfunction
endlibrary