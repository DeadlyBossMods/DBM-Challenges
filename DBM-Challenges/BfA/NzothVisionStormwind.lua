local mod	= DBM:NewMod("d1993", "DBM-Challenges", 3)--1993 Stormwind 1995 Org
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone()
mod.noStatistics = true

mod:RegisterCombat("scenario", 2213)--2212, 2213 (org, stormwind)

--RegisterEvents
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 308278 309819 309648 298691 308669",
	"SPELL_AURA_APPLIED 311390 306955 315385 316481 311641",
	"SPELL_AURA_APPLIED_DOSE 311390",
	"SPELL_CAST_SUCCESS 305672 310173",
	"SPELL_PERIODIC_DAMAGE 312121",
	"SPELL_PERIODIC_MISSED 312121",
	"UNIT_DIED"
--	"SCENARIO_UPDATE"
)

--TODO, detect engaging of end bosses for start timers
--TODO, notable trash or affix warnings
--TODO, detect hard modes on end boss
--TODO, verify Explosive Ordnance cast ID
--TODO, proper place to stop dark gaze timer
--TODO, verify if scenario is appropriate combat tactic for this mod
--TODO, verify all the Affix warnings using correct spellIds/events
--TODO, maybe add https://ptr.wowhead.com/spell=292021/madness-leaden-foot#see-also-other affix? just depends on warning to stop moving can be counter to a stacked affix
--Extra Abilities (used by Alleria and the area LTs)
local warnTaintedPolymorph		= mod:NewCastAnnounce(309648, 3)
local warnExplosiveOrdnance		= mod:NewSpellAnnounce(305672, 3)

--General (GTFOs and Affixes)
local specWarnGTFO				= mod:NewSpecialWarningGTFO(312121, nil, nil, nil, 1, 8)
local specWarnEntomophobia		= mod:NewSpecialWarningJump(311389, nil, nil, nil, 1, 6)
local specWarnDarkDelusions		= mod:NewSpecialWarningRun(306955, nil, nil, nil, 4, 2)
local specWarnScorchedFeet		= mod:NewSpecialWarningYou(315385, nil, nil, nil, 1, 2)
local yellScorchedFeet			= mod:NewYell(315385)
local specWarnSplitPersonality	= mod:NewSpecialWarningYou(316481, nil, nil, nil, 1, 2)
local specWarnWaveringWill		= mod:NewSpecialWarningReflect(311641, "false", nil, nil, 1, 2)--Off by default, it's only 5%, but that might matter to some classes
local specWarnHauntingShadows	= mod:NewSpecialWarningDodge(310173, nil, nil, nil, 2, 2)
--Alleria Windrunner
local specWarnDarkenedSky		= mod:NewSpecialWarningDodge(308278, nil, nil, nil, 2, 2)
local specWarnVoidEruption		= mod:NewSpecialWarningMoveTo(309819, nil, nil, nil, 3, 2)
--Extra Abilities (used by Alleria and the area LTs)
local specWarnChainsofServitude	= mod:NewSpecialWarningRun(298691, nil, nil, nil, 4, 2)
local specWarnDarkGaze			= mod:NewSpecialWarningLookAway(308669, nil, nil, nil, 2, 2)

--Alleria Windrunner
local timerDarkenedSkyCD		= mod:NewAITimer(21, 308278, nil, nil, nil, 3)
local timerVoidEruptionCD		= mod:NewAITimer(21, 309819, nil, nil, nil, 2)
--Extra Abilities (used by Alleria and the area LTs)
local timerTaintedPolymorphCD	= mod:NewAITimer(21, 309648, nil, nil, nil, 3, nil, DBM_CORE_MAGIC_ICON)
local timerExplosiveOrdnanceCD	= mod:NewAITimer(21, 305672, nil, nil, nil, 3)
local timerChainsofServitudeCD	= mod:NewAITimer(21, 298691, nil, nil, nil, 2)
local timerDarkGazeCD			= mod:NewAITimer(21, 308669, nil, nil, nil, 3)

--local started = false
local playerName = UnitName("player")

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 308278 then
		specWarnDarkenedSky:Show()
		specWarnDarkenedSky:Play("watchstep")
		timerDarkenedSkyCD:Start()
	elseif spellId == 309819 then
		specWarnVoidEruption:Show(DBM_CORE_BREAK_LOS)
		specWarnVoidEruption:Play("findshelter")
		timerVoidEruptionCD:Start()
	elseif spellId == 309648 then
		warnTaintedPolymorph:Show()
		timerTaintedPolymorphCD:Start()
	elseif spellId == 298691 then
		specWarnChainsofServitude:Show()
		specWarnChainsofServitude:Play("justrun")
		timerChainsofServitudeCD:Start()
	elseif spellId == 308669 then
		specWarnDarkGaze:Show(args.sourceName)
		specWarnDarkGaze:Play("turnaway")
		timerDarkGazeCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 305672 then
		warnExplosiveOrdnance:Show()
		timerExplosiveOrdnanceCD:Start()
	elseif spellId == 310173 then
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

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 312121 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 155928 then--Alleria Windrunner
		timerDarkenedSkyCD:Stop()
		timerVoidEruptionCD:Stop()
		timerTaintedPolymorphCD:Stop()
		timerExplosiveOrdnanceCD:Stop()
		timerChainsofServitudeCD:Stop()
		timerDarkGazeCD:Stop()--Stopped when she dies or eye?
		DBM:EndCombat(self)
	elseif cid == 158315 then--Eye of Chaos
		timerDarkGazeCD:Stop()--Stopped when she dies or eye?
	elseif cid == 156577 then--Therum Deepforge
		timerExplosiveOrdnanceCD:Stop()
	elseif cid == 153541 then--slavemaster-ulrok
		timerChainsofServitudeCD:Stop()
	elseif cid == 158157 then--Overlord Mathias Shaw
		timerDarkGazeCD:Stop()--Stopped when he dies or eye?
	elseif cid == 158035 then--Magister Umbric
		timerTaintedPolymorphCD:Stop()
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
	local playerName = UnitName("player")
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
