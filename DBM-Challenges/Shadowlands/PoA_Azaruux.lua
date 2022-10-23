local mod	= DBM:NewMod("Azaruux", "DBM-Challenges", 1)
--L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(172333)--Guessed
mod.soloChallenge = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 335497 335748",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
	"UNIT_SPELLCAST_SUCCEEDED",
	"CRITERIA_COMPLETE",
	"TALKINGHEAD_REQUESTED"
)

local specWarnPowerSwing			= mod:NewSpecialWarningSpell(335497, nil, nil, nil, 1, 2)
local specWarnMassiveCharge			= mod:NewSpecialWarningDodge(335748, nil, nil, nil, 1, 2)

local timerPowerSwingCD				= mod:NewCDTimer(13.3, 335497, nil, nil, nil, 3)--13.3-15.7
local timerMassiveChargeCD			= mod:NewCDTimer(30, 335748, nil, nil, nil, 3)

--local berserkTimer								= mod:NewBerserkTimer(480)

--function mod:OnCombatStart(delay)
--	timerPowerSwingCD:Start(15.6-delay)
--	timerMassiveChargeCD:Start(33-delay)
--	berserkTimer:Start(100-delay)
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 335497 then
		specWarnPowerSwing:Show()
		specWarnPowerSwing:Play("carefly")
		timerPowerSwingCD:Start()
	elseif spellId == 335748 then
		specWarnMassiveCharge:Show()
		specWarnMassiveCharge:Play("chargemove")
		timerMassiveChargeCD:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 333198 then--[DNT] Set World State: Win Encounter-
		DBM:EndCombat(self)
	end
end

function mod:CRITERIA_COMPLETE()
	DBM:EndCombat(self)
end

function mod:TALKINGHEAD_REQUESTED()
	DBM:EndCombat(self, true)
end
