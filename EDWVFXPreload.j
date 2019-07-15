library EDWVFXPreload initializer init requires SpecialEffect, Platformer, SandMovement
	private function init takes nothing returns nothing
		//gamemode changes
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_PLATFORMING_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_STANDARD_FX, 0, 0))
		
		//collision effects
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireMissile.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\SunderingBlades\\SunderingBlades.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdl", 0, 0))
		
		//standard mazing terrain effects
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_LAVA_MOVEMENT_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(StandardGameLoop_VINES_MOVEMENT_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(SAND_MOVEMENT_FX, 0, 0))
	
		//platforming terrain effects
		call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect("Doodads\\Icecrown\\Water\\BubbleGeyserSteam\\BubbleGeyserSteam.mdl", 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_VINES_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_SUPERBOUNCE_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_VERTICAL_JUMP_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_NON_VERTICAL_JUMP_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_OCEAN_JUMP_FX, 0, 0))
		call DestroyEffect(AddSpecialEffect(Platformer_TERRAIN_KILL_FX, 0, 0))
		
	endfunction
endlibrary