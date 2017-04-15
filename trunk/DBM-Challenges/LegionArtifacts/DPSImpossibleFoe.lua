local mod	= DBM:NewMod("ArtifactImpossibleFoe", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(115638)
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)
mod.soloChallenge = true

mod:RegisterCombat("combat")
mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED 243113",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 243113",
--	"SPELL_AURA_REMOVED_DOSE",
--	"SPELL_CAST_SUCCESS",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1",
--	"ENCOUNTER_START",
	"CHAT_MSG_RAID_BOSS_EMOTE"
--	"SCENARIO_UPDATE"
)
--Notes:
--TODO, all. mapids, mob iDs, win event to stop timers (currently only death event stops them)
--NEW VOICE: attackshield
--Damage

--local warnTormentingEye		= mod:NewSpellAnnounce(234428, 2)

--local specWarnDecay			= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6)
local specWarnImpServants		= mod:NewSpecialWarningSwitch(235140, nil, nil, nil, 1, 2)--Agatha's Vengeance spellId used for now
local specWarnDarkFury			= mod:NewSpecialWarningSwitch(243111, nil, nil, nil, 1, 7)

local timerImpServantsCD		= mod:NewAITimer(15, 235140, nil, nil, nil, 1)
local timerDarkFuryCD			= mod:NewAITimer(15, 243111, nil, nil, nil, 5)

--local countdownTimer			= mod:NewCountdownFades(10, 141582)

local voiceImpServants			= mod:NewVoice(235140)--bigmob
local voiceDarkFury				= mod:NewVoice(243111)--attackshield/shieldover

mod:AddInfoFrameOption(243113, true)

function mod:OnCombatStart(delay)
	timerImpServantsCD:Start(1-delay)--14 in one log
	timerDarkFuryCD:Start(1-delay)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 234423 then

	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 237950 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 243113 then
		specWarnDarkFury:Show()
		voiceDarkFury:Play("attackshield")
		timerDarkFuryCD:Start()
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", args.spellName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 243113 then
		voiceDarkFury:Play("shieldover")
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end
--mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED

function mod:UNIT_DIED(args)
	if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
		DBM:EndCombat(self, true)
	end
	--local cid = self:GetCIDFromGUID(args.destGUID)
--	if cid == 177933 then--Variss

--	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 234428 then--Summon Tormenting Eye

	end
end

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 5 do
		local unitID = "boss"..i
		local unitGUID = UnitGUID(unitID)
		if UnitExists(unitID) and not activeBossGUIDS[unitGUID] then
			local bossName = UnitName(unitID)
			local cid = self:GetUnitCreatureId(unitID)
			--Tank
			if cid == 177933 then--Variss (Tank/Kruul Scenario)
				started = true
				timerTormentingEyeCD:Start(1)--3.8?
				timerHolyWardCD:Start(1)--8?
				timerDrainLifeCD:Start(1)--9?
				timerNetherAbberationCD:Start(1)
			elseif cid == 117230 then--Tugar Bloodtotem (DPS Fel Totem Fall)
				started = true
				timerFelRuptureCD:Start(7.5)
				timerEarthquakeCD:Start(20.5)
				timerFelSurgeCD:Start(62)--Correct place to do it?
			end
		end
	end
end

function mod:ENCOUNTER_START(id)
	if id == 2059 then--Fury of the God Queen
		started = true
	end
end
--]]

--"<53.75 21:03:46> [CHAT_MSG_MONSTER_EMOTE] |TInterface\\Icons\\spell_shaman_earthquake:20|t%s readies itself to charge!#Jormog the Behemoth###Kylistà##0#0##0#12#nil#0#false#false#false#false", -- [133]
function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find(L.impServants) or msg == L.impServants then
		specWarnImpServants:Show()
		voiceImpServants:Play("bigmob")
		timerImpServantsCD:Start()
	end
end
