local origfunc = GroupAITweakData._init_unit_categories
function GroupAITweakData:_init_unit_categories(...)
	origfunc(self, ...)
	self.special_unit_spawn_limits.tank = (self.special_unit_spawn_limits.tank or 0) + 2
end