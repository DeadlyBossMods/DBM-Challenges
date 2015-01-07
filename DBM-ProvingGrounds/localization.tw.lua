if GetLocale() ~= "zhTW" then return end
local L

------------------------
-- White TIger Temple --
------------------------
L= DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless				= "無盡",--Could not find a global for this one.
	ReplyWhisper		= "<Deadly Boss Mods> %s正在試煉場試煉中(模式:%s 波數:%d)"
})