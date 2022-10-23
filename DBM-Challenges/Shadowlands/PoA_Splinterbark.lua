local mod	= DBM:NewMod("Splinterbark", "DBM-Challenges", 1)
--L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(172682)--Guessed
mod.soloChallenge = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED 337419",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
	"UNIT_SPELLCAST_SUCCEEDED",
--	"CRITERIA_COMPLETE",
	"TALKINGHEAD_REQUESTED"
)

local specWarnRage				= mod:NewSpecialWarningRun(337419, nil, nil, nil, 4, 2)

--local berserkTimer								= mod:NewBerserkTimer(480)

--function mod:OnCombatStart(delay)
--	berserkTimer:Start(100-delay)
--end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 332985 then
		specWarnRage:Show()
		specWarnRage:Play("justrun")
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 333198 then--[DNT] Set World State: Win Encounter-
		DBM:EndCombat(self)
	end
end

do
	local function checkForWipe(self)
		DBM:EndCombat(self, true)
	end

--	function mod:CRITERIA_COMPLETE()
--		self:Unschedule(checkForWipe)
--		DBM:EndCombat(self)
--	end

	function mod:TALKINGHEAD_REQUESTED()
		self:Unschedule(checkForWipe)
		self:Schedule(5, checkForWipe, self)
	end
end
