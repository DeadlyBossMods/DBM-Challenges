local mod	= DBM:NewMod("NZothVisions", "DBM-Challenges", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone()
mod.noStatistics = true

--mod:RegisterCombat("scenario", 1148)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_SUCCESS",
	"UNIT_DIED"
--	"SCENARIO_UPDATE"
)

--local warnBurrow			= mod:NewTargetAnnounce(145260, 2)

--local specWarnInvokeLava	= mod:NewSpecialWarningSpell(144374, nil, nil, nil, 2)

--local timerWindBlastCD	= mod:NewAITimer(21, 144106, nil, nil, nil, 5)

--local started = false

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 147601 then

	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 144383 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 144084 then

	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71076 then

	end
end

--[[
--TODO, probably use it to record stage progress etc and improve status whispers
function mod:SCENARIO_UPDATE(newStep)
	local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
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
--]]

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
