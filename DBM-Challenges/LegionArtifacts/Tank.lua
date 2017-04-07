local mod	= DBM:NewMod("Kruul", "DBM-WorldEvents", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetZone()--Healer (1710), Tank (1698), DPS (1703-The God-Queen's Fury), DPS (Fel Totem Fall)

mod:RegisterEvents(
	"SPELL_CAST_START 234423 233473",
	"SPELL_AURA_APPLIED 234422",
	"SPELL_AURA_APPLIED_DOSE 234422",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5",--need all 5?
	"INSTANCE_ENCOUNTER_ENGAGE_UNIT"
--	"SCENARIO_UPDATE"
)
--Notes:
--TODO, all. mapids, mob iDs, win event to stop timers (currently only death event stops them)
--Tank
-- Stack warning? what amounts switch from reg warning to special warning?
-- Variss 177933 does things, Only have very little of it. Need more CDs, more warnings
-- Boss after does things, have no logs of that

--Tank (Kruul)
local warnHolyWard			= mod:NewCastAnnounce(233473, 1)
local warnDecay				= mod:NewStackAnnounce(234422, 3)
----Add Spawns
local warnTormentingEye		= mod:NewSpellAnnounce(234428, 2)
local warnNetherAberration	= mod:NewSpellAnnounce(235110, 2)
local warnInfernal			= mod:NewSpellAnnounce(235112, 2)

--Tank
local specWarnDecay			= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6)
local specWarnDrainLife		= mod:NewSpecialWarningInterrupt(234423)

--Tank
local timerDrainLifeCD			= mod:NewAITimer(15, 234423, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerHolyWardCD			= mod:NewAITimer(15, 233473, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerHolyWard				= mod:NewCastTimer(8, 233473, nil, false, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerTormentingEyeCD		= mod:NewAITimer(15, 234428, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerNetherAbberationCD	= mod:NewAITimer(15, 235110, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerInfernalCD			= mod:NewAITimer(15, 235112, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

--local countdownTimer		= mod:NewCountdownFades(10, 141582)

--Tank
local voiceDecay			= mod:NewVoice(234422)--stackhigh
local voiceDrainLife		= mod:NewVoice(234423)--kickcast

mod:RemoveOption("HealthFrame")

local started = false
local activeBossGUIDS = {}

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 234423 then
		specWarnDrainLife:Show(args.sourceName)
		voiceDrainLife:Play("kickcast")
		timerDrainLifeCD:Start()
	elseif spellId == 233473 then
		warnHolyWard:Show()
		timerHolyWard:Start()
		timerHolyWardCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 234422 then
		local amount = args.amount or 1
		if amount >= 5 then
			specWarnDecay:Show(args.destName)
			voiceDecay:Play("stackhigh")
		else
			warnDecay:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
		started = false
		table.wipe(activeBossGUIDS)
		timerDrainLifeCD:Stop()
		timerTormentingEyeCD:Stop()
		timerHolyWardCD:Stop()
		timerNetherAbberationCD:Stop()
	end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 177933 then--Variss
		timerDrainLifeCD:Stop()
		timerTormentingEyeCD:Stop()
		timerNetherAbberationCD:Stop()
		--Does holy ward reset here? reset timer here if it does
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 234428 then--Summon Tormenting Eye
		warnTormentingEye:Show()
		timerTormentingEyeCD:Start()--15?
	elseif spellId == 235110 then--Nether Aberration
		warnNetherAberration:Show()
		timerNetherAbberationCD:Start()
	elseif spellId == 235112 then--Smoldering Infernal Summon
		warnInfernal:Show()
		timerInfernalCD:Start()
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
			end
		end
	end
end

--[[
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
