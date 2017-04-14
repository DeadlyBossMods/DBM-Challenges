﻿local mod	= DBM:NewMod("Kruul", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(117933, 117198)--Variss, Kruul
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 234423 233473",
	"SPELL_AURA_APPLIED 234422",
	"SPELL_AURA_APPLIED_DOSE 234422",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3"
)

--Notes:
--TODO, all. mapids, mob iDs, win event to stop timers (currently only death event stops them)
--Tank
-- Stack warning? what amounts switch from reg warning to special warning?
-- Variss 117933 does things, Only have very little of it. Need more CDs, more warnings
-- Boss after does things, have no logs of that
--Tank (Kruul)
local warnHolyWard			= mod:NewCastAnnounce(233473, 1)
local warnDecay				= mod:NewStackAnnounce(234422, 3)
----Add Spawns
local warnTormentingEye		= mod:NewSpellAnnounce(234428, 2)
local warnNetherAberration	= mod:NewSpellAnnounce(235110, 2)
local warnInfernal			= mod:NewSpellAnnounce(235112, 2)

--Tank
local specWarnDecay			= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6)
local specWarnDrainLife		= mod:NewSpecialWarningInterrupt(234423)

--Tank
local timerDrainLifeCD			= mod:NewCDTimer(24.3, 234423, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerHolyWardCD			= mod:NewCDTimer(33, 233473, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerHolyWard				= mod:NewCastTimer(8, 233473, nil, false, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerTormentingEyeCD		= mod:NewCDTimer(16.6, 234428, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerNetherAbberationCD	= mod:NewCDTimer(38, 235110, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerInfernalCD			= mod:NewCDTimer(53, 235112, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

--local countdownTimer		= mod:NewCountdownFades(10, 141582)

--Tank
local voiceDecay			= mod:NewVoice(234422)--stackhigh
local voiceDrainLife		= mod:NewVoice(234423)--kickcast

mod.vb.phase = 1
local activeBossGUIDS = {}

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	timerTormentingEyeCD:Start(3.8)--3.8-5
	timerDrainLifeCD:Start(5)--5-9?
	timerHolyWardCD:Start(8)
	timerNetherAbberationCD:Start(9.6)--9.6-12.3
	timerInfernalCD:Start(37.5)
	DBM:AddMsg("There is a good chance a few of these timers are health based and can't be relied upon. More data is needed to determine what timers are cooldowns and what are just based on your dps")
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 234423 then
		specWarnDrainLife:Show(args.sourceName)
		voiceDrainLife:Play("kickcast")
		timerDrainLifeCD:Start()
	elseif spellId == 233473 then
		warnHolyWard:Show()
		timerHolyWard:Start()
		timerHolyWardCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 234422 then
		local amount = args.amount or 1
		if amount >= 5 then
			specWarnDecay:Show(amount)
			voiceDecay:Play("stackhigh")
		else
			warnDecay:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
		table.wipe(activeBossGUIDS)
		timerDrainLifeCD:Stop()
		timerTormentingEyeCD:Stop()
		timerHolyWardCD:Stop()
		timerNetherAbberationCD:Stop()
	end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 117933 then--Variss
		self.vb.phase = 2
		timerDrainLifeCD:Stop()
		timerTormentingEyeCD:Stop()
		timerNetherAbberationCD:Stop()
		--Does holy ward reset here? reset timer here if it does
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 234428 then--Summon Tormenting Eye
		warnTormentingEye:Show()
		timerTormentingEyeCD:Start()--15?
	elseif spellId == 235110 then--Nether Aberration
		warnNetherAberration:Show()
		timerNetherAbberationCD:Start()
	elseif spellId == 235112 then--Smoldering Infernal Summon
		warnInfernal:Show()
		timerInfernalCD:Start()
	end
end