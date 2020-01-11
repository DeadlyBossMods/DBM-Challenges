local mod	= DBM:NewMod("d1995", "DBM-Challenges", 3)--1993 Stormwind 1995 Org
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone()
mod.noStatistics = true

mod:RegisterCombat("scenario", 2212)--2212, 2213 (org, stormwind)

--RegisterEvents
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 297822 297746 304976 297574 304251 306726",
	"SPELL_AURA_APPLIED 311390 306955 315385 316481 311641",
	"SPELL_AURA_APPLIED_DOSE 311390",
	"SPELL_CAST_SUCCESS 310173",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
--	"SCENARIO_UPDATE"
)

--TODO, detect engaging of end bosses for start timers
--TODO, notable trash or affix warnings
--TODO, detect hard modes on end boss
--TODO, verify if scenario is appropriate combat tactic for this mod
--Extra Abilities (used by Thrall and the area LTs)
local warnCriesoftheVoid		= mod:NewCastAnnounce(304976, 4)
local warnVoidQuills			= mod:NewCastAnnounce(304251, 3)

--General (GTFOs and Affixes)
local specWarnGTFO				= mod:NewSpecialWarningGTFO(312121, nil, nil, nil, 1, 8)
local specWarnEntomophobia		= mod:NewSpecialWarningJump(311389, nil, nil, nil, 1, 6)
local specWarnDarkDelusions		= mod:NewSpecialWarningRun(306955, nil, nil, nil, 4, 2)
local specWarnScorchedFeet		= mod:NewSpecialWarningYou(315385, nil, nil, nil, 1, 2)
local yellScorchedFeet			= mod:NewYell(315385)
local specWarnSplitPersonality	= mod:NewSpecialWarningYou(316481, nil, nil, nil, 1, 2)
local specWarnWaveringWill		= mod:NewSpecialWarningReflect(311641, "false", nil, nil, 1, 2)--Off by default, it's only 5%, but that might matter to some classes
local specWarnHauntingShadows	= mod:NewSpecialWarningDodge(310173, nil, nil, nil, 2, 2)
--Thrall
local specWarnSurgingDarkness	= mod:NewSpecialWarningDodge(297822, nil, nil, nil, 2, 2)
local specWarnSeismicSlam		= mod:NewSpecialWarningDodge(297746, nil, nil, nil, 2, 2)--Can this be dodged?
--Extra Abilities (used by Thrall and the area LTs)
local specWarnHopelessness		= mod:NewSpecialWarningMoveTo(297574, nil, nil, nil, 1, 2)
local specWarnDefiledGround		= mod:NewSpecialWarningDodge(306726, nil, nil, nil, 2, 2)--Can this be dodged?

--Thrall
local timerSurgingDarknessCD	= mod:NewAITimer(21, 297822, nil, nil, nil, 3)
local timerSeismicSlamCD		= mod:NewAITimer(21, 297746, nil, nil, nil, 3)
--Extra Abilities (used by Thrall and the area LTs)
local timerCriesoftheVoidCD		= mod:NewAITimer(21, 304976, nil, nil, nil, 3, nil, DBM_CORE_DAMAGE_ICON)
local timerDefiledGroundCD		= mod:NewAITimer(21, 306726, nil, nil, nil, 3)

--local started = false
local playerName = UnitName("player")

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 297822 then
		specWarnSurgingDarkness:Show()
		specWarnSurgingDarkness:Play("watchstep")
		timerSurgingDarknessCD:Start()
	elseif spellId == 297746 then
		specWarnSeismicSlam:Show()
		specWarnSeismicSlam:Play("shockwave")
		timerSeismicSlamCD:Start()
	elseif spellId == 304976 then
		warnCriesoftheVoid:Show()
		timerCriesoftheVoidCD:Start()
	elseif spellId == 297574 then
		specWarnHopelessness:Show(DBM_CORE_ORB)
		specWarnHopelessness:Play("orbrun")--Technically not quite accurate but closest match to "find orb"
	elseif spellId == 304251 and self:AntiSpam(3, 1) then--Two boars, 3 second throttle
		warnVoidQuills:Show()
	elseif spellId == 306726 then
		specWarnDefiledGround:Show()
		specWarnDefiledGround:Play("shockwave")
		timerDefiledGroundCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 310173 then
		specWarnHauntingShadows:Show()
		specWarnHauntingShadows:Play("watchstep")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 311390 and args:IsPlayer() then
		local amount = args.amount or 1
		if amount >= 3 then
			specWarnEntomophobia:Show()
			specWarnEntomophobia:Play("keepjump")
		end
	elseif spellId == 306955 and args:IsPlayer() then
		specWarnDarkDelusions:Show()
		specWarnDarkDelusions:Play("justrun")
	elseif spellId == 315385 and args:IsPlayer() then
		specWarnScorchedFeet:Show()
		specWarnScorchedFeet:Play("targetyou")
		if IsInGroup() then--Warn allies if in scenario with others
			yellScorchedFeet:Yell()
		end
	elseif spellId == 316481 and args:IsPlayer() then
		specWarnSplitPersonality:Show()
		specWarnSplitPersonality:Play("targetyou")
	elseif spellId == 311641 and args:IsPlayer() then
		specWarnWaveringWill:Show(playerName)
		specWarnWaveringWill:Play("stopattack")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 312121 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 152698 then--Thrall
		timerSurgingDarknessCD:Stop()
		timerSeismicSlamCD:Stop()
		timerCriesoftheVoidCD:Stop()
		timerDefiledGroundCD:Stop()
		DBM:EndCombat(self)
	elseif cid == 156161 then--Inquisitor Gnshal
		timerCriesoftheVoidCD:Stop()
	--elseif cid == 153244 then--Oblivion Elemental

	--elseif cid == 155098 then--Rexxar

	--elseif cid == 157349 then--Wild Boar

	end
end

--[[
--TODO, backup if scenario behavior doesn't work for combat detection and whisper use it to record stage progress etc and add status whispers
function mod:SCENARIO_UPDATE(newStep)
	local _, currentStage = C_Scenario.GetInfo()
	if diffID > 0 then
		started = true
		if DBM.Options.AutoRespond then--Use global whisper option
			self:RegisterShortTermEvents(
				"CHAT_MSG_WHISPER"
			)
		end
	elseif started then
		started = false
		self:UnregisterShortTermEvents()
	end
end

do
	function mod:CHAT_MSG_WHISPER(msg, name, _, _, _, status)
		if status ~= "GM" then--Filter GMs
			name = Ambiguate(name, "none")
			local message = L.ReplyWhisper:format(playerName)
			if msg == "status" then
				SendChatMessage(message, "WHISPER", nil, name)
			elseif self:AntiSpam(20, name) then--If not "status" then auto respond only once per 20 seconds per person.
				SendChatMessage(message, "WHISPER", nil, name)
			end
		end
	end
end

--]]
