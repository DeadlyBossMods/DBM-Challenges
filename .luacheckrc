std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	"231/_.*", -- unused variables starting with _
	"311", -- Value assigned to a local variable is unused
	"431", -- shadowing upvalue
	"542", -- An empty if branch
}
globals = {
	-- DBM
	"DBM",
	"DBM_CORE_L",
	"DBM_COMMON_L",

	-- Lua
	"table.wipe",

	-- WoW
	"ALTERNATE_POWER_INDEX",
	"CHALLENGE_MODE_MEDAL1",
	"CHALLENGE_MODE_MEDAL2",
	"CHALLENGE_MODE_MEDAL3",
	"RUNES",

	"C_Scenario.GetProvingGroundsInfo",
	"Ambiguate",
	"GetLocale",
	"GetNumGroupMembers",
	"GetCVar",
	"InCombatLockdown",
	"PlaySoundFile",
	"SendChatMessage",
	"SetCVar",
	"UnitGUID",
	"UnitPlayerOrPetInParty",
	"UnitPlayerOrPetInRaid",
	"UnitName",
}
