if GetBuildInfo() ~= "5.4.0" then return end
local mod	= DBM:NewMod("d640", "DBM-ProvingGrounds-MoP")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetZone()

--mod:RegisterCombat("scenario", 1148)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_SUCCESS",
	"UNIT_DIED",
	"SCENARIO_UPDATE"
)

--Tank
----Adds spawning
local warnRipperTank		= mod:NewSpellAnnounce(144084, 2, nil, false)--145408 is healer version of mob
local warnFlamecallerTank	= mod:NewSpellAnnounce(144091, 2)--145401 is healer version of mob
local warnWindGuard			= mod:NewSpellAnnounce(144087, 3)
local warnAmbusher			= mod:NewSpellAnnounce(144086, 4)
local warnConquerorTank		= mod:NewSpellAnnounce(144088, 3)--145409 is healer version of mob
----Adds spawning
local warnPyroBlast			= mod:NewCastAnnounce(147601, 3)
local warnInvokeLava		= mod:NewSpellAnnounce(144374, 3)
local warnWindBlast			= mod:NewSpellAnnounce(144106, 4)--Threat wipe & knockback, must taunt, very important
local warnEnrage			= mod:NewTargetAnnounce(144404, 3)
local warnPowerfulSlam		= mod:NewSpellAnnounce(144401, 4)
--Damager
local warnBanshee			= mod:NewSpellAnnounce(142838, 4)
local warnAmberGlobule		= mod:NewSpellAnnounce(142189, 4)
local warnHealIllusion		= mod:NewCastAnnounce(142238, 4)
--Healer
local warnAquaBomb			= mod:NewTargetAnnounce(145206, 3)
local warnBurrow			= mod:NewTargetAnnounce(145260, 2)

--Tank
local specWarnPyroBlast		= mod:NewSpecialWarningInterrupt(147601, false)
local specWarnInvokeLava	= mod:NewSpecialWarningSpell(144374, nil, nil, nil, 2)
local specWarnInvokeLavaSIS	= mod:NewSpecialWarningMove(144383)
local specWarnWindBlast		= mod:NewSpecialWarningSpell(144106)
local specWarnAmbusher		= mod:NewSpecialWarningSwitch(144086)
local specWarnPowerfulSlam	= mod:NewSpecialWarningMove(144401)
--Damager
local specWarnAmberGlob		= mod:NewSpecialWarningSpell(142189)
local specWarnHealIllusion	= mod:NewSpecialWarningInterrupt(142238)
local specWarnBanshee		= mod:NewSpecialWarningSwitch(142838)
--Healer
local specWarnAquaBomb		= mod:NewSpecialWarningTarget(145206)--It's cast too often to dispel them off, so it's better as a target warning.

--Tank
local timerWindBlastCD		= mod:NewNextTimer(21, 144106)
local timerPowerfulSlamCD	= mod:NewCDTimer(15, 144401)--15-17sec variation
--Damager
local timerAmberGlobCD		= mod:NewNextTimer(10.5, 142189)
local timerHealIllusionCD	= mod:NewNextTimer(25, 142238)
--Healer
local timerAquaBombCD		= mod:NewCDTimer(12, 145206, nil, false)--12-22 second variation? off by default do to this

local countdownTimer		= mod:NewCountdownFades(10, 141582)

mod:RemoveOption("HealthFrame")
mod:RemoveOption("SpeedKillTimer")

function mod:SPELL_CAST_START(args)
	if args.spellId == 147601 then
		warnPyroBlast:Show()
		specWarnPyroBlast:Show(args.sourceName)
	elseif args.spellId == 144374 then
		warnInvokeLava:Show()
		specWarnInvokeLava:Show()
	elseif args.spellId == 144106 then
		warnWindBlast:Show()
		specWarnWindBlast:Show()
		timerWindBlastCD:Start(args.sourceGUID)
	elseif args.spellId == 144401 then
		warnPowerfulSlam:Show()
		specWarnPowerfulSlam:Show()
		timerPowerfulSlamCD:Start(args.sourceGUID)
	elseif args.spellId == 142189 then
		warnAmberGlobule:Show()
		specWarnAmberGlob:Show()
		timerAmberGlobCD:Start(args.sourceGUID)
	elseif args.spellId == 142238 then
		warnHealIllusion:Show()
		specWarnHealIllusion:Show(args.sourceName)
		timerHealIllusionCD:Start(args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 144383 and args:IsPlayer() and self:AntiSpam(1.5) then
		specWarnInvokeLavaSIS:Show()
	elseif args.spellId == 144404 then
		warnEnrage:Show(args.destName)
	elseif args.spellId == 145206 then
		warnAquaBomb:Show(args.destName)
		specWarnAquaBomb:Show(args.destName)
		timerAquaBombCD:Start(args.sourceGUID)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
--new Damager adds (at this time not worth adding that i can see. They don't spawn mid round like tank ones, they all spawn at wave start)
"<41.9 18:54:22> [CLEU] SPELL_CAST_SUCCESS#false#0xF131159C00001436#Large Illusionary Amber-Weaver#2632#0##nil#-2147483648#-2147483648#142835#Illusionary Amber-Weaver#1", -- [273]
"<41.9 18:54:22> [CLEU] SPELL_CAST_SUCCESS#false#0xF13116F600001437#Large Illusionary Banana-Tosser#2632#0##nil#-2147483648#-2147483648#142839#Illusionary Banana-Tosser#1", -- [274]
"<76.9 18:54:57> [CLEU] SPELL_CAST_SUCCESS#false#0xF13115A400001499#Small Illusionary Mystic#2632#0##nil#-2147483648#-2147483648#142833#Illusionary Mystic#1", -- [569]
--New Healer Adds
"<48.7 18:00:50> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311A90000005B9#Small Illusionary Ripper#2632#0##nil#-2147483648#-2147483648#145408#Illusionary Ripper#1", -- [1183]
"<3.6 18:00:05> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311A960000057D#Small Illusionary Hive-Singer#2632#0##nil#-2147483648#-2147483648#145198#Illusionary Hive-Singer#1", -- [96]
"<3.6 18:00:05> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311A980000057E#Small Illusionary Aqualyte#2632#0##nil#-2147483648#-2147483648#145204#Illusionary Aqualyte#1", -- [97]
"<48.7 18:00:50> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311AC2000005B8#Unknown#2632#0##nil#-2147483648#-2147483648#145258#Illusionary Tunneler#1", -- [1182]
"<208.5 18:03:30> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311A9400000647#Unknown#2632#0##nil#-2147483648#-2147483648#145409#Illusionary Conqueror#1", -- [5867]
"<328.4 18:05:29> [CLEU] SPELL_CAST_SUCCESS#false#0xF1311A93000006C8#Large Illusionary Flamecaller#2632#0##nil#-2147483648#-2147483648#145401#Illusionary Flamecaller#1", -- [9132]
--]]
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 144084 then
		warnRipperTank:Show()
	elseif args.spellId == 144091 then
		warnFlamecallerTank:Show()
	elseif args.spellId == 144088 then
		warnConquerorTank:Show()
	elseif args.spellId == 144086 then
		warnAmbusher:Show()
		specWarnAmbusher:Show()
	elseif args.spellId == 144087 then
		warnWindGuard:Show()
	elseif args.spellId == 145260 then
		warnBurrow:Show(args.destName)
	elseif args.spellId == 142838 then
		warnBanshee:Show()
		specWarnBanshee:Show()
	end
end

--local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 71076 or cid == 71069 then--Illusionary Mystic
		timerHealIllusionCD:Cancel(args.destGUID)
	elseif cid == 71077 or cid == 71068 then--Illusionary Amber-Weave
		timerAmberGlobCD:Cancel(args.destGUID)
	elseif cid == 71834 or cid == 71833 then--Illusionary Wind-Guard
		timerWindBlastCD:Cancel(args.destGUID)
	elseif cid == 71842 or cid == 71841 then--Illusionary Conqueror (Tank)
		timerPowerfulSlamCD:Cancel(args.destGUID)
	elseif cid == 72344 then--Illusionary Aqualyte (Missing ID for large)
		timerAquaBombCD:Cancel(args.destGUID)
	end
end

function mod:SCENARIO_UPDATE(newStep)
	local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
	if diffID > 0 then
		countdownTimer:Cancel()
		countdownTimer:Start(duration)
	else
		countdownTimer:Cancel()
	end
end
