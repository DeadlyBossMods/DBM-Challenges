local mod	= DBM:NewMod("AlderynandMynir", "DBM-Challenges", 1)
--L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(172408, 172409)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

local berserkTimer								= mod:NewBerserkTimer(480)

function mod:OnCombatStart(delay)
	berserkTimer:Start(100-delay)
end
