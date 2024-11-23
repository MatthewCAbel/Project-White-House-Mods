Hooks:PostHook(WeaponFactoryTweakData, "init", "ImprovedBipods", function(self)
	if not self.wpn_fps_lmg_m249.override then
		self.wpn_fps_lmg_m249.override = {}
	end
	if not self.wpn_fps_lmg_mg42.override then
		self.wpn_fps_lmg_mg42.override = {}
	end
	if not self.wpn_fps_lmg_rpk.override then
		self.wpn_fps_lmg_rpk.override = {}
	end
	self.wpn_fps_lmg_m249.override.wpn_fps_upg_bp_lmg_lionbipod = {unit = "units/mods/weapons/wpn_fps_lmg_m249_pts/wpn_fps_lmg_m249_bipod"}
	self.wpn_fps_lmg_mg42.override.wpn_fps_upg_bp_lmg_lionbipod = {unit = "units/mods/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_bipod"}
	self.wpn_fps_lmg_rpk.override.wpn_fps_upg_bp_lmg_lionbipod = {unit = "units/mods/weapons/wpn_fps_lmg_rpk_pts/wpn_fps_lmg_rpk_bipod"}
end)