﻿local mod	= DBM:NewMod("ArtifactTwins", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(116409, 116410)--Raest Magespear, Karam Magespear
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 235317 235578",
	"SPELL_CAST_SUCCESS 235426",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2"
)

--General
local warnPhase					= mod:NewPhaseChangeAnnounce()
--Karam
local warnRisingDragon			= mod:NewSpellAnnounce(235426, 3)

--Karam
local specWarnFixate			= mod:NewSpecialWarningRun(202081, nil, nil, nil, 4, 2)
local specWarnGrasp				= mod:NewSpecialWarningInterrupt(235578, nil, nil, nil, 1, 2)
--Raest
local specWarnRift				= mod:NewSpecialWarningSwitch(235446, nil, nil, nil, 1, 2)
local specWarnRune				= mod:NewSpecialWarningMoveTo(236460, nil, nil, nil, 1, 2)

--Karam
local timerRisingDragonCD		= mod:NewCDTimer(35, 235426, nil, nil, nil, 2)
--Raest
local timerHandCD				= mod:NewNextTimer(28, 235580, nil, nil, nil, 1, 235578, DBM_CORE_DAMAGE_ICON)
local timerGraspCD				= mod:NewCDTimer(15, 235578, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerRuneCD				= mod:NewCDTimer(35, 236460, nil, nil, nil, 5)

local countHand					= mod:NewCountdown(28, 235580)
local countRune					= mod:NewCountdown("Alt35", 236460)

--Karam
local voiceFixate				= mod:NewVoice(202081)--justrun/keepmove
local voiceGrasp				= mod:NewVoice(235578)--kickcast/killmob
--Raest
local voiceRift					= mod:NewVoice(235446)--killmob
local voiceRunes				= mod:NewVoice(236460)--157060 (temp, until diff voice added for non yellow runes)

mod.vb.phase = 1

function mod:OnCombatStart(delay)
	self.vb.phase = 1
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 235317 then--Dismiss (cast by Raest Magespear for phase 2 and phase 4 start)
		self.vb.phase = self.vb.phase + 1
		if self.vb.phase == 2 then
			warnPhase:Show(DBM_CORE_AUTO_ANNOUNCE_TEXTS.phase:format(2))
		else--4
			warnPhase:Show(DBM_CORE_AUTO_ANNOUNCE_TEXTS.phase:format(4))
			timerHandCD:Stop()
			countHand:Cancel()
		end
	elseif spellId == 235578 then--Grasp from Beyond
		specWarnGrasp:Show(args.sourceName)
		voiceGrasp:Play("kickcast")
		timerGraspCD:Start(15, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 235426 then
		warnRisingDragon:Show()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 116409 then--Raest
		DBM:EndCombat(self)
	elseif cid == 118698 then--Hand
		timerGraspCD:Stop(args.destGUID)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID, spellId)
	--local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 202081 then--Fixate (Karam Magespear returning in phase 3 and 5)
		specWarnFixate:Show()
		voiceFixate:Play("justrun")
		voiceFixate:Schedule("keepmove")
		if self.vb.phase >= 2 then--Should filter fixate done on pull
			self.vb.phase = self.vb.phase + 1
			timerHandCD:Start(9)
			countHand:Start(9)
			if self.vb.phase == 3 then
				warnPhase:Show(DBM_CORE_AUTO_ANNOUNCE_TEXTS.phase:format(3))
			else--5
				warnPhase:Show(DBM_CORE_AUTO_ANNOUNCE_TEXTS.phase:format(5))
				timerRuneCD:Start(18.2)
				countRune:Start(18.2)
				timerRisingDragonCD:Start(25)--Only one time? need more data to be sure
			end
		end
	elseif spellId == 235580 then--Hand from Beyond
		--voiceGrasp:Schedule(1, "killmob")
		timerHandCD:Start()
		countHand:Start()
	elseif spellId == 236468 then--Rune of Summoning
		specWarnRune:Show(RUNES)
		voiceRunes:Play("157060")
		timerRuneCD:Start()
		countRune:Start()
	elseif spellId == 235525 then--Tear Rift (about 3 seconds after Dismiss)
		specWarnRift:Show()
		voiceRift:Play("killmob")
	end
end

--[[
--"<53.75 21:03:46> [CHAT_MSG_MONSTER_EMOTE] |TInterface\\Icons\\spell_shaman_earthquake:20|t%s readies itself to charge!#Jormog the Behemoth###Kylistà##0#0##0#12#nil#0#false#false#false#false", -- [133]
function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg:find("Interface\\Icons\\spell_shaman_earthquake") then
		specWarnCharge:Show()
		voiceCharge:Play("charge")
	end
end
--]]
