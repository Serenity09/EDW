library EDWEffects requires SpecialEffect
    function CPEffect takes integer i returns nothing
        call DestroyLightning(AddLightning("AFOD", false, GetUnitX(MazersArray[i]), GetUnitY(MazersArray[i]), 0, 0))
    endfunction
    
    function CollisionDeathEffect takes unit target, unit source returns nothing
		local integer sourceTypeID = GetUnitTypeId(source)
		call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target))
		
		if sourceTypeID == LGUARD or sourceTypeID == GUARD or sourceTypeID == WWWISP or sourceTypeID == WWSKUL then
			call CreateTimedSpecialEffectTarget("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", target, SpecialEffect_CHEST, GetOwningPlayer(target), 2.)
		elseif sourceTypeID == REGRET or sourceTypeID == LMEMORY or sourceTypeID == GUILT then
			call CreateTimedSpecialEffect("Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target), 2.)
		elseif sourceTypeID == ICETROLL or sourceTypeID == SPIRITWALKER or sourceTypeID == CLAWMAN or IndexedUnit(GetUnitUserData(source)).RectangularGeometry then
			//TODO reduce scale
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
	
	function GravityEffect takes unit target, unit source returns nothing
		//call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", source, SpecialEffect_ORIGIN, GetOwningPlayer(target))
		local effect fx = CreateSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target))
		call BlzSetSpecialEffectScale(fx, .5)
		call BlzSetSpecialEffectAlpha(fx, 55)
		call DestroyEffect(fx)
		//call BlzSetSpecialEffectPitch(fx, bj_PI / 2)
		set fx = null
		
		call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", GetUnitX(target), GetUnitY(target), GetOwningPlayer(target))
	endfunction
	function BounceEffect takes unit target, unit source returns nothing
		// local effect fx = CreateSpecialEffect("Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target))
		// call BlzSetSpecialEffectScale(fx, .5)
		// call BlzSetSpecialEffectAlpha(fx, 55)
		// call DestroyEffect(fx)
		// set fx = null
		
		//call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\SpellSteal\\SpellStealTarget.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target))
		// local effect fx = CreateSpecialEffectTarget("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", source, "origin", GetOwningPlayer(target))
		// call BlzSetSpecialEffectAlpha(fx, 0)
		// call DestroyEffect(fx)
		// set fx = null
		
		local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Human\\SunderingBlades\\SunderingBlades.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target), 1.)
		call BlzSetSpecialEffectScale(fx, 2.)
		set fx = null
		
		//play spell steal target sound
		
		// call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", source, SpecialEffect_CHEST, GetOwningPlayer(target))
		// call CreateInstantSpecialEffect("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target))
				
		//local effect fx = CreateTimedSpecialEffectTarget("Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdl", source, SpecialEffect_ORIGIN, GetOwningPlayer(target), .5)
		
		//call BlzSetSpecialEffectScale(fx, 3)
		//call BlzSetSpecialEffectAlpha(fx, 200)
		
		// set fx = null
		
		//call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", source, "origin", GetOwningPlayer(target))
	endfunction
	function DirectionalBounceEffect takes unit target, unit source returns nothing
		call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl", target, SpecialEffect_CHEST, GetOwningPlayer(target))
	endfunction
	function SuperSpeedEffect takes unit target, unit source returns nothing
		local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireMissile.mdl", GetUnitX(source), GetUnitY(source), GetOwningPlayer(target), 1.)
		call BlzSetSpecialEffectYaw(fx, GetUnitFacing(source) * bj_DEGTORAD)
		set fx = null
		
		call User(GetPlayerId(GetOwningPlayer(target))).CreateUserTimedEffect("Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl", SpecialEffect_CHEST, 2.)
    endfunction
	
	function HardStopEffect takes Platformer p, real velocity returns nothing
		// local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", GetUnitX(p.Unit), GetUnitY(p.Unit), Player(p.PID), .5)
		// //local effect fx = CreateTimedSpecialEffect("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", GetUnitX(p.Unit), GetUnitY(p.Unit), Player(p.PID), .5)
		// local real scale
		
		// if velocity < 0 then
			// set velocity = -velocity
		// endif
		// set scale = velocity / VELOCITY_HARDSTOP_THRESHOLD / 20.
		// if scale > 3. then
			// set scale = 3.
		// endif
		
		// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Hard stop scale: " + R2S(scale))
		
		// call BlzSetSpecialEffectScale(fx, scale)
		// call BlzSetSpecialEffectAlpha(fx, 100)
		// //call DestroyEffect(fx)
		// set fx = null
		
		if User(p.PID).ActiveEffect != null then
			call DestroyEffect(User(p.PID).ActiveEffect)
			set User(p.PID).ActiveEffect = null
		endif
	endfunction
	
	function TeleportEffect takes widget source, User target returns nothing
		call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl", target.ActiveUnit, SpecialEffect_ORIGIN, Player(target))
	endfunction
	function CollectibleAcquireEffect takes Collectible source, User target returns nothing
		//call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", source.UncollectedUnit, SpecialEffect_ORIGIN, Player(target))
		//call CreateInstantSpecialEffect("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", GetUnitX(source.UncollectedUnit), GetUnitY(source.UncollectedUnit), Player(target))
		local effect fx = CreateSpecialEffect("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", GetUnitX(source.UncollectedUnit), GetUnitY(source.UncollectedUnit), Player(target))
		call BlzSetSpecialEffectScale(fx, .5)
		
		call DestroyEffect(fx)
		set fx = null
	endfunction
	
	function AddContinueEffect takes InWorldPowerup source, User target returns nothing
		call CreateTimedSpecialEffect("Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl", GetUnitX(source.Unit), GetUnitY(source.Unit), Player(target), 3.)
	endfunction
	function StealContinueEffect takes InWorldPowerup source, User target returns nothing
		//TODO show parasite overhead team stolen from
		
		local effect fx = CreateSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", GetUnitX(source.Unit), GetUnitY(source.Unit), Player(target))
		call BlzSetSpecialEffectYaw(fx, Atan2(GetUnitY(source.Unit) - GetUnitY(target.ActiveUnit), GetUnitX(source.Unit) - GetUnitX(target.ActiveUnit)) + bj_PI)
		call DestroyEffect(fx)
		set fx = null
		
		call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", target.ActiveUnit, SpecialEffect_ORIGIN, Player(target))
	endfunction
	
	function AddScoreEffect takes InWorldPowerup source, User target returns nothing
		call CreateInstantSpecialEffectTarget("Abilities\\Spells\\Items\\ResourceItems\\ResourceEffectTarget.mdl", target.ActiveUnit, SpecialEffect_ORIGIN, Player(target))
		call CreateInstantSpecialEffect("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", GetUnitX(source.Unit), GetUnitY(source.Unit), Player(target))
		//TODO play gold coin sound		
	endfunction
	function StealScoreEffect takes InWorldPowerup source, User target returns nothing
		//TODO show parasite overhead team stolen from
		
		local effect fx = CreateSpecialEffect("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", GetUnitX(source.Unit), GetUnitY(source.Unit), Player(target))
		call BlzSetSpecialEffectScale(fx, 1.5)
		call DestroyEffect(fx)
		set fx = null
	endfunction
endlibrary