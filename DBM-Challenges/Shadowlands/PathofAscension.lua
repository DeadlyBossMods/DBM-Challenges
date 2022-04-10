local mod1	= DBM:NewMod("Echthra", "DBM-Challenges", 1)
local L		= mod1:GetLocalizedStrings()

mod1:SetRevision("@file-date-integer@")
mod1:SetCreatureID(172177)

mod1:RegisterCombat("combat")

mod1:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

local berserkTimer								= mod1:NewBerserkTimer(480)

function mod1:OnCombatStart(delay)
	berserkTimer:Start(100-delay)
end

------------------------------------------------------------------------------------------
local mod2	= DBM:NewMod("AlderynandMynir", "DBM-Challenges", 1)
local L		= mod2:GetLocalizedStrings()

mod2:SetRevision("@file-date-integer@")
mod2:SetCreatureID(172408, 172409)

mod2:RegisterCombat("combat")

mod2:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

local berserkTimer								= mod2:NewBerserkTimer(480)

function mod2:OnCombatStart(delay)
	berserkTimer:Start(100-delay)
end

------------------------------------------------------------------------------------------
local mod3	= DBM:NewMod("Nuuminuuru", "DBM-Challenges", 1)
local L		= mod3:GetLocalizedStrings()

mod3:SetRevision("@file-date-integer@")
mod3:SetCreatureID(172410)

mod3:RegisterCombat("combat")

mod3:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

local berserkTimer								= mod3:NewBerserkTimer(480)

function mod3:OnCombatStart(delay)
	berserkTimer:Start(100-delay)
end

------------------------------------------------------------------------------------------
local mod4	= DBM:NewMod("CravenCorinth", "DBM-Challenges", 1)
local L		= mod4:GetLocalizedStrings()

mod4:SetRevision("@file-date-integer@")
mod4:SetCreatureID(172412)

mod4:RegisterCombat("combat")

mod4:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED"
)

local berserkTimer								= mod4:NewBerserkTimer(480)

function mod4:OnCombatStart(delay)
	berserkTimer:Start(80-delay)
end

