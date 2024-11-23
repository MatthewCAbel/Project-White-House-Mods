
local tweak = tweak_data.player
for name, stance in pairs(tweak.stances) do
	PVM:AddDefaultStance(name, stance)
end
PVM:SaveTweak(tweak)