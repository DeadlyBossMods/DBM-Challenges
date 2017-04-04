local mod	= DBM:NewMod("LegionMageTower", "DBM-WorldEvents")
--[[local mod	= DBM:NewMod("d640", "DBM-Challenges", nil, nil, function(t)
	if( GetLocale() == "deDE") then
		return select(2, string.match(t, "(%S+): (%S+.%S+.%S+.%S+)")) -- "Feuerprobe: Tempel des Weißen Tigers QUEST nil"
	else
		return select(2, string.match(t, "(%S+.%S+): (%S+.%S+)")) or select(2, string.match(t, "(%S+.%S+):(%S+.%S+)"))
	end
end)
--]]
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetZone()

--mod:RegisterCombat("scenario", 1148)

--[[
mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_SUCCESS",
	"UNIT_DIED",
	"SCENARIO_UPDATE"
)

--Tank
local warnWindGuard			= mod:NewSpellAnnounce(144087, 3)
--Damager
local warnBanshee			= mod:NewSpellAnnounce(142838, 4)
--Healer
local warnStinger			= mod:NewSpellAnnounce(145198, 3)

--Tank
local specWarnPyroBlast		= mod:NewSpecialWarningInterrupt(147601, "HasInterrupt")
--Damager
local specWarnAmberGlob		= mod:NewSpecialWarningSpell(142189)
--Healer
local specWarnStinger		= mod:NewSpecialWarningSpell(145198, false)

--Tank
local timerPowerfulSlamCD	= mod:NewCDTimer(15, 144401, nil, nil, nil, 3)
--Damager
local timerHealIllusionCD	= mod:NewNextTimer(20, 142238, nil, nil, nil, 4)
--Healer
local timerSonicBlastCD		= mod:NewCDTimer(6, 145200, nil, nil, nil, 2)

--local countdownTimer		= mod:NewCountdownFades(10, 141582)

local voiceHealIllusion		= mod:NewVoice(142238)

mod:RemoveOption("HealthFrame")

local started = false

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 147601 then
		warnPyroBlast:Show()
		specWarnPyroBlast:Show(args.sourceName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 144404 then

	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 144084 and self:AntiSpam(2, 4) then
		warnRipperTank:Show()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71076 or cid == 71069 then--Illusionary Mystic
		timerHealIllusionCD:Cancel(args.destGUID)
	end
end

function mod:SCENARIO_UPDATE(newStep)
	local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
	if diffID > 0 then
		started = true
		countdownTimer:Cancel()
		countdownTimer:Start(duration)
		if DBM.Options.AutoRespond then--Use global whisper option
			self:RegisterShortTermEvents(
				"CHAT_MSG_WHISPER"
			)
		end
	elseif started then
		started = false
		countdownTimer:Cancel()
		self:UnregisterShortTermEvents()
	end
end

local mode = {
	[1] = CHALLENGE_MODE_MEDAL1,
	[2] = CHALLENGE_MODE_MEDAL2,
	[3] = CHALLENGE_MODE_MEDAL3,
	[4] = L.Endless,
}
function mod:CHAT_MSG_WHISPER(msg, name, _, _, _, status)
	if status ~= "GM" then--Filter GMs
		name = Ambiguate(name, "none")
		local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
		local message = L.ReplyWhisper:format(UnitName("player"), mode[diffID], currWave)
		if msg == "status" then
			SendChatMessage(message, "WHISPER", nil, name)
		elseif self:AntiSpam(20, name) then--If not "status" then auto respond only once per 20 seconds per person.
			SendChatMessage(message, "WHISPER", nil, name)
		end
	end
end
--]]
