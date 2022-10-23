local mod	= DBM:NewMod("Kalisthene", "DBM-Challenges", 1)
--L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(170654)--Guessed
mod.soloChallenge = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 332985 333244",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
	"UNIT_SPELLCAST_SUCCEEDED",
	"TALKINGHEAD_REQUESTED"
)
local warnTetheringSpear					= mod:NewSpellAnnounce(332985, 4)

local specWarnAscendantBarrage				= mod:NewSpecialWarningDodge(333244, nil, nil, nil, 2, 2)

local timerAscendantBarrageCD				= mod:NewAITimer(23.1, 333244, nil, nil, nil, 3)
--local berserkTimer								= mod:NewBerserkTimer(480)

function mod:OnCombatStart(delay)
	timerAscendantBarrageCD:Start(1-delay)
--	berserkTimer:Start(100-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 332985 then
		warnTetheringSpear:Show()
	elseif spellId == 333244 then
		specWarnAscendantBarrage:Show()
		specWarnAscendantBarrage:Play("watchstep")
		timerAscendantBarrageCD:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 333198 then--[DNT] Set World State: Win Encounter-
		DBM:EndCombat(self)
	end
end

function mod:TALKINGHEAD_REQUESTED()
	DBM:EndCombat(self, true)
end
