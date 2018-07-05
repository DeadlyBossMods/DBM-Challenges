﻿local mod	= DBM:NewMod("Kruul", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(117933, 117198)--Variss, Kruul
mod:SetZone()
mod:SetBossHPInfoToHighest()
mod.soloChallenge = true
mod.onlyNormal = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 234423 233473 234631 241717 236537 236572 234676",
	"SPELL_CAST_SUCCESS 236572",
	"SPELL_AURA_APPLIED 234422",
	"SPELL_AURA_APPLIED_DOSE 234422",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3"
)

--Tank
-- Stack warning? what amounts switch from reg warning to special warning?
-- Improve timers still with more data?
-- Countdown prioriites?
--Tank (Kruul)
local warnHolyWard				= mod:NewCastAnnounce(233473, 1)
local warnDecay					= mod:NewStackAnnounce(234422, 3)
local warnShadowSweep			= mod:NewSpellAnnounce(234441, 3)
----Add Spawns
local warnTormentingEye			= mod:NewSpellAnnounce(234428, 2)
local warnNetherAberration		= mod:NewSpellAnnounce(235110, 2)
local warnInfernal				= mod:NewSpellAnnounce(235112, 2)

--Tank
local specWarnDecay				= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6)
local specWarnDrainLife			= mod:NewSpecialWarningInterrupt(234423, nil, nil, 2, 3, 2)
local specWarnSmash				= mod:NewSpecialWarningDodge(234631, nil, nil, nil, 1, 2)
local specWarnAnnihilate		= mod:NewSpecialWarningDefensive(236572, nil, nil, nil, 1, 2)
local specWarnTwistedReflection	= mod:NewSpecialWarningInterrupt(234676, nil, nil, nil, 3, 2)

--Tank
local timerDrainLifeCD			= mod:NewCDTimer(24.3, 234423, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerHolyWardCD			= mod:NewCDTimer(33, 233473, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerHolyWard				= mod:NewCastTimer(8, 233473, nil, false, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerTormentingEyeCD		= mod:NewCDTimer(15.4, 234428, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)--15.4-19.4
local timerNetherAbberationCD	= mod:NewCDTimer(35, 235110, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerInfernalCD			= mod:NewCDTimer(65, 235112, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
--Phase 2
local timerShadowSweepCD		= mod:NewCDTimer(20, 234441, nil, nil, nil, 3)--20-27
local timerAnnihilateCD			= mod:NewCDCountTimer(27, 236572, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)

local countdownAbberations		= mod:NewCountdown(35, 235110)
local countdownDrainLife		= mod:NewCountdown("Alt24", 234423)
local countdownInfernal			= mod:NewCountdown("AltTwo65", 235112)
--Phase 2
local countdownAnnihilate		= mod:NewCountdown("Alt27", 236572)

mod.vb.phase = 1
mod.vb.annihilateCast = 0
local activeBossGUIDS = {}

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	self.vb.annihilateCast = 0
	timerTormentingEyeCD:Start(3.8)--3.8-5
	timerDrainLifeCD:Start(5)--5-9?
	countdownDrainLife:Start(5)
	timerHolyWardCD:Start(8)--8-16
	timerNetherAbberationCD:Start(9.6)--9.6-12.3
	countdownAbberations:Start(9.6)
	timerInfernalCD:Start(37.5)--37-43
	countdownInfernal:Start(37.5)
	DBM:AddMsg("There is a chance some of these timers are health based and can't be completely relied upon. More data is needed")
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 234423 then
		specWarnDrainLife:Show(args.sourceName)
		specWarnDrainLife:Play("kickcast")
		timerDrainLifeCD:Start()
		countdownDrainLife:Start()
	elseif spellId == 233473 then
		warnHolyWard:Show()
		timerHolyWard:Start()
		timerHolyWardCD:Start()
	elseif (spellId == 234631 or spellId == 241717 or spellId == 236537) and self:AntiSpam(2.5, 1) then
		specWarnSmash:Show()
		specWarnSmash:Play("shockwave")
	elseif spellId == 236572 then
		specWarnAnnihilate:Show()
		specWarnAnnihilate:Play("defensive")
	elseif spellId == 234676 then
		specWarnTwistedReflection:Show(args.sourceName)
		specWarnTwistedReflection:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 236572 then--Timer here, boss sometimes stutter casts/interrupts his own annihilate cast to do soething else, then returns to annihilate 4-5 seconds later
		self.vb.annihilateCast = self.vb.annihilateCast + 1
		timerAnnihilateCD:Start(25, self.vb.annihilateCast+1)
		countdownAnnihilate:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 234422 then
		local amount = args.amount or 1
		if amount >= 5 then
			specWarnDecay:Show(amount)
			if amount > 10 then
				specWarnDecay:Play("runout")
			else
				specWarnDecay:Play("stackhigh")
			end
		elseif amount % 2 == 0 then
			warnDecay:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 117933 then--Variss
		self.vb.phase = 2
		timerDrainLifeCD:Stop()
		countdownDrainLife:Cancel()
		timerTormentingEyeCD:Stop()
		timerNetherAbberationCD:Stop()
		countdownAbberations:Cancel()
		timerInfernalCD:Stop()
		countdownInfernal:Cancel()
		--timerAnnihilateCD:Start(16.5, 1)--16-28?, too variable, disabled for now
		--Does holy ward reset here? reset timer here if it does
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 234428 then--Summon Tormenting Eye
		warnTormentingEye:Show()
		timerTormentingEyeCD:Start()
	elseif spellId == 235110 then--Nether Aberration
		warnNetherAberration:Show()
		if self.vb.phase == 2 then
			timerNetherAbberationCD:Start(30)
			countdownAbberations:Start(30)
		else
			timerNetherAbberationCD:Start()--35
			countdownAbberations:Start(35)
		end
	elseif spellId == 235112 then--Smoldering Infernal Summon
		warnInfernal:Show()
		timerInfernalCD:Start()
		countdownInfernal:Start()
	elseif spellId == 234920 then
		warnShadowSweep:Show()
		timerShadowSweepCD:Start()
	elseif spellId == 233456 then--Kill Credit
		DBM:EndCombat(self)
	end
end
