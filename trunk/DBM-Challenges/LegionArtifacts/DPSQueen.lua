local mod	= DBM:NewMod("ArtifactQueen", "DBM-Challenges", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)

mod:RegisterEvents(
	"SPELL_CAST_START 238694 237870 237947 237945",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"SPELL_AURA_REMOVED_DOSE",
	"SPELL_CAST_SUCCESS 237849",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3",
--	"INSTANCE_ENCOUNTER_ENGAGE_UNIT"
	"ENCOUNTER_START"
--	"CHAT_MSG_MONSTER_EMOTE"
--	"SCENARIO_UPDATE"
)
--Notes:
--TODO, all. mapids, mob iDs, win event to stop timers (currently only death event stops them)
--Damage

--Sigryn
local warnHurlAxe				= mod:NewSpellAnnounce(237870, 2, nil, false)
local warnAdvance				= mod:NewSpellAnnounce(237849, 2)

--Sigryn
local specWarnThrowSpear		= mod:NewSpecialWarningDodge(238694, nil, nil, nil, 1, 2)
local specWarnBloodFeather		= mod:NewSpecialWarningTarget(237945, nil, nil, nil, 3, 7)
--Jarl Velbrand
local specWarnBerserkersRage	= mod:NewSpecialWarningDodge(237947, nil, nil, nil, 4, 2)

--Sigryn
local timerThrowSpearCD			= mod:NewCDTimer(13.4, 238694, nil, nil, nil, 3)
local timerAdvanceCD			= mod:NewCDTimer(13.4, 237849, nil, nil, nil, 2)
local timerBloodFeatherCD		= mod:NewCDTimer(13.4, 237945, nil, nil, nil, 2)
--Jarl Velbrand
local timerBerserkersRageCD		= mod:NewCDTimer(13.4, 237947, nil, nil, nil, 3)

--local countdownTimer		= mod:NewCountdownFades(10, 141582)

--Sigryn
local voiceThrowSpear			= mod:NewVoice(238694)--watchstep
local voiceBloodFeather			= mod:NewVoice(237945)--crowdcontrol (new)
--Jarl Velbrand
local voiceBerserkersRage		= mod:NewVoice(237947)--justrun

mod:RemoveOption("HealthFrame")

local started = false
local activeBossGUIDS = {}

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 238694 then
		specWarnThrowSpear:Show()
		voiceThrowSpear:Play("watchstep")
		timerThrowSpearCD:Start()
	elseif spellId == 237870 then
		warnHurlAxe:Show()
	elseif spellId == 237947 then
		specWarnBerserkersRage:Show()
		voiceBerserkersRage:Play("justrun")
	elseif spellId == 237945 then
		specWarnBloodFeather:Show(args.destName)
		voiceBloodFeather:Play("crowdcontrol")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 237849 then
		warnAdvance:Show()
		--timerAdvanceCD:Start()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 237945 then--Blood of the Father
		timerThrowSpearCD:Stop()
		timerAdvanceCD:Stop()
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 237945 then--Blood of the Father

	end
end
--mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 144084 and self:AntiSpam(2, 4) then

	end
end
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
		started = false
		table.wipe(activeBossGUIDS)
	end
	local cid = self:GetCIDFromGUID(args.destGUID)
--	if cid == 177933 then--Variss

--	end
end
--]]

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 237914 then--Runic Detonation

	end
end

--[[
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
--]]

function mod:ENCOUNTER_START(id)
	if id == 2059 then--Fury of the God Queen
		started = true
		timerThrowSpearCD:Start(14.4)
		timerAdvanceCD:Start(20.5)
		timerBerserkersRageCD:Start(26)
		timerBloodFeatherCD:Start(61)
	end
end

--[[
--"<53.75 21:03:46> [CHAT_MSG_MONSTER_EMOTE] |TInterface\\Icons\\spell_shaman_earthquake:20|t%s readies itself to charge!#Jormog the Behemoth###Kylistà##0#0##0#12#nil#0#false#false#false#false", -- [133]
function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg:find("Interface\\Icons\\spell_shaman_earthquake") then
		specWarnCharge:Show()
		voiceCharge:Play("charge")
	end
end
--]]
