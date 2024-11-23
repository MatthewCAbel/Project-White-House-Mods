local original_init_winchester = WeaponFactoryTweakData._init_winchester1874
function WeaponFactoryTweakData:_init_winchester1874()
	original_init_winchester(self)
	self.parts.wpn_fps_upg_winchester_o_classic.stance_mod.wpn_fps_snp_winchester = {
	translation = Vector3(-0.004, -28, -1.343)
	}
end