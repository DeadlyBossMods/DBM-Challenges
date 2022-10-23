local mod	= DBM:NewMod("Athanos", "DBM-Challenges", 1)
--L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(171873)--Guessed
mod.soloChallenge = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
	"UNIT_SPELLCAST_SUCCEEDED",
	"TALKINGHEAD_REQUESTED"
)

--local berserkTimer								= mod:NewBerserkTimer(480)

--function mod:OnCombatStart(delay)
--	berserkTimer:Start(100-delay)
--end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 333198 then--[DNT] Set World State: Win Encounter-
		DBM:EndCombat(self)
	end
end

function mod:TALKINGHEAD_REQUESTED()
	DBM:EndCombat(self, true)
end
